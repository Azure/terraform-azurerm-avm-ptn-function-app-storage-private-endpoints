output "deprecated_variables" {
  description = "The list of deprecated variables."
  value = {
    new_service_plan = var.new_service_plan
  }
}

output "function_app_private_dns_zone" {
  description = "The resource output for the private dns zone of the function app"
  value       = length(var.private_dns_zones) > 0 && var.zone_key_for_link != null ? module.private_dns_zone[var.zone_key_for_link].resource : null
}

output "function_app_private_dns_zone_id" {
  description = "The resource output for the private dns zone of the function app"
  value       = length(var.private_dns_zones) > 0 && var.zone_key_for_link != null ? module.private_dns_zone[var.zone_key_for_link].resource.id : null
}

output "name" {
  description = "This is the name of the resource."
  value       = module.function_app.name
}

output "resource" {
  description = "The Function App resource with compatibility fields for id, name, default_hostname and identity."
  sensitive   = true
  value       = local.function_app_resource
}

output "resource_id" {
  description = "The resource ID of the Function App."
  sensitive   = true
  value       = module.function_app.resource_id
}

output "service_plan_resource" {
  description = "Identity and configuration of the service plan created by this module."
  value = var.create_service_plan ? {
    id                           = module.service_plan[0].resource_id
    name                         = module.service_plan[0].name
    location                     = coalesce(var.service_plan.location, var.location)
    resource_group_name          = coalesce(var.service_plan.resource_group_name, var.resource_group_name)
    os_type                      = var.os_type
    sku_name                     = var.service_plan.sku_name
    app_service_environment_id   = var.service_plan.app_service_environment_resource_id
    maximum_elastic_worker_count = var.service_plan.maximum_elastic_worker_count
    per_site_scaling_enabled     = var.service_plan.per_site_scaling_enabled
    worker_count                 = var.service_plan.worker_count
    zone_balancing_enabled       = var.service_plan.zone_balancing_enabled
    tags                         = var.tags
  } : null
}

output "storage_account_resource" {
  description = "This is the full output for the storage account."
  sensitive   = true
  value = var.create_secure_storage_account ? merge(module.storage_account[0].resource, {
    primary_access_key        = local.function_app_storage_access_key
    primary_connection_string = local.function_app_storage_connection_string
  }) : null
}
