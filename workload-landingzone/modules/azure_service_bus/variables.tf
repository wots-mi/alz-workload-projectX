
variable "name" {
  description = "The name of the Service Bus Namespace"
  type        = string
}

variable "location" {
  description = "The Azure region where the Service Bus Namespace is deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "sku" {
  description = "The SKU for the Service Bus Namespace"
  type        = string
  default     = "Premium"
}

variable "capacity" {
  description = "The messaging units for Premium SKU. Must be 1, 2, or 4 if using Premium. Null otherwise."
  type        = number
  default     = null
}

variable "premium_messaging_partitions" {
  description = <<EOT
(Optional) Number of messaging partitions for Premium Service Bus.
Valid only for sku = "Premium". Must be 1, 2, or 4. Default is 0 (Standard/Basic).
EOT
  type    = number
  default = 0

  validation {
    condition = (
      var.sku != "Premium" && var.premium_messaging_partitions == 0
    ) || (
      var.sku == "Premium" && contains([1, 2, 4], var.premium_messaging_partitions)
    )
    error_message = "premium_messaging_partitions must be 1, 2, or 4 for Premium SKU, and 0 for Basic or Standard."
  }
}


variable "identity" {
  description = "Optional Managed Identity configuration"
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null
}

variable "authorization_rules" {
  description = "List of namespace authorization rules"
  type = list(object({
    name   = string
    rights = list(string)
  }))
  default = []
}

variable "queues" {
  description = "List of Service Bus Queues to create"
  type = list(object({
    name                 = string
    partitioning_enabled = optional(bool, false)
    authorization_rules = optional(list(object({
      name   = string
      rights = list(string)
    })), [])
  }))
  default = []
}

variable "topics" {
  description = "List of Service Bus Topics to create"
  type = list(object({
    name                 = string
    partitioning_enabled = optional(bool, false)
    authorization_rules = optional(list(object({
      name   = string
      rights = list(string)
    })), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags to be applied to the Service Bus Namespace"
  type        = map(string)
  default     = {}
}
