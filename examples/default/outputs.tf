output "location" {
  description = "The location of the resource group that the resources were created in."
  value       = azurerm_resource_group.example.location
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
