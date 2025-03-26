
variable "resource_group_name" {
  description = "(Required) Specifies the resource group name"
  type = string
}

variable "location" {
  description = "(Required) Specifies the location of the linux function app"
  type = string
  default = "northeurope"
}

variable "function_storage_account_tier" {
  description = "(Required) Specifies the storage account tier for the function app"
  type = string
  default = "Standard"
}

variable "function_storage_account_replication_type" {
  description = "(Required) Specifies the storage account replication type for the function app"
  type = string
  default = "LRS"
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource"
  type = map(string)
}

variable "vnet_image_pull_enabled" {
  description = "(Optional) Specifies if the image pull is enabled for the function app"
  type = bool
  default = true 
}

variable "function_apps" {
  description = "List of function apps with their configurations, including stack details."
  type = list(object({
    function_app_name             = string
    function_storage_account_name = string
    service_plan_id               = string
    application_stack = optional(object({
      dotnet_version               = string
      use_dotnet_isolated_runtime  = bool
    }))
  }))
}
