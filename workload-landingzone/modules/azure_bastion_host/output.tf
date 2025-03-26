output "bastion_host_id" {
  description = "The ID of the created Bastion Host."
  value       = azurerm_bastion_host.this.id
}

output "public_ip_id" {
  description = "The ID of the Public IP associated with the Bastion Host."
  value       = azurerm_public_ip.this.id
}

output "bastion_host_ip_configuration" {
  description = "Details of the Bastion Host IP configuration."
  value = {
    name                 = var.ip_configuration_name
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }
}