# VARIABLES ------------------------------------------------------------------------------------------------------------------------
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

# RESOURCES ------------------------------------------------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "umid" {
  location            = var.location
  name                = "id-${var.proj}-${var.env}"
  resource_group_name = var.rg_name
}