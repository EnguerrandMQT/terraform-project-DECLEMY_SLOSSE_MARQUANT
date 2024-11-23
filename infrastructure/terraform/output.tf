output "database" {
  value = length(module.database) == 0 ? null : {
    host     = local.database_connection.host
    port     = local.database_connection.port
    database = local.database.name
    username = local.database.username
    password = local.database.password
    ssl      = "enabled"
  }
  sensitive   = true
  description = "Database connection information"
}

output "app_service" {
  value = length(module.examples_api_service) == 0 ? null : {
    url = module.examples_api_service.url
  }
  description = "URL to access the HTTP API"
}

output "storage" {
  value = module.api_storage
  description = "URL to access the storage account"
}

output "api" {
  description = "Public IP address of the API gateway"
  value = module.gateway.gateway_dns_name
}

# output "ip" {
#   value = data.http.ip.response_body
# }