output "function_app_private_dns_zone" {
  description = "The resource output for the private dns zone of the function app"
  value       = module.test.function_app_private_dns_zone
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.test.name
}

output "resource" {
  description = "This is the full output for the resource."
  sensitive   = true
  value       = module.test.resource
}
