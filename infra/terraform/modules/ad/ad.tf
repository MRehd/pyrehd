# VARIABLES ---------------------------------------------
variable "env" {
  type = string
}
variable "kv_id" {
  type = string
}

locals {
  data_eng = [
    "Storage Blob Data Contributor"
  ]
}

# RESOURCES ---------------------------------------------
resource "azuread_group" "data_eng" {
  display_name     = "data-eng-${var.env}"
  security_enabled = true
}

resource "azuread_group_member" "me" {
  group_object_id  = azuread_group.data_eng.id
  member_object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "data_eng_role_assignment" {
  for_each             = toset(local.data_eng)
  principal_id         = azuread_group.data_eng.object_id
  role_definition_name = each.value
  scope                = data.azurerm_subscription.primary.id
}

resource "azurerm_key_vault_access_policy" "data_eng_kv_access" {
  key_vault_id = var.kv_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_group.data_eng.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Backup",
    "Restore",
    "Import",
    "Recover",
    "Sign",
    "Verify",
    "Encrypt",
    "Decrypt",
    "UnwrapKey",
    "WrapKey",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Backup",
    "Restore",
    "Recover",
    "Delete",
    "Purge"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Create",
    "Import",
    "Update",
    "ManageContacts",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers",
    "ManageIssuers",
    "Delete"
  ]
}

# DATA ------------------------------------------------
data "azurerm_client_config" "current" {}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

data "azurerm_subscription" "primary" {
}

provider "azurerm" {
  features {}
}
