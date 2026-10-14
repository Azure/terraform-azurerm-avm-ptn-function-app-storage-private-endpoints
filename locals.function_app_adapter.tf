locals {
  function_app_parent_id    = "/subscriptions/${data.azapi_client_config.function_app.subscription_id}/resourceGroups/${var.resource_group_name}"
  function_app_storage_name = var.create_secure_storage_account ? module.storage_account[0].name : var.storage_account_name
  existing_storage_access_key = var.storage_account_access_key != null ? var.storage_account_access_key : (
    var.storage_account_primary_connection_string == null ? null : one([
      for part in split(";", var.storage_account_primary_connection_string) :
      substr(part, length("AccountKey="), length(part) - length("AccountKey="))
      if startswith(lower(part), "accountkey=")
    ])
  )
  function_app_storage_access_key = var.create_secure_storage_account ? module.storage_account[0].resource.primary_access_key : local.existing_storage_access_key
  function_app_storage_uses_managed_identity = var.storage_key_vault_secret_id == null && (
    var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0
  )
  function_app_storage_connection_string = var.create_secure_storage_account ? module.storage_account[0].resource.primary_connection_string : (
    var.storage_account_primary_connection_string != null ? var.storage_account_primary_connection_string : (
      local.function_app_storage_name != null && local.function_app_storage_access_key != null ?
      "DefaultEndpointsProtocol=https;AccountName=${local.function_app_storage_name};AccountKey=${local.function_app_storage_access_key};EndpointSuffix=core.windows.net" : null
    )
  )
  function_app_storage_secret_reference  = var.storage_key_vault_secret_id == null ? null : "@Microsoft.KeyVault(SecretUri=${var.storage_key_vault_secret_id})"
  function_app_content_connection_string = local.function_app_storage_secret_reference != null ? local.function_app_storage_secret_reference : local.function_app_storage_connection_string
  function_app_app_settings = merge(
    var.app_settings,
    local.function_app_storage_name == null ? {} : {
      AzureWebJobsStorage__blobServiceUri  = "https://${local.function_app_storage_name}.blob.core.windows.net"
      AzureWebJobsStorage__queueServiceUri = "https://${local.function_app_storage_name}.queue.core.windows.net"
      AzureWebJobsStorage__tableServiceUri = "https://${local.function_app_storage_name}.table.core.windows.net"
    },
    {
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = local.function_app_content_connection_string
      WEBSITE_CONTENTSHARE                     = var.create_secure_storage_account ? coalesce(var.storage_contentshare_name, var.storage_account.name) : var.storage_contentshare_name
      WEBSITE_CONTENTOVERVNET                  = var.content_share_force_disabled ? "0" : "1"
      WEBSITE_VNET_ROUTE_ALL                   = "1"
      AzureWebJobsDashboard                    = var.builtin_logging_enabled ? local.function_app_content_connection_string : ""
    },
    local.function_app_storage_secret_reference == null ? {} : {
      AzureWebJobsStorage = local.function_app_storage_secret_reference
    },
    var.site_config.health_check_eviction_time_in_min == null ? {} : {
      WEBSITE_HEALTHCHECK_MAXPINGFAILURES = tostring(var.site_config.health_check_eviction_time_in_min)
    }
  )
  function_app_insights_connection_string = var.enable_application_insights ? module.application_insights[0].connection_string : var.site_config.application_insights_connection_string
  function_app_insights_key               = var.enable_application_insights ? module.application_insights[0].instrumentation_key : var.site_config.application_insights_key

  legacy_site_configs = merge(
    { root = var.site_config },
    { for key, slot in var.deployment_slots : "slot:${key}" => slot.site_config }
  )
  legacy_application_stacks = {
    for key, config in local.legacy_site_configs : key => one(values(config.application_stack))
  }
  legacy_app_service_logs = {
    for key, config in local.legacy_site_configs : key => one(values(config.app_service_logs))
  }
  site_configs_adapted = {
    for key, config in local.legacy_site_configs : key => merge(config, {
      cors = one(values(config.cors))
      ip_restriction = [
        for restriction in config.ip_restriction : merge(restriction, {
          headers = one(values(restriction.headers))
        })
      ]
      scm_ip_restriction = [
        for restriction in config.scm_ip_restriction : merge(restriction, {
          headers = one(values(restriction.headers))
        })
      ]
      virtual_application = [
        for application in config.virtual_application : merge(application, {
          virtual_directory = values(application.virtual_directory)
        })
      ]
      logs_directory_size_limit = local.legacy_app_service_logs[key] == null ? null : local.legacy_app_service_logs[key].disk_quota_mb
      application_stack = local.legacy_application_stacks[key] == null ? null : {
        dotnet = local.legacy_application_stacks[key].dotnet_version != null || local.legacy_application_stacks[key].use_custom_runtime == true || local.legacy_application_stacks[key].use_dotnet_isolated_runtime == true ? {
          dotnet_version              = local.legacy_application_stacks[key].dotnet_version
          current_stack               = local.legacy_application_stacks[key].current_stack
          use_custom_runtime          = local.legacy_application_stacks[key].use_custom_runtime
          use_dotnet_isolated_runtime = local.legacy_application_stacks[key].use_dotnet_isolated_runtime
        } : null
        java = local.legacy_application_stacks[key].java_version == null ? null : {
          java_version           = local.legacy_application_stacks[key].java_version
          java_container         = local.legacy_application_stacks[key].java_server
          java_container_version = local.legacy_application_stacks[key].java_server_version
        }
        node = local.legacy_application_stacks[key].node_version == null ? null : {
          node_version = local.legacy_application_stacks[key].node_version
        }
        powershell = local.legacy_application_stacks[key].powershell_core_version == null ? null : {
          powershell_version = local.legacy_application_stacks[key].powershell_core_version
        }
        python = local.legacy_application_stacks[key].python_version == null ? null : {
          python_version = local.legacy_application_stacks[key].python_version
        }
        php = local.legacy_application_stacks[key].php_version == null ? null : {
          php_version = local.legacy_application_stacks[key].php_version
        }
        docker = local.legacy_application_stacks[key].docker_image_name != null ? {
          docker_image_name   = local.legacy_application_stacks[key].docker_image_name
          docker_registry_url = local.legacy_application_stacks[key].docker_registry_url
          docker_image_tag    = local.legacy_application_stacks[key].docker_container_tag
          } : (
          local.legacy_application_stacks[key].docker == null ? null : {
            docker_image_name   = one(local.legacy_application_stacks[key].docker).image_name
            docker_registry_url = one(local.legacy_application_stacks[key].docker).registry_url
            docker_image_tag    = one(local.legacy_application_stacks[key].docker).image_tag
          }
        )
      }
    })
  }
  auto_heal_raw = one(values(var.auto_heal_setting))
  auto_heal_rules_adapted = local.auto_heal_raw == null ? null : {
    actions = local.auto_heal_raw.action == null ? null : {
      action_type                = local.auto_heal_raw.action.action_type
      min_process_execution_time = local.auto_heal_raw.action.minimum_process_execution_time
      custom_action = local.auto_heal_raw.action.custom_action == null ? null : {
        exe        = local.auto_heal_raw.action.custom_action.executable
        parameters = local.auto_heal_raw.action.custom_action.parameters
      }
    }
    triggers = local.auto_heal_raw.trigger == null ? null : {
      private_bytes_in_kb = local.auto_heal_raw.trigger.private_memory_kb
      requests = length(local.auto_heal_raw.trigger.requests) == 0 ? null : {
        count         = one(values(local.auto_heal_raw.trigger.requests)).count
        time_interval = one(values(local.auto_heal_raw.trigger.requests)).interval
      }
      slow_requests = length(local.auto_heal_raw.trigger.slow_request) == 0 ? null : {
        count         = one(values(local.auto_heal_raw.trigger.slow_request)).count
        time_interval = one(values(local.auto_heal_raw.trigger.slow_request)).interval
        time_taken    = one(values(local.auto_heal_raw.trigger.slow_request)).time_taken
        path          = one(values(local.auto_heal_raw.trigger.slow_request)).path
      }
      slow_requests_with_path = [
        for request in local.auto_heal_raw.trigger.slow_request_with_path : {
          count         = request.count
          time_interval = request.interval
          time_taken    = request.time_taken
          path          = request.path
        }
      ]
      status_codes = [
        for status in local.auto_heal_raw.trigger.status_code : {
          count         = status.count
          time_interval = status.interval
          status        = status.status_code_range
          path          = status.path
          sub_status    = status.sub_status
          win32_status  = status.win32_status_code
        }
      ]
    }
  }
  function_app_site_config = merge(local.site_configs_adapted.root, {
    auto_heal_rules                        = local.auto_heal_rules_adapted
    application_insights_connection_string = local.function_app_insights_connection_string
    application_insights_key               = local.function_app_insights_key
  })

  auth_settings_raw = merge(
    { root = var.auth_settings },
    {
      for key, slot in var.deployment_slots : "slot:${key}" => {
        for auth_key, auth in slot.auth_settings : auth_key => merge(auth, {
          additional_login_parameters = auth.additional_login_parameters == null ? null : {
            for parameter in auth.additional_login_parameters :
            split("=", parameter)[0] => join("=", slice(split("=", parameter), 1, length(split("=", parameter))))
          }
        })
      }
    }
  )
  auth_settings_adapted = {
    for key, settings in local.auth_settings_raw : key => length(settings) == 0 ? null : merge(one(values(settings)), {
      active_directory = one(values(coalesce(one(values(settings)).active_directory, {})))
      facebook         = one(values(coalesce(one(values(settings)).facebook, {})))
      github           = one(values(coalesce(one(values(settings)).github, {})))
      google           = one(values(coalesce(one(values(settings)).google, {})))
      microsoft        = one(values(coalesce(one(values(settings)).microsoft, {})))
      twitter          = one(values(coalesce(one(values(settings)).twitter, {})))
    })
  }
  auth_settings_v2_raw = merge(
    { root = one(values(var.auth_settings_v2)) },
    { for key, slot in var.deployment_slots : "slot:${key}" => one(values(slot.auth_settings_v2)) }
  )
  auth_settings_v2_adapted = {
    for key, auth in local.auth_settings_v2_raw : key => auth == null ? null : {
      auth_enabled                           = auth.auth_enabled
      config_file_path                       = auth.config_file_path
      excluded_paths                         = auth.excluded_paths
      forward_proxy_convention               = auth.forward_proxy_convention
      forward_proxy_custom_host_header_name  = auth.forward_proxy_custom_host_header_name
      forward_proxy_custom_proto_header_name = auth.forward_proxy_custom_scheme_header_name
      http_route_api_prefix                  = auth.http_route_api_prefix
      redirect_to_provider                   = auth.default_provider
      require_authentication                 = auth.require_authentication
      require_https                          = auth.require_https
      runtime_version                        = auth.runtime_version
      unauthenticated_client_action          = auth.unauthenticated_action
      identity_providers = {
        apple = length(auth.apple_v2) == 0 ? null : {
          enabled = true
          login   = { scopes = one(values(auth.apple_v2)).login_scopes }
          registration = {
            client_id                  = one(values(auth.apple_v2)).client_id
            client_secret_setting_name = one(values(auth.apple_v2)).client_secret_setting_name
          }
        }
        azure_active_directory = length(auth.active_directory_v2) == 0 ? null : {
          enabled = true
          login = {
            disable_www_authenticate = one(values(auth.active_directory_v2)).www_authentication_disabled
            login_parameters = [
              for name, value in coalesce(one(values(auth.active_directory_v2)).login_parameters, {}) : "${name}=${value}"
            ]
          }
          registration = {
            client_id                            = one(values(auth.active_directory_v2)).client_id
            client_secret_certificate_thumbprint = one(values(auth.active_directory_v2)).client_secret_certificate_thumbprint
            client_secret_setting_name           = one(values(auth.active_directory_v2)).client_secret_setting_name
            open_id_issuer                       = one(values(auth.active_directory_v2)).tenant_auth_endpoint
          }
          validation = {
            allowed_audiences = one(values(auth.active_directory_v2)).allowed_audiences
            default_authorization_policy = {
              allowed_applications = one(values(auth.active_directory_v2)).allowed_applications
              allowed_principals = {
                groups     = one(values(auth.active_directory_v2)).allowed_groups
                identities = one(values(auth.active_directory_v2)).allowed_identities
              }
            }
            jwt_claim_checks = {
              allowed_client_applications = one(values(auth.active_directory_v2)).jwt_allowed_client_applications
              allowed_groups              = one(values(auth.active_directory_v2)).jwt_allowed_groups
            }
          }
        }
        azure_static_web_apps = length(auth.azure_static_web_app_v2) == 0 ? null : {
          enabled      = true
          registration = { client_id = one(values(auth.azure_static_web_app_v2)).client_id }
        }
        custom_open_id_connect_providers = {
          for provider_key, provider in auth.custom_oidc_v2 : coalesce(provider.name, provider_key) => {
            enabled = true
            login = {
              name_claim_type = provider.name_claim_type
              scopes          = provider.scopes
            }
            registration = {
              client_id = provider.client_id
              client_credential = {
                method                     = provider.client_credential_method
                client_secret_setting_name = provider.client_secret_setting_name
              }
              open_id_connect_configuration = {
                authorization_endpoint           = provider.authorisation_endpoint
                certification_uri                = provider.certification_uri
                issuer                           = provider.issuer_endpoint
                token_endpoint                   = provider.token_endpoint
                well_known_open_id_configuration = provider.openid_configuration_endpoint
              }
            }
          }
        }
        facebook = length(auth.facebook_v2) == 0 ? null : {
          enabled           = true
          graph_api_version = one(values(auth.facebook_v2)).graph_api_version
          login             = { scopes = one(values(auth.facebook_v2)).login_scopes }
          registration = {
            app_id                  = one(values(auth.facebook_v2)).app_id
            app_secret_setting_name = one(values(auth.facebook_v2)).app_secret_setting_name
          }
        }
        github = length(auth.github_v2) == 0 ? null : {
          enabled = true
          login   = { scopes = one(values(auth.github_v2)).login_scopes }
          registration = {
            client_id                  = one(values(auth.github_v2)).client_id
            client_secret_setting_name = one(values(auth.github_v2)).client_secret_setting_name
          }
        }
        google = length(auth.google_v2) == 0 ? null : {
          enabled    = true
          login      = { scopes = one(values(auth.google_v2)).login_scopes }
          validation = { allowed_audiences = one(values(auth.google_v2)).allowed_audiences }
          registration = {
            client_id                  = one(values(auth.google_v2)).client_id
            client_secret_setting_name = one(values(auth.google_v2)).client_secret_setting_name
          }
        }
        legacy_microsoft_account = length(auth.microsoft_v2) == 0 ? null : {
          enabled    = true
          login      = { scopes = one(values(auth.microsoft_v2)).login_scopes }
          validation = { allowed_audiences = one(values(auth.microsoft_v2)).allowed_audiences }
          registration = {
            client_id                  = one(values(auth.microsoft_v2)).client_id
            client_secret_setting_name = one(values(auth.microsoft_v2)).client_secret_setting_name
          }
        }
        twitter = length(auth.twitter_v2) == 0 ? null : {
          enabled = true
          registration = {
            consumer_key                 = one(values(auth.twitter_v2)).consumer_key
            consumer_secret_setting_name = one(values(auth.twitter_v2)).consumer_secret_setting_name
          }
        }
      }
      login = length(auth.login) == 0 ? null : {
        allowed_external_redirect_urls = one(values(auth.login)).allowed_external_redirect_urls
        cookie_expiration = {
          convention         = one(values(auth.login)).cookie_expiration_convention
          time_to_expiration = one(values(auth.login)).cookie_expiration_time
        }
        nonce = {
          nonce_expiration_interval = one(values(auth.login)).nonce_expiration_time
          validate_nonce            = one(values(auth.login)).validate_nonce
        }
        preserve_url_fragments_for_logins = one(values(auth.login)).preserve_url_fragments_for_logins
        routes                            = { logout_endpoint = one(values(auth.login)).logout_endpoint }
        token_store = {
          enabled                       = one(values(auth.login)).token_store_enabled
          token_refresh_extension_hours = one(values(auth.login)).token_refresh_extension_time
          azure_blob_storage            = { sas_url_setting_name = one(values(auth.login)).token_store_sas_setting_name }
          file_system                   = { directory = one(values(auth.login)).token_store_path }
        }
      }
    }
  }

  private_endpoint_scopes = merge(
    { root = var.private_endpoints },
    { for key, slot in var.deployment_slots : "slot:${key}" => slot.private_endpoints }
  )
  slot_locks_adapted = {
    for key, slot in var.deployment_slots : key => (
      (var.all_child_resources_inherit_lock || var.deployment_slots_inherit_lock) && var.lock != null ? {
        kind = var.lock.kind
        name = try(slot.lock.name, null) != null ? slot.lock.name : "lock-${coalesce(slot.name, "slot-${var.name}")}"
      } : slot.lock
    )
  }
  private_endpoint_parent_locks = merge(
    { root = var.lock },
    { for key, lock in local.slot_locks_adapted : "slot:${key}" => lock }
  )
  private_endpoints_adapted = {
    for scope, endpoints in local.private_endpoint_scopes : scope => {
      for key, endpoint in endpoints : key => merge(endpoint, {
        name                            = coalesce(endpoint.name, "pep-${var.name}")
        private_service_connection_name = coalesce(endpoint.private_service_connection_name, "pse-${var.name}")
        tags                            = var.all_child_resources_inherit_tags ? merge(var.tags, endpoint.tags) : endpoint.tags
        lock = endpoint.lock != null || (
          (var.all_child_resources_inherit_lock || var.private_endpoints_inherit_lock) && local.private_endpoint_parent_locks[scope] != null
          ) ? {
          kind = (var.all_child_resources_inherit_lock || var.private_endpoints_inherit_lock) && local.private_endpoint_parent_locks[scope] != null ? local.private_endpoint_parent_locks[scope].kind : endpoint.lock.kind
          name = try(endpoint.lock.name, null) != null ? endpoint.lock.name : (
            endpoint.name == null ? "lock-pe-${var.name}" : "lock-${endpoint.name}"
          )
          notes = endpoint.lock == null ? null : endpoint.lock.notes
        } : null
        ip_configurations = {
          for ip_key, ip in endpoint.ip_configurations : ip_key => merge(ip, {
            member_name = ip.member_name != null ? ip.member_name : (
              endpoint.subresource_name != null ? endpoint.subresource_name : (
                scope == "root" ? "sites" : "sites-${coalesce(var.deployment_slots[trimprefix(scope, "slot:")].name, trimprefix(scope, "slot:"))}"
              )
            )
          })
        }
      })
    }
  }
  diagnostic_settings_adapted = {
    for key, setting in var.diagnostic_settings : key => merge(setting, {
      logs = concat(
        [for category in setting.log_categories : { category = category }],
        [for group in setting.log_groups : { category_group = group }]
      )
      metrics = [for category in setting.metric_categories : { category = category }]
    })
  }
  logs_adapted = {
    for key, setting in var.logs : key => merge(setting, {
      failed_requests_tracing = setting.failed_request_tracing
      application_logs = {
        for log_key, log in setting.application_logs : log_key => merge(log, {
          file_system = { level = log.file_system_level }
        })
      }
      http_logs = {
        for log_key, log in setting.http_logs : log_key => {
          azure_blob_storage = log.azure_blob_storage_http
          file_system        = log.file_system
        }
      }
    })
  }
  deployment_slots_adapted = {
    for key, slot in var.deployment_slots : key => merge(slot, {
      app_settings = merge(
        coalesce(slot.app_settings, {}),
        local.function_app_storage_secret_reference == null ? {} : { AzureWebJobsStorage = local.function_app_storage_secret_reference },
        { FUNCTIONS_EXTENSION_VERSION = slot.functions_extension_version }
      )
      key_vault_reference_identity                   = slot.key_vault_reference_identity_id
      server_farm_id                                 = slot.service_plan_id
      private_endpoints                              = local.private_endpoints_adapted["slot:${key}"]
      lock                                           = local.slot_locks_adapted[key]
      ftp_publish_basic_authentication_enabled       = slot.site_config.ftps_state == "Disabled" ? false : slot.ftp_publish_basic_authentication_enabled
      webdeploy_publish_basic_authentication_enabled = slot.site_config.ftps_state == "Disabled" ? false : slot.webdeploy_publish_basic_authentication_enabled
      site_config = merge(local.site_configs_adapted["slot:${key}"], {
        application_insights_connection_string = slot.site_config.application_insights_connection_string != null ? slot.site_config.application_insights_connection_string : local.function_app_insights_connection_string
        application_insights_key               = slot.site_config.application_insights_key != null ? slot.site_config.application_insights_key : local.function_app_insights_key
      })
      vnet_content_share_enabled = !slot.content_share_force_disabled
    })
  }
  function_app_resource = merge(module.function_app.resource, {
    default_hostname = module.function_app.resource_uri
    identity = var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0 ? [{
      type         = var.managed_identities.system_assigned ? (length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned") : "UserAssigned"
      identity_ids = var.managed_identities.user_assigned_resource_ids
      principal_id = module.function_app.system_assigned_mi_principal_id
      tenant_id    = data.azapi_client_config.function_app.tenant_id
    }] : []
  })
}
