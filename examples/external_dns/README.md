<!-- BEGIN_TF_DOCS -->
# Referencing existing resources

## Example is still a work-in-progress

This deploys an example showing the pattern referencing existing resources or resources created outside of the `avm-res-web-site` module

```hcl
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.10)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.app_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_bypass_ip_cidr"></a> [bypass\_ip\_cidr](#input\_bypass\_ip\_cidr)

Description: value to bypass the IP CIDR on firewall rules

Type: `string`

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_function_app_private_dns_zone"></a> [function\_app\_private\_dns\_zone](#output\_function\_app\_private\_dns\_zone)

Description: The resource output for the private dns zone of the function app

### <a name="output_location"></a> [location](#output\_location)

Description: The location of the resource group that the resources were created in.

### <a name="output_name"></a> [name](#output\_name)

Description: This is the full output for the resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The full output of the function app.

### <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group)

Description: The resource group the resources were created in.

### <a name="output_service_plan_name"></a> [service\_plan\_name](#output\_service\_plan\_name)

Description: The name of the service plan.

### <a name="output_storage_account"></a> [storage\_account](#output\_storage\_account)

Description: The name of the storage account.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: = 0.3.0

### <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone)

Source: Azure/avm-res-network-privatednszone/azurerm

Version: 0.3.4

### <a name="module_public_ip"></a> [public\_ip](#module\_public\_ip)

Source: lonegunmanb/public-ip/lonegunmanb

Version: 0.1.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: = 0.3.0

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->