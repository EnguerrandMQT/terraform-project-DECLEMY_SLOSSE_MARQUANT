data "azurerm_subscription" "current" {
}

data "azuread_user" "user" {
  user_principal_name = var.email_address
}

data "github_user" "user" {
  username = var.github_handle
}

resource "azurerm_resource_group" "ressourcegroup-dms" {
  name     = var.resource_group_name
  location = var.location
}

locals {
  resource_group = azurerm_resource_group.ressourcegroup-dms.name
  location       = azurerm_resource_group.ressourcegroup-dms.location
  app_name       = "app-service-dms"
}

module "examples_api_service" {
  source = "./modules/app_service"
  #count  = var.enable_api ? 1 : 0

  resource_group_name = local.resource_group
  location            = local.location

  app_name            = local.app_name
  pricing_plan        = "P0v3"
  docker_image        = "fhuitelec/examples-api:2.1.0"
  docker_registry_url = "https://ghcr.io"

  gateway_ip          = module.gateway.public_ip_address
  subnet_id           = module.virtual_network_storage.subnet_id

  app_settings = {
    DATABASE_HOST     = local.database_connection.host
    DATABASE_PORT     = local.database_connection.port
    DATABASE_NAME     = local.database.name
    DATABASE_USER     = local.database.username
    DATABASE_PASSWORD = local.database.password

    STORAGE_ACCOUNT_URL = module.api_storage.url

    NEW_RELIC_LICENSE_KEY = var.new_relic_licence_key
    NEW_RELIC_APP_NAME    = local.app_name
  }
}

module "database" {
  source = "./modules/database"
  #count  = var.enable_database ? 1 : 0

  resource_group_name = local.resource_group
  location            = local.location

  entra_administrator_tenant_id      = data.azurerm_subscription.current.tenant_id
  entra_administrator_object_id      = data.azuread_user.user.object_id
  entra_administrator_principal_type = "User"
  entra_administrator_principal_name = data.azuread_user.user.user_principal_name

  server_name                     = local.database.server_name
  database_administrator_login    = local.database.username
  database_administrator_password = local.database.password
  database_name                   = local.database.name
}

locals {
  database_connection = {
    # host = try(module.database[0].server_address, null)
    host = module.database.server_address
    # port = try(module.database[0].port, null)
    port = module.database.port
  }
}

module "api_storage" {
  source = "./modules/storage"
  #count  = var.enable_storage ? 1 : 0

  resource_group_name  = local.resource_group
  location             = local.location
  storage_account_name = local.storage.name
  container_name       = "api"
  storage_subnet_id    = module.virtual_network_storage.subnet_id

  service_principal_id = module.examples_api_service.principal_id
  user_principal_id    = data.azuread_user.user.object_id
}

locals {
  storage_url = try(module.api_storage[0].url, null)
}

module "gateway" {
  source = "./modules/gateway"

  resource_group_name = local.resource_group
  location            = local.location
  public_ip_name      = "ippublique"
  subnet = module.virtual_network.subnet_id

  application_gateway_name = "gateway-dms"
  sku_name                 = "Standard_v2"
  sku_tier                 = "Standard_v2"
  sku_capacity             = 2
  backend_fqdn             = "${local.app_name}.azurewebsites.net"
}

module "virtual_network" {
  source = "./modules/virtual_network"

  resource_group_name = local.resource_group
  location            = local.location
  vnet_name           = "Vnet"
  vnet_address_space  = ["10.0.0.0/16"]
  subnet_name         = "Subnet"
  subnet_prefix       = ["10.0.1.0/24"]
}

module "virtual_network_storage" {
  source = "./modules/virtual_network_delegation"

  resource_group_name = local.resource_group
  location            = local.location
  vnet_name           = "Vnet_storage"
  vnet_address_space  = ["192.168.0.0/16"]
  subnet_name         = "Subnet_storage"
  subnet_prefix       = ["192.168.1.0/24"]
}