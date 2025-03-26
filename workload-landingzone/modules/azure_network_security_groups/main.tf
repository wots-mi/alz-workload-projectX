resource "azurerm_network_security_group" "this" {
  for_each           = { for nsg in var.network_security_groups : nsg.network_security_group_name => nsg }
  name               = each.key
  location           = var.location
  resource_group_name = var.resource_group_name
  tags               = var.tags

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges    = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "null_resource" "wait_for_nsg" {
  for_each = azurerm_network_security_group.this

  triggers = {
    nsg_id = azurerm_network_security_group.this[each.key].id
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each               = { for nsg in var.network_security_groups : nsg.network_security_group_name => nsg }
  subnet_id              = each.value.subnet_id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
  depends_on = [null_resource.wait_for_nsg]
}