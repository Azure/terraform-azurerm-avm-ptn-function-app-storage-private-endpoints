variable "function_app_storage_account" {
  type = object({
    name                     = optional(string)
    resource_group_name      = optional(string)
    account_replication_type = optional(string, "LRS")
  })
  default = {

  }
  description = <<DESCRIPTION
  A map of objects that represent a Storage Account to mount to the Function App.

  - `name` - (Optional) The name of the Storage Account.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the Storage Account in.
  - `account_replication_type` - (Optional) The replication type of the Storage Account. Defaults to `LRS`.

  ```terraform

  ```
  DESCRIPTION
}