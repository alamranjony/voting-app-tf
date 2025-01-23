locals {
  app_services = {
    voting-app = { 
        sku_name = "P1v2" 
        os_type  = "Linux" 
     } 
    # api-admin-user = { 
    #     sku_name = "B1" 
    #     os_type  = "Windows" 
    # } 
    # api-mobile = { 
    #     sku_name = "B1" 
    #     os_type  = "Windows" 
    #  } 
    # web-admin = { 
    #     sku_name = "B1" 
    #     os_type  = "Windows" 
    # } 
    # api-public = {
    #     sku_name = "B1"
    #     os_type  = "Windows"
    # }
    # web-public = {
    #     sku_name = "B1"
    #     os_type  = "Windows"
    # }
  }

  app_service_plans = {
    for plan in distinct(
      [
        for service_name, service in local.app_services : {
          sku_name = service.sku_name
          os_type  = service.os_type
        }
    ]) : lower("${plan.sku_name}-${plan.os_type}") => plan
  }
}

resource "azurerm_application_insights" "appi" {
  for_each = local.app_services

  name                = "appi-${each.key}-${local.env}-${local.location}-001"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
}

resource "azurerm_service_plan" "app_service" {
  for_each = local.app_service_plans

  name                = "asp-${each.key}-${local.env}-001"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_name            = each.value.sku_name
  os_type             = each.value.os_type
}

resource "azurerm_linux_web_app" "app" {
  for_each = local.app_services

  name                      = "app-${each.key}-${local.env}-001"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_service_plan.app_service[lower("${each.value.sku_name}-${each.value.os_type}")].location
  service_plan_id           = azurerm_service_plan.app_service[lower("${each.value.sku_name}-${each.value.os_type}")].id
# virtual_network_subnet_id = azurerm_subnet.v4.id
  client_affinity_enabled   = true
  https_only                = true

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.appi[each.key].instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.appi[each.key].connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "XDT_MicrosoftApplicationInsights_Mode"      = "Recommended"
  }

  site_config {
    ftps_state              = "AllAllowed"
    scm_minimum_tls_version = "1.0"
    vnet_route_all_enabled  = true
    application_stack {
      python_version = "3.11"
    }
    # app_command_line = "gunicorn --bind 0.0.0.0:8000 test:app"
  }
}

# locals {
#   app_services = {
#     vote = { 
#       sku_name  = "P1v2"
#       os_type   = "Linux"
#       runtime   = "PYTHON|3.11"
#       command   = "gunicorn --bind 0.0.0.0:8000 test:app"
#     }
#     results = {
#       sku_name  = "P1v2"
#       os_type   = "Linux"
#       runtime   = "NODE|18-lts"
#       command   = "npm start"
#     }
#   }

#   app_service_plans = {
#     for plan in distinct(
#       [
#         for service_name, service in local.app_services : {
#           sku_name = service.sku_name
#           os_type  = service.os_type
#         }
#       ]
#     ) : "${lower(plan.sku_name)}-${lower(plan.os_type)}" => plan
#   }
# }

# # Application Insights
# resource "azurerm_application_insights" "appi" {
#   for_each = local.app_services

#   name                = "appi-${each.key}-${local.env}-${local.location}-001"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   application_type    = "web"
# }

# # Azure App Service Plans
# resource "azurerm_service_plan" "app_service" {
#   for_each = local.app_service_plans

#   name                = "asp-${each.key}-${local.env}-001"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   sku_name            = each.value.sku_name
#   os_type             = each.value.os_type
# }

# # Web Apps Deployment
# resource "azurerm_linux_web_app" "app" {
#   for_each = local.app_services

#   name                      = "app-${local.env}-100"
#   resource_group_name       = azurerm_resource_group.main.name
#   location                  = azurerm_resource_group.main.location
#   service_plan_id           = azurerm_service_plan.app_service["${lower(each.value.sku_name)}-${lower(each.value.os_type)}"].id
#   client_affinity_enabled   = true
#   https_only                = true

#   app_settings = {
#     "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.appi[each.key].instrumentation_key
#     "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.appi[each.key].connection_string
#     "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
#     "XDT_MicrosoftApplicationInsights_Mode"      = "Recommended"
#   }

#   site_config {
#     ftps_state              = "AllAllowed"
#     scm_minimum_tls_version = "1.2"
#     app_command_line        = each.value.command

#     application_stack {
#       python_version = each.value.runtime == "PYTHON|3.11" ? "3.11" : null
#       node_version   = each.value.runtime == "NODE|18-lts" ? "18-lts" : null
#     }
#   }
# }
