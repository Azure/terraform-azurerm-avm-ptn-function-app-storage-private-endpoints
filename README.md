<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.71)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_os_type"></a> [os\_type](#input\_os\_type)

Description: The operating system that should be the same type of the App Service Plan to deploy the Function/Web App in.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings)

Description:   A map of key-value pairs for [App Settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) and custom values to assign to the Function App.

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
```

Type: `map(string)`

Default: `{}`

### <a name="input_application_insights"></a> [application\_insights](#input\_application\_insights)

Description:   
  The Application Insights settings to assign to the Function App.

Type:

```hcl
object({
    application_type                      = optional(string, "web")
    inherit_tags                          = optional(bool, false)
    location                              = optional(string)
    name                                  = optional(string)
    resource_group_name                   = optional(string)
    tags                                  = optional(map(string), null)
    workspace_resource_id                 = optional(string)
    daily_data_cap_in_gb                  = optional(number)
    daily_data_cap_notifications_disabled = optional(bool)
    retention_in_days                     = optional(number, 90)
    sampling_percentage                   = optional(number, 100)
    disable_ip_masking                    = optional(bool, false)
    local_authentication_disabled         = optional(bool, false)
    internet_ingestion_enabled            = optional(bool, true)
    internet_query_enabled                = optional(bool, true)
    force_customer_storage_for_profiler   = optional(bool, false)
  })
```

Default: `{}`

### <a name="input_create_secure_storage_account"></a> [create\_secure\_storage\_account](#input\_create\_secure\_storage\_account)

Description: Should a secure Storage Account be created for the Function App?

Type: `bool`

Default: `false`

### <a name="input_create_service_plan"></a> [create\_service\_plan](#input\_create\_service\_plan)

Description: Should the module create a new App Service Plan for the Function App?

Type: `bool`

Default: `false`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description:   This variable controls whether or not telemetry is enabled for the module.  
  For more information see <https://aka.ms/avm/telemetryinfo>.  
  If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_function_app_storage_account"></a> [function\_app\_storage\_account](#input\_function\_app\_storage\_account)

Description:   A map of objects that represent a Storage Account to mount to the Function App.

  - `name` - (Optional) The name of the Storage Account.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the Storage Account in.

  ```terraform

```

Type:

```hcl
object({
    name                = optional(string)
    resource_group_name = optional(string)
  })
```

Default: `{}`

### <a name="input_function_app_storage_account_access_key"></a> [function\_app\_storage\_account\_access\_key](#input\_function\_app\_storage\_account\_access\_key)

Description: The access key of the Storage Account to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_function_app_storage_account_name"></a> [function\_app\_storage\_account\_name](#input\_function\_app\_storage\_account\_name)

Description: The name of the existing Storage Account to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_function_app_storage_account_primary_connection_string"></a> [function\_app\_storage\_account\_primary\_connection\_string](#input\_function\_app\_storage\_account\_primary\_connection\_string)

Description: The primary connection string of the Storage Account to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = string
  })
```

Default: `null`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Managed identities to be created for the resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_new_service_plan"></a> [new\_service\_plan](#input\_new\_service\_plan)

Description:   A map of objects that represent a new App Service Plan to create for the Function App.

  - `name` - (Optional) The name of the App Service Plan.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the App Service Plan in.
  - `location` - (Optional) The Azure region where the App Service Plan will be deployed. Defaults to the location of the resource group.
  - `sku_name` - (Optional) The SKU name of the App Service Plan. Defaults to `B1`.
  - `app_service_environment_resource_id` - (Optional) The resource ID of the App Service Environment to deploy the App Service Plan in.
  - `maximum_elastic_worker_count` - (Optional) The maximum number of workers that can be allocated to this App Service Plan.
  - `worker_count` - (Optional) The number of workers to allocate to this App Service Plan.
  - `per_site_scaling_enabled` - (Optional) Should per site scaling be enabled for the App Service Plan? Defaults to `false`.
  - `zone_balancing_enabled` - (Optional) Should zone balancing be enabled for the App Service Plan? Changing this forces a new resource to be created.
  > **NOTE:** If this setting is set to `true` and the `worker_count` value is specified, it should be set to a multiple of the number of availability zones in the region. Please see the Azure documentation for the number of Availability Zones in your region.

