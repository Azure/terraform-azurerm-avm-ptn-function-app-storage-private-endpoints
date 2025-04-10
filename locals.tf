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