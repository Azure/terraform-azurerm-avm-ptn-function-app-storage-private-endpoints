terraform {
  required_version = ">= 1.6.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

# tflint-ignore: terraform_module_provider_declaration, terraform_output_separate, terraform_variable_separate
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

data "azurerm_client_config" "this" {}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = "${module.naming.resource_group.name_unique}-default-secured"
}

# A vnet is required for the private endpoint.
resource "azurerm_virtual_network" "example" {
  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.example.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  address_prefixes     = ["192.168.0.0/25"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}

resource "azurerm_subnet" "app_service" {
  address_prefixes     = ["192.168.0.128/25"]
  name                 = "${module.naming.subnet.name_unique}-appservice"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "Microsoft.Web/serverFarms"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# LAW for Application Insights
resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "law-test-001"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

module "public_ip" {
  count = var.bypass_ip_cidr == null ? 1 : 0

  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
}

module "test" {
  source = "../../"

  # source             = "Azure/avm-ptn-function-app-storage-private-endpoints/azurerm"
  # version = "0.1.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-secured"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  os_type = "Windows"

  # Creates a new app service plan
  create_service_plan = true
  new_service_plan = {
    sku_name = "B1"
  }


  # Uses the avm-res-storage-storageaccount module to create a new storage account within root module
  create_secure_storage_account = true
  function_app_storage_account = {
    name                          = module.naming.storage_account.name_unique
    resource_group_name           = azurerm_resource_group.example.name
    public_network_access_enabled = true
    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
      virtual_network_subnet_ids = toset([azurerm_subnet.app_service.id])
    }
  }

  application_insights = {
    name                  = module.naming.application_insights.name_unique
    resource_group_name   = azurerm_resource_group.example.name
    location              = azurerm_resource_group.example.location
    application_type      = "web"
    workspace_resource_id = azurerm_log_analytics_workspace.example.id
    tags = {
      environment = "dev-tf"
    }
  }

  # Creates the private dns zones via avm-res-network-privatednszone module
  private_dns_zones = {
    blob = {
      domain_name         = "blob.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
    },
    file = {
      domain_name         = "file.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
    },
    queue = {
      domain_name         = "queue.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
    },
    table = {
      domain_name         = "table.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
    },
    function_app = {
      domain_name         = "privatelink.azurewebsites.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "${azurerm_virtual_network.example.name}-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    }
  }

  zone_key_for_link = "function_app"

  private_dns_zone_resource_group_name = azurerm_resource_group.example.name
  private_dns_zone_subscription_id     = data.azurerm_client_config.this.subscription_id
  private_endpoint_subnet_resource_id  = azurerm_subnet.example.id
  virtual_network_subnet_id            = azurerm_subnet.app_service.id
}
