resource "azurerm_service_plan" "app_service" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.pricing_plan
}

resource "azurerm_linux_web_app" "app_service" {
  name                  = "${var.app_name}-web"
  location              = var.location
  resource_group_name   = var.resource_group_name
  service_plan_id       = azurerm_service_plan.app_service.id
  app_settings          = var.app_settings
  #https_only            = true
  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      docker_registry_url = var.docker_registry_url
      docker_image_name   = var.docker_image
    }
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 1
        retention_in_mb   = 50
      }
    }
  }
}