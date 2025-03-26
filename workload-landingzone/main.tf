provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

provider "github" {
  token = var.github_personal_access_token
  owner = var.github_organization_name
}

data "azurerm_client_config" "this" {}
data "azapi_client_config" "current" {}

data "github_organization" "alz" {
  name = var.github_organization_name
}

resource "random_string" "name" {
  length  = 6
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg-workload" {
  name     = var.name_prefix == null ? "${random_string.name.result}${var.resource_group_workload}" : "${var.name_prefix}${var.resource_group_workload}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "rg-network" {
  name     = var.name_prefix == null ? "${random_string.name.result}${var.resource_group_network}" : "${var.name_prefix}${var.resource_group_network}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "rg-github-runners" {
  name     = var.name_prefix == null ? "${random_string.name.result}${var.resource_group_github_runners}" : "${var.name_prefix}${var.resource_group_github_runners}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "management" {
  name     = var.name_prefix == null ? "${random_string.name.result}${var.resource_group_management}" : "${var.name_prefix}${var.resource_group_management}"
  location = var.location
  tags     = var.tags
}

resource "azapi_resource_action" "resource_provider_registration" {
  for_each = local.resource_providers_to_register

  resource_id = "/subscriptions/${data.azurerm_client_config.this.subscription_id}"
  type        = "Microsoft.Resources/subscriptions@2021-04-01"
  action      = "providers/${each.value.resource_provider}/register"
  method      = "POST"
}


module "azure_virtual_network" {
  source              = "./modules/azure_virtual_network"
  
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-network.name
  address_space       = var.vnet_address_space
  subnets             = var.vnet_subnets
  tags                = var.tags
  depends_on          = [ azurerm_resource_group.rg-network ]
}

module "azure_network_security_groups" {
  source                 = "./modules/azure_network_security_groups"
  
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg-network.name
  network_security_groups = local.network_security_groups_resolved
  tags                    = var.tags
  depends_on              = [ azurerm_resource_group.rg-network, module.azure_virtual_network ]
}


module "azure_app_service_environment_v3" {
  source = "./modules/azure_app_service_environment_v3"
  
  name                          = var.ase_name
  resource_group_name           = azurerm_resource_group.rg-network.name
  subnet_id                     = module.azure_virtual_network.subnet_ids["snet-dev-app_service_environment_v3-northeurope-001"]
  internal_load_balancing_mode  = var.internal_load_balancing_mode
  tags                          = var.tags
  depends_on                    = [ azurerm_resource_group.rg-network, module.azure_virtual_network ]
}

module "private_dns_zone_app_service_environment_v3" {
  source = "./modules/azure_private_dns_zone"

  private_dns_zone_name = "${var.ase_name}.appserviceenvironment.net"
  resource_group_name = azurerm_resource_group.rg-network.name
  tags = var.tags
  virtual_network_links = {
    vnet1 = {
      name               = "${var.ase_name}.appserviceenvironment.net"
      virtual_network_id = module.azure_virtual_network.virtual_network_id
    }
  }
  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network ]
}

module "private_dns_zone_records_app_service_environment_v3" {
  source                                = "./modules/azure_private_dns_record"
  
  resource_group_name                   = azurerm_resource_group.rg-network.name
  dns_zone_name                         = module.private_dns_zone_app_service_environment_v3.name
  dns_records = {
    ase = {
      name    = "*"
      ttl     = 300
      records = module.azure_app_service_environment_v3.internal_inbound_ip_addresses
    },
    ase2 = {
      name    = "*.scm"
      ttl     = 300
      records = module.azure_app_service_environment_v3.internal_inbound_ip_addresses
    },
    ase3 = {
      name    = "@"
      ttl     = 300
      records = module.azure_app_service_environment_v3.internal_inbound_ip_addresses
    }
  }
  depends_on = [ module.private_dns_zone_app_service_environment_v3, azurerm_resource_group.rg-network ]
}

module "azure_apim_instance" {
  source = "./modules/azure_apim"
  
  name = var.api_name_prefix == null ? "${random_string.name.result}${var.apim_name}" : "${var.api_name_prefix}${var.apim_name}"
  resource_group_name = azurerm_resource_group.rg-network.name
  sku_name = var.apim_sku_name
  publisher_name = var.publisher_name
  publisher_email = var.publisher_email
  virtual_network_type = var.virtual_network_type
  subnet_id = module.azure_virtual_network.subnet_ids["snet-dev-api_management-northeurope-001"]
  location = var.location
  tags = var.tags

  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network, module.azure_network_security_groups ]
}

module "azure_app_service_plans" {
  source = "./modules/azure_app_service_plans"
  
  resource_group_name = azurerm_resource_group.rg-workload.name
  location = var.location
  app_service_plans = [
    for plan in var.app_service_plans : merge(plan, {
      app_service_environment_id = module.azure_app_service_environment_v3.app_service_environment_id
    })
  ]
  autoscale_settings = var.autoscale_settings
  depends_on = [ azurerm_resource_group.rg-workload, module.azure_app_service_environment_v3 ]
}