Type:

```hcl
object({
    name                                = optional(string)
    resource_group_name                 = optional(string)
    location                            = optional(string)
    sku_name                            = optional(string)
    app_service_environment_resource_id = optional(string)
    maximum_elastic_worker_count        = optional(number)
    worker_count                        = optional(number)
    per_site_scaling_enabled            = optional(bool, false)
    zone_balancing_enabled              = optional(bool)
  })
```

Default: `{}`

### <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name)

Description: resource group name where private DNS zones are registered

Type: `string`

Default: `null`

### <a name="input_private_dns_zone_subscription_id"></a> [private\_dns\_zone\_subscription\_id](#input\_private\_dns\_zone\_subscription\_id)

Description: subscription id where the Private DNS Zones are registered

Type: `string`

Default: `null`

### <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones)

Description: A map of private DNS zones to create and associate with the storage account and/or Function App.

Type:

```hcl
map(object({
    domain_name         = string
    resource_group_name = string
    tags                = optional(map(string), null)
    virtual_network_links = optional(map(object({
      vnetlinkname     = string
      vnetid           = string
      autoregistration = optional(bool, false)
      tags             = optional(map(string), null)
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_endpoint_subnet_resource_id"></a> [private\_endpoint\_subnet\_resource\_id](#input\_private\_endpoint\_subnet\_resource\_id)

Description: subnet for private endpoints

Type: `string`

Default: `null`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
    name = optional(string, null)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      name = optional(string, null)
      kind = string
    }), null)
    tags                                    = optional(map(string), null)
    subnet_resource_id                      = string
    private_dns_zone_group_name             = optional(string, "default")
    private_dns_zone_resource_ids           = optional(set(string), [])
    application_security_group_associations = optional(map(string), {})
    private_service_connection_name         = optional(string, null)
    network_interface_name                  = optional(string, null)
    location                                = optional(string, null)
    resource_group_name                     = optional(string, null)
    ip_configurations = optional(map(object({
      name               = string
      private_ip_address = string
    })), {})
  }))
```

Default: `{}`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_service_plan_resource_id"></a> [service\_plan\_resource\_id](#input\_service\_plan\_resource\_id)

Description: The resource ID of the App Service Plan to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_site_config"></a> [site\_config](#input\_site\_config)

