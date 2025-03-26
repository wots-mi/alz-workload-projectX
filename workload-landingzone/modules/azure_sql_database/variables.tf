variable "sql_server_name" {
  description = "The name of the SQL Server"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group in which to create the SQL Server"
  type        = string
}
variable "location" {
  description = "The location/region where the SQL Server should be created"
  type        = string
}
variable "sql_server_version" {
  description = "The version of the SQL Server"
  type        = string
}
variable "sql_server_administrator_login" {
  description = "The administrator login for the SQL Server"
  type        = string
}
variable "sql_server_administrator_login_password" {
  description = "The administrator login password for the SQL Server"
  type        = string
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}
variable "sql_database_name" {
  description = "The name of the SQL Database"
  type        = string
}
variable "collation" {
    description = "The collation of the SQL Database"
    type        = string
    default    = "SQL_Latin1_General_CP1_CI_AS"
}
variable "license_type" {
    description = "The license type of the SQL Database"
    type        = string
    default    = "LicenseIncluded"
}
variable "max_size_gb" {
    description = "The maximum size of the SQL Database in gigabytes"
    type        = number
    default    = 2
}
variable "sku_name" {
    description = "The name of the SKU used by the SQL Database"
    type        = string
    default    = "S0"
}
variable "enclave_type" {
    description = "The enclave type of the SQL Database"
    type        = string
    default    = "VBS"
}

