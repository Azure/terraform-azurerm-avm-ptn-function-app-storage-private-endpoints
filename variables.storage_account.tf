variable "function_app_storage_account" {
  type = object({
    name                          = optional(string)
    resource_group_name           = optional(string)
    account_replication_type      = optional(string, "LRS")
    public_network_access_enabled = optional(bool, false)
    network_rules = optional(object({
      bypass                     = optional(set(string), [])
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(set(string), [])
      virtual_network_subnet_ids = optional(set(string), [])
      private_link_access = optional(list(object({
        endpoint_resource_id = string
        endpoint_tenant_id   = optional(string)
      })))
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    }), {})
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