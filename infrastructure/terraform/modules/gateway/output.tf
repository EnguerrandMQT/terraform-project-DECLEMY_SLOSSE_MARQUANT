output "application_gateway_id" {
  description = "ID of the application gateway."
  value       = azurerm_application_gateway.gateway.id
}

output "public_ip_address" {
  description = "Public IP address of the application gateway."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "gateway_dns_name" {
  value = azurerm_public_ip.public_ip.fqdn
  description = "FQDN associated to gateway public IP to access API"
}