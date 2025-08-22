variable "create_secure_storage_account" {
  type        = bool
  default     = true
  description = "Should a secure Storage Account be created for the Function App? Defaults to `true`."
}

variable "storage_account" {
  type = object({
    name                     = optional(string)
    resource_group_name      = optional(string)
    access_tier              = optional(string, "Hot")
    account_kind             = optional(string, "StorageV2")
    account_replication_type = optional(string, "ZRS")
    endpoints = optional(map(object({
      name                         = optional(string, null)
      type                         = string
      private_dns_zone_resource_id = optional(string, null)
      })), {
      blob = {
        type = "blob"
      }
    })
    allow_nested_items_to_be_public  = optional(bool, false)
    allowed_copy_scope               = optional(string, null)
    cross_tenant_replication_enabled = optional(bool, false)
    diagnostic_settings_blob = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    diagnostic_settings_file = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    diagnostic_settings_queue = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    diagnostic_settings_storage_account = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    diagnostic_settings_table = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    custom_domains = optional(object({
      name          = string
      use_subdomain = optional(bool)
    }), null)
    public_network_access_enabled = optional(bool, false)
    tags                          = optional(map(string), null)
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
    customer_managed_key = optional(object({
      key_vault_resource_id = string
      key_name              = string
      key_version           = optional(string, null)
      user_assigned_identity = optional(object({
        resource_id = string
      }), null)
    }), null)
    containers = optional(map(object({
      public_access                  = optional(string, "None")
      metadata                       = optional(map(string))
      name                           = string
      default_encryption_scope       = optional(string)
      deny_encryption_scope_override = optional(bool)
      enable_nfs_v3_all_squash       = optional(bool)
      enable_nfs_v3_root_squash      = optional(bool)
      immutable_storage_with_versioning = optional(object({
        enabled = bool
      }))
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
      })), {})
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    })), {})
    storage_management_policy_timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }), null)
    storage_management_policy_rule = optional(map(object({
      enabled = bool
      name    = string
      actions = object({
        base_blob = optional(object({
          auto_tier_to_hot_from_cool_enabled                             = optional(bool)
          delete_after_days_since_creation_greater_than                  = optional(number)
          delete_after_days_since_last_access_time_greater_than          = optional(number)
          delete_after_days_since_modification_greater_than              = optional(number)
          tier_to_archive_after_days_since_creation_greater_than         = optional(number)
          tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
          tier_to_archive_after_days_since_modification_greater_than     = optional(number)
          tier_to_cold_after_days_since_creation_greater_than            = optional(number)
          tier_to_cold_after_days_since_last_access_time_greater_than    = optional(number)
          tier_to_cold_after_days_since_modification_greater_than        = optional(number)
          tier_to_cool_after_days_since_creation_greater_than            = optional(number)
          tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)
          tier_to_cool_after_days_since_modification_greater_than        = optional(number)
        }))
        snapshot = optional(object({
          change_tier_to_archive_after_days_since_creation               = optional(number)
          change_tier_to_cool_after_days_since_creation                  = optional(number)
          delete_after_days_since_creation_greater_than                  = optional(number)
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
          tier_to_cold_after_days_since_creation_greater_than            = optional(number)
        }))
        version = optional(object({
          change_tier_to_archive_after_days_since_creation               = optional(number)
          change_tier_to_cool_after_days_since_creation                  = optional(number)
          delete_after_days_since_creation                               = optional(number)
          tier_to_archive_after_days_since_last_tier_change_greater_than = optional(number)
          tier_to_cold_after_days_since_creation_greater_than            = optional(number)
        }))
      })
      filters = object({
        blob_types   = set(string)
        prefix_match = optional(set(string))
        match_blob_index_tag = optional(set(object({
          name      = string
          operation = optional(string)
          value     = string
        })))
      })
    })), {})
    immutability_policy = optional(object({
      allow_protected_append_writes = bool
      period_since_creation_in_days = number
      state                         = string
    }), null)
    is_hns_enabled = optional(bool)
    blob_properties = optional(object({
      change_feed_enabled           = optional(bool)
      change_feed_retention_in_days = optional(number)
      default_service_version       = optional(string)
      last_access_time_enabled      = optional(bool)
      versioning_enabled            = optional(bool, true)
      container_delete_retention_policy = optional(object({
        days = optional(number, 7)
      }), { days = 7 })
      cors_rule = optional(map(object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })), {})
      delete_retention_policy = optional(object({
        days = optional(number, 7)
      }), { days = 7 })
      diagnostic_settings = optional(map(object({
        name                                     = optional(string, null)
        log_categories                           = optional(set(string), [])
        log_groups                               = optional(set(string), ["allLogs"])
        metric_categories                        = optional(set(string), ["AllMetrics"])
        log_analytics_destination_type           = optional(string, "Dedicated")
        workspace_resource_id                    = optional(string, null)
        resource_id                              = optional(string, null)
        event_hub_authorization_rule_resource_id = optional(string, null)
        event_hub_name                           = optional(string, null)
        marketplace_partner_resource_id          = optional(string, null)
      })), {})
      restore_policy = optional(object({
        days = number
      }))
    }), null)
    queue_encryption_key_type = optional(string, null)
    queue_properties = optional(map(object({
      cors_rule = optional(map(object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })), {})
      diagnostic_settings = optional(map(object({
        name                                     = optional(string, null)
        log_categories                           = optional(set(string), [])
        log_groups                               = optional(set(string), ["allLogs"])
        metric_categories                        = optional(set(string), ["AllMetrics"])
        log_analytics_destination_type           = optional(string, "Dedicated")
        workspace_resource_id                    = optional(string, null)
        resource_id                              = optional(string, null)
        event_hub_authorization_rule_resource_id = optional(string, null)
        event_hub_name                           = optional(string, null)
        marketplace_partner_resource_id          = optional(string, null)
      })), {})
      hour_metrics = optional(object({
        enabled               = bool
        include_apis          = optional(bool)
        retention_policy_days = optional(number)
        version               = string
      }))
      logging = optional(object({
        delete                = bool
        read                  = bool
        retention_policy_days = optional(number)
        version               = string
        write                 = bool
      }))
      minute_metrics = optional(object({
        enabled               = bool
        include_apis          = optional(bool)
        retention_policy_days = optional(number)
        version               = string
      }))
    })), {})
    queues = optional(map(object({
      metadata = optional(map(string))
      name     = string
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
      })), {})
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    })), {})
    tables = optional(map(object({
      name = string
      signed_identifiers = optional(list(object({
        id = string
        access_policy = optional(object({
          expiry_time = string
          permission  = string
          start_time  = string
        }))
      })))
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
      })), {})
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    })), {})
    table_encryption_key_type = optional(string, null)
    private_endpoints = optional(map(object({
      name = optional(string, null)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
        principal_type                         = optional(string, null)
      })), {})
      lock = optional(object({
        kind = string
        name = optional(string, null)
      }), null)
      tags                                    = optional(map(string), null)
      subnet_resource_id                      = string
      subresource_name                        = string
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string), [])
      application_security_group_associations = optional(map(string), {})
      private_service_connection_name         = optional(string, null)
      network_interface_name                  = optional(string, null)
      location                                = optional(string, null)
      resource_group_name                     = optional(string, null)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
      })), {})
    })), {})
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    lock = optional(object({
      name = optional(string, null)
      kind = string
    }), null)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }), null)
    local_user = optional(map(object({
      home_directory       = optional(string)
      name                 = string
      ssh_key_enabled      = optional(bool)
      ssh_password_enabled = optional(bool)
      permission_scope = optional(list(object({
        resource_name = string
        service       = string
        permissions = object({
          create = optional(bool)
          delete = optional(bool)
          list   = optional(bool)
          read   = optional(bool)
          write  = optional(bool)
        })
      })))
      ssh_authorized_key = optional(list(object({
        description = optional(string)
        key         = string
      })))
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    })), {})
    default_to_oauth_authentication   = optional(bool, null)
    edge_zone                         = optional(string, null)
    https_traffic_only_enabled        = optional(bool, true)
    infrastructure_encryption_enabled = optional(bool, false)
    static_website = optional(map(object({
      error_404_document = optional(string)
      index_document     = optional(string)
    })), null)
    shared_access_key_enabled = optional(bool, true)
    shares = optional(map(object({
      access_tier      = optional(string, "Hot")
      enabled_protocol = optional(string)
      metadata         = optional(map(string))
      name             = string
      quota            = number
      root_squash      = optional(string)
      signed_identifiers = optional(list(object({
        id = string
        access_policy = optional(object({
          expiry_time = string
          permission  = string
          start_time  = string
        }))
      })))
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string, null)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string, null)
        condition_version                      = optional(string, null)
        delegated_managed_identity_resource_id = optional(string, null)
      })), {})
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    })), {})
    min_tls_version = optional(string, "TLS1_2")
    nfsv3_enabled   = optional(bool, false)
    sas_policy = optional(object({
      expiration_action = optional(string, "Log")
      expiration_period = string
    }), null)
    sftp_enabled = optional(bool, false)
    routing = optional(object({
      choice                      = optional(string, "MicrosoftRouting")
      publish_internet_endpoints  = optional(bool, false)
      publish_microsoft_endpoints = optional(bool, false)
    }), null)

  })
  default = {

  }
  description = <<DESCRIPTION
  A map of objects that represent a Storage Account to mount to the Function App.

  - `name` - (Optional) The name of the Storage Account.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the Storage Account in.
  - `account_replication_type` - (Optional) The replication type of the Storage Account. Defaults to `LRS`.
  - `endpoints` - (Optional) A map of objects that represent the endpoints for the Storage Account.
  ```terraform

  ```
  DESCRIPTION
}