module "azure_linux_web_apps" {
  source = "./modules/azure_linux_web_apps"
  
  resource_group_name = azurerm_resource_group.rg-workload.name
  location = var.location
  web_apps = local.web_apps_with_ids
  tags = var.tags
  application_insights_key               = module.azure_application_insights.instrumentation_key
  application_insights_connection_string = module.azure_application_insights.connection_string
  depends_on = [module.azure_app_service_plans,module.azure_application_insights, azurerm_resource_group.rg-workload]
}

module "azure_function_apps" {
  source = "./modules/azure_linux_function_apps"
  resource_group_name      = azurerm_resource_group.rg-workload.name
  location                 = var.location
  vnet_image_pull_enabled = var.vnet_image_pull_enabled
  function_apps = local.function_apps_with_ids
  tags = var.tags
}

module "private_dns_zone_container_registry" {
  source = "./modules/azure_private_dns_zone"

  private_dns_zone_name = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.rg-github-runners.name
  tags = var.tags
  virtual_network_links = {
    vnet1 = {
      name               = "privatelink.azurecr.io"
      virtual_network_id = module.azure_virtual_network.virtual_network_id
    }
  }
  depends_on = [ azurerm_resource_group.rg-github-runners, module.azure_virtual_network ]
}

module "github_runners" {
  source  = "Azure/avm-ptn-cicd-agents-and-runners/azurerm"
  version = "~> 0.2"

  postfix                                              = random_string.name.result
  location                                             = var.location
  version_control_system_type                          = var.version_control_system_type
  version_control_system_personal_access_token         = var.github_personal_access_token
  version_control_system_organization                  = var.github_organization_name
  version_control_system_repository                    = var.version_control_system_repository
  virtual_network_creation_enabled                     = false
  virtual_network_id                                   = module.azure_virtual_network.virtual_network_id
  resource_group_creation_enabled                      = false
  resource_group_name                                  = azurerm_resource_group.rg-github-runners.name
  container_app_subnet_id                              = module.azure_virtual_network.subnet_ids["snet-dev-container-apps-github-runners"]
  container_registry_private_dns_zone_creation_enabled = false
  container_registry_dns_zone_id                       = module.private_dns_zone_container_registry.id
  container_registry_private_endpoint_subnet_id        = module.azure_virtual_network.subnet_ids["snet-dev-private_endpoints-northeurope-001"]
  tags                                                 = var.tags
  depends_on                                           = [module.private_dns_zone_container_registry, module.azure_virtual_network]
}

# Management jumpbox VM - used to access resources deployed in VNET
module "management_vms" {
  source = "./modules/azure_virtual_machine"
  network_interface_name             = var.network_interface_name
  resource_group_name                = azurerm_resource_group.management.name
  location                           = var.location
  subnet_id                          = module.azure_virtual_network.subnet_ids["snet-dev-vmdesktop-northeurope-001"] 
  vm_public_ip_name                  = var.vm_public_ip_name
  vm_name                            = var.vm_name
  vm_size                            = var.vm_size
  admin_username                     = var.admin_username
  admin_password                     = var.admin_password
  tags = var.tags
}

# Azure Bastion Host
module "bastion_host" {
  source                          = "./modules/azure_bastion_host"
  
  bastion_name                    = var.bastion_name
  public_ip_name                  = var.public_ip_name
  ip_configuration_name           = var.ip_configuration_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.management.name
  subnet_id                       = module.azure_virtual_network.subnet_ids["AzureBastionSubnet"]
  tags                            = var.tags
  depends_on                      = [module.azure_virtual_network, azurerm_resource_group.management]
}

#Azure Key Vault
module "azure_key_vault" {
  source                          = "./modules/azure_key_vault"
  
  name                            = var.key_vault_name
  resource_group_name             = azurerm_resource_group.rg-workload.name
  location                        = var.location
  tenant_id                       = data.azapi_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enable_rbac_authorization       = var.key_vault_enabled_for_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  access_policies                 = var.key_vault_access_policies
  network_acls                    = var.key_vault_network_acls
  tags                            = var.tags
}

# Azure User Assigned Managed Identity
module "azure_user_assigned_managed_identity" {
  source                          = "./modules/azure_user_assigned_managed_identity"

  resource_group_name             = azurerm_resource_group.rg-workload.name
  managed_identity_name           = var.managed_identity_name
  location                        = var.location
  tags                            = var.tags
}

# Azure Service Bus
module "service_bus_namespace" {
  source              = "./modules/azure_service_bus"

  name                = var.service_bus_namespace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-workload.name
  sku                 = var.service_bus_sku
  capacity            = var.service_bus_capacity
  premium_messaging_partitions = var.premium_messaging_partitions
  authorization_rules = var.service_bus_authorization_rules
  queues              = var.service_bus_queues
  topics              = var.service_bus_topics
  tags                = var.tags
  identity = {
    type = var.service_bus_identity_type
    identity_ids = [module.azure_user_assigned_managed_identity.managed_identity_id]
  }
  depends_on = [ module.azure_user_assigned_managed_identity ]
}

