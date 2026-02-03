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
  storage_account_role_assignment_helper = { for key, value in var.storage_account.role_assignments : key => {
    role_definition_id_or_name = value.role_definition_id_or_name
    principal_id               = module.function_app.resource.identity[0].principal_id
    }
  }
}
