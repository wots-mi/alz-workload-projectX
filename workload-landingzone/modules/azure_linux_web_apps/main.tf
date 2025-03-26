resource "azurerm_linux_web_app" "this" {
  for_each            = { for app in var.web_apps : app.web_app_name => app }
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = each.value.service_plan_id
  tags                = var.tags
  site_config {
    always_on = true
    application_stack {
      dotnet_version  = try(each.value.dotnet_version, null)
      node_version    = try(each.value.node_version, null)
      python_version  = try(each.value.python_version, null)
      php_version     = try(each.value.php_version, null)
    }
  }
  app_settings = merge(
    try(each.value.app_settings, {}),
    var.application_insights_key != null ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = var.application_insights_key
    } : {},
    var.application_insights_connection_string != null ? {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.application_insights_connection_string
    } : {}
  )
}