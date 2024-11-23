resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "dms-api"
}

resource "azurerm_application_gateway" "gateway" {
  name                = var.application_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.subnet
  }

  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  backend_address_pool {
    name = "backpool"
    fqdns = [ var.backend_fqdn ]
  }

  backend_http_settings {
    name                  = "listenerback"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "listenerentree"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "reglepasserelle"
    rule_type                  = "Basic"
    http_listener_name         = "listenerentree"
    backend_address_pool_name  = "backpool"
    backend_http_settings_name = "listenerback"
    priority = 1
  }

  enable_http2 = true

  depends_on = [ azurerm_public_ip.public_ip ]
}
