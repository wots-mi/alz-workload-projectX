resource "azurerm_storage_account" "storageaccount" {
  for_each                 = { for app in var.function_apps : app.function_app_name => app }
  name                     = each.value.function_storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.function_storage_account_tier
  account_replication_type = var.function_storage_account_replication_type
  tags                     = var.tags
}

resource "azurerm_linux_function_app" "functionapp" {
  for_each                 = { for app in var.function_apps : app.function_app_name => app }
  name                     = each.key
  resource_group_name      = var.resource_group_name
  location                 = var.location
  storage_account_name     = azurerm_storage_account.storageaccount[each.key].name
  storage_account_access_key = azurerm_storage_account.storageaccount[each.key].primary_access_key
  service_plan_id = each.value.service_plan_id
  vnet_image_pull_enabled = var.vnet_image_pull_enabled
  site_config {
    dynamic "application_stack" {
      for_each = each.value.application_stack != null ? [each.value.application_stack] : []
      content {
        dotnet_version              = application_stack.value.dotnet_version
        use_dotnet_isolated_runtime = application_stack.value.use_dotnet_isolated_runtime
      }
    }
  }
  tags = var.tags
}