mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_id          = "00000000-0000-0000-0000-000000000001"
      tenant_id                = "00000000-0000-0000-0000-000000000002"
      client_id                = "00000000-0000-0000-0000-000000000003"
      object_id                = "00000000-0000-0000-0000-000000000004"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001"
    }
  }
  mock_data "azapi_resource_list" {
    defaults = {
      output = { value = [], results = [] }
    }
  }
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/sites/function-wrapper"
      output = {
        identity = {
          principalId = "00000000-0000-0000-0000-000000000005"
        }
        properties = {
          defaultHostName            = "function-wrapper.azurewebsites.net"
          customDomainVerificationId = "fake-verification-id"
          thumbprint                 = "0011223344556677889900112233445566778899"
        }
      }
    }
  }
}

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000001"
      tenant_id       = "00000000-0000-0000-0000-000000000002"
      client_id       = "00000000-0000-0000-0000-000000000003"
      object_id       = "00000000-0000-0000-0000-000000000004"
    }
  }
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Storage/storageAccounts/wrapperstorage"
      primary_access_key        = "ZmFrZS13cmFwcGVyLWtleQ=="
      primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=wrapperstorage;AccountKey=ZmFrZS13cmFwcGVyLWtleQ==;EndpointSuffix=core.windows.net"
    }
  }
  mock_resource "azurerm_application_insights" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Insights/components/ai-function-wrapper"
      connection_string   = "InstrumentationKey=00000000-0000-0000-0000-000000000006;IngestionEndpoint=https://fake.applicationinsights.azure.com/"
      instrumentation_key = "00000000-0000-0000-0000-000000000006"
    }
  }
}

mock_provider "modtm" {
  mock_data "modtm_module_source" {
    defaults = {
      module_source  = "registry.terraform.io/Azure/avm-ptn-function-app-storage-private-endpoints/azurerm"
      module_version = "0.0.0"
    }
  }
}

mock_provider "random" {}

mock_provider "time" {}

variables {
  location                                  = "eastus"
  name                                      = "function-wrapper"
  os_type                                   = "Windows"
  resource_group_name                       = "rg-wrapper"
  create_service_plan                       = false
  create_secure_storage_account             = false
  service_plan_resource_id                  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/serverFarms/plan-wrapper"
  storage_account_name                      = "wrapperstorage"
  storage_account_primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=wrapperstorage;AccountKey=ZmFrZS13cmFwcGVyLWtleQ==;EndpointSuffix=core.windows.net"
  storage_contentshare_name                 = "wrapper-content"
  enable_application_insights               = false
  enable_telemetry                          = true
}

run "existing_resources_windows" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  assert {
    condition     = module.function_app.resource.parent_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper"
    error_message = "The existing public resource-group name must be translated to the required parent_id."
  }
  assert {
    condition     = output.name == "function-wrapper" && output.resource_id == module.function_app.resource_id && output.resource.id == output.resource_id
    error_message = "The public name, resource and resource_id outputs must retain consistent resource identity."
  }
  assert {
    condition     = length(output.resource.identity) == 0 && output.resource.default_hostname == "function-wrapper.azurewebsites.net"
    error_message = "The legacy identity collection shape and default hostname must remain usable."
  }
  assert {
    condition     = local.function_app_storage_access_key == "ZmFrZS13cmFwcGVyLWtleQ==" && local.function_app_app_settings.WEBSITE_CONTENTSHARE == "wrapper-content"
    error_message = "A connection string must supply its AccountKey rather than being used as an access key itself."
  }
  assert {
    condition     = module.function_app.resource.body.properties.outboundVnetRouting.contentShareTraffic == true && length(module.application_insights) == 0
    error_message = "Content-share routing and the disabled Application Insights control must retain their intended behavior."
  }
}

