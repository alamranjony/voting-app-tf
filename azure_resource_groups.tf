resource "azurerm_resource_group" "main" {
  name     = "rg-${local.project}-${local.env}-${local.region}-001"
  location = local.location
}