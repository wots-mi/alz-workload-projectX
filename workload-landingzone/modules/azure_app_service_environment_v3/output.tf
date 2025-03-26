output "app_service_environment_id" {
  value = azurerm_app_service_environment_v3.this.id
}

output "app_service_environment_name" {
  value = azurerm_app_service_environment_v3.this.name
}

output "internal_inbound_ip_addresses" {
  value = azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses
}
