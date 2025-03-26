variable "name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group where the Key Vault will be created"
  type        = string
}

variable "location" {
  description = "The Azure region where the Key Vault will be created"
  type        = string
}

variable "tenant_id" {
  description = "The Tenant ID for Key Vault access"
  type        = string
}

variable "sku_name" {
  description = "The SKU of the Key Vault (e.g., 'standard' or 'premium')"
  type        = string
}

variable "enabled_for_deployment" {
  description = "Enable for VM deployment"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Enable for disk encryption"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Enable for ARM template deployments"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization"
  type        = bool
  default     = false
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted Key Vaults"
  type        = number
  default     = 7
}

variable "access_policies" {
  description = "List of access policies"
  type = list(object({
    tenant_id              = string
    object_id              = string
    application_id         = optional(string)
    key_permissions        = list(string)
    secret_permissions     = list(string)
    storage_permissions    = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "network_acls" {
  description = "Network access control settings"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the Key Vault"
  type        = map(string)
  default     = {}
}