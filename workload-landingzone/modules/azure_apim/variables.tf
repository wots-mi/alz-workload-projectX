variable "name" {
  description = "(Required) The name of the API Management Service. Changing this forces a new resource to be created."
  type        = string
}
variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the Service Plan should exist."
  type        = string
}
variable "publisher_name" {
  description = "(Required) The name of the publisher of the API Management Service."
  type        = string
}
variable "publisher_email"{
  description = "(Required) The email address of the publisher of the API Management Service."
  type        = string
}
variable "location" {
  description = "(Required) The Azure Region where the Service Plan should exist"
  type        = string
}
variable "sku_name" {
  description = "(Required) sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)."
  type        = string
}
variable "virtual_network_type" {
  description = "(Optional) The type of virtual network you want to use, valid values include: None, External, Internal. Defaults to None."
  type        = string
}
variable "subnet_id" {
  description = "(Optional) The ID of the Subnet where the API Management Service should be deployed."
  type        = string
}
variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}