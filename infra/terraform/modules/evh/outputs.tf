output "evhns_conn_str" {
  value     = azurerm_eventhub_namespace_authorization_rule.evhns_rules.primary_connection_string
  sensitive = true
}

output "evh_name" {
  value = azurerm_eventhub.evh.name
}
