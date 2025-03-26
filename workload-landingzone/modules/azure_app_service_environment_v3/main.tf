resource "azurerm_app_service_environment_v3" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  subnet_id                    = var.subnet_id
  internal_load_balancing_mode = var.internal_load_balancing_mode

  dynamic "cluster_setting" {
    for_each = var.cluster_settings
    content {
      name  = cluster_setting.value.name
      value = cluster_setting.value.value
    }
  }
  tags = var.tags
}