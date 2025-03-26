variable "location" {
  description = "The location/region where the network security group should be created."
  type = string
}
variable "resource_group_name" {
  description = "The name of the resource group in which the network security group should be created."
  type = string
}
variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type = map(string)
}

variable "network_security_groups" {
  description = "A list of network security groups with associated subnets and rules."
  type = list(object({
    network_security_group_name = string
    subnet_id                   = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = optional(string)
      destination_port_ranges    = optional(list(string))
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}
