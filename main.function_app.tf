module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "0.17.2"

  kind                             = "functionapp"
  location                         = var.location
  name                             = var.name
  os_type                          = var.os_type
  resource_group_name              = var.resource_group_name
  service_plan_resource_id         = var.create_service_plan ? module.service_plan[0].resource_id : var.service_plan_resource_id
  all_child_resources_inherit_lock = var.all_child_resources_inherit_lock
  all_child_resources_inherit_tags = var.all_child_resources_inherit_tags
  app_service_active_slot          = var.app_service_active_slot
  # https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
  app_settings = merge(
    var.app_settings,
    {
      # these are used by managed identity, but MI can only be used on dedicated plans, not on elastic premium
      # ref: # https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
      AzureWebJobsStorage__blobServiceUri      = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.blob.core.windows.net" : "https://${var.storage_account_name}.blob.core.windows.net"
      AzureWebJobsStorage__queueServiceUri     = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.queue.core.windows.net" : "https://${var.storage_account_name}.queue.core.windows.net"
      AzureWebJobsStorage__tableServiceUri     = var.create_secure_storage_account ? "https://${module.storage_account[0].name}.table.core.windows.net" : "https://${var.storage_account_name}.table.core.windows.net"
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = var.create_secure_storage_account ? module.storage_account[0].resource.primary_connection_string : var.storage_account_primary_connection_string
      WEBSITE_CONTENTSHARE                     = var.create_secure_storage_account ? coalesce(var.storage_contentshare_name, var.storage_account.name) : var.storage_contentshare_name
      # Although `WEBSITE_CONTENTOVERVNET` has been superseded by `vnetContentShareEnabled` site setting, there is currently no way to configure this setting in greenfield scenario.
      # Therefore, we are setting both settings to ensure compatibility with existing configurations.
      WEBSITE_CONTENTOVERVNET = var.content_share_force_disabled != true ? 1 : 0
      WEBSITE_VNET_ROUTE_ALL  = 1
    }
  )
  application_insights                     = var.application_insights
  auth_settings                            = var.auth_settings
  auth_settings_v2                         = var.auth_settings_v2
  auto_heal_setting                        = var.auto_heal_setting
  backup                                   = var.backup
  builtin_logging_enabled                  = var.builtin_logging_enabled
  client_affinity_enabled                  = var.client_affinity_enabled
  client_certificate_enabled               = var.client_certificate_enabled
  client_certificate_exclusion_paths       = var.client_certificate_exclusion_paths
  client_certificate_mode                  = var.client_certificate_mode
  connection_strings                       = var.connection_strings
  content_share_force_disabled             = var.content_share_force_disabled
  custom_domains                           = var.custom_domains
  daily_memory_time_quota                  = var.daily_memory_time_quota
  deployment_slots                         = var.deployment_slots
  deployment_slots_inherit_lock            = var.deployment_slots_inherit_lock
  diagnostic_settings                      = var.diagnostic_settings
  enable_application_insights              = var.enable_application_insights
  enable_telemetry                         = var.enable_telemetry
  ftp_publish_basic_authentication_enabled = var.ftp_publish_basic_authentication_enabled
  functions_extension_version              = var.functions_extension_version
  https_only                               = var.https_only
  key_vault_reference_identity_id          = var.key_vault_reference_identity_id
  lock                                     = var.lock
  logs                                     = var.logs
  managed_identities = {
    system_assigned = true
  }
  private_endpoints                              = var.private_endpoints
  private_endpoints_inherit_lock                 = var.private_endpoints_inherit_lock
  private_endpoints_manage_dns_zone_group        = var.private_endpoints_manage_dns_zone_group
  public_network_access_enabled                  = var.public_network_access_enabled
  role_assignments                               = var.role_assignments
  site_config                                    = var.site_config
  storage_account_access_key                     = var.create_secure_storage_account ? module.storage_account[0].resource.primary_connection_string : coalesce(var.storage_account_access_key, var.storage_account_primary_connection_string)
  storage_account_name                           = var.create_secure_storage_account ? module.storage_account[0].name : var.storage_account_name
  storage_key_vault_secret_id                    = var.storage_key_vault_secret_id
  storage_shares_to_mount                        = var.storage_shares_to_mount
  storage_uses_managed_identity                  = true
  tags                                           = var.tags
  timeouts                                       = var.timeouts
  virtual_network_subnet_id                      = var.virtual_network_subnet_id
  webdeploy_publish_basic_authentication_enabled = var.webdeploy_publish_basic_authentication_enabled
  zip_deploy_file                                = var.zip_deploy_file
}

# Toggle on `vnetContentShareEnabled` site property.
# This property cannot be set through `azurerm` currently, so we are using the `azapi_update_resource` resource to set it after deployment.
# `WEBSITE_CONTENTOVERVNET` app setting is still needed for greenfield deployments.
resource "azapi_update_resource" "this" {
  count = var.content_share_force_disabled != true ? 1 : 0

  resource_id = module.function_app.resource_id
  type        = "Microsoft.Web/sites@2022-03-01"
  body = {
    properties = {
      vnetContentShareEnabled = true
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

