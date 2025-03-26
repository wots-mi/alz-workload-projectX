variable "name" {
  description = "Name of the Private Endpoint"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the private endpoint will be created"
  type        = string
}

variable "private_connection_name" {
  description = "Name of the private service connection"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The resource ID of the target service (e.g., SQL Server)"
  type        = string
}

variable "subresource_names" {
  description = "List of subresource names, e.g., [\"sqlServer\"]"
  type        = list(string)
}

variable "dns_zone_group_name" {
  description = "Name of the DNS zone group"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs"
  type        = list(string)
}