run "managed_identity_linux" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  variables {
    os_type = "Linux"
    managed_identities = {
      system_assigned = true
    }
  }
  assert {
    condition     = local.function_app_storage_uses_managed_identity && output.resource.identity[0].principal_id == "00000000-0000-0000-0000-000000000005"
    error_message = "The managed-identity storage path and consumed identity[0].principal_id output must remain intact."
  }
  assert {
    condition     = local.system_assigned_storage_account_role_assignment_default_helper.storage_blob_data_owner.principal_id == "00000000-0000-0000-0000-000000000005"
    error_message = "Storage-role propagation must use the actual current-module identity principal output."
  }
}

run "root_endpoint_fields_managed" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  variables {
    all_child_resources_inherit_lock = false
    private_endpoints_inherit_lock   = false
    private_endpoints = {
      primary = {
        name                = "pe-wrapper"
        subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Network/virtualNetworks/vnet-wrapper/subnets/endpoints"
        subresource_name    = "sites-staging"
        resource_group_name = "rg-endpoints"
        location            = "westus2"
        private_dns_zone_resource_ids = [
          "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
        ]
        lock = {
          kind  = "ReadOnly"
          name  = "lock-wrapper-endpoint"
          notes = "Wrapper endpoint notes"
        }
        role_assignments = {
          reader = {
            name                       = "00000000-0000-0000-0000-000000000007"
            role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000001/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
            principal_id               = "00000000-0000-0000-0000-000000000004"
          }
        }
        ip_configurations = {
          primary = {
            name               = "static-v4"
            private_ip_address = "10.0.0.5"
            member_name        = "sites-staging-member"
          }
        }
      }
    }
  }
  assert {
    condition     = module.function_app.private_endpoints.primary.body.properties.privateLinkServiceConnections[0].properties.groupIds[0] == "sites-staging"
    error_message = "The wrapper's service field must survive both the wrapper and exact current-owner input boundaries."
  }
  assert {
    condition     = module.function_app.private_endpoints.primary.body.properties.ipConfigurations[0].properties.memberName == "sites-staging-member"
    error_message = "The explicit IP member field must reach the current endpoint ARM body."
  }
  assert {
    condition     = local.private_endpoints_adapted.root.primary.role_assignments.reader.name == "00000000-0000-0000-0000-000000000007" && local.private_endpoints_adapted.root.primary.lock.notes == "Wrapper endpoint notes"
    error_message = "Endpoint assignment names and lock notes must not be lost in wrapper normalization."
  }
  assert {
    condition     = module.function_app.private_endpoints.primary.parent_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-endpoints"
    error_message = "The public bare endpoint resource-group override must be preserved."
  }
}

run "root_endpoint_fields_unmanaged" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  variables {
    private_endpoints_manage_dns_zone_group = false
    private_endpoints = {
      primary = {
        subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Network/virtualNetworks/vnet-wrapper/subnets/endpoints"
        ip_configurations = {
          primary = {
            name               = "static-v4"
            private_ip_address = "10.0.0.5"
          }
        }
      }
    }
  }
  assert {
    condition     = module.function_app.private_endpoints.primary.name == "pep-function-wrapper" && module.function_app.private_endpoints.primary.body.properties.privateLinkServiceConnections[0].name == "pse-function-wrapper"
    error_message = "Existing generated endpoint and connection names must be retained."
  }
  assert {
    condition     = module.function_app.private_endpoints.primary.body.properties.ipConfigurations[0].properties.memberName == "sites"
    error_message = "Omitted IP member names must retain the wrapper's sites default."
  }
}

