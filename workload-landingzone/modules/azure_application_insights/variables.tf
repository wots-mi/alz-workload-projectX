variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  type        = string
}
variable "location" {
  description = "The location/region where the Log Analytics Workspace should be created"
  type        = string   
}
variable "resource_group_name" {
  description = "The name of the resource group in which the Log Analytics Workspace should be created"
  type        = string
}
variable "sku" {
  description = "The SKU (pricing tier) of the Log Analytics Workspace"
  type        = string
  default = "PerGB2018"
}
variable "retention_in_days" {
  description = "The retention period for the logs in days"
  type        = number
  default = 30
}
variable "application_insights_name" {
  description = "The name of the Application Insights resource"
  type        = string
}
variable "application_type" {
  description = "The type of the Application Insights resource"
  type        = string
  default = "web"
}
variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}