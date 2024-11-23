resource "azurerm_postgresql_flexible_server" "playground_computing" {
  administrator_login           = var.database_administrator_login
  administrator_password        = var.database_administrator_password
  auto_grow_enabled             = false
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  location                      = var.location
  name                          = var.server_name
  # delegated_subnet_id           = var.subnet_id     # activer pour l'intégration réseau
  # private_dns_zone_id           = azurerm_private_dns_zone.private_dns_zone.id  # activer pour l'intégration réseau
  public_network_access_enabled = true  # mettre à false pour l'intération réseau
  resource_group_name           = var.resource_group_name
  sku_name                      = "B_Standard_B1ms"
  storage_tier                  = "P4"
  storage_mb                    = "32768"
  version                       = "16"
  zone                          = "1"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = var.entra_administrator_tenant_id
  }
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "administrator" {
  tenant_id           = var.entra_administrator_tenant_id
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_flexible_server.playground_computing.name
  principal_type      = var.entra_administrator_principal_type
  object_id           = var.entra_administrator_object_id
  principal_name      = var.entra_administrator_principal_name
  
  depends_on = [ azurerm_postgresql_flexible_server.playground_computing ]
}

# désactiver pour l'intégration réseau

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_client" {
  name             = "AllowClient"
  server_id        = azurerm_postgresql_flexible_server.playground_computing.id
  start_ip_address = var.ip_exception
  end_ip_address   = var.ip_exception
  
  depends_on = [ azurerm_postgresql_flexible_server.playground_computing ]
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.playground_computing.id
  
  depends_on = [ azurerm_postgresql_flexible_server.playground_computing ]
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "endpoint-db"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "db-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.playground_computing.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  depends_on = [ azurerm_postgresql_flexible_server.playground_computing ]
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = "postgre-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.resource_group_name
  
  depends_on = [ azurerm_private_dns_zone.private_dns_zone ]
}

resource "azurerm_private_dns_a_record" "dns_record" {
  name                = azurerm_postgresql_flexible_server.playground_computing.name
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 10
  records             = [azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address]

  depends_on = [ azurerm_private_dns_zone_virtual_network_link.private_dns_zone_virtual_network_link, azurerm_postgresql_flexible_server.playground_computing ]
}

# resource "null_resource" "populate_db" {
#   provisioner "local-exec" {
#     command = <<EOT
#     az postgres flexible-server execute -n ${azurerm_postgresql_flexible_server.playground_computing.name} -u ${var.database_administrator_login} -p '${var.database_administrator_password}' -d ${azurerm_postgresql_flexible_server_database.database.name} -f ${path.module}/../../../resources/database/script.sql
#     EOT
#   }
#   depends_on = [ azurerm_postgresql_flexible_server.playground_computing ]
# }

# resource "null_resource" "populate_db" {
#   provisioner "local-exec" {
#     command = <<EOT
#     PGPASSWORD="${var.database_administrator_password}" psql \
#       -h ${azurerm_postgresql_flexible_server.playground_computing.fqdn} \
#       -U ${var.database_administrator_login} \
#       -d ${azurerm_postgresql_flexible_server_database.database.name} \
#       -f ${path.module}/../../../resources/database/script.sql
#     EOT
#   }
#   depends_on = [ azurerm_postgresql_flexible_server.playground_computing ]
# }