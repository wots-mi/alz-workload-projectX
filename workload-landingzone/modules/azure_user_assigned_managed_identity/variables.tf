variable "resource_group_name" {
  description = "The resource group where the managed identity will be created"
  type        = string
}

variable "location" {
  description = "The Azure region for the managed identity"
  type        = string
}

variable "managed_identity_name" {
  description = "The name of the managed identity to create"
  type        = string
}

variable "tags" {
  description = "Global tags to apply to the identity"
  type        = map(string)
  default     = {}
}