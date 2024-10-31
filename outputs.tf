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
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.function_app.resource
}

output "resource_id" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.function_app.resource.id
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
