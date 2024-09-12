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
  name     = "${module.naming.resource_group.name_unique}-existing-secured"
}

# LAW for Application Insights
resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "law-test-001"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
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

module "avm_res_storage_storageaccount" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.2.4"

  enable_telemetry              = var.enable_telemetry
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  shared_access_key_enabled     = true
  public_network_access_enabled = false

  network_rules = {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
    virtual_network_subnet_ids = toset([azurerm_subnet.app_service.id])
  }

  private_endpoints = {
    for endpoint in local.endpoints :
    endpoint => {
      name                          = "pe-${endpoint}-${module.naming.storage_account.name_unique}"
      subnet_resource_id            = azurerm_subnet.example.id
      subresource_name              = endpoint
      private_dns_zone_resource_ids = ["/subscriptions/${data.azurerm_client_config.this.subscription_id}/resourceGroups/${azurerm_resource_group.example.name}/providers/Microsoft.Network/privateDnsZones/${endpoint}.core.windows.net"]
      tags = {
        environment = "dev"
      }
    }
  }

  role_assignments = {
    storage_blob_data_owner = {
      role_definition_id_or_name = "Storage Blob Data Owner"
      principal_id               = module.test.resource.identity[0].principal_id
    }
    storage_account_contributor = {
      role_definition_id_or_name = "Storage Account Contributor"
      principal_id               = module.test.resource.identity[0].principal_id
    }
    storage_queue_data_contributor = {
      role_definition_id_or_name = "Storage Queue Data Contributor"
      principal_id               = module.test.resource.identity[0].principal_id
    }
  }
  # shares = {
  #   function_app_share = {
  #     name  = module.naming.storage_account.name_unique
  #     quota = 1 # in GB
  #   }
  # }
}

resource "azurerm_service_plan" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.app_service_plan.name_unique
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "B1"
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

  name                = "${module.naming.function_app.name_unique}-secured" # TODO update with module.naming.<RESOURCE_TYPE>.name_unique
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id

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

  # Uses an existing storage account  
  storage_account_name                      = module.avm_res_storage_storageaccount.name
  storage_account_primary_connection_string = module.avm_res_storage_storageaccount.resource.primary_connection_string
  storage_account_access_key                = module.avm_res_storage_storageaccount.resource.primary_access_key

  private_endpoint_subnet_resource_id = azurerm_subnet.example.id
  virtual_network_subnet_id           = azurerm_subnet.app_service.id

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
}