#Azure SQL Database
module "azure_sql_database" {
  source              = "./modules/azure_sql_database"

  sql_server_name     = var.sql_server_name
  resource_group_name = azurerm_resource_group.rg-workload.name
  location            = var.location
  sql_server_administrator_login = var.sql_server_administrator_login
  sql_server_administrator_login_password = var.sql_server_administrator_login_password
  sql_server_version = var.sql_server_version
  sql_database_name   = var.sql_database_name
  collation           = var.collation
  license_type        = var.license_type
  max_size_gb         = var.max_size_gb
  sku_name            = var.sku_name
  enclave_type        = var.enclave_type
  tags                = var.tags
  depends_on          = [ azurerm_resource_group.rg-workload ]
}

#Azure storage account
module "azure_storage_account" {
  source              = "./modules/azure_storage_account"

  storage_account_name = "st${random_string.name.result}eur"
  resource_group_name  = azurerm_resource_group.rg-workload.name
  location             = var.location
  storage_account_tier = var.storage_account_tier
  storage_account_replication_type = var.storage_account_replication_type
  tags                 = var.tags
  depends_on           = [ azurerm_resource_group.rg-workload ]
}

#Azure Private DNS Zone for SQL Server
module "private_dns_zone_sql_server" {
  source = "./modules/azure_private_dns_zone"

  private_dns_zone_name = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg-network.name
  tags = var.tags
  virtual_network_links = {
    vnet1 = {
      name               = "privatelink.database.windows.net"
      virtual_network_id = module.azure_virtual_network.virtual_network_id
    }
  }
  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network ]
}

# Create private endpoint for SQL server
module "sql_private_endpoint" {
  source = "./modules/azure_private_endpoint"

  name                         = "private-endpoint-sql"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg-network.name
  subnet_id                    = module.azure_virtual_network.subnet_ids["snet-dev-private_endpoints-northeurope-001"]
  private_connection_name      = "private-serviceconnection"
  private_connection_resource_id = module.azure_sql_database.sql_server_id
  subresource_names            = ["sqlServer"]
  dns_zone_group_name          = "dns-zone-group"
  private_dns_zone_ids         = [module.private_dns_zone_sql_server.id]

  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network, module.azure_sql_database, module.private_dns_zone_sql_server ]
}

# Azure Private DNS Zone for Service Bus
module "private_dns_zone_service_bus" {
  source = "./modules/azure_private_dns_zone"

  private_dns_zone_name = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.rg-network.name
  tags = var.tags
  virtual_network_links = {
    vnet1 = {
      name               = "privatelink.servicebus.windows.net"
      virtual_network_id = module.azure_virtual_network.virtual_network_id
    }
  }
  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network ]
}

# Create private endpoint for Azure Service Bus
module "service_bus_private_endpoint" {
  source = "./modules/azure_private_endpoint"

  name                         = "private-endpoint-service-bus"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg-network.name
  subnet_id                    = module.azure_virtual_network.subnet_ids["snet-dev-private_endpoints-northeurope-001"]
  private_connection_name      = "private-serviceconnection"
  private_connection_resource_id = module.service_bus_namespace.servicebus_namespace_id
  subresource_names            = ["namespace"]
  dns_zone_group_name          = "dns-zone-group"
  private_dns_zone_ids         = [module.private_dns_zone_service_bus.id]

  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network, module.service_bus_namespace, module.private_dns_zone_service_bus ]
}

# Azure Private DNS Zone for Azure Storage
module "private_dns_zone_storage" {
  source = "./modules/azure_private_dns_zone"

  private_dns_zone_name = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg-network.name
  tags = var.tags
  virtual_network_links = {
    vnet1 = {
      name               = "privatelink.blob.core.windows.net"
      virtual_network_id = module.azure_virtual_network.virtual_network_id
    }
  }
  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network, module.azure_storage_account ]
}

# Create private endpoint for Azure Storage
module "storage_private_endpoint" {
  source = "./modules/azure_private_endpoint"

  name                         = "private-endpoint-storage"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.rg-network.name
  subnet_id                    = module.azure_virtual_network.subnet_ids["snet-dev-private_endpoints-northeurope-001"]
  private_connection_name      = "private-serviceconnection"
  private_connection_resource_id = module.azure_storage_account.id
  subresource_names            = ["blob"]
  dns_zone_group_name          = "dns-zone-group"
  private_dns_zone_ids         = [module.private_dns_zone_storage.id]

  depends_on = [ azurerm_resource_group.rg-network, module.azure_virtual_network, module.azure_storage_account, module.private_dns_zone_storage ]
}

# Azure Application Insights
module "azure_application_insights" {
  source = "./modules/azure_application_insights"

  log_analytics_workspace_name = var.log_analytics_workspace_name
  location                     = var.location
  resource_group_name          = azurerm_resource_group.management.name
  application_insights_name    = var.application_insights_name
  application_type             = var.application_type
  tags                         = var.tags

  depends_on = [ azurerm_resource_group.management ]
}