run "application_insights_composition" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  variables {
    enable_application_insights = true
    application_insights = {
      name                  = "ai-wrapper-custom"
      location              = "westus2"
      resource_group_name   = "rg-monitoring"
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/workspace-wrapper"
      retention_in_days     = 120
      sampling_percentage   = 50
      inherit_tags          = true
      tags                  = { component = "insights" }
    }
    tags = { owner = "wrapper" }
  }
  assert {
    condition     = length(module.application_insights) == 1 && module.application_insights[0].resource.name == "ai-wrapper-custom" && module.application_insights[0].resource.location == "westus2"
    error_message = "Enabled Application Insights must still create the requested component with its location/name overrides."
  }
  assert {
    condition     = module.application_insights[0].resource.resource_group_name == "rg-monitoring" && module.application_insights[0].resource.retention_in_days == 120 && module.application_insights[0].resource.sampling_percentage == 50
    error_message = "Component scope, retention and sampling behavior must be preserved."
  }
  assert {
    condition     = module.application_insights[0].resource.tags.owner == "wrapper" && module.application_insights[0].resource.tags.component == "insights"
    error_message = "Application Insights tag inheritance must retain the public input's merge semantics."
  }
  assert {
    condition     = local.function_app_site_config.application_insights_key == "00000000-0000-0000-0000-000000000006"
    error_message = "The created instrumentation key must be forwarded to the current Function App."
  }
}

run "key_vault_storage_reference" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  variables {
    storage_key_vault_secret_id     = "https://fixture.vault.azure.net/secrets/storage-connection/00000000000000000000000000000001"
    key_vault_reference_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.ManagedIdentity/userAssignedIdentities/vault-reader"
    managed_identities = {
      user_assigned_resource_ids = [
        "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.ManagedIdentity/userAssignedIdentities/vault-reader"
      ]
    }
  }
  assert {
    condition     = local.function_app_app_settings.AzureWebJobsStorage == "@Microsoft.KeyVault(SecretUri=https://fixture.vault.azure.net/secrets/storage-connection/00000000000000000000000000000001)"
    error_message = "The previously advertised Key Vault storage connection must be represented as a platform reference, without a secret read."
  }
  assert {
    condition     = !local.function_app_storage_uses_managed_identity && module.function_app.resource.body.properties.keyVaultReferenceIdentity == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.ManagedIdentity/userAssignedIdentities/vault-reader"
    error_message = "The Key Vault reference identity must not silently turn the connection-string host path into managed-identity host storage."
  }
}

run "nested_site_and_auth_v1" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  variables {
    auth_settings = {
      main = {
        enabled = true
        active_directory = {
          main = { client_id = "00000000-0000-0000-0000-000000000008" }
        }
      }
    }
    site_config = {
      ftps_state = "FtpsOnly"
      application_stack = {
        main = { node_version = "~20" }
      }
      cors = {
        main = { allowed_origins = ["https://fixture.example"] }
      }
      ip_restriction = {
        main = {
          name       = "trusted"
          ip_address = "10.0.0.0/24"
          headers = {
            main = { x_forwarded_host = ["fixture.example"] }
          }
        }
      }
    }
    auto_heal_setting = {
      main = {
        action = { action_type = "Recycle" }
        trigger = {
          requests = {
            main = { count = 20, interval = "00:01:00" }
          }
        }
      }
    }
  }
  assert {
    condition     = local.auth_settings_adapted.root.active_directory.client_id == "00000000-0000-0000-0000-000000000008" && local.function_app_site_config.application_stack.node.node_version == "~20"
    error_message = "Legacy named authentication/runtime maps must be translated to the current typed object shapes."
  }
  assert {
    condition     = local.function_app_site_config.cors.allowed_origins[0] == "https://fixture.example" && local.function_app_site_config.ip_restriction[0].headers.x_forwarded_host[0] == "fixture.example"
    error_message = "CORS and restriction headers must not be silently discarded during map-to-object/list conversion."
  }
  assert {
    condition     = local.function_app_site_config.auto_heal_rules.triggers.requests.count == 20 && local.function_app_site_config.auto_heal_rules.triggers.requests.time_interval == "00:01:00"
    error_message = "The unsupported top-level auto-heal argument must reach the current nested rule shape."
  }
}

