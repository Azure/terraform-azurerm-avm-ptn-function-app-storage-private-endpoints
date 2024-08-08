terraform {
  required_version = ">= 1.6.1"
  required_providers {
    # TODO: Ensure all required providers are listed here and the version property includes a constraint on the maximum major version.
    # azapi = {
    #   source  = "Azure/azapi"
    #   version = ">= 1.9.0, < 2.0"
    # }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.71"
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
