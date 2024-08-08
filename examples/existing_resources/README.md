<!-- BEGIN_TF_DOCS -->
# Referencing existing resources

This deploys an example showing the pattern referencing existing resources or resources created outside of the `avm-res-web-site` module

```hcl
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
  name     = module.naming.resource_group.name_unique
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
  version = "0.2.1"

  enable_telemetry              = var.enable_telemetry
  name                          = module.naming.storage_account.name_unique
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  shared_access_key_enabled     = true
  public_network_access_enabled = false

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
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
  sku_name            = "S1"
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # source             = "Azure/avm-ptn-function-app-storage-private-endpoints/azurerm"
  # version = "0.1.0"

  enable_telemetry = var.enable_telemetry

  name                = "${module.naming.function_app.name_unique}-secured" # TODO update with module.naming.<RESOURCE_TYPE>.name_unique
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # os_type = "Windows"


  # Uses an existing app service plan
  os_type                  = azurerm_service_plan.example.os_type
  service_plan_resource_id = azurerm_service_plan.example.id


  /*
  # Creates a new app service plan
  create_service_plan = true
  new_service_plan = {
    sku_name = "S1"
  }
  */

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
  function_app_storage_account_name                      = module.avm_res_storage_storageaccount.name
  function_app_storage_account_primary_connection_string = module.avm_res_storage_storageaccount.resource.primary_connection_string
  function_app_storage_account_access_key                = module.avm_res_storage_storageaccount.resource.primary_access_key

  /*
  # Uses the avm-res-storage-storageaccount module to create a new storage account within root module
  function_app_create_storage_account = true
  function_app_storage_account = {
    name                = module.naming.storage_account.name_unique
    resource_group_name = azurerm_resource_group.example.name
  }
  */

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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.6.1)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.7.0, < 4.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.7.0, < 4.0.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_subnet.app_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### <a name="output_function_app_private_dns_zone"></a> [function\_app\_private\_dns\_zone](#output\_function\_app\_private\_dns\_zone)

Description: The resource output for the private dns zone of the function app

### <a name="output_name"></a> [name](#output\_name)

Description: This is the full output for the resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

## Modules

The following Modules are called:

### <a name="module_avm_res_storage_storageaccount"></a> [avm\_res\_storage\_storageaccount](#module\_avm\_res\_storage\_storageaccount)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: 0.2.1

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: >= 0.3.0

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/regions/azurerm

Version: >= 0.3.0

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->