run "auth_v2_diagnostics_and_slot" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  override_resource {
    target = module.function_app.module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/sites/function-wrapper/slots/staging"
    }
  }
  variables {
    auth_settings_v2 = {
      main = {
        auth_enabled                            = true
        default_provider                        = "azureactivedirectory"
        forward_proxy_custom_scheme_header_name = "X-Forwarded-Proto"
        active_directory_v2 = {
          main = {
            client_id            = "00000000-0000-0000-0000-000000000008"
            tenant_auth_endpoint = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000002/v2.0"
            login_parameters     = { prompt = "select_account" }
          }
        }
        login = {
          main = { token_store_enabled = true }
        }
      }
    }
    diagnostic_settings = {
      main = {
        workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.OperationalInsights/workspaces/workspace-wrapper"
        log_categories        = ["FunctionAppLogs"]
        log_groups            = []
        metric_categories     = ["AllMetrics"]
      }
    }
    deployment_slots = {
      staging = {
        name                            = "staging"
        key_vault_reference_identity_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.ManagedIdentity/userAssignedIdentities/vault-reader"
        site_config = {
          application_stack = {
            main = { node_version = "~20" }
          }
        }
      }
    }
  }
  assert {
    condition     = local.auth_settings_v2_adapted.root.redirect_to_provider == "azureactivedirectory" && local.auth_settings_v2_adapted.root.forward_proxy_custom_proto_header_name == "X-Forwarded-Proto"
    error_message = "Auth V2 renamed routing/proxy fields must retain their public caller meaning."
  }
  assert {
    condition     = local.auth_settings_v2_adapted.root.identity_providers.azure_active_directory.registration.client_id == "00000000-0000-0000-0000-000000000008" && local.auth_settings_v2_adapted.root.login.token_store.enabled
    error_message = "Legacy Auth V2 provider/login maps must reach the ARM-shaped current interface."
  }
  assert {
    condition     = local.diagnostic_settings_adapted.main.logs[0].category == "FunctionAppLogs" && local.diagnostic_settings_adapted.main.metrics[0].category == "AllMetrics"
    error_message = "Legacy diagnostic category sets must produce current V2 logs and metrics rather than disappearing."
  }
  assert {
    condition     = module.function_app.deployment_slots.staging.name == "staging" && local.deployment_slots_adapted.staging.key_vault_reference_identity == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.ManagedIdentity/userAssignedIdentities/vault-reader"
    error_message = "Slot names and supported slot identity settings must survive the current nested boundary."
  }
}

run "inherited_locks_and_slot_endpoint" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  override_resource {
    target = module.function_app.module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/sites/function-wrapper/slots/staging"
    }
  }
  variables {
    all_child_resources_inherit_lock = true
    private_endpoints_inherit_lock   = false
    deployment_slots_inherit_lock    = false
    lock                             = { kind = "CanNotDelete", name = "lock-parent" }
    deployment_slots = {
      staging = {
        name = "staging"
        lock = { kind = "ReadOnly", name = "lock-staging" }
        private_endpoints = {
          primary = {
            name               = "pe-staging"
            subnet_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Network/virtualNetworks/vnet-wrapper/subnets/endpoints"
            subresource_name   = "sites-staging"
            lock = {
              kind  = "ReadOnly"
              name  = "lock-staging-endpoint"
              notes = "Inherited slot endpoint"
            }
            role_assignments = {
              reader = {
                name                       = "00000000-0000-0000-0000-000000000009"
                role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000001/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
                principal_id               = "00000000-0000-0000-0000-000000000004"
              }
            }
          }
        }
      }
    }
  }
  assert {
    condition     = local.deployment_slots_adapted.staging.lock.kind == "CanNotDelete" && local.deployment_slots_adapted.staging.private_endpoints.primary.lock.kind == "CanNotDelete"
    error_message = "The removed all_child_resources_inherit_lock argument must still control slot and endpoint lock levels."
  }
  assert {
    condition     = local.deployment_slots_adapted.staging.private_endpoints.primary.lock.notes == "Inherited slot endpoint" && local.deployment_slots_adapted.staging.private_endpoints.primary.role_assignments.reader.name == "00000000-0000-0000-0000-000000000009"
    error_message = "All endpoint fields must survive the wrapper's nested slot schema and inheritance adapter."
  }
}

