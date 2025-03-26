output "virtual_network_id" {
  description = "The ID of the virtual network."
  value = azurerm_virtual_network.this.id
}

output "subnet_names" {
  description = "Map of subnet names"
  value = { for subnet in azurerm_virtual_network.this.subnet : subnet.name => subnet.name }
}

output "virtual_network_name" {
  description = "The name of the virtual network."
  value = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "The IDs of the subnets created within the virtual network."
  value = {
    for k, s in azurerm_subnet.this : k => s.id
  }
}

