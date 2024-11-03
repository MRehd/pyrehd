output "umid_id" {
  value     = azurerm_user_assigned_identity.umid.id
  sensitive = true
}

output "umid_principal_id" {
  value     = azurerm_user_assigned_identity.umid.principal_id
  sensitive = true
}