# VARIABLES ------------------------------------------------------------------------------------------------------------------------------
variable "env" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "location" {
  type = string
}
variable "proj" {
  type = string
}
variable "ip_rules" {
  type = list(string)
}
variable "sub_ids" {
  type = list(string)
}
variable "umid_principal_id" {
  type = string
}

# RESOURCES ------------------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "st" {
  name                     = "st${var.proj}${var.env}"
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  access_tier              = "Hot"
  is_hns_enabled           = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.sub_ids
    bypass                     = ["Logging", "Metrics", "AzureServices"]
  }

  tags = {
    environment = var.env
  }
}

resource "azurerm_storage_container" "stc" {
  name                 = var.proj
  storage_account_name = azurerm_storage_account.st.name
}

# RBAC -----------------------------------------------------------------------------------------------------
resource "azurerm_role_assignment" "st_blob_data_contrib" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.umid_principal_id
}

resource "azurerm_role_assignment" "st_contrib" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = var.umid_principal_id
}

# DATA -----------------------------------------------------------------------------------------------------
data "azurerm_subscription" "current" {}