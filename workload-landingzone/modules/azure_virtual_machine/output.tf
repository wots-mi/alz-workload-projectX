output "vm_id" {
  description = "The ID of the virtual machine."
  value       = azurerm_windows_virtual_machine.this.id
}

output "public_ip_address" {
  description = "The public IP address of the virtual machine."
  value       = azurerm_public_ip.this.ip_address
}