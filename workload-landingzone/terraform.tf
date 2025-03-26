terraform {
  required_version = "~> 1.9"
  
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.36"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
    resource_group_name   = "rg--state-dev-northeurope"
    storage_account_name  = "shelltfstatedev"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}