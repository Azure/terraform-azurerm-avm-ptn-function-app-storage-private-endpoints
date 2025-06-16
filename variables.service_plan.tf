variable "create_service_plan" {
  type        = bool
  default     = true
  description = "Should a service plan be created for the Function App? Defaults to `true`."
}

variable "service_plan" {
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
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
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
  })
  default = {

  }
  description = <<DESCRIPTION
  A map of objects that represent a new App Service Plan to create for the Function App.

  - `name` - (Optional) The name of the App Service Plan.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the App Service Plan in.
  - `location` - (Optional) The Azure region where the App Service Plan will be deployed. Defaults to the location of the resource group.
  - `sku_name` - (Optional) The SKU name of the App Service Plan. Defaults to `P1v2`. 
  > Possible values include `B1`, `B2`, `B3`, `D1`, `F1`, `I1`, `I2`, `I3`, `I1v2`, `I2v2`, `I3v2`, `I4v2`, `I5v2`, `I6v2`, `P1v2`, `P2v2`, `P3v2`, `P0v3`, `P1v3`,``P2v3`, `P3v3`, `P1mv3`, `P2mv3`, `P3mv3`, `P4mv3`, `P5mv3`, `S1`, `S2`, `S3`, `SHARED`, `EP1`, `EP2`, `EP3`, `FC1`, `WS1`, `WS2`, `WS3`, and `Y1`.
  - `app_service_environment_resource_id` - (Optional) The resource ID of the App Service Environment to deploy the App Service Plan in.
  - `maximum_elastic_worker_count` - (Optional) The maximum number of workers that can be allocated to Elastic SKU Plan. Cannot be set unless using an Elastic SKU.
  - `worker_count` - (Optional) The number of workers to allocate to this App Service Plan. Defaults to `3`.
  - `per_site_scaling_enabled` - (Optional) Should per site scaling be enabled for the App Service Plan? Defaults to `false`.
  - `zone_balancing_enabled` - (Optional) Should zone balancing be enabled for the App Service Plan? Changing this forces a new resource to be created.
  > **NOTE:** If this setting is set to `true` and the `worker_count` value is specified, it should be set to a multiple of the number of availability zones in the region. Please see the Azure documentation for the number of Availability Zones in your region.
  DESCRIPTION
}
