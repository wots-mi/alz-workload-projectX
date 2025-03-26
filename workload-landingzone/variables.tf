variable "subscription_id" {
  description = "The Azure subscription ID"
    type        = string
}
variable "github_personal_access_token" {
  type        = string
  description = "The personal access token used for authentication to GitHub."
  sensitive   = true
}
variable "github_organization_name" {
  type        = string
  description = "GitHub Organisation Name"
}
variable "version_control_system_type" {
  type        = string
  description = "The type of version control system"
}

variable "version_control_system_repository" {
  type        = string
  description = "The repository name"
}
variable "location" {
  description = "The Azure region where the resources will be deployed"
  type        = string
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}
variable "name_prefix" {
  description = "(Optional) A prefix for the name of all the resource groups and resources."
  type        = string
  default     = null
}

variable "api_name_prefix" {
  description = "(Optional) A prefix for the name of the API Management service."
  type        = string
  nullable    = true
}
variable "resource_group_workload" {
  description = "The name of the resource group"
  type        = string
}
variable "resource_group_network" {
  description = "The name of the resource group"
  type        = string
}
variable "resource_group_github_runners" {
  description = "The name of the resource group"
  type        = string
}
variable "resource_group_management" {
  description = "The name of the resource group"
  type        = string
}
variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}
variable "vnet_address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
}
variable "vnet_subnets" {
  description = "(Optional) A list of subnets to create in the Azure virtual network."
  type = list(object({
    name             = string
    address_prefixes = list(string)
    security_group   = optional(string)
    delegation       = optional(object({
      name               = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
}

# Network Security Groups
variable "network_security_groups" {
  description = "A list of network security groups with associated subnets and rules."
  type = list(object({
    network_security_group_name = string
    subnet_id                   = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = optional(string)
      destination_port_ranges    = optional(list(string))
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}

# Azure App Service Environment v3
variable "ase_name" {
  description = "(Required) The name of the App Service Environment v3"
  type = string
}
variable "internal_load_balancing_mode" {
  description = "(Optional) Specifies which endpoints to serve internally in the Virtual Network for the App Service Environment. Possible values are None (for an External VIP Type), and 'Web, Publishing' (for an Internal VIP Type). Defaults to None"
  type        = string
}

# Azure API Management
variable "apim_name" {
  description = "(Required) The name of the API Management Service. Changing this forces a new resource to be created."
  type = string
  default = "sunrise1898"
}
variable "apim_sku_name" {
  description = "(Required) sku_name is a string consisting of two parts separated by an underscore(_). The first part is the name, valid values include: Consumption, Developer, Basic, Standard and Premium. The second part is the capacity (e.g. the number of deployed units of the sku), which must be a positive integer (e.g. Developer_1)."
  type = string
}
variable "publisher_name" {
  description = "(Required) The name of publisher/company."
  type = string
}
variable "publisher_email" {
  description = "(Required) The email of publisher/company."
  type = string
}
variable "virtual_network_type" {
  description = "(Optional) The type of virtual network you want to use, valid values include: None, External, Internal. Defaults to None. NOTE: Please ensure that in the subnet, inbound port 3443 is open when virtual_network_type is Internal or External. And please ensure other necessary ports are open according to api management network configuration."
  type = string
  default = "External"
}


# Azure App Service Plans
variable "app_service_plans" {
  description = "List of app service plans"
  type = list(object({
    name                       = string
    os_type                    = string
    sku_name                   = string
    app_service_environment_id = optional(string)
    tags                       = optional(map(string), {})
  }))
}
variable "autoscale_settings" {
  description = "Autoscale settings for app service plans"
  type = list(object({
    plan_name      = string
    autoscale_name = string
    profiles = list(object({
      name = string
      capacity = object({
        minimum = number
        default = number
        maximum = number
      })
      rules = list(object({
        metric_name      = string
        operator         = string
        threshold        = number
        time_grain       = string
        statistic        = string
        time_window      = string
        time_aggregation = string
        direction        = string
        type             = string
        value            = number
        cooldown         = string
      }))
    }))
  }))
}

# Azure Web Apps (Linux)
variable "web_apps" {
  description = "List of web apps"
  type = list(object({
    web_app_name     = string
    service_plan_id  = string
    dotnet_version   = optional(string)
    node_version     = optional(string)
    python_version   = optional(string)
    php_version      = optional(string)
    app_settings     = optional(map(string), {})
  }))
  validation {
    condition = alltrue([
      for app in var.web_apps :
      length(compact([
        lookup(app, "dotnet_version", null),
        lookup(app, "node_version", null),
        lookup(app, "python_version", null),
        lookup(app, "php_version", null)
      ])) == 1
    ])
    error_message = "Each web app must have exactly one runtime: dotnet_version, node_version, python_version, or php_version."
  }
}
variable "application_insights_key" {
  type        = string
  description = "Instrumentation Key for Application Insights"
  default     = null
}

variable "application_insights_connection_string" {
  type        = string
  description = "Connection string for Application Insights"
  default     = null
}


# Azure Function Apps
variable "vnet_image_pull_enabled" {
  description = "Enable VNet image pull for the function apps"
  type        = bool
  default = true
}
variable "function_apps" {
  description = "List of function apps with their storage accounts"
  type = list(object({
    function_app_name             = string
    function_storage_account_name = string
    service_plan_id               = string
    application_stack = optional(object({
      dotnet_version               = string
      use_dotnet_isolated_runtime  = bool
    }))
  }))
}

# Azure Virtual Machine - Management Jumpbox
variable "network_interface_name" {
  description = "(Required) The name of the network interface."
  type        = string
}

variable "vm_public_ip_name" {
  description = "(Required) The name of the public IP."
  type        = string
}

variable "vm_name" {
  description = "(Required) The name of the Windows 10 virtual machine."
  type        = string
}

variable "vm_size" {
  description = "(Required) The size of the virtual machine (e.g., Standard_D2s_v3)."
  type        = string
}

variable "admin_username" {
  description = "(Required) The admin username for the virtual machine."
  type        = string
}

variable "admin_password" {
  description = "(Required) The admin password for the virtual machine."
  type        = string
}

# Variables for Azure Bastion Host
variable "bastion_name" {
  description = "(Required) Specifies the name of the Bastion Host."
  type        = string
}
variable "public_ip_name" {
  description = "(Required) Specifies the name of the Public IP."
  type        = string
}
variable "ip_configuration_name" {
  description = "(Required) Specifies the name of the IP Configuration."
  type        = string
}

# Variables for Azure Service Bus
variable "service_bus_namespace_name" {
  description = "The name of the Service Bus namespace."
  type        = string
}

variable "service_bus_sku" {
  description = "The SKU of the Service Bus namespace."
  type        = string
  default    = "Standard"
}

variable "service_bus_capacity" {
  description = "The messaging units for Premium SKU. Must be 1, 2, or 4 if using Premium. Null otherwise."
  type        = number
  default     = null
}
variable "premium_messaging_partitions" {
  description = <<EOT
(Optional) Number of messaging partitions for Premium Service Bus.
Valid only for sku = "Premium". Must be 1, 2, or 4. Default is 0 (Standard/Basic).
EOT
  type    = number
  default = 0
}


variable "service_bus_authorization_rules" {
  description = "List of namespace authorization rules"
  type = list(object({
    name   = string
    rights = list(string)
  }))
  default = []
}

variable "service_bus_queues" {
  description = "List of Service Bus Queues to create"
  type = list(object({
    name                 = string
    partitioning_enabled = optional(bool, false)
    authorization_rules = optional(list(object({
      name   = string
      rights = list(string)
    })), [])
  }))
  default = []
}

variable "service_bus_topics" {
  description = "List of Service Bus Topics to create"
  type = list(object({
    name                 = string
    partitioning_enabled = optional(bool, false)
    authorization_rules = optional(list(object({
      name   = string
      rights = list(string)
    })), [])
  }))
  default = []
}

variable "service_bus_identity_type" {
  description = "The type of identity to assign to the Service Bus namespace."
  type        = string
  default    = "UserAssigned"
}

# Variables for Azure Managed Identity
variable "managed_identity_name" {
  description = "The name for user assigned managed identity."
  type = string
}


# Variables for Azure Key Vault
variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
}
variable "key_vault_sku_name" {
  description = "The SKU of the Key Vault."
  type        = string
  default    = "standard"
}
variable "key_vault_enabled_for_deployment" {
  description = "Enable for VM deployment."
  type        = bool
  default     = false
}
variable "key_vault_enabled_for_disk_encryption" {
  description = "Enable for disk encryption."
  type        = bool
  default     = false
}
variable "key_vault_enabled_for_rbac_authorization" {
  description = "Enable RBAC authorization."
  type        = bool
  default     = true
}
variable "key_vault_purge_protection_enabled" {
  description = "Enable purge protection."
  type        = bool
  default     = false
}
variable "key_vault_soft_delete_retention_days" {
  description = "The number of days to retain soft-deleted keys."
  type        = number
  default = 7
}
variable "key_vault_access_policies" {
  description = "A list of access policies for the Key Vault."
  type = list(object({
    tenant_id              = string
    object_id              = string
    application_id         = optional(string)
    key_permissions        = list(string)
    secret_permissions     = list(string)
    certificate_permissions = list(string)
    storage_permissions    = list(string)
  }))
  default = []
}
variable "key_vault_network_acls" {
  description = "Network access control settings"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

# Variables for Azure SQL Database
variable "sql_server_name" {
  description = "The name of the SQL Server."
  type        = string
}
variable "sql_server_administrator_login" {
  description = "The administrator login for the SQL Server."
  type        = string
}
variable "sql_server_administrator_login_password" {
  description = "The administrator login password for the SQL Server."
  type        = string
}
variable "sql_server_version" {
  description = "The version of the SQL Server."
  type        = string
  default     = "12.0"
}
variable "sql_database_name" {
  description = "The name of the SQL Database."
  type        = string
}
variable "collation" {
  description = "The collation of the SQL Database."
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}
variable "license_type" {
  description = "The license type for the SQL Database."
  type        = string
  default     = "LicenseIncluded"
}
variable "max_size_gb" {
  description = "The maximum size of the SQL Database in gigabytes."
  type        = number
  default     = 2
}
variable "sku_name" {
  description = "The SKU name for the SQL Database."
  type        = string
  default     = "S0"
}
variable "enclave_type" {
  description = "The enclave type for the SQL Database."
  type        = string
  default     = "VBS"
}

# Variables for Azure Storage Account
variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
  default = null
}
variable "storage_account_tier" {
  description = "The tier of the storage account."
  type        = string
  default     = "Standard"
}
variable "storage_account_replication_type" {
  description = "The replication type of the storage account."
  type        = string
  default     = "LRS"
}

# variables for Azure Application Insights
variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
}
variable "application_insights_name" {
  description = "The name of the Application Insights instance."
  type        = string
}
variable "application_type" {
  description = "The type of the Application Insights instance."
  type        = string
  default     = "web"
}
