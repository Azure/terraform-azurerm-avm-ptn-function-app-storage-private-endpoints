variable "new_service_plan" {
  type = object({
    name                                = optional(string)
    resource_group_name                 = optional(string)
    location                            = optional(string)
    sku_name                            = optional(string, "P1v2")
    app_service_environment_resource_id = optional(string)
    maximum_elastic_worker_count        = optional(number)
    worker_count                        = optional(number, 3)
    per_site_scaling_enabled            = optional(bool, false)
    zone_balancing_enabled              = optional(bool, true)
  })
  default     = null
  description = <<DESCRIPTION
  DEPRECATED, use `create_service_plan` and `service_plan` instead.
  
  A map of objects that represent a new App Service Plan to create for the Function App.

  - `name` - (Optional) The name of the App Service Plan.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the App Service Plan in.
  - `location` - (Optional) The Azure region where the App Service Plan will be deployed. Defaults to the location of the resource group.
  - `sku_name` - (Optional) The SKU name of the App Service Plan. Defaults to `P1v2`.
  - `app_service_environment_resource_id` - (Optional) The resource ID of the App Service Environment to deploy the App Service Plan in.
  - `maximum_elastic_worker_count` - (Optional) The maximum number of workers that can be allocated to this App Service Plan.
  - `worker_count` - (Optional) The number of workers to allocate to this App Service Plan.
  - `per_site_scaling_enabled` - (Optional) Should per site scaling be enabled for the App Service Plan? Defaults to `false`.
  - `zone_balancing_enabled` - (Optional) Should zone balancing be enabled for the App Service Plan? Changing this forces a new resource to be created.
  > **NOTE:** If this setting is set to `true` and the `worker_count` value is specified, it should be set to a multiple of the number of availability zones in the region. Please see the Azure documentation for the number of Availability Zones in your region.
  DESCRIPTION
}
