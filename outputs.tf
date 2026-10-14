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
  description = "This is the name of the service plan."
  value       = var.create_service_plan ? module.service_plan[0].resource : null
}

output "storage_account_resource" {
  description = "This is the full output for the storage account."
  sensitive   = true
  value       = var.create_secure_storage_account ? module.storage_account[0].resource : null
}
