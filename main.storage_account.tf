module "storage_account" {
  source = "Azure/avm-res-storage-storageaccount/azurerm"

  version = "0.5.0"

  count = var.create_secure_storage_account ? 1 : 0

  enable_telemetry              = var.enable_telemetry
  account_replication_type      = var.storage_account.account_replication_type
  access_tier                   = var.storage_account.access_tier
  account_kind                  = var.storage_account.account_kind
  name                          = var.storage_account.name
  resource_group_name           = coalesce(var.storage_account.resource_group_name, var.resource_group_name)
  location                      = var.location
  public_network_access_enabled = var.storage_account.public_network_access_enabled
  # this is necessary as managed identity does not work with Elastic Premium Plans due to missing authentication support in Azure Files
  shared_access_key_enabled          = var.storage_account.shared_access_key_enabled
  storage_management_policy_rule     = var.storage_account.storage_management_policy_rule
  storage_management_policy_timeouts = var.storage_account.storage_management_policy_timeouts
  immutability_policy                = var.storage_account.immutability_policy
  containers                         = var.storage_account.containers
  network_rules                      = var.storage_account.network_rules
  table_encryption_key_type          = var.storage_account.table_encryption_key_type
  tables                             = var.storage_account.tables
  queues                             = var.storage_account.queues
  queue_encryption_key_type          = var.storage_account.queue_encryption_key_type
  queue_properties                   = var.storage_account.queue_properties
  lock                               = var.storage_account.lock
  edge_zone                          = var.storage_account.edge_zone
  https_traffic_only_enabled         = var.storage_account.https_traffic_only_enabled
  static_website                     = var.storage_account.static_website
  min_tls_version                    = var.storage_account.min_tls_version
  nfsv3_enabled                      = var.storage_account.nfsv3_enabled
  routing                            = var.storage_account.routing
  sftp_enabled                       = var.storage_account.sftp_enabled
  cross_tenant_replication_enabled   = var.storage_account.cross_tenant_replication_enabled
  private_endpoints = {
    for endpoint in local.endpoints :
    endpoint => {
      name                          = "pe-${endpoint}-${var.storage_account.name}"
      subnet_resource_id            = var.private_endpoint_subnet_resource_id
      subresource_name              = endpoint
      private_dns_zone_resource_ids = ["/subscriptions/${var.private_dns_zone_subscription_id}/resourceGroups/${var.private_dns_zone_resource_group_name}/providers/Microsoft.Network/privateDnsZones/privatelink.${endpoint}.core.windows.net"]
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
  shares = length(var.storage_account.shares) > 0 ? local.var_shares : local.shares
  tags   = var.tags
}