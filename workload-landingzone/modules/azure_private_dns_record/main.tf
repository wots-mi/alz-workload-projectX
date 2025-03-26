resource "azurerm_private_dns_a_record" "this" {
  for_each             = var.dns_records
  name                 = each.value.name
  zone_name            = var.dns_zone_name
  resource_group_name  = var.resource_group_name
  ttl                  = each.value.ttl
  records              = each.value.records
}
