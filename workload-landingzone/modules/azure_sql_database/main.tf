resource "azurerm_mssql_server" "this" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sql_server_version
  administrator_login          = var.sql_server_administrator_login
  administrator_login_password = var.sql_server_administrator_login_password
  tags                         = var.tags
}

resource "azurerm_mssql_database" "this" {
  name         = var.sql_database_name
  server_id    = azurerm_mssql_server.this.id
  collation    = var.collation
  license_type = var.license_type
  max_size_gb  = var.max_size_gb
  sku_name     = var.sku_name
  enclave_type = var.enclave_type
  tags = var.tags
  
  # prevent the possibility of accidental data loss
  # lifecycle {
  #   prevent_destroy = true
  # }
}