output "principal_id" {
  description = "The Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.this.principal_id
}
output "managed_identity_id" {
  description = "The Managed Identity ID"
  value       = azurerm_user_assigned_identity.this.id
}