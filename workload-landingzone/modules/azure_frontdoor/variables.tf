variable "resource_group_name" {
  description = "The name of the Resource Group where this Front Door Profile should exist."
  type        = string
}

variable "front_door_profile_name" {
  description = "The name of the Front Door Profile."
  type        = string
}

variable "front_door_sku_name" {
  description = "Specifies the SKU for this Front Door Profile."
  type        = string
}

variable "front_door_endpoint_names" {
  description = "List of endpoint names to create for the Front Door profile."
  type        = list(string)
}

variable "front_door_origin_group_names" {
  description = "List of names for Front Door origin groups."
  type        = list(string)
}

variable "route_configs" {
  description = "Configuration for routes for each endpoint."
  type = map(list(object({
    name                  = string
    patterns_to_match     = list(string)
    forwarding_protocol   = string
    https_redirect_enabled = bool
  })))
}

# variable "endpoint_to_origin_group" {
#   description = "Mapping of endpoints to origin groups."
#   type        = map(string)
# }

variable "session_affinity_enabled" {
  description = "Specifies whether session affinity should be enabled on this host."
  type        = bool
  default     = true
}

variable "load_balancing" {
  description = "Load balancing configuration."
  type = object({
    sample_size                 = number
    successful_samples_required = number
  })
  default = {
    sample_size                 = 4
    successful_samples_required = 3
  }
}

variable "health_probe_config" {
  description = "Configuration for health probes."
  type = object({
    path                = optional(string)
    request_type        = optional(string)
    protocol            = optional(string)
    interval_in_seconds = optional(number)
  })
  default = null
}

variable "tags" {
  description = "Tags to assign to resources."
  type        = map(string)
}

variable "endpoint_to_origin_group" {
  description = "Mapping of endpoints to origin groups."
  type        = map(string)
}

variable "origin_configs" {
  description = "Map of origin group names to their respective origins. Each group must have at least one origin."
  type = map(list(object({
    name                          = string
    host_name                     = string
    http_port                     = number
    https_port                    = number
    origin_host_header            = string
    priority                      = number
    weight                        = number
    certificate_name_check_enabled = bool
  })))
}