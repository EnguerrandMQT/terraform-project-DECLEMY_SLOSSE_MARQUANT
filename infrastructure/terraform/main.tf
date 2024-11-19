data "azurerm_subscription" "current" {
}

data "azuread_user" "user" {
  user_principal_name = var.email_address
}

data "github_user" "user" {
  username = var.github_handle
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

locals {
  resource_group = azurerm_resource_group.rg.name
  location       = azurerm_resource_group.rg.location
  app_name       = "${var.github_handle}"
}

module "api_service" {
  source = "./modules/app_service"

  resource_group_name = local.resource_group
  location            = local.location

  app_name            = local.app_name
  pricing_plan        = "B1"
  docker_image        = "enguerrandmqt/terraform-project-declemy_slosse_marquant:main"
  docker_registry_url = "https://ghcr.io"

  #app_settings = {
  #  DATABASE_HOST     = local.database_connection.host
  #  DATABASE_PORT     = local.database_connection.port
  #  DATABASE_NAME     = local.database.name
  #  DATABASE_USER     = local.database.username
  #  DATABASE_PASSWORD = local.database.password

    #STORAGE_ACCOUNT_URL = local.storage_url

    #NEW_RELIC_LICENSE_KEY = var.new_relic_licence_key
  #  NEW_RELIC_APP_NAME    = local.app_name
  #}
}