variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the Service Plan should exist."
  type        = string
}

variable "location" {
  description = "(Required) The Azure Region where the Service Plan should exist"
  type        = string
}

variable "app_service_plans" {
  description = <<EOT
A map of configurations for Azure App Service Plan.
Each configuration can include:
- `name`: (Required) Name which should be used for this Service Plan.
- `os_type`: (Required) The O/S type for the App Services to be hosted in this plan. Possible values include Windows, Linux, and WindowsContainer.
- `sku_name`: (Required) The SKU for the plan. Possible values include B1, B2, B3, D1, F1, I1, I2, I3, I1v2, I2v2, I3v2, I4v2, I5v2, I6v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, EP1, EP2, EP3, FC1, WS1, WS2, WS3, and Y1. Isolated SKUs (I1, I2, I3, I1v2, I2v2, and I3v2) can only be used with App Service Environments. Elastic and Consumption SKUs (Y1, FC1, EP1, EP2, and EP3) are for use with Function Apps.
- `tags`: (Optional) Tags to assign to the App Service Plan.
- `app_service_environment_id`: (Optional) The ID of the App Service Environment to create this Service Plan in. Requires an Isolated SKU. Use one of I1, I2, I3 for azurerm_app_service_environment, or I1v2, I2v2, I3v2, I4v2, I5v2 or I6v2 for azurerm_app_service_environment_v3.
EOT
  type = list(object({
    name                        = string
    os_type                     = string
    sku_name                    = string
    tags                        = optional(map(string), {})
    app_service_environment_id  = optional(string)
  }))
}

variable "autoscale_settings" {
  description = "List of autoscale settings for App Service Plans. Each setting should include the plan name, autoscale name, and profiles."
  type = list(object({
    plan_name = string
    autoscale_name = string
    profiles = list(object({
      name = string
      capacity = object({
        minimum = number
        default = number
        maximum = number
      })
      rules = list(object({
        metric_name        = string
        operator           = string
        threshold          = number
        time_grain         = string
        statistic          = string
        time_window        = string
        time_aggregation   = string
        direction          = string
        type               = string
        value              = number
        cooldown           = string
      }))
    }))
  }))
}