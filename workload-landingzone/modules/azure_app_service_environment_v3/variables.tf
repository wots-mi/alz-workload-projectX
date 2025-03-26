variable "name" {
  description = "(Required) The name of the App Service Environment. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the App Service Environment."
  type        = string
}

variable "subnet_id" {
  description = "(Required) The ID of the Subnet which the App Service Environment should be connected to. Changing this forces a new resource to be created."
  type        = string
}

variable "internal_load_balancing_mode" {
  description = "(Optional) Specifies which endpoints to serve internally in the Virtual Network for the App Service Environment. Possible values are None (for an External VIP Type), and 'Web, Publishing' (for an Internal VIP Type). Defaults to None"
  type        = string
}

variable "cluster_settings" {
  description = "(Optional) A list of cluster settings for the App Service Environment."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the App Service Environment."
  type        = map(string)
  default     = {}
}
