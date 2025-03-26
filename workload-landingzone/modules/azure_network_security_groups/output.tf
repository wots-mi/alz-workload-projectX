# output "network_security_group_ids" {
#   description = "The IDs of the network security groups created."
#   value = {
#     for nsg in azurerm_network_security_group.this : nsg.name => nsg.id
#   }
# }
output "network_security_group_ids" {
  description = "The IDs of the network security groups created."
  value = {
    for nsg in azurerm_network_security_group.this : nsg.name => try(nsg.id, null)
  }
}