Description:   An object that configures the Function App's `site_config` block.
 - `always_on` - (Optional) If this Linux Web App is Always On enabled. Defaults to `false`.
 - `api_definition_url` - (Optional) The URL of the API definition that describes this Linux Function App.
 - `api_management_api_id` - (Optional) The ID of the API Management API for this Linux Function App.
 - `app_command_line` - (Optional) The App command line to launch.
 - `app_scale_limit` - (Optional) The number of workers this function app can scale out to. Only applicable to apps on the Consumption and Premium plan.
 - `application_insights_connection_string` - (Optional) The Connection String for linking the Linux Function App to Application Insights.
 - `application_insights_key` - (Optional) The Instrumentation Key for connecting the Linux Function App to Application Insights.
 - `container_registry_managed_identity_client_id` - (Optional) The Client ID of the Managed Service Identity to use for connections to the Azure Container Registry.
 - `container_registry_use_managed_identity` - (Optional) Should connections for Azure Container Registry use Managed Identity.
 - `default_documents` - (Optional) Specifies a list of Default Documents for the Linux Web App.
 - `elastic_instance_minimum` - (Optional) The number of minimum instances for this Linux Function App. Only affects apps on Elastic Premium plans.
 - `ftps_state` - (Optional) State of FTP / FTPS service for this function app. Possible values include: `AllAllowed`, `FtpsOnly` and `Disabled`. Defaults to `Disabled`.
 - `health_check_eviction_time_in_min` - (Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between `2` and `10`. Only valid in conjunction with `health_check_path`.
 - `health_check_path` - (Optional) The path to be checked for this function app health.
 - `http2_enabled` - (Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to `false`.
 - `load_balancing_mode` - (Optional) The Site load balancing mode. Possible values include: `WeightedRoundRobin`, `LeastRequests`, `LeastResponseTime`, `WeightedTotalTraffic`, `RequestHash`, `PerSiteRoundRobin`. Defaults to `LeastRequests` if omitted.
 - `managed_pipeline_mode` - (Optional) Managed pipeline mode. Possible values include: `Integrated`, `Classic`. Defaults to `Integrated`.
 - `minimum_tls_version` - (Optional) The configures the minimum version of TLS required for SSL requests. Possible values include: `1.0`, `1.1`, and `1.2`. Defaults to `1.2`.
 - `pre_warmed_instance_count` - (Optional) The number of pre-warmed instances for this function app. Only affects apps on an Elastic Premium plan.
 - `remote_debugging_enabled` - (Optional) Should Remote Debugging be enabled. Defaults to `false`.
 - `remote_debugging_version` - (Optional) The Remote Debugging Version. Possible values include `VS2017`, `VS2019`, and `VS2022`.
 - `runtime_scale_monitoring_enabled` - (Optional) Should Scale Monitoring of the Functions Runtime be enabled?
 - `scm_minimum_tls_version` - (Optional) Configures the minimum version of TLS required for SSL requests to the SCM site Possible values include: `1.0`, `1.1`, and `1.2`. Defaults to `1.2`.
 - `scm_use_main_ip_restriction` - (Optional) Should the Linux Function App `ip_restriction` configuration be used for the SCM also.
 - `use_32_bit_worker` - (Optional) Should the Linux Web App use a 32-bit worker process. Defaults to `false`.
 - `vnet_route_all_enabled` - (Optional) Should all outbound traffic to have NAT Gateways, Network Security Groups and User Defined Routes applied? Defaults to `false`.
 - `websockets_enabled` - (Optional) Should Web Sockets be enabled. Defaults to `false`.
 - `worker_count` - (Optional) The number of Workers for this Linux Function App.

 ---
 `app_service_logs` block supports the following:
 - `disk_quota_mb` - (Optional) The amount of disk space to use for logs. Valid values are between `25` and `100`. Defaults to `35`.
 - `retention_period_days` - (Optional) The retention period for logs in days. Valid values are between `0` and `99999`.(never delete).

 ---
 `application_stack` block supports the following:
 - `dotnet_version` - (Optional) The version of .NET to use. Possible values include `3.1`, `6.0`, `7.0` and `8.0`.
 - `java_version` - (Optional) The Version of Java to use. Supported versions include `8`, `11` & `17`.
 - `node_version` - (Optional) The version of Node to run. Possible values include `12`, `14`, `16` and `18`.
 - `powershell_core_version` - (Optional) The version of PowerShell Core to run. Possible values are `7`, and `7.2`.
 - `python_version` - (Optional) The version of Python to run. Possible values are `3.12`, `3.11`, `3.10`, `3.9`, `3.8` and `3.7`.
 - `go_version` - (Optional) The version of Go to use. Possible values are `1.18`, and `1.19`.
 - `ruby_version` - (Optional) The version of Ruby to use. Possible values are `2.6`, and `2.7`.
 - `java_server` - (Optional) The Java server type. Possible values are `JAVA`, `TOMCAT`, and `JBOSSEAP`.
 - `java_server_version` - (Optional) The version of the Java server to use.
 - `php_version` - (Optional) The version of PHP to use. Possible values are `7.4`, `8.0`, `8.1`, and `8.2`.
 - `use_custom_runtime` - (Optional) Should the Linux Function App use a custom runtime?
 - `use_dotnet_isolated_runtime` - (Optional) Should the DotNet process use an isolated runtime. Defaults to `false`.

 ---
 `docker` block supports the following:
 - `image_name` - (Required) The name of the Docker image to use.
 - `image_tag` - (Required) The image tag of the image to use.
 - `registry_password` - (Optional) The password for the account to use to connect to the registry.
 - `registry_url` - (Required) The URL of the docker registry.
 - `registry_username` - (Optional) The username to use for connections to the registry.

 ---
 `cors` block supports the following:
 - `allowed_origins` - (Optional) Specifies a list of origins that should be allowed to make cross-origin calls.
 - `support_credentials` - (Optional) Are credentials allowed in CORS requests? Defaults to `false`.

 ---
 `ip_restriction` block supports the following:
 - `action` - (Optional) The action to take. Possible values are `Allow` or `Deny`. Defaults to `Allow`.
 - `ip_address` - (Optional) The CIDR notation of the IP or IP Range to match. For example: `10.0.0.0/24` or `192.168.10.1/32`
 - `name` - (Optional) The name which should be used for this `ip_restriction`.
 - `priority` - (Optional) The priority value of this `ip_restriction`. Defaults to `65000`.
 - `service_tag` - (Optional) The Service Tag used for this IP Restriction.
 - `virtual_network_subnet_id` - (Optional) The Virtual Network Subnet ID used for this IP Restriction.

 ---
 `headers` block supports the following:
 - `x_azure_fdid` - (Optional) Specifies a list of Azure Front Door IDs.
 - `x_fd_health_probe` - (Optional) Specifies if a Front Door Health Probe should be expected. The only possible value is `1`.
 - `x_forwarded_for` - (Optional) Specifies a list of addresses for which matching should be applied. Omitting this value means allow any.
 - `x_forwarded_host` - (Optional) Specifies a list of Hosts for which matching should be applied.

 ---
 `scm_ip_restriction` block supports the following:
 - `action` - (Optional) The action to take. Possible values are `Allow` or `Deny`. Defaults to `Allow`.
 - `ip_address` - (Optional) The CIDR notation of the IP or IP Range to match. For example: `10.0.0.0/24` or `192.168.10.1/32`
 - `name` - (Optional) The name which should be used for this `ip_restriction`.
 - `priority` - (Optional) The priority value of this `ip_restriction`. Defaults to `65000`.
 - `service_tag` - (Optional) The Service Tag used for this IP Restriction.
 - `virtual_network_subnet_id` - (Optional) The Virtual Network Subnet ID used for this IP Restriction.

 ---
 `headers` block supports the following:
 - `x_azure_fdid` - (Optional) Specifies a list of Azure Front Door IDs.
 - `x_fd_health_probe` - (Optional) Specifies if a Front Door Health Probe should be expected. The only possible value is `1`.
 - `x_forwarded_for` - (Optional) Specifies a list of addresses for which matching should be applied. Omitting this value means allow any.
 - `x_forwarded_host` - (Optional) Specifies a list of Hosts for which matching should be applied.

Type:

```hcl
object({
    always_on                                     = optional(bool, false) # when running in a Consumption or Premium Plan, `always_on` feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
    api_definition_url                            = optional(string)      # (Optional) The URL of the OpenAPI (Swagger) definition that provides schema for the function's HTTP endpoints.
    api_management_api_id                         = optional(string)      # (Optional) The API Management API identifier.
    app_command_line                              = optional(string)      # (Optional) The command line to launch the application.
    auto_heal_enabled                             = optional(bool)        # (Optional) Should auto-heal be enabled for the Function App?
    app_scale_limit                               = optional(number)      # (Optional) The maximum number of workers that the Function App can scale out to.
    application_insights_connection_string        = optional(string)      # (Optional) The connection string of the Application Insights resource to send telemetry to.
    application_insights_key                      = optional(string)      # (Optional) The instrumentation key of the Application Insights resource to send telemetry to.
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    default_documents                             = optional(list(string))            #(Optional) Specifies a list of Default Documents for the Windows Function App.
    elastic_instance_minimum                      = optional(number)                  #(Optional) The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
    ftps_state                                    = optional(string, "Disabled")      #(Optional) State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
    health_check_eviction_time_in_min             = optional(number)                  #(Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path.
    health_check_path                             = optional(string)                  #(Optional) The path to be checked for this Windows Function App health.
    http2_enabled                                 = optional(bool, false)             #(Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to false.
    ip_restriction_default_action                 = optional(string, "Allow")         #(Optional) The default action for IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
    load_balancing_mode                           = optional(string, "LeastRequests") #(Optional) The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests if omitted.
    local_mysql_enabled                           = optional(bool, false)             #(Optional) Should local MySQL be enabled. Defaults to false.
    managed_pipeline_mode                         = optional(string, "Integrated")    #(Optional) Managed pipeline mode. Possible values include: Integrated, Classic. Defaults to Integrated.
    minimum_tls_version                           = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
    pre_warmed_instance_count                     = optional(number)                  #(Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
    remote_debugging_enabled                      = optional(bool, false)             #(Optional) Should Remote Debugging be enabled. Defaults to false.
    remote_debugging_version                      = optional(string)                  #(Optional) The Remote Debugging Version. Possible values include VS2017, VS2019, and VS2022.
    runtime_scale_monitoring_enabled              = optional(bool)                    #(Optional) Should runtime scale monitoring be enabled.
    scm_ip_restriction_default_action             = optional(string, "Allow")         #(Optional) The default action for SCM IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
    scm_minimum_tls_version                       = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests to Kudu. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
    scm_use_main_ip_restriction                   = optional(bool, false)             #(Optional) Should the SCM use the same IP restrictions as the main site. Defaults to false.
    use_32_bit_worker                             = optional(bool, false)             #(Optional) Should the 32-bit worker process be used. Defaults to false.
    vnet_route_all_enabled                        = optional(bool, false)             #(Optional) Should all traffic be routed to the virtual network. Defaults to false.
    websockets_enabled                            = optional(bool, false)             #(Optional) Should Websockets be enabled. Defaults to false.
    worker_count                                  = optional(number)                  #(Optional) The number of workers for this Windows Function App. Only affects apps on an Elastic Premium plan.
    app_service_logs = optional(map(object({
      disk_quota_mb         = optional(number, 35)
      retention_period_days = optional(number)
    })), {})
    application_stack = optional(map(object({
      dotnet_version              = optional(string)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
      python_version              = optional(string)
      go_version                  = optional(string)
      ruby_version                = optional(string)
      java_server                 = optional(string)
      java_server_version         = optional(string)
      php_version                 = optional(string)
      use_custom_runtime          = optional(bool)
      use_dotnet_isolated_runtime = optional(bool)
      docker = optional(list(object({
        image_name        = string
        image_tag         = string
        registry_password = optional(string)
        registry_url      = string
        registry_username = optional(string)
      })))
      current_stack                = optional(string)
      docker_image_name            = optional(string)
      docker_registry_url          = optional(string)
      docker_registry_username     = optional(string)
      docker_registry_password     = optional(string)
      docker_container_name        = optional(string)
      docker_container_tag         = optional(string)
      java_embedded_server_enabled = optional(bool)
      tomcat_version               = optional(bool)
    })), {})
    cors = optional(map(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool, false)
    })), {}) #(Optional) A cors block as defined above.
    ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(number)
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {}) #(Optional) One or more ip_restriction blocks as defined above.
    scm_ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(number)
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {}) #(Optional) One or more scm_ip_restriction blocks as defined above.
    virtual_application = optional(map(object({
      physical_path   = optional(string, "site\\wwwroot")
      preload_enabled = optional(bool, false)
      virtual_directory = optional(map(object({
        physical_path = optional(string)
        virtual_path  = optional(string)
      })), {})
      virtual_path = optional(string, "/")
      })),
      {
        default = {
          physical_path   = "site\\wwwroot"
          preload_enabled = false
          virtual_path    = "/"
        }
    }) #(Optional) One or more virtual_application blocks as defined above.
  })
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: The map of tags to be applied to the resource

Type: `map(string)`

Default: `null`

### <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id)

Description: The ID of the subnet to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_zone_key_for_link"></a> [zone\_key\_for\_link](#input\_zone\_key\_for\_link)

Description: The key of the zone to link the Function App to.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_function_app_private_dns_zone"></a> [function\_app\_private\_dns\_zone](#output\_function\_app\_private\_dns\_zone)

Description: The resource output for the private dns zone of the function app

### <a name="output_function_app_private_dns_zone_id"></a> [function\_app\_private\_dns\_zone\_id](#output\_function\_app\_private\_dns\_zone\_id)

Description: The resource output for the private dns zone of the function app

### <a name="output_name"></a> [name](#output\_name)

Description: This is the name of the resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This is the full output for the resource.

## Modules

The following Modules are called:

### <a name="module_function_app"></a> [function\_app](#module\_function\_app)

Source: Azure/avm-res-web-site/azurerm

Version: 0.5.0

### <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone)

Source: Azure/avm-res-network-privatednszone/azurerm

Version: 0.1.1

### <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: 0.1.3

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->