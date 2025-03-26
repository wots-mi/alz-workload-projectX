variable "bastion_name" {
  description = "The name of the Bastion Host."
  type        = string
}

variable "public_ip_name" {
  description = "The name of the Public IP for the Bastion Host."
  type        = string
}

variable "ip_configuration_name" {
  description = "The name of the IP configuration for the Bastion Host."
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
  type        = string
}

variable "bastion_sku" {
  description = "(Optional) The SKU of the Bastion Host. Accepted values are Developer, Basic, Standard and Premium. Defaults to Basic."
  type        = string
  default     = "Standard"
}

variable "subnet_id" {
  description = "The ID of the subnet where the Bastion Host will be deployed."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}