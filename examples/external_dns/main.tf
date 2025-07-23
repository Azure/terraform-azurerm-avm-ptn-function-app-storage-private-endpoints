## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "= 0.3.0"
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
  version = "= 0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = "${module.naming.resource_group.name_unique}-external-dns-secured"
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
  location            = azurerm_resource_group.example.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "example" {
  address_prefixes     = ["192.168.0.0/25"]
  name                 = module.naming.subnet.name_unique
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  service_endpoints    = ["Microsoft.Storage"]
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

module "private_dns_zone" {
  source   = "Azure/avm-res-network-privatednszone/azurerm"
  version  = "0.3.4"
  for_each = local.endpoint_zones

  domain_name           = each.value.domain_name
  resource_group_name   = each.value.resource_group_name
  enable_telemetry      = var.enable_telemetry
  virtual_network_links = each.value.virtual_network_links
}

module "public_ip" {
  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
  count   = var.bypass_ip_cidr == null ? 1 : 0
}

module "test" {
  source = "../../"

  location            = azurerm_resource_group.example.location
  name                = "${module.naming.function_app.name_unique}-external-dns"
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
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
  create_secure_storage_account       = true
  create_service_plan                 = true
  enable_telemetry                    = var.enable_telemetry
  private_endpoint_subnet_resource_id = azurerm_subnet.example.id
  public_network_access_enabled       = true
  site_config = {
    ftps_state = "FtpsOnly"
    application_stack = {
      stack_1 = {
        node_version = "~20"
      }
    }
  }
  storage_account = {
    name                = module.naming.storage_account.name_unique
    resource_group_name = azurerm_resource_group.example.name
    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = [try(module.public_ip[0].public_ip, var.bypass_ip_cidr)]
      virtual_network_subnet_ids = toset([azurerm_subnet.app_service.id, azurerm_subnet.example.id])
    }
    shares = {
      share_1 = {
        name  = module.naming.storage_account.name_unique
        quota = 10
      }
    }
    endpoints = {
      blob = {
        type                         = "blob"
        private_dns_zone_resource_id = module.private_dns_zone["blob"].resource_id
      }
      file = {
        type                         = "file"
        private_dns_zone_resource_id = module.private_dns_zone["file"].resource_id
      }
      queue = {
        type                         = "queue"
        private_dns_zone_resource_id = module.private_dns_zone["queue"].resource_id
      }
      table = {
        type                         = "table"
        private_dns_zone_resource_id = module.private_dns_zone["table"].resource_id
      }
    }
  }
  use_external_managed_dns_for_storage = true
  virtual_network_subnet_id            = azurerm_subnet.app_service.id
}
