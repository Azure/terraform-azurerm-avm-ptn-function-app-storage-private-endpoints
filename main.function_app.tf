module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.5.0"

  enable_telemetry = var.enable_telemetry

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  kind    = "functionapp"
  os_type = var.os_type

  public_network_access_enabled = false

  create_service_plan = var.create_service_plan
  new_service_plan    = var.new_service_plan

  # Existing service plan
  service_plan_resource_id = var.service_plan_resource_id

  # Uses external storage account module call, which creates a new storage account. References the name of the new storage account.
  function_app_create_storage_account        = false
  function_app_storage_account_name          = var.create_secure_storage_account ? module.storage_account[0].name : var.function_app_storage_account_name
  function_app_storage_uses_managed_identity = true
  virtual_network_subnet_id                  = var.virtual_network_subnet_id
  function_app_storage_account_access_key    = var.create_secure_storage_account ? module.storage_account[0].resource.primary_connection_string : var.function_app_storage_account_access_key
  tags                                       = var.tags

  lock = var.lock == null ? null : var.lock

  managed_identities = {
    system_assigned = true
  }

  private_endpoints = {
    primary = {
      name                          = "pe-${var.name}"
      private_dns_zone_resource_ids = var.private_dns_zones == null || length(var.private_dns_zones) < 1 ? ["/subscriptions/${var.private_dns_zone_subscription_id}/resourceGroups/${var.private_dns_zone_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"] : [module.private_dns_zone[var.zone_key_for_link].private_dnz_zone_output.id]
      subnet_resource_id            = var.private_endpoint_subnet_resource_id
      tags                          = var.tags
    }
  }

  site_config = merge(
    var.site_config,
    {
      # application_insights_connection_string = ""
      vnet_route_all_enabled = true
    }
  )

  # https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
  app_settings = merge(
    var.app_settings,
    {

      # these are used by managed identity, but MI can only be used on dedicated plans, not on elastic premium
      # ref: # https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings     
      AzureWebJobsStorage__blobServiceUri  = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.blob.core.windows.net" : "https://${var.function_app_storage_account_name}.blob.core.windows.net"
      AzureWebJobsStorage__queueServiceUri = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.queue.core.windows.net" : "https://${var.function_app_storage_account_name}.queue.core.windows.net"
      AzureWebJobsStorage__tableServiceUri = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.table.core.windows.net" : "https://${var.function_app_storage_account_name}.table.core.windows.net"

      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = var.create_secure_storage_account ? module.storage_account[0].resource.primary_connection_string : var.function_app_storage_account_primary_connection_string
      WEBSITE_CONTENTSHARE                     = var.create_secure_storage_account ? var.function_app_storage_account.name : var.function_app_storage_account_name

      WEBSITE_CONTENTOVERVNET = 1
    }
  )
}

