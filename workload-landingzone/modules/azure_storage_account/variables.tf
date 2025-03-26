variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group in which to create the storage account"
  type        = string
}
variable "location" {
  description = "The location/region where the storage account should be created"
  type        = string
}
variable "storage_account_tier" {
  description = "The Tier to use for this storage account"
  type        = string
}
variable "storage_account_replication_type" {
  description = "The Replication type to use for this storage account"
  type        = string
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
}