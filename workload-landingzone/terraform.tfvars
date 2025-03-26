location = "northeurope"
tags = {
  environment = "dev"
  owner = "onefps"
}
subscription_id = "dd3318727-2ac4-4db5-8a63-f05891e25212f"
github_personal_access_token = "ghp_nqvICehNOJ6635sgsgJ4mRM4TKjym"
github_organization_name = "wots-mi"
version_control_system_type = "github"
version_control_system_repository = "alz-workload-projectX"

# Variables for Azure Virtual Network
resource_group_network = "rg-developer-vnet"
resource_group_workload = "rg-developer-workload"
resource_group_github_runners = "rg-github-runners"
resource_group_management = "rg-developer-management"
vnet_name = "vnet-dev-northeurope-001"
vnet_address_space = ["11.0.0.0/16"]
vnet_subnets = [
  {
    name           = "snet-dev-app_service_environment_v3-northeurope-001"
    address_prefixes = ["11.0.0.0/20"]
    delegation       = {
      name = "Microsoft.Web.hostingEnvironments"
      service_delegation = {
        name    = "Microsoft.Web/hostingEnvironments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  },
  {
    name           = "snet-dev-api_management-northeurope-001"
    address_prefixes = ["11.0.16.0/20"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
  },
  {
    name           = "snet-dev-vmdesktop-northeurope-001"
    address_prefixes = ["11.0.33.0/24"]
  },
  {
    name          = "snet-dev-private_endpoints-northeurope-001"
    address_prefixes = ["11.0.34.0/24"]
  },
  {
    name = "snet-dev-container-apps-github-runners"
    address_prefixes = ["11.0.35.0/27"]
    delegation = {
      name = "Microsoft.App/environments"
      service_delegation = {
        name    = "Microsoft.App/environments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  },
  {
    name             = "AzureBastionSubnet"
    address_prefixes = ["11.0.36.0/24"]
  }
]

# Variables for Azure Network Security Groups
network_security_groups = [
  {
    network_security_group_name = "nsg-apim"
    subnet_id                  = "snet-dev-api_management-northeurope-001"
    security_rules = [
      {
        name                       = "Allow-Client-Communication"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges     = ["80", "443"]
        source_address_prefix      = "Internet"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "Allow-Management-Endpoint-Portal-PPS"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3443"
        source_address_prefix      = "ApiManagement"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "Allow-Infra-LB"
        priority                   = 102
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6390"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "Allow-TraficManager-Routing"
        priority                   = 103
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "AzureTrafficManager"
        destination_address_prefix = "VirtualNetwork"
      },
      {
        name                       = "Allow-AzureStorage-Access"
        priority                   = 104
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "Storage"
      },
      {
        name                       = "Allow-SQL-Core"
        priority                   = 105
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "SQL"
      },
      {
        name                       = "Allow-KeyVault-Core"
        priority                   = 106
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "AzureKeyVault"
      },
      {
        name                       = "Allow-Monitor-Core"
        priority                   = 107
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["1886", "443"]
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "AzureMonitor"
      }
    ]
  }
]

# Variables for Azure App Service Environment
ase_name = "ase1984"
internal_load_balancing_mode = "Web, Publishing"

# Variables for Azure App Service Plans
app_service_plans = [
    {
        name                       = "sunrise"
        os_type                    = "Linux"
        sku_name                   = "I1v2"
        tags                       = {
            environment = "dev"
            program     = "oneFPS"
        }
    }
]

autoscale_settings = [
  {
    plan_name      = "sunrise"
    autoscale_name = "autoscale-plan-1"
    profiles = [
      {
        name = "default"
        capacity = {
          minimum = 1
          default = 2
          maximum = 3
        }
        rules = [
          {
            metric_name      = "CpuPercentage"
            operator         = "GreaterThan"
            threshold        = 75
            time_grain       = "PT1M"
            statistic        = "Average"
            time_window      = "PT5M"
            time_aggregation = "Average"
            direction        = "Increase"
            type             = "ChangeCount"
            value            = 1
            cooldown         = "PT1M"
          },
          {
            metric_name      = "CpuPercentage"
            operator         = "LessThan"
            threshold        = 20
            time_grain       = "PT1M"
            statistic        = "Average"
            time_window      = "PT5M"
            time_aggregation = "Average"
            direction        = "Decrease"
            type             = "ChangeCount"
            value            = 1
            cooldown         = "PT5M"
          }
        ]
      }
    ]
  }
]

web_apps = [
  {
    web_app_name     = "webmilesqwa12"
    service_plan_id  = "sunrise"
    dotnet_version   = "8.0"
    tags = {
      environment = "dev"
      program     = "oneFPS"
    }
  },
  {
    web_app_name     = "webmilesqwa122"
    service_plan_id  = "sunrise"
    dotnet_version   = "8.0"
    tags = {
      environment = "dev"
      program     = "oneFPS"
    }
  },
  {
    web_app_name     = "webmilesqwa123"
    service_plan_id  = "sunrise"
    dotnet_version   = "8.0"
    tags = {
      environment = "dev"
      program     = "oneFPS"
    }
  },
  {
    web_app_name     = "webmilesqwa124"
    service_plan_id  = "sunrise"
    dotnet_version   = "8.0"
    tags = {
      environment = "dev"
      program     = "oneFPS"
    }
  }
]

function_apps = [
  {
    function_app_name             = "app1qwerty"
    function_storage_account_name = "stormila1024"
    service_plan_id               = "sunrise"
    application_stack = {
      dotnet_version = "8.0"
      use_dotnet_isolated_runtime = false
    }
    tags = {
      environment = "dev"
      program     = "oneFPS"
    }
  },
  {
    function_app_name             = "app2qwerty"
    function_storage_account_name = "stormila015"
    service_plan_id = "sunrise"
    application_stack = {
      dotnet_version = "8.0"
      use_dotnet_isolated_runtime = false
    }
    tags = {
      environment = "dev"
      program     = "oneFPS"
    }
  }
]

# Variables for Azure VM
vm_name = "my-win10-vm"
vm_size = "Standard_D2ads_v6"
admin_username = "milanju"
admin_password = "Tales198321$$$$"
network_interface_name = "my-win10-vm-nic"
vm_public_ip_name = "my-win10-vm-pip"

# Variables for Azure Bastion Host
bastion_name = "mybastion"
public_ip_name = "bastionip"
ip_configuration_name = "bastionipconfig"

# Variables for API Management
api_name_prefix = "proba"
publisher_email = "milan@walkonthetechside.com"
publisher_name = "WOTS"
apim_sku_name = "Developer_1"

# Variables for Azure Key Vault
key_vault_name = "bingo123"

# Variables for User Assigned Managed Identity
managed_identity_name = "pigeon"

# Variables for Azure Service Bus
service_bus_namespace_name = "bingo1984wq"
service_bus_sku     = "Premium"
service_bus_capacity = 1
premium_messaging_partitions = 1
service_bus_authorization_rules = [
  { name = "namespace-rule1", rights = ["Listen", "Send"] }
]
service_bus_queues = [
  {
    name                 = "orders-queue"
    partitioning_enabled = false
    authorization_rules = [
      { name = "orders-queue-rule", rights = ["Listen"] }
    ]
  },
  {
    name                 = "payments-queue"
    partitioning_enabled = false
    authorization_rules = [
      { name = "payments-queue-rule", rights = ["Send"] }
    ]
  }
]

service_bus_topics = [
  {
    name                 = "notifications-topic"
    partitioning_enabled = false
    authorization_rules = [
      { name = "notifications-topic-rule", rights = ["Send"] }
    ]
  }
]

# Variables for Azure SQL Database
sql_server_name = "sqlserver9841"
sql_server_administrator_login = "milanju"
sql_server_administrator_login_password = "Tales198321$$$$"
sql_database_name = "primer"

# Variables for Azure Application Insights
log_analytics_workspace_name = "law1984"
application_insights_name = "ai1984"
application_type = "web"