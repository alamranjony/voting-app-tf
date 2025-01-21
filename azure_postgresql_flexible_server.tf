# PostgreSQL Database
resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                    = "pg-db-${local.env}-001"
  location                = azurerm_resource_group.main.location
  resource_group_name     = azurerm_resource_group.main.name
  administrator_login     = "pgadmin"
  administrator_password  = "$pringRa!n21!"
  sku_name                = "B_Standard_B1ms"
  storage_mb              = 32768
  backup_retention_days   = 7
  version                 = 12
}

resource "azurerm_postgresql_flexible_server_configuration" "postgresql_config" {
  for_each            = toset(["timezone"])
  name                = each.value
  value               = each.value == "ssl_enforcement" ? "Enabled" : "UTC"
  server_id           = azurerm_postgresql_flexible_server.postgresql.id
}