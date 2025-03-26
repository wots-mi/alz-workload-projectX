variable "resource_group_name" {
  type = string
}
variable "dns_zone_name" {
  type = string
}
variable "dns_records" {
  type = map(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
}