# Dynamic App Service Plan Creation
resource "azurerm_service_plan" "this" {
  for_each                  = { for plan in var.app_service_plans : plan.name => plan }
  name                      = each.value.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  app_service_environment_id = lookup(each.value, "app_service_environment_id", null)
  os_type                   = each.value.os_type
  sku_name                  = each.value.sku_name
  tags                      = lookup(each.value, "tags", {})
  timeouts {
    create = "180m"
    update = "180m"
    delete = "180m"
    read = "60m"
  }
}

# Dynamic Autoscale Settings Creation
resource "azurerm_monitor_autoscale_setting" "this" {
  for_each = { for setting in var.autoscale_settings : setting.plan_name => setting }

  name                = each.value.autoscale_name
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_service_plan.this[each.value.plan_name].id

  dynamic "profile" {
    for_each = each.value.profiles
    content {
      name = profile.value.name
      capacity {
        default = profile.value.capacity.default
        minimum = profile.value.capacity.minimum
        maximum = profile.value.capacity.maximum
      }

      dynamic "rule" {
        for_each = profile.value.rules
        content {
          metric_trigger {
            metric_name        = rule.value.metric_name
            metric_resource_id = azurerm_service_plan.this[each.key].id
            time_grain         = rule.value.time_grain
            statistic          = rule.value.statistic
            time_window        = rule.value.time_window
            time_aggregation   = rule.value.time_aggregation
            operator           = rule.value.operator
            threshold          = rule.value.threshold
          }
          scale_action {
            direction = rule.value.direction
            type      = rule.value.type
            value     = tostring(rule.value.value)
            cooldown  = rule.value.cooldown
          }
        }
      }
    }
  }
}