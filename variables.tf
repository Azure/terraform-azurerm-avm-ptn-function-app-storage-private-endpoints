variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."
  nullable    = false
}

variable "os_type" {
  type        = string
  description = "The operating system that should be the same type of the App Service Plan to deploy the Function/Web App in."

  validation {
    error_message = "The value must be on of: `Linux` or `Windows`"
    condition     = contains(["Linux", "Windows"], var.os_type)
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
  nullable    = false
}

variable "app_settings" {
  type = map(string)
  default = {

  }
  description = <<DESCRIPTION
  A map of key-value pairs for [App Settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) and custom values to assign to the Function App. 
  
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
  DESCRIPTION
}

variable "application_insights" {
  type = object({
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
  default = {

  }
  description = <<DESCRIPTION

  The Application Insights settings to assign to the Function App.

  DESCRIPTION
}

variable "create_secure_storage_account" {
  type        = bool
  default     = false
  description = "Should a secure Storage Account be created for the Function App?"
}

variable "create_service_plan" {
  type        = bool
  default     = false
  description = "Should the module create a new App Service Plan for the Function App?"
}

variable "diagnostic_settings" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

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
DESCRIPTION
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
  This variable controls whether or not telemetry is enabled for the module.
  For more information see <https://aka.ms/avm/telemetryinfo>.
  If it is set to false, then no telemetry will be collected.
  DESCRIPTION
}

variable "function_app_storage_account_access_key" {
  type        = string
  default     = null
  description = "The access key of the Storage Account to deploy the Function App in."
  sensitive   = true
}

variable "function_app_storage_account_name" {
  type        = string
  default     = null
  description = "The name of the existing Storage Account to deploy the Function App in."
}

variable "function_app_storage_account_primary_connection_string" {
  type        = string
  default     = null
  description = "The primary connection string of the Storage Account to deploy the Function App in."
  sensitive   = true
}

variable "lock" {
  type = object({
    name = optional(string, null)
    kind = string
  })
  default     = null
  description = "The lock level to apply. Possible values are `CanNotDelete` and `ReadOnly`."

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'CanNotDelete' or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = "Managed identities to be created for the resource."
  nullable    = false
}

variable "new_service_plan" {
  type = object({
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
  default = {

  }
  description = <<DESCRIPTION
  A map of objects that represent a new App Service Plan to create for the Function App.

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
  DESCRIPTION
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  default     = null
  description = "resource group name where private DNS zones are registered"
}

variable "private_dns_zone_subscription_id" {
  type        = string
  default     = null
  description = "subscription id where the Private DNS Zones are registered"
}

variable "private_endpoint_subnet_resource_id" {
  type        = string
  default     = null
  description = "subnet for private endpoints"
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "service_plan_resource_id" {
  type        = string
  default     = null
  description = "The resource ID of the App Service Plan to deploy the Function App in."
}

variable "site_config" {
  type = object({
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
  default     = {}
  description = <<DESCRIPTION
  An object that configures the Function App's `site_config` block.
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

  DESCRIPTION
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "The map of tags to be applied to the resource"
}

variable "virtual_network_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet to deploy the Function App in."
}

variable "zone_key_for_link" {
  type        = string
  default     = null
  description = "The key of the zone to link the Function App to."
}
