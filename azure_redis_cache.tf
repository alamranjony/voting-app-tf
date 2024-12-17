resource "azurerm_redis_cache" "main" {
  name                               = "votingapp-001"
  location                           = azurerm_resource_group.main.location
  resource_group_name                = azurerm_resource_group.main.name
  capacity                           = 0
  family                             = "C"
  sku_name                           = "Standard"
  non_ssl_port_enabled               = false
  minimum_tls_version                = "1.2"
  access_keys_authentication_enabled = false
  public_network_access_enabled      = false

  redis_configuration {
    active_directory_authentication_enabled = true
    maxmemory_policy                        = "volatile-lru"
  }
}