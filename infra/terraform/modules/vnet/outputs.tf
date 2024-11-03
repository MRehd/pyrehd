output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "sub_id" {
  value = azurerm_subnet.sub.id
}

output "sub_name" {
  value = azurerm_subnet.sub.name
}

output "sub_dbk_private_id" {
  value = azurerm_subnet.sub_dbk_private.id
}

output "sub_dbk_private_name" {
  value = azurerm_subnet.sub_dbk_private.name
}

output "sub_dbk_public_id" {
  value = azurerm_subnet.sub_dbk_public.id
}

output "sub_dbk_public_name" {
  value = azurerm_subnet.sub_dbk_public.name
}

output "sub_dbk_private_association_id" {
  value = azurerm_subnet_network_security_group_association.sub_dbk_private_association.id
}

output "sub_dbk_public_association_id" {
  value = azurerm_subnet_network_security_group_association.sub_dbk_public_association.id
}