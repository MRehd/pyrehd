# VARIABLES ------------------------------------------------------------------------------------------------------------
variable "env" {
  type = string
}
variable "location" {
  type = string
}
variable "umid_principal_id" {
  type = string
}
variable "vnet_id" {
  type = string
}
variable "sub_private_name" {
  type = string
}
variable "sub_private_association_id" {
  type = string
}
variable "sub_public_name" {
  type = string
}
variable "sub_public_association_id" {
  type = string
}
variable "proj" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "st_name" {
  type = string
}
variable "stc_name" {
  type = string
}
variable "umid_id" {
  type = string
}
variable "dependencies" {
  type = list(string)
}
variable "kv_id" {
  type = string
}
variable "kv_uri" {
  type = string
}
variable "git_config" {
  type = object({
    url             = string
    git_provider    = string
    branch          = string
    path            = string
    sparse_checkout = list(string)
  })
}
variable "ip_rules" {
  type = list(string)
}

# RESOURCES ------------------------------------------------------------------------------------------------------------
#resource "azurerm_databricks_access_connector" "aconn" {
#  name                = "aconn-${var.proj}"
#  resource_group_name = var.rg_name
#  location            = var.location
#  identity {
#    type         = "UserAssigned"
#    identity_ids = [var.umid_id]
#  }
#}

resource "azurerm_databricks_workspace" "dbk" {
  name                             = "dbk-${var.proj}-${var.env}"
  location                         = var.location
  resource_group_name              = var.rg_name
  sku                              = "premium"
  #access_connector_id              = azurerm_databricks_access_connector.aconn.id
  #default_storage_firewall_enabled = true

  managed_resource_group_name   = "rg-dbk-${var.env}"
  public_network_access_enabled = true

  custom_parameters {
    storage_account_name                                 = "stdbk${var.env}"
    virtual_network_id                                   = var.vnet_id
    private_subnet_name                                  = var.sub_private_name
    public_subnet_name                                   = var.sub_public_name
    private_subnet_network_security_group_association_id = var.sub_private_association_id
    public_subnet_network_security_group_association_id  = var.sub_public_association_id
  }
}

#resource "databricks_storage_credential" "dbk_st_creds" {
#  name = "creds-dbk"
#  azure_managed_identity {
#    access_connector_id = azurerm_databricks_workspace.dbk.access_connector_id
#    managed_identity_id = var.umid_id
#  }
#}
#
#resource "databricks_grants" "dbk_de_st_creds_grants" {
#  storage_credential = databricks_storage_credential.dbk_st_creds.id
#  grant {
#    principal  = data.databricks_current_user.me.user_name
#    privileges = ["ALL_PRIVILEGES"]
#  }
#}
#
#resource "databricks_external_location" "dbk_st_loc" {
#  name            = "dbk-${var.st_name}-loc"
#  credential_name = databricks_storage_credential.dbk_st_creds.id
#  url             = "abfss://${var.stc_name}@${var.st_name}.dfs.core.windows.net"
#}
#
#resource "databricks_grants" "dbk_de_st_loc_grants" {
#  external_location = databricks_external_location.dbk_st_loc.id
#  grant {
#    principal  = data.databricks_current_user.me.user_name
#    privileges = ["ALL_PRIVILEGES"]
#  }
#}

resource "databricks_workspace_conf" "dfk_conf" {
  custom_config = {
    "enableIpAccessLists" : true
  }
  depends_on = [
    azurerm_databricks_workspace.dbk,
    azurerm_role_assignment.me_dbk_owner,
    azurerm_role_assignment.umid_dbk_owner
  ]
}

resource "databricks_ip_access_list" "dbk_ip_rule" {
  label        = "allow_in"
  list_type    = "ALLOW"
  ip_addresses = var.ip_rules
  depends_on   = [databricks_workspace_conf.dfk_conf]
}

resource "databricks_repo" "proj_repo" {
  url          = var.git_config.url
  path         = var.git_config.path
  git_provider = var.git_config.git_provider
  branch       = var.env
  sparse_checkout {
    patterns = var.git_config.sparse_checkout
  }
  depends_on = [azurerm_databricks_workspace.dbk]
}

resource "azurerm_role_assignment" "umid_dbk_owner" {
  principal_id         = var.umid_principal_id
  role_definition_name = "Owner"
  scope                = azurerm_databricks_workspace.dbk.id
}

resource "azurerm_role_assignment" "me_dbk_owner" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Owner"
  scope                = azurerm_databricks_workspace.dbk.id
}

resource "databricks_cluster" "spk" {
  cluster_name            = "spk-${var.proj}-${var.env}"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = "Standard_DS3_v2" #data.databricks_node_type.smallest.id
  data_security_mode      = "LEGACY_PASSTHROUGH" #USER_ISOLATION #SINGLE_USER #LEGACY_PASSTHROUGH #NO_ISOLATION
  autotermination_minutes = 30
  num_workers             = 1
  #autoscale {
  #  min_workers = 1
  #  max_workers = 3
  #}
  
  spark_env_vars = {
    "ENV" : var.env
    "PROJ" : var.proj
  }

  dynamic "library" {
    for_each = toset(var.dependencies)
    content {
      pypi {
        package = library.value
      }
    }
  }

  library {
    maven {
      coordinates = "com.microsoft.azure:azure-storage:8.4.0"
    }
  }

  depends_on = [azurerm_databricks_workspace.dbk]
}

resource "databricks_secret_scope" "kv_scope" {
  name = "kv-${var.proj}"

  keyvault_metadata {
    resource_id = var.kv_id
    dns_name    = var.kv_uri
  }

  depends_on = [azurerm_key_vault_access_policy.dbk_kv_access]
}

resource "time_rotating" "thirty" {
  rotation_days = 30
}

resource "databricks_token" "pat" {
  provider         = databricks
  comment          = "Terraform (created: ${time_rotating.thirty.rfc3339})"
  lifetime_seconds = 60 * 24 * 60 * 60
  depends_on       = [databricks_cluster.spk]
}

# DATA ------------------------------------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on        = [azurerm_databricks_workspace.dbk]
}

data "databricks_current_user" "me" {
  depends_on = [azurerm_databricks_workspace.dbk]
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.dbk.id
  host                        = azurerm_databricks_workspace.dbk.workspace_url
}

# DATABRICKS APPLICATION SP -----------------------------------------------------------------------------------------
provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azuread_service_principal" "databricks_sp" {
  display_name = "AzureDatabricks"
  depends_on   = [azurerm_databricks_workspace.dbk]
}

# RBAC ---------------------------------------------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "dbk_kv_access" {
  key_vault_id = var.kv_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_service_principal.databricks_sp.object_id

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [azurerm_databricks_workspace.dbk]
}

resource "azurerm_role_assignment" "dbk_st_blob_data_contrib" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.databricks_sp.object_id
}

resource "azurerm_role_assignment" "dbk_st_contrib" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azuread_service_principal.databricks_sp.object_id
}