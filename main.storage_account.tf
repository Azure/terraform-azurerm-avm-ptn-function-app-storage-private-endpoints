module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.4"
  count   = var.create_secure_storage_account ? 1 : 0

  location                            = var.location
  name                                = var.storage_account.name
  resource_group_name                 = coalesce(var.storage_account.resource_group_name, var.resource_group_name)
  access_tier                         = var.storage_account.access_tier
  account_kind                        = var.storage_account.account_kind
  account_replication_type            = var.storage_account.account_replication_type
  containers                          = var.storage_account.containers
  cross_tenant_replication_enabled    = var.storage_account.cross_tenant_replication_enabled
  diagnostic_settings_blob            = var.storage_account.diagnostic_settings_blob
  diagnostic_settings_file            = var.storage_account.diagnostic_settings_file
  diagnostic_settings_queue           = var.storage_account.diagnostic_settings_queue
  diagnostic_settings_storage_account = var.storage_account.diagnostic_settings_storage_account
  diagnostic_settings_table           = var.storage_account.diagnostic_settings_table
  edge_zone                           = var.storage_account.edge_zone
  enable_telemetry                    = var.enable_telemetry
  https_traffic_only_enabled          = var.storage_account.https_traffic_only_enabled
  immutability_policy                 = var.storage_account.immutability_policy
  lock                                = var.storage_account.lock
  min_tls_version                     = var.storage_account.min_tls_version
  network_rules                       = var.storage_account.network_rules
  nfsv3_enabled                       = var.storage_account.nfsv3_enabled
  private_endpoints = var.use_external_managed_dns_for_storage == false && (var.private_dns_zones != null || length(var.private_dns_zones) > 0) ? {
    for endpoint in local.endpoints :
    endpoint => {
      name                          = "pe-${endpoint}-${var.storage_account.name}"
      subnet_resource_id            = var.private_endpoint_subnet_resource_id
      subresource_name              = endpoint
      private_dns_zone_resource_ids = ["/subscriptions/${var.private_dns_zone_subscription_id}/resourceGroups/${var.private_dns_zone_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.${endpoint}.core.windows.net"]
      tags                          = var.tags
    }
    } : {
    for endpoint in var.storage_account.endpoints :
    endpoint.type => {
      name                          = "pe-${endpoint.type}-${var.storage_account.name}"
      subnet_resource_id            = var.private_endpoint_subnet_resource_id
      subresource_name              = endpoint.type
      private_dns_zone_resource_ids = [endpoint.private_dns_zone_resource_id]
      tags                          = var.tags
    }
  }
  public_network_access_enabled = var.storage_account.public_network_access_enabled
  queue_encryption_key_type     = var.storage_account.queue_encryption_key_type
  queue_properties              = var.storage_account.queue_properties
  queues                        = var.storage_account.queues
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
  routing      = var.storage_account.routing
  sftp_enabled = var.storage_account.sftp_enabled
  # this is necessary as managed identity does not work with Elastic Premium Plans due to missing authentication support in Azure Files
  shared_access_key_enabled          = var.storage_account.shared_access_key_enabled
  shares                             = length(var.storage_account.shares) > 0 ? local.var_shares : local.shares
  static_website                     = var.storage_account.static_website
  storage_management_policy_rule     = var.storage_account.storage_management_policy_rule
  storage_management_policy_timeouts = var.storage_account.storage_management_policy_timeouts
  table_encryption_key_type          = var.storage_account.table_encryption_key_type
  tables                             = var.storage_account.tables
  tags                               = var.tags
}