run "custom_domain_dns_certificate_and_slot" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  override_resource {
    target = module.function_app.module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/sites/function-wrapper/slots/staging"
    }
  }
  variables {
    deployment_slots = { staging = { name = "staging" } }
    custom_domains = {
      main = {
        hostname             = "app.fixture.example"
        ssl_state            = "SniEnabled"
        create_certificate   = true
        certificate_name     = "cert-wrapper"
        certificate_location = "eastus"
        resource_group_name  = "rg-wrapper"
        pfx_blob             = "ZmFrZS1wZng="
        thumbprint_key       = "main"
        create_cname_records = true
        cname_name           = "app"
        cname_zone_name      = "fixture.example"
        cname_record         = "function-wrapper.azurewebsites.net"
        create_txt_records   = true
        txt_name             = "asuid.app"
        txt_zone_name        = "fixture.example"
        txt_records          = { verification = { value = "" } }
        ttl                  = 600
      }
      slot = {
        hostname             = "stage.fixture.example"
        slot_as_target       = true
        app_service_slot_key = "staging"
        ssl_state            = "SniEnabled"
        thumbprint_key       = "main"
      }
    }
  }
  assert {
    condition     = azapi_resource.custom_domain_cname["main"].body.properties.CNAMERecord.cname == "function-wrapper.azurewebsites.net" && azapi_resource.custom_domain_cname["main"].body.properties.TTL == 600
    error_message = "Requested CNAME creation and TTL must not disappear in the current owner interface."
  }
  assert {
    condition     = azapi_resource.custom_domain_txt["main"].body.properties.TXTRecords[0].value[0] == "fake-verification-id"
    error_message = "An empty verification TXT value must still use the site's actual verification output."
  }
  assert {
    condition     = module.custom_domain_certificate["main"].name == "cert-wrapper" && local.custom_domain_bindings.slot.thumbprint == "0011223344556677889900112233445566778899"
    error_message = "Certificate creation and shared thumbprint-key references must remain connected."
  }
}

run "slot_authentication_v1" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  override_resource {
    target = module.function_app.module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/sites/function-wrapper/slots/staging"
    }
  }
  variables {
    deployment_slots = {
      staging = {
        name = "staging"
        auth_settings = {
          main = {
            enabled                     = true
            additional_login_parameters = ["domain=fixture"]
            active_directory = {
              main = { client_id = "00000000-0000-0000-0000-000000000008" }
            }
          }
        }
      }
    }
  }
  assert {
    condition     = azapi_update_resource.slot_auth_settings["staging"].body.properties.enabled && azapi_update_resource.slot_auth_settings["staging"].body.properties.clientId == "00000000-0000-0000-0000-000000000008"
    error_message = "Working public slot authentication must not be dropped by the current slot schema."
  }
  assert {
    condition     = azapi_update_resource.slot_auth_settings["staging"].parent_id == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/sites/function-wrapper/slots/staging"
    error_message = "Slot authentication must target the actual slot, never the main site."
  }
}

