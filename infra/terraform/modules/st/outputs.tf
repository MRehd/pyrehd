output "st_name" {
  value = azurerm_storage_account.st.name
}

output "st_id" {
  value = azurerm_storage_account.st.id
}

output "st_key" {
  value     = azurerm_storage_account.st.primary_access_key
  sensitive = true
}

output "stc_name" {
  value = azurerm_storage_container.stc.name
}