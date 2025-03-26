output "sql_server_id" {
  description = "The resource ID of the SQL Server"
  value       = azurerm_mssql_server.this.id
}