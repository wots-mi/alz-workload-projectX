locals {
  web_apps_with_ids = [
    for app in var.web_apps : merge(app, {
      service_plan_id = module.azure_app_service_plans.service_plan_ids[app.service_plan_id]
    })
  ]

  function_apps_with_ids = [
    for app in var.function_apps : merge(app, {
      service_plan_id = module.azure_app_service_plans.service_plan_ids[app.service_plan_id]
    })
  ]
  network_security_groups_resolved = [
    for nsg in var.network_security_groups : {
      network_security_group_name = nsg.network_security_group_name
      subnet_id                   = module.azure_virtual_network.subnet_ids[nsg.subnet_id]
      security_rules              = nsg.security_rules
    }
  ]
  resource_providers_to_register = {
    dev_center = {
      resource_provider = "Microsoft.App"
    }
  }
}
