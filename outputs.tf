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

output "storage_account_name" {
  description = "This is the name of the storage account."
  value       = var.create_secure_storage_account ? module.storage_account[0].name : null
}
