terraform {
  required_version = ">= 1.6.1"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.114.0"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
