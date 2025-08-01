<!-- BEGIN_TF_DOCS -->
<!-- Code generated by terraform-docs. DO NOT EDIT. -->
# Default example

This deploys the pattern module in its simplest form.

```hcl
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "= 0.3.0"
}

resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}


# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "= 0.3.0"
}

data "azurerm_client_config" "this" {}

resource "azurerm_resource_group" "example" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = "${module.naming.resource_group.name_unique}-secure-storage-default"
}

resource "azurerm_virtual_network" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "private_endpoints" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "${module.naming.subnet.name_unique}-privateendpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "app_service" {
  address_prefixes     = ["192.168.1.0/24"]
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

resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "law-test-001"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

module "public_ip" {
  source  = "lonegunmanb/public-ip/lonegunmanb"
  version = "0.1.0"
  count   = var.bypass_ip_cidr == null ? 1 : 0
}

# Should you want the function app to be secured by private endpoints, you can use the following code:
module "function_app_private_dns_zone" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.3.2"

  domain_name         = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.example.name
  enable_telemetry    = var.enable_telemetry
  virtual_network_links = {
    example = {
      vnetlinkname = "${azurerm_virtual_network.example.name}-link"
      vnetid       = azurerm_virtual_network.example.id
    }
  }
}

module "test" {
  source = "../../"

  location            = azurerm_resource_group.example.location
  name                = "${module.naming.function_app.name_unique}-secured"
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.example.name
  app_settings = {

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
  # Uses the avm-res-storage-storageaccount module to create a new storage account
  create_secure_storage_account = true
  # Creates a new app service plan
  create_service_plan                  = true
  enable_telemetry                     = var.enable_telemetry
  private_dns_zone_resource_group_name = azurerm_resource_group.example.name
  private_dns_zone_subscription_id     = data.azurerm_client_config.this.subscription_id
  # Creates the private dns zones via avm-res-network-privatednszone module
  private_dns_zones = {
    blob = {
      domain_name         = "privatelink.blob.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.blob.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    },
    file = {
      domain_name         = "privatelink.file.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.file.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    },
    queue = {
      domain_name         = "privatelink.queue.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.queue.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    },
    table = {
      domain_name         = "privatelink.table.core.windows.net"
      resource_group_name = azurerm_resource_group.example.name
      virtual_network_links = {
        example = {
          vnetlinkname = "privatelink.table.core.windows.net-link"
          vnetid       = azurerm_virtual_network.example.id
        }
      }
    }
  }
  private_endpoint_subnet_resource_id = azurerm_subnet.private_endpoints.id
  # Should you want the function app to be secured by private endpoints, you can use the following code:
  private_endpoints = {
    primary = {
      name                          = "pe-${module.naming.function_app.name_unique}-secured-default"
      private_dns_zone_resource_ids = [module.function_app_private_dns_zone.resource.id]
      subnet_resource_id            = azurerm_subnet.private_endpoints.id
    }
  }
  service_plan = {
    name                   = module.naming.app_service_plan.name_unique
    sku_name               = "P1v2"
    zone_balancing_enabled = true
  }
  site_config = {
    ftps_state = "FtpsOnly"
    always_on  = true
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
      virtual_network_subnet_ids = toset([azurerm_subnet.app_service.id, azurerm_subnet.private_endpoints.id])
    }
    shares = {
      share_1 = {
        name  = module.naming.storage_account.name_unique
        quota = 10
      }
    }
  }
  storage_contentshare_name = module.naming.storage_account.name_unique
  virtual_network_subnet_id = azurerm_subnet.app_service.id
}

# Virtual machine to use for private endpoint testing:
resource "random_integer" "zone_index" {
  max = length(module.regions.regions_by_name[local.azure_regions[random_integer.region_index.result]].zones)
  min = 1
}

resource "azurerm_network_security_group" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.network_security_group.name_unique
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "example" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "AllowAllRDPInbound"
  network_security_group_name = azurerm_network_security_group.example.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.example.name
  destination_address_prefix  = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  source_port_range           = "*"
}

module "vm_sku" {
  source  = "Azure/avm-utl-sku-finder/azapi"
  version = "0.3.0"

  location      = azurerm_resource_group.example.location
  cache_results = true
  vm_filters = {
    min_vcpus                      = 2
    max_vcpus                      = 2
    encryption_at_host_supported   = true
    accelerated_networking_enabled = true
    premium_io_supported           = true
    location_zone                  = random_integer.zone_index.result
  }

  depends_on = [random_integer.zone_index]
}

# Create the virtual machine
module "avm_res_compute_virtualmachine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.19.3"

  location = azurerm_resource_group.example.location
  name     = "${module.naming.virtual_machine.name_unique}-tf"
  network_interfaces = {
    network_interface_1 = {
      name = "nic-${module.naming.network_interface.name_unique}-tf"
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.naming.network_interface.name_unique}-ipconfig1-public"
          private_ip_subnet_resource_id = azurerm_subnet.private_endpoints.id
          create_public_ip_address      = true
          public_ip_address_name        = "pip-${module.naming.virtual_machine.name_unique}-tf"
          is_primary_ipconfiguration    = true
        }
      }
      network_security_groups = {
        group1 = {
          network_security_group_resource_id = azurerm_network_security_group.example.id
        }
      }
    }
  }
  resource_group_name                = azurerm_resource_group.example.name
  zone                               = random_integer.zone_index.result
  admin_password                     = "P@ssw0rd1234!"
  admin_username                     = "TestAdmin"
  allow_extension_operations         = false
  enable_telemetry                   = false
  encryption_at_host_enabled         = false
  generate_admin_password_or_ssh_key = false
  os_type                            = "Windows"
  provision_vm_agent                 = false
  sku_size                           = module.vm_sku.sku
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  tags = {

  }
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
- [azurerm_network_security_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) (resource)
- [azurerm_network_security_rule.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) (resource)
- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_subnet.app_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [random_integer.zone_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

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

### <a name="module_avm_res_compute_virtualmachine"></a> [avm\_res\_compute\_virtualmachine](#module\_avm\_res\_compute\_virtualmachine)

Source: Azure/avm-res-compute-virtualmachine/azurerm

Version: 0.19.3

### <a name="module_function_app_private_dns_zone"></a> [function\_app\_private\_dns\_zone](#module\_function\_app\_private\_dns\_zone)

Source: Azure/avm-res-network-privatednszone/azurerm

Version: 0.3.2

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: = 0.3.0

### <a name="module_public_ip"></a> [public\_ip](#module\_public\_ip)

Source: lonegunmanb/public-ip/lonegunmanb

Version: 0.1.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: = 0.3.0

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

### <a name="module_vm_sku"></a> [vm\_sku](#module\_vm\_sku)

Source: Azure/avm-utl-sku-finder/azapi

Version: 0.3.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->