# VARIABLES ------------------------------------------------------------------------------------------------------------------------------
variable "env" {
  type = string
}
variable "location" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "umid_id" {
  type = string
}
variable "sub_id" {
  type = string
}
variable "sub_private_id" {
  type = string
}
variable "sub_public_id" {
  type = string
}
variable "proj" {
  type = string
}
variable "ip_rules" {
  type = list(string)
}

# RESOURCES ------------------------------------------------------------------------------------------------------------------------------
resource "azurerm_eventhub_namespace" "evhns" {
  name                = "evhns-${var.proj}-${var.env}"
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.umid_id]
  }

  network_rulesets {
    default_action                 = "Deny"
    trusted_service_access_enabled = true
    public_network_access_enabled  = true

    ip_rule = [
      for ip in var.ip_rules : {
        action  = "Allow"
        ip_mask = ip
      }
    ]

    virtual_network_rule {
      subnet_id                                       = var.sub_id
      ignore_missing_virtual_network_service_endpoint = false
    }

    virtual_network_rule {
      subnet_id                                       = var.sub_private_id
      ignore_missing_virtual_network_service_endpoint = false
    }

    virtual_network_rule {
      subnet_id                                       = var.sub_public_id
      ignore_missing_virtual_network_service_endpoint = false
    }
  }

  public_network_access_enabled = true
  local_authentication_enabled  = true
  auto_inflate_enabled          = false
}

resource "azurerm_eventhub_namespace_authorization_rule" "evhns_rules" {
  name                = "default"
  namespace_name      = azurerm_eventhub_namespace.evhns.name
  resource_group_name = var.rg_name

  listen = true
  send   = true
}

resource "azurerm_eventhub" "evh" {
  name                = "evh-btc"
  namespace_name      = azurerm_eventhub_namespace.evhns.name
  resource_group_name = var.rg_name

  partition_count   = 1
  message_retention = 1
  status            = "Active"
}
