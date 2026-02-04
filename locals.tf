locals {
  endpoints = toset(["blob", "queue", "table", "file"])
  # Workaround for a default share
  shares = {
    default_share = {
      name  = coalesce(var.storage_contentshare_name, var.storage_account.name)
      quota = 10
    }
  }
  storage_account_role_definitions_default = {
    storage_blob_data_owner        = "Storage Blob Data Owner"
    storage_account_contributor    = "Storage Account Contributor"
    storage_queue_data_contributor = "Storage Queue Data Contributor"
  }
  system_assigned_storage_account_role_assignment_default_helper = var.managed_identities.system_assigned ? { for key, value in local.storage_account_role_definitions_default : key => {
    role_definition_id_or_name = value
    principal_id               = module.function_app.resource.identity[0].principal_id
    }
  } : {}
  var_shares = {
    for key, value in var.storage_account.shares :
    key => {
      name  = value.name
      quota = value.quota
    }
  }
}
