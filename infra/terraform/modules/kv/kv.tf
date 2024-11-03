# VARIABLES ------------------------------------------------------------------------------------------------------------
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
variable "subnet_ids" {
  type = list(string)
}
variable "umid_principal_id" {
  type = string
}
variable "evhns_conn_str" {
  type      = string
  sensitive = true
}
variable "st_name" {
  type = string
}
variable "stc_name" {
  type = string
}
variable "st_key" {
  type      = string
  sensitive = true
}

# RESOURCES ------------------------------------------------------------------------------------------------------------
resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.proj}-${var.env}"
  location            = var.location
  resource_group_name = var.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = false
  public_network_access_enabled   = true
  enable_rbac_authorization       = false

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.subnet_ids
  }
}

resource "azurerm_key_vault_secret" "kvs_evhns_conn_str" {
  name         = "kvs-evhns-conn-str"
  value        = var.evhns_conn_str
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ azurerm_key_vault_access_policy.me_kv_access ]
}

resource "azurerm_key_vault_secret" "kvs_st_name" {
  name         = "kvs-st-name"
  value        = var.st_name
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ azurerm_key_vault_access_policy.me_kv_access ]
}

resource "azurerm_key_vault_secret" "kvs_stc_name" {
  name         = "kvs-stc-name"
  value        = var.stc_name
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ azurerm_key_vault_access_policy.me_kv_access ]
}

resource "azurerm_key_vault_secret" "kvs_st_key" {
  name         = "kvs-st-key"
  value        = var.st_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on = [ azurerm_key_vault_access_policy.me_kv_access ]
}

# RBAC ------------------------------------------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "umid_kv_access" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.umid_principal_id

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set"
  ]

  certificate_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_key_vault_access_policy" "me_kv_access" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

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

# DATA ------------------------------------------------------------------------------------------------------------
data "azurerm_client_config" "current" {}