output "function_app_private_dns_zone" {
  description = "The resource output for the private dns zone of the function app"
  value       = length(var.private_dns_zones) > 0 && var.zone_key_for_link != null ? module.private_dns_zone[var.zone_key_for_link].private_dnz_zone_output : null
}

output "function_app_private_dns_zone_id" {
  description = "The resource output for the private dns zone of the function app"
  value       = length(var.private_dns_zones) > 0 && var.zone_key_for_link != null ? module.private_dns_zone[var.zone_key_for_link].private_dnz_zone_output.id : null
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
