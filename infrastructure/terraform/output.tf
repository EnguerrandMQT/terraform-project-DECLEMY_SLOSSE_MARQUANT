output "database" {
  value = length(module.database) == 0 ? null : {
    description = "Accessible only via the connected virtual network. Warning: Only the deployer's public IP can access the Database (to be able to fill it); others are blocked."
    host        = local.database_connection.host
    port        = local.database_connection.port
    database    = local.database.name
    username    = local.database.username
    password    = local.database.password
    ssl         = "enabled"
  }
  sensitive   = true
  description = "Database connection information"
}

output "app_service" {
  value = length(module.examples_api_service) == 0 ? null : {
    description = "Not accessible from the public internet. Only accessible via the gateway and the virtual newtork."
    url         = module.examples_api_service.url
  }
  description = "URL to access the HTTP API"
}

output "storage" {
  value = {
    description = "Accessible only via the connected virtual network. Warning: Only the deployer's public IP can access the Blob (to be able to fill it); others are blocked."
    url         = module.api_storage
  }
  description = "URL to access the storage account"
}

output "api" {
  description = "Public IP address of the API gateway"
  value       = module.gateway.gateway_dns_name
}
