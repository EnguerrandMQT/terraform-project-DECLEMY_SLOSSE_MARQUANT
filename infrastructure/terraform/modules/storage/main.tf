resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "service_binding" {
  scope                = azurerm_storage_container.container.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.service_principal_id
}

resource "azurerm_role_assignment" "user_binding" {
  scope                = azurerm_storage_container.container.resource_manager_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = var.user_principal_id
}

resource "azurerm_storage_blob" "json_blob" {
  name                   = "quotes.json"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "${path.module}/../../../resources/storage/quotes.json"
}

resource "azurerm_storage_account_network_rules" "network_rules" {
  storage_account_id = azurerm_storage_account.storage.id

  default_action = "Deny"
  bypass = ["AzureServices", "Logging", "Metrics"]

  virtual_network_subnet_ids = [
    var.storage_subnet_id
  ]

  depends_on = [azurerm_storage_container.container] # Applique les règles après avoir créé le conteneur
}