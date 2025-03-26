variable "name" {
  description = "(Required) The name of the virtual network."
  type        = string
}

variable "location" {
  description = "(Required) The location of the virtual network."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group where the virtual network is created."
  type        = string
}

variable "address_space" {
  description = "(Required) The address space for the virtual network."
  type        = list(string)
}

variable "dns_servers" {
  description = "(Optional) A list of DNS servers for the virtual network."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "(Optional) A list of subnets to create in the virtual network."
  type = list(object({
    name             = string
    address_prefixes = list(string)
    security_group   = optional(string)
    delegation       = optional(object({
      name               = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
    service_endpoints = optional(list(string), [])
  }))
}

variable "tags" {
  description = "(Optional) Tags to assign to the virtual network."
  type        = map(string)
  default     = {}
}

