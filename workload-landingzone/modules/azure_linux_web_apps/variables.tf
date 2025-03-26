variable "resource_group_name" {
  description = "(Required) Specifies the resource group name"
  type = string
}
variable "location" {
  description = "(Required) Specifies the location of the linux function app"
  type = string
  default = "northeurope"
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type = map(string)
  default = {}
}

variable "web_apps" {
  description = "(Required) List of Linux Web Apps to be created."
  type = list(object({
    web_app_name     = string
    service_plan_id  = string
    app_settings     = optional(map(string), {})

    dotnet_version   = optional(string)
    node_version     = optional(string)
    python_version   = optional(string)
    php_version      = optional(string)
  }))
  validation {
    condition = alltrue([
      for app in var.web_apps :
      length(compact([
        lookup(app, "dotnet_version", null),
        lookup(app, "node_version", null),
        lookup(app, "python_version", null),
        lookup(app, "php_version", null)
      ])) == 1
    ])
    error_message = "Each web app must have exactly one runtime: dotnet_version, node_version, python_version, or php_version."
  }
  default = []
}
variable "application_insights_key" {
  description = "(Optional) Instrumentation Key for Application Insights."
  type        = string
  default     = null
}

variable "application_insights_connection_string" {
  description = "(Optional) Connection string for Application Insights."
  type        = string
  default     = null
}