run "slot_authentication_v2_with_insights" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  override_resource {
    target = module.function_app.module.slot["staging"].azapi_resource.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/sites/function-wrapper/slots/staging"
    }
  }
  variables {
    enable_application_insights = true
    application_insights = {
      workspace_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.OperationalInsights/workspaces/workspace-wrapper"
    }
    deployment_slots = {
      staging = {
        name = "staging"
        auth_settings_v2 = {
          main = {
            auth_enabled     = true
            default_provider = "azureactivedirectory"
            active_directory_v2 = {
              main = {
                client_id            = "00000000-0000-0000-0000-000000000008"
                tenant_auth_endpoint = "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000002/v2.0"
              }
            }
            facebook_v2 = {
              main = { app_id = "123", app_secret_setting_name = "FacebookSecret" }
            }
            login = {
              main = { token_store_enabled = true }
            }
          }
        }
      }
    }
  }
  assert {
    condition     = azapi_update_resource.slot_auth_settings_v2["staging"].body.properties.platform.enabled && azapi_update_resource.slot_auth_settings_v2["staging"].body.properties.identityProviders.azureActiveDirectory.registration.clientId == "00000000-0000-0000-0000-000000000008"
    error_message = "Slot Auth V2 provider registration must retain the public legacy input meaning."
  }
  assert {
    condition     = azapi_update_resource.slot_auth_settings_v2["staging"].body.properties.login.tokenStore.enabled && local.deployment_slots_adapted.staging.site_config.application_insights_key == "00000000-0000-0000-0000-000000000006"
    error_message = "Slot login/token storage and Application Insights integration must work together."
  }
}

run "created_storage_and_plan" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  override_resource {
    target = module.service_plan[0].azurerm_service_plan.this
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/serverFarms/created-plan-wrapper"
    }
  }
  override_resource {
    target = module.storage_account[0].azurerm_storage_account.this
    values = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Storage/storageAccounts/createdwrapperstorage"
      primary_access_key        = "ZmFrZS1jcmVhdGVkLXN0b3JhZ2Uta2V5"
      primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=createdwrapperstorage;AccountKey=ZmFrZS1jcmVhdGVkLXN0b3JhZ2Uta2V5;EndpointSuffix=core.windows.net"
    }
  }
  override_data {
    target = module.service_plan[0].data.azurerm_location.region
    values = {
      zone_mappings = [
        { logical_zone = "1", physical_zone = "eastus-az1" },
        { logical_zone = "2", physical_zone = "eastus-az2" },
        { logical_zone = "3", physical_zone = "eastus-az3" }
      ]
    }
  }
  variables {
    create_secure_storage_account        = true
    create_service_plan                  = true
    private_endpoint_subnet_resource_id  = "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Network/virtualNetworks/vnet-wrapper/subnets/endpoints"
    private_dns_zone_subscription_id     = "00000000-0000-0000-0000-000000000001"
    private_dns_zone_resource_group_name = "rg-wrapper"
    storage_account = {
      name = "createdwrapperstorage"
    }
    service_plan = {
      name = "created-plan-wrapper"
    }
    managed_identities = {
      system_assigned = true
    }
  }
  assert {
    condition     = length(module.storage_account) == 1 && length(module.service_plan) == 1 && local.function_app_storage_access_key == "ZmFrZS1jcmVhdGVkLXN0b3JhZ2Uta2V5"
    error_message = "Created storage must supply its actual access key, not its connection string."
  }
  assert {
    condition     = module.function_app.resource.body.properties.serverFarmId == "/subscriptions/00000000-0000-0000-0000-000000000001/resourceGroups/rg-wrapper/providers/Microsoft.Web/serverfarms/created-plan-wrapper"
    error_message = "The created service plan must remain connected to the current Function App."
  }
  assert {
    condition     = local.function_app_app_settings.WEBSITE_CONTENTAZUREFILECONNECTIONSTRING == module.storage_account[0].resource.primary_connection_string && output.resource.identity[0].principal_id == "00000000-0000-0000-0000-000000000005"
    error_message = "Content-share configuration and storage-role identity propagation must remain connected for created resources."
  }
}

run "disabled_insights_accepts_null_settings" {
  command = apply
  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }
  variables {
    application_insights = null
  }
  assert {
    condition     = length(module.application_insights) == 0 && local.function_app_site_config.application_insights_key == null
    error_message = "Disabled Application Insights must accept an omitted or null optional settings object."
  }
}
