terraform {
  required_version = ">= 0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
  }
}

locals {
  azure = jsondecode(file("${path.module}/azure_credentials.json"))
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  client_id       = local.azure.clientId
  client_secret   = local.azure.clientSecret
  subscription_id = local.azure.subscriptionId
  tenant_id       = local.azure.tenantId
}

provider "azapi" {
  client_id       = local.azure.clientId
  client_secret   = local.azure.clientSecret
  subscription_id = local.azure.subscriptionId
  tenant_id       = local.azure.tenantId
}

provider "azuread" {
  client_id       = local.azure.clientId
  client_secret   = local.azure.clientSecret
  tenant_id       = local.azure.tenantId
}