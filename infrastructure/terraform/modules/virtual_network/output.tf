output "name" {
  value = azurerm_virtual_network.vnet.name
}

output "id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "IDs des sous-réseaux créés"
  value = {
    for subnet_name, subnet in azurerm_subnet.subnets : subnet_name => subnet.id
  }
}