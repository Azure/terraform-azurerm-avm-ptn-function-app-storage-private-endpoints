output "function_app_private_dns_zone" {
  description = "The resource output for the private dns zone of the function app"
  value       = module.test.function_app_private_dns_zone
}

output "location" {
  description = "The location of the resource group that the resources were created in."
  value       = azurerm_resource_group.example.location
}

output "name" {
  description = "This is the full output for the resource."
  value       = module.test.name
}

output "resource" {
  description = "The full output of the function app."
  sensitive   = true
  value       = module.test.resource
}

output "resource_group" {
  description = "The resource group the resources were created in."
  value       = azurerm_resource_group.example.name
}

output "storage_account" {
  description = "The name of the storage account."
  value       = module.test.storage_account_name
}
