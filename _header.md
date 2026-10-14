# terraform-azurerm-avm-ptn-function-app-storage-private-endpoints

This pattern deploys a Function App with secured storage.

The pattern uses `Azure/avm-res-web-site/azurerm` version `0.24.1`. Existing public authentication, diagnostics, lock-inheritance and site-configuration inputs are translated to its current interface. Private endpoints accept role assignment `name`, lock `notes`, `subresource_name` and IP configuration `member_name` for both the site and deployment slots.

Application Insights is composed separately when enabled and requires `application_insights.workspace_resource_id`. For user-assigned host-storage authentication, set `app_settings.AzureWebJobsStorage__clientId` to the identity's client ID and grant that identity the required storage roles. `storage_key_vault_secret_id` remains a connection-string secret URI; the platform resolves it without a Terraform secret read.

The `resource` output retains `id`, `name`, `default_hostname` and the `identity` collection, including `identity[0].principal_id`. Other provider-specific AzureRM attributes are not guaranteed by the AzAPI resource shape. Output names and sensitivity are unchanged.

## Upgrading from web-site 0.19.3

This is a breaking dependency migration, not a pin-only or state-safe upgrade. Back up state and review the actual resource addresses, IDs, provider conversion support and external DNS ownership in a non-production copy before applying. Addresses below are relative to this pattern; prepend its consumer module address and retain the actual instance keys. No generic migration blocks are supplied.

| Resource | Previous address | Current address / prerequisite |
| --- | --- | --- |
| Main Function App | `module.function_app.azurerm_windows_function_app.this[0]` or `module.function_app.azurerm_linux_function_app.this[0]` | `module.function_app.azapi_resource.this`; select only the actual flavour and validate its provider conversion. |
| Deployment slots | `module.function_app.azurerm_windows_function_app_slot.this["slot"]` or its Linux equivalent | `module.function_app.module.slot["slot"].azapi_resource.this`; review each slot. Slot locks, role assignments and endpoints changed collection boundaries and may require recreation. |
| Private endpoints | `module.function_app.azurerm_private_endpoint.this["endpoint"]` or `module.function_app.azurerm_private_endpoint.this_unmanaged_dns_zone_groups["endpoint"]` | `module.function_app.azapi_resource.private_endpoint["endpoint"]`; the dependency declares a managed-endpoint move only. An unmanaged endpoint is not a DNS zone group and needs a consumer-specific migration. |
| Application Insights | `module.function_app.azurerm_application_insights.this[0]` | `module.application_insights[0].azurerm_application_insights.this`; establish an explicit cross-module migration and supply the workspace ID. |
| Custom-domain certificates | `module.function_app.azurerm_app_service_certificate.this["domain"]` | `module.custom_domain_certificate["domain"].azapi_resource.this`; validate the AzureRM-to-AzAPI conversion. |
| Custom-domain DNS | `module.function_app.azurerm_dns_cname_record.this["domain"]` and `module.function_app.azurerm_dns_txt_record.this["domain"]` | `azapi_resource.custom_domain_cname["domain"]` and `azapi_resource.custom_domain_txt["domain"]`; existing DNS zones remain externally owned. |
| Hostname bindings | `module.function_app.azurerm_app_service_custom_hostname_binding.this["domain"]` or `module.function_app.azurerm_app_service_slot_custom_hostname_binding.slot["domain"]` | `module.custom_domain_binding["domain"].azapi_resource.this`; review each hostname and target site/slot. |
| Slot authentication | Embedded in the previous slot resource | `azapi_update_resource.slot_auth_settings["slot"]` or `slot_auth_settings_v2["slot"]`; configuration is now managed by a separate update resource. |

Follow the dependency's [flavour-specific migration guidance](https://github.com/Azure/terraform-azurerm-avm-res-web-site/tree/v0.24.1#migration-from-earlier-module-versions), but do not treat a move declaration or mocked test as proof of provider-state conversion. Resolve unintended deletion/replacement before applying; explicitly plan any required slot-resource recreation. Supplying a previously ignored endpoint assignment name or subresource can itself change resource identity or require replacement.
