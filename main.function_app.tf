module "function_app" {
  source    = "Azure/avm-res-web-site/azurerm"
  version   = "0.24.1"
  providers = { modtm = modtm }

  location                                 = var.location
  name                                     = var.name
  parent_id                                = local.function_app_parent_id
  service_plan_resource_id                 = var.create_service_plan ? module.service_plan[0].resource_id : var.service_plan_resource_id
  all_child_resources_inherit_tags         = var.all_child_resources_inherit_tags
  app_service_active_slot                  = var.app_service_active_slot
  app_settings                             = local.function_app_app_settings
  auth_settings                            = local.auth_settings_adapted.root
  auth_settings_v2                         = local.auth_settings_v2_adapted.root
  backup                                   = var.backup
  builtin_logging_enabled                  = var.builtin_logging_enabled
  client_affinity_enabled                  = var.client_affinity_enabled
  client_certificate_enabled               = var.client_certificate_enabled
  client_certificate_exclusion_paths       = var.client_certificate_exclusion_paths
  client_certificate_mode                  = var.client_certificate_mode
  connection_strings                       = var.connection_strings
  content_share_force_disabled             = var.content_share_force_disabled
  custom_domains                           = {}
  daily_memory_time_quota                  = var.daily_memory_time_quota
  deployment_slots                         = local.deployment_slots_adapted
  deployment_slots_inherit_lock            = false
  diagnostic_settings                      = local.diagnostic_settings_adapted
  enable_telemetry                         = var.enable_telemetry
  ftp_publish_basic_authentication_enabled = var.site_config.ftps_state == "Disabled" ? false : var.ftp_publish_basic_authentication_enabled
  functions_extension_version              = var.functions_extension_version
  https_only                               = var.https_only
  key_vault_reference_identity             = var.key_vault_reference_identity_id
  kind                                     = "functionapp"
  lock                                     = var.lock
  logs                                     = local.logs_adapted
  managed_identities = {
    system_assigned            = var.managed_identities.system_assigned
    user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
  }
  os_type                                  = var.os_type
  private_endpoints                        = local.private_endpoints_adapted.root
  private_endpoints_inherit_lock           = false
  private_endpoints_manage_dns_zone_group  = var.private_endpoints_manage_dns_zone_group
  public_network_access_enabled            = var.public_network_access_enabled
  retry                                    = var.retry
  role_assignments                         = var.role_assignments
  scm_publish_basic_authentication_enabled = var.site_config.ftps_state == "Disabled" ? false : var.webdeploy_publish_basic_authentication_enabled
  site_config                              = local.function_app_site_config
  storage_account_access_key               = local.function_app_storage_uses_managed_identity || var.storage_key_vault_secret_id != null ? null : local.function_app_storage_access_key
  storage_account_name                     = var.storage_key_vault_secret_id != null ? null : local.function_app_storage_name
  storage_shares_to_mount                  = var.storage_shares_to_mount
  storage_uses_managed_identity            = local.function_app_storage_uses_managed_identity
  tags                                     = var.tags
  timeouts                                 = var.timeouts
  virtual_network_subnet_id                = var.virtual_network_subnet_id
  vnet_content_share_enabled               = !var.content_share_force_disabled
  zip_deploy_file                          = var.zip_deploy_file
}

data "azapi_client_config" "function_app" {}

# Retain the existing content-share update address for upgrades.
resource "azapi_update_resource" "this" {
  count = var.content_share_force_disabled != true ? 1 : 0

  resource_id = module.function_app.resource_id
  type        = var.resource_types.web_sites
  body = {
    properties = {
      vnetContentShareEnabled = true
    }
  }
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  lifecycle {
    precondition {
      condition     = length(var.ignore_body_changes.web_sites) == 0
      error_message = "ignore_body_changes.web_sites is unsupported on the existing content-share update resource."
    }
  }
}
