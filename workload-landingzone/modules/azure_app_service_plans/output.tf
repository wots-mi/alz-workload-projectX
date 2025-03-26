output "service_plan_ids" {
  description = "A map of App Service Plan IDs, keyed by plan name."
  value       = { for key, plan in azurerm_service_plan.this : key => plan.id }
}

output "service_plan_names" {
  description = "A map of App Service Plan names, keyed by plan name."
  value       = { for key, plan in azurerm_service_plan.this : key => plan.name }
}

output "autoscale_setting_ids" {
  description = "A map of Autoscale Setting IDs, keyed by the App Service Plan name they are associated with."
  value       = { for key, setting in azurerm_monitor_autoscale_setting.this : key => setting.id }
}
