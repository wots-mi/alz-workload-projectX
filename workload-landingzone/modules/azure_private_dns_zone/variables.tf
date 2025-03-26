variable "private_dns_zone_name" {
  type = string
}
variable "resource_group_name" {
  type = string
}

variable "virtual_network_links" {
  type = map(object({
    name               = string
    virtual_network_id = string
  }))
}
variable "tags" {
  type = map(string)
  default = {}
}