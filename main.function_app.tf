# New branch, commit, and push for AVM-Review-PR

module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.9.1"

  enable_telemetry = var.enable_telemetry

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  kind    = "functionapp"
  os_type = var.os_type

  public_network_access_enabled = var.public_network_access_enabled
  https_only                    = var.https_only

  create_service_plan = var.create_service_plan
  new_service_plan    = var.new_service_plan

  # Existing service plan
  service_plan_resource_id = var.service_plan_resource_id

  # Uses external storage account module call, which creates a new storage account. References the name of the new storage account.
  function_app_create_storage_account            = false
  function_app_storage_account_name              = var.create_secure_storage_account ? module.storage_account[0].name : var.storage_account_name
  function_app_storage_uses_managed_identity     = true
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  function_app_storage_account_access_key        = var.create_secure_storage_account ? module.storage_account[0].resource.primary_connection_string : coalesce(var.storage_account_access_key, var.storage_account_primary_connection_string)
  tags                                           = var.tags
  zip_deploy_file                                = var.zip_deploy_file
  timeouts                                       = var.timeouts
  storage_shares_to_mount                        = var.storage_shares_to_mount
  storage_key_vault_secret_id                    = var.storage_key_vault_secret_id
  logs                                           = var.logs
  auth_settings                                  = var.auth_settings
  auth_settings_v2                               = var.auth_settings_v2
  auto_heal_setting                              = var.auto_heal_setting
  all_child_resources_inherit_lock               = var.all_child_resources_inherit_lock
  all_child_resources_inherit_tags               = var.all_child_resources_inherit_tags
  backup                                         = var.backup
  builtin_logging_enabled                        = var.builtin_logging_enabled
  client_affinity_enabled                        = var.client_affinity_enabled
  client_certificate_enabled                     = var.client_certificate_enabled
  client_certificate_exclusion_paths             = var.client_certificate_exclusion_paths
  client_certificate_mode                        = var.client_certificate_mode
  connection_strings                             = var.connection_strings
  content_share_force_disabled                   = var.content_share_force_disabled
  custom_domains                                 = var.custom_domains
  daily_memory_time_quota                        = var.daily_memory_time_quota
  enable_application_insights                    = var.enable_application_insights
  ftp_publish_basic_authentication_enabled       = var.ftp_publish_basic_authentication_enabled
  functions_extension_version                    = var.functions_extension_version
  key_vault_reference_identity_id                = var.key_vault_reference_identity_id
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled

  lock = var.lock

  managed_identities = {
    system_assigned = true
  }

  application_insights = var.application_insights
  diagnostic_settings  = var.diagnostic_settings
  role_assignments     = var.role_assignments

  private_endpoints = merge(
    var.private_endpoints,
    {
      primary = {
        name                          = "pe-${var.name}"
        private_dns_zone_resource_ids = var.private_dns_zones == null || length(var.private_dns_zones) < 1 ? ["/subscriptions/${var.private_dns_zone_subscription_id}/resourceGroups/${var.private_dns_zone_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"] : [module.private_dns_zone[var.zone_key_for_link].resource.id]
        subnet_resource_id            = var.private_endpoint_subnet_resource_id
        tags                          = var.tags
      }
    }
  )
  private_endpoints_inherit_lock          = var.private_endpoints_inherit_lock
  private_endpoints_manage_dns_zone_group = var.private_endpoints_manage_dns_zone_group

  site_config = merge(
    var.site_config,
    {
      # application_insights_connection_string = ""
      vnet_route_all_enabled = true
    }
  )

  deployment_slots              = var.deployment_slots
  app_service_active_slot       = var.app_service_active_slot
  deployment_slots_inherit_lock = var.deployment_slots_inherit_lock

  # https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
  app_settings = merge(
    var.app_settings,
    {

      # these are used by managed identity, but MI can only be used on dedicated plans, not on elastic premium
      # ref: # https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings     
      AzureWebJobsStorage__blobServiceUri  = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.blob.core.windows.net" : "https://${var.storage_account_name}.blob.core.windows.net"
      AzureWebJobsStorage__queueServiceUri = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.queue.core.windows.net" : "https://${var.storage_account_name}.queue.core.windows.net"
      AzureWebJobsStorage__tableServiceUri = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.table.core.windows.net" : "https://${var.storage_account_name}.table.core.windows.net"

      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = var.create_secure_storage_account ? module.storage_account[0].resource.primary_connection_string : var.storage_account_primary_connection_string
      WEBSITE_CONTENTSHARE                     = var.create_secure_storage_account ? coalesce(var.storage_contentshare_name, var.storage_account.name) : var.storage_contentshare_name

      WEBSITE_CONTENTOVERVNET = 1
    }
  )
}

