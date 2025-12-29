locals {
  endpoints = toset(["blob", "queue", "table", "file"])
  # Workaround for a default share
  shares = {
    default_share = {
      name  = coalesce(var.storage_contentshare_name, var.storage_account.name)
      quota = 10
    }
  }
  var_shares = {
    for key, value in var.storage_account.shares :
    key => {
      name  = value.name
      quota = value.quota
    }
  }
}

locals {
  storage_account_role_definitions = {
    storage_blob_data_owner        = "Storage Blob Data Owner"
    storage_account_contributor    = "Storage Account Contributor"
    storage_queue_data_contributor = "Storage Queue Data Contributor"
  }

  # Checking for managed identities passed in
  has_managed_identities       = length(var.managed_identities.user_assigned_resource_ids) > 0
  has_system_assigned_identity = var.managed_identities.system_assigned

  system_assigned_identity_role_assignments = local.has_system_assigned_identity ? {
    for key, value in local.storage_account_role_definitions : key => {
      role_definition_id_or_name = value
      principal_id               = module.function_app.resource.identity[0].principal_id
    }
  } : {}


  # parsed_id = {
  # "full_resource_type" = "Microsoft.ApiManagement/service/gateways/hostnameConfigurations"
  # "parent_resources" = tomap({
  # "gateways" = "gateway1"
  # "service" = "service1"
  # })
  # "resource_group_name" = "resGroup1"
  # "resource_name" = "config1"
  # "resource_provider" = "Microsoft.ApiManagement"
  # "resource_scope" = tostring(null)
  # "resource_type" = "hostnameConfigurations"
  # "subscription_id" = "12345678-1234-9876-4563-123456789012"
  # }
  # resource_name = "config1"
  managed_identities_parsed = local.has_managed_identities ? {
    for key in var.managed_identities.user_assigned_resource_ids : key => {
      parsed_id = provider::azurerm::parse_resource_id(key)
    }
  } : {}

  managed_identities_role_assignments = local.has_managed_identities ? { for sa in flatten([
    for mk in var.managed_identities.user_assigned_resource_ids : [
      for sk, sv in local.storage_account_role_definitions : {
        ma_key                     = mk
        sa_key                     = sk
        principal_id               = data.azurerm_user_assigned_identity.identities[mk].principal_id
        role_definition_id_or_name = sv
      }
    ]
  ]) : "${sa.ma_key}-${sa.sa_key}" => sa } : {}


  # Merges all role assignment settings into one
  storage_account_role_assignments = merge(local.system_assigned_identity_role_assignments, local.managed_identities_role_assignments, var.storage_account.role_assignments)
}
