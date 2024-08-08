module "storage_account" {
  count   = var.create_secure_storage_account ? 1 : 0
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.2.1"

  enable_telemetry = var.enable_telemetry

  account_replication_type      = "LRS"
  name                          = var.function_app_storage_account.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  public_network_access_enabled = false
  # this is necessary as managed identity does work with Elastic Premium Plans due to missing authentication support in Azure Files
  shared_access_key_enabled = true

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }

  private_endpoints = {
    for endpoint in local.endpoints :
    endpoint => {
      name                          = "pe-${endpoint}-${var.function_app_storage_account.name}"
      subnet_resource_id            = var.private_endpoint_subnet_resource_id
      subresource_name              = endpoint
      private_dns_zone_resource_ids = ["/subscriptions/${var.private_dns_zone_subscription_id}/resourceGroups/${var.private_dns_zone_resource_group_name}/providers/Microsoft.Network/privateDnsZones/${endpoint}.core.windows.net"]
      tags                          = var.tags
    }
  }

  role_assignments = {
    storage_blob_data_owner = {
      role_definition_id_or_name = "Storage Blob Data Owner"
      principal_id               = module.function_app.resource.identity[0].principal_id
    }
    storage_account_contributor = {
      role_definition_id_or_name = "Storage Account Contributor"
      principal_id               = module.function_app.resource.identity[0].principal_id
    }
    storage_queue_data_contributor = {
      role_definition_id_or_name = "Storage Queue Data Contributor"
      principal_id               = module.function_app.resource.identity[0].principal_id
    }
  }

  # shares = {
  #   function_app_share = {
  #     name  = var.function_app_storage_account.name
  #     quota = 1 # in GB
  #   }
  # }

  tags = var.tags
}