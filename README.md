<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-ptn-function-app-storage-private-endpoints

This is the pattern module to deply function app with secured storage.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.10)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0, >= 4.8.0, >= 4.21.1, < 5.0.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_update_resource.this](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the this resource.

Type: `string`

### <a name="input_os_type"></a> [os\_type](#input\_os\_type)

Description: The operating system that should be the same type of the App Service Plan to deploy the Function/Web App in.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_all_child_resources_inherit_lock"></a> [all\_child\_resources\_inherit\_lock](#input\_all\_child\_resources\_inherit\_lock)

Description: Should the Function App inherit the lock from the parent resource? Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_all_child_resources_inherit_tags"></a> [all\_child\_resources\_inherit\_tags](#input\_all\_child\_resources\_inherit\_tags)

Description: Should the Function App inherit tags from the parent resource? Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_app_service_active_slot"></a> [app\_service\_active\_slot](#input\_app\_service\_active\_slot)

Description:
  ```
  Object that sets the active slot for the App Service.

  `slot_key` - The key of the slot object to set as active.
  `overwrite_network_config` - Determines if the network configuration should be overwritten. Defaults to `true`.

```

Type:

```hcl
object({
    slot_key                 = optional(string)
    overwrite_network_config = optional(bool, true)
  })
```

Default: `null`

### <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings)

Description:   A map of key-value pairs for [App Settings](https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings) and custom values to assign to the Function App.

  ```terraform
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "10.14.1"
    WEBSITE_TIME_ZONE            = "Pacific Standard Time"
    WEB_CONCURRENCY              = "1"
    WEBSITE_RUN_FROM_PACKAGE     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE_LOCKED = "false"
    WEBSITE_NODE_DEFAULT_VERSION_LOCKED = "false"
    WEBSITE_TIME_ZONE_LOCKED = "false"
    WEB_CONCURRENCY_LOCKED = "false"
    WEBSITE_RUN_FROM_PACKAGE_LOCKED = "false"
  }
```

Type: `map(string)`

Default: `{}`

### <a name="input_application_insights"></a> [application\_insights](#input\_application\_insights)

Description:   
  The Application Insights settings to assign to the Function App.

Type:

```hcl
object({
    application_type                      = optional(string, "web")
    inherit_tags                          = optional(bool, false)
    location                              = optional(string)
    name                                  = optional(string)
    resource_group_name                   = optional(string)
    tags                                  = optional(map(string), null)
    workspace_resource_id                 = optional(string)
    daily_data_cap_in_gb                  = optional(number)
    daily_data_cap_notifications_disabled = optional(bool)
    retention_in_days                     = optional(number, 90)
    sampling_percentage                   = optional(number, 100)
    disable_ip_masking                    = optional(bool, false)
    local_authentication_disabled         = optional(bool, false)
    internet_ingestion_enabled            = optional(bool, true)
    internet_query_enabled                = optional(bool, true)
    force_customer_storage_for_profiler   = optional(bool, false)
  })
```

Default: `{}`

### <a name="input_auth_settings"></a> [auth\_settings](#input\_auth\_settings)

Description:   A map of authentication settings to assign to the Function App.
 - `additional_login_parameters` - (Optional) Specifies a map of login Parameters to send to the OpenID Connect authorization endpoint when a user logs in.
 - `allowed_external_redirect_urls` - (Optional) Specifies a list of External URLs that can be redirected to as part of logging in or logging out of the Linux Web App.
 - `default_provider` - (Optional) The default authentication provider to use when multiple providers are configured. Possible values include: `AzureActiveDirectory`, `Facebook`, `Google`, `MicrosoftAccount`, `Twitter`, `Github`
 - `enabled` - (Required) Should the Authentication / Authorization feature be enabled for the Linux Web App?
 - `issuer` - (Optional) The OpenID Connect Issuer URI that represents the entity which issues access tokens for this Linux Web App.
 - `runtime_version` - (Optional) The RuntimeVersion of the Authentication / Authorization feature in use for the Linux Web App.
 - `token_refresh_extension_hours` - (Optional) The number of hours after session token expiration that a session token can be used to call the token refresh API. Defaults to `72` hours.
 - `token_store_enabled` - (Optional) Should the Linux Web App durably store platform-specific security tokens that are obtained during login flows? Defaults to `false`.
 - `unauthenticated_client_action` - (Optional) The action to take when an unauthenticated client attempts to access the app. Possible values include: `RedirectToLoginPage`, `AllowAnonymous`.

 ---
 `active_directory` block supports the following:
 - `allowed_audiences` - (Optional) Specifies a list of Allowed audience values to consider when validating JWTs issued by Azure Active Directory.
 - `client_id` - (Required) The ID of the Client to use to authenticate with Azure Active Directory.
 - `client_secret` - (Optional) The Client Secret for the Client ID. Cannot be used with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The App Setting name that contains the client secret of the Client. Cannot be used with `client_secret`.

 ---
 `facebook` block supports the following:
 - `app_id` - (Required) The App ID of the Facebook app used for login.
 - `app_secret` - (Optional) The App Secret of the Facebook app used for Facebook login. Cannot be specified with `app_secret_setting_name`.
 - `app_secret_setting_name` - (Optional) The app setting name that contains the `app_secret` value used for Facebook login. Cannot be specified with `app_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes to be requested as part of Facebook login authentication.

 ---
 `github` block supports the following:
 - `client_id` - (Required) The ID of the GitHub app used for login.
 - `client_secret` - (Optional) The Client Secret of the GitHub app used for GitHub login. Cannot be specified with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The app setting name that contains the `client_secret` value used for GitHub login. Cannot be specified with `client_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes that will be requested as part of GitHub login authentication.

 ---
 `google` block supports the following:
 - `client_id` - (Required) The OpenID Connect Client ID for the Google web application.
 - `client_secret` - (Optional) The client secret associated with the Google web application. Cannot be specified with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The app setting name that contains the `client_secret` value used for Google login. Cannot be specified with `client_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes that will be requested as part of Google Sign-In authentication. If not specified, `openid`, `profile`, and `email` are used as default scopes.

 ---
 `microsoft` block supports the following:
 - `client_id` - (Required) The OAuth 2.0 client ID that was created for the app used for authentication.
 - `client_secret` - (Optional) The OAuth 2.0 client secret that was created for the app used for authentication. Cannot be specified with `client_secret_setting_name`.
 - `client_secret_setting_name` - (Optional) The app setting name containing the OAuth 2.0 client secret that was created for the app used for authentication. Cannot be specified with `client_secret`.
 - `oauth_scopes` - (Optional) Specifies a list of OAuth 2.0 scopes that will be requested as part of Microsoft Account authentication. If not specified, `wl.basic` is used as the default scope.

 ---
 `twitter` block supports the following:
 - `consumer_key` - (Required) The OAuth 1.0a consumer key of the Twitter application used for sign-in.
 - `consumer_secret` - (Optional) The OAuth 1.0a consumer secret of the Twitter application used for sign-in. Cannot be specified with `consumer_secret_setting_name`.
 - `consumer_secret_setting_name` - (Optional) The app setting name that contains the OAuth 1.0a consumer secret of the Twitter application used for sign-in. Cannot be specified with `consumer_secret`.

  ```terraform
  auth_settings = {
    example = {
      enabled = true
      active_directory = {
        client_id                  = "00000000-0000-0000-0000-000000000000"
        allowed_audiences          = ["00000000-0000-0000-0000-000000000000"]
        client_secret              = "00000000-0000-0000-0000-000000000000"
        client_secret_setting_name = "00000000-0000-0000-0000-000000000000"
      }
    }
  }
```

Type:

```hcl
map(object({
    additional_login_parameters    = optional(map(string))
    allowed_external_redirect_urls = optional(list(string))
    default_provider               = optional(string)
    enabled                        = optional(bool, false)
    issuer                         = optional(string)
    runtime_version                = optional(string)
    token_refresh_extension_hours  = optional(number, 72)
    token_store_enabled            = optional(bool, false)
    unauthenticated_client_action  = optional(string)
    active_directory = optional(map(object({
      client_id                  = optional(string)
      allowed_audiences          = optional(list(string))
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
    })))
    facebook = optional(map(object({
      app_id                  = optional(string)
      app_secret              = optional(string)
      app_secret_setting_name = optional(string)
      oauth_scopes            = optional(list(string))
    })))
    github = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })))
    google = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })))
    microsoft = optional(map(object({
      client_id                  = optional(string)
      client_secret              = optional(string)
      client_secret_setting_name = optional(string)
      oauth_scopes               = optional(list(string))
    })))
    twitter = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret              = optional(string)
      consumer_secret_setting_name = optional(string)
    })))
  }))
```

Default: `{}`

### <a name="input_auth_settings_v2"></a> [auth\_settings\_v2](#input\_auth\_settings\_v2)

Description: A map of authentication settings (V2) to assign to the Function App.

- `auth_enabled` - (Optional) Should the AuthV2 Settings be enabled. Defaults to `false`.
- `config_file_path` - (Optional) The path to the App Auth settings.
- `default_provider` - (Optional) The Default Authentication Provider to use when the `unauthenticated_action` is set to `RedirectToLoginPage`. Possible values include: `apple`, `azureactivedirectory`, `facebook`, `github`, `google`, `twitter` and the `name` of your `custom_oidc_v2` provider.
- `excluded_paths` - (Optional) The paths which should be excluded from the `unauthenticated_action` when it is set to `RedirectToLoginPage`.
- `forward_proxy_convention` - (Optional) The convention used to determine the url of the request made. Possible values include `NoProxy`, `Standard`, `Custom`. Defaults to `NoProxy`.
- `forward_proxy_custom_host_header_name` - (Optional) The name of the custom header containing the host of the request.
- `forward_proxy_custom_scheme_header_name` - (Optional) The name of the custom header containing the scheme of the request.
- `http_route_api_prefix` - (Optional) The prefix that should precede all the authentication and authorisation paths. Defaults to `/.auth`.
- `require_authentication` - (Optional) Should the authentication flow be used for all requests.
- `require_https` - (Optional) Should HTTPS be required on connections? Defaults to `true`.
- `runtime_version` - (Optional) The Runtime Version of the Authentication and Authorisation feature of this App. Defaults to `~1`.
- `unauthenticated_action` - (Optional) The action to take for requests made without authentication. Possible values include `RedirectToLoginPage`, `AllowAnonymous`, `Return401`, and `Return403`. Defaults to `RedirectToLoginPage`.

---
`active_directory_v2` block supports the following:
- `allowed_applications` - (Optional) The list of allowed Applications for the Default Authorisation Policy.
- `allowed_audiences` - (Optional) Specifies a list of Allowed audience values to consider when validating JWTs issued by Azure Active Directory.
- `allowed_groups` - (Optional) The list of allowed Group Names for the Default Authorisation Policy.
- `allowed_identities` - (Optional) The list of allowed Identities for the Default Authorisation Policy.
- `client_id` - (Required) The ID of the Client to use to authenticate with Azure Active Directory.
- `client_secret_certificate_thumbprint` - (Optional) The thumbprint of the certificate used for signing purposes.
- `client_secret_setting_name` - (Optional) The App Setting name that contains the client secret of the Client.
- `jwt_allowed_client_applications` - (Optional) A list of Allowed Client Applications in the JWT Claim.
- `jwt_allowed_groups` - (Optional) A list of Allowed Groups in the JWT Claim.
- `login_parameters` - (Optional) A map of key-value pairs to send to the Authorisation Endpoint when a user logs in.
- `tenant_auth_endpoint` - (Required) The Azure Tenant Endpoint for the Authenticating Tenant. e.g. `https://login.microsoftonline.com/v2.0/{tenant-guid}/`
- `www_authentication_disabled` - (Optional) Should the www-authenticate provider should be omitted from the request? Defaults to `false`.

---
`apple_v2` block supports the following:
- `client_id` - (Required) The OpenID Connect Client ID for the Apple web application.
- `client_secret_setting_name` - (Required) The app setting name that contains the `client_secret` value used for Apple Login.

---
`azure_static_web_app_v2` block supports the following:
- `client_id` - (Required) The ID of the Client to use to authenticate with Azure Static Web App Authentication.

---
`custom_oidc_v2` block supports the following:
- `client_id` - (Required) The ID of the Client to use to authenticate with the Custom OIDC.
- `name` - (Required) The name of the Custom OIDC Authentication Provider.
- `name_claim_type` - (Optional) The name of the claim that contains the users name.
- `openid_configuration_endpoint` - (Required) The app setting name that contains the `client_secret` value used for the Custom OIDC Login.
- `scopes` - (Optional) The list of the scopes that should be requested while authenticating.

---
`facebook_v2` block supports the following:
- `app_id` - (Required) The App ID of the Facebook app used for login.
- `app_secret_setting_name` - (Required) The app setting name that contains the `app_secret` value used for Facebook Login.
- `graph_api_version` - (Optional) The version of the Facebook API to be used while logging in.
- `login_scopes` - (Optional) The list of scopes that should be requested as part of Facebook Login authentication.

---
`github_v2` block supports the following:
- `client_id` - (Required) The ID of the GitHub app used for login..
- `client_secret_setting_name` - (Required) The app setting name that contains the `client_secret` value used for GitHub Login.
- `login_scopes` - (Optional) The list of OAuth 2.0 scopes that should be requested as part of GitHub Login authentication.

---
`google_v2` block supports the following:
- `allowed_audiences` - (Optional) Specifies a list of Allowed Audiences that should be requested as part of Google Sign-In authentication.
- `client_id` - (Required) The OpenID Connect Client ID for the Google web application.
- `client_secret_setting_name` - (Required) The app setting name that contains the `client_secret` value used for Google Login.
- `login_scopes` - (Optional) The list of OAuth 2.0 scopes that should be requested as part of Google Sign-In authentication.

---
`login` block supports the following:
- `allowed_external_redirect_urls` - (Optional) External URLs that can be redirected to as part of logging in or logging out of the app. This is an advanced setting typically only needed by Windows Store application backends.
- `cookie_expiration_convention` - (Optional) The method by which cookies expire. Possible values include: `FixedTime`, and `IdentityProviderDerived`. Defaults to `FixedTime`.
- `cookie_expiration_time` - (Optional) The time after the request is made when the session cookie should expire. Defaults to `08:00:00`.
- `logout_endpoint` - (Optional) The endpoint to which logout requests should be made.
- `nonce_expiration_time` - (Optional) The time after the request is made when the nonce should expire. Defaults to `00:05:00`.
- `preserve_url_fragments_for_logins` - (Optional) Should the fragments from the request be preserved after the login request is made. Defaults to `false`.
- `token_refresh_extension_time` - (Optional) The number of hours after session token expiration that a session token can be used to call the token refresh API. Defaults to `72` hours.
- `token_store_enabled` - (Optional) Should the Token Store configuration Enabled. Defaults to `false`
- `token_store_path` - (Optional) The directory path in the App Filesystem in which the tokens will be stored.
- `token_store_sas_setting_name` - (Optional) The name of the app setting which contains the SAS URL of the blob storage containing the tokens.
- `validate_nonce` - (Optional) Should the nonce be validated while completing the login flow. Defaults to `true`.

---
`microsoft_v2` block supports the following:
- `allowed_audiences` - (Optional) Specifies a list of Allowed Audiences that will be requested as part of Microsoft Sign-In authentication.
- `client_id` - (Required) The OAuth 2.0 client ID that was created for the app used for authentication.
- `client_secret_setting_name` - (Required) The app setting name containing the OAuth 2.0 client secret that was created for the app used for authentication.
- `login_scopes` - (Optional) The list of Login scopes that should be requested as part of Microsoft Account authentication.

---
`twitter_v2` block supports the following:
- `consumer_key` - (Required) The OAuth 1.0a consumer key of the Twitter application used for sign-in.
- `consumer_secret_setting_name` - (Required) The app setting name that contains the OAuth 1.0a consumer secret of the Twitter application used for sign-in.

```terraform
auth_settings_v2 = {
  example = {
    auth_enabled = true
    active_directory_v2 = {
      client_id                  = "00000000-0000-0000-0000-000000000000"
      client_secret_setting_name = "00000000-0000-0000-0000-000000000000"
      login_scopes               = ["00000000-0000-0000-0000-000000000000"]
    }
  }
}
```

Type:

```hcl
map(object({
    auth_enabled                            = optional(bool, false)
    config_file_path                        = optional(string)
    default_provider                        = optional(string)
    excluded_paths                          = optional(list(string))
    forward_proxy_convention                = optional(string, "NoProxy")
    forward_proxy_custom_host_header_name   = optional(string)
    forward_proxy_custom_scheme_header_name = optional(string)
    http_route_api_prefix                   = optional(string, "/.auth")
    require_authentication                  = optional(bool, false)
    require_https                           = optional(bool, true)
    runtime_version                         = optional(string, "~1")
    unauthenticated_action                  = optional(string, "RedirectToLoginPage")
    active_directory_v2 = optional(map(object({
      allowed_applications                 = optional(list(string))
      allowed_audiences                    = optional(list(string))
      allowed_groups                       = optional(list(string))
      allowed_identities                   = optional(list(string))
      client_id                            = optional(string)
      client_secret_certificate_thumbprint = optional(string)
      client_secret_setting_name           = optional(string)
      jwt_allowed_client_applications      = optional(list(string))
      jwt_allowed_groups                   = optional(list(string))
      login_parameters                     = optional(map(any))
      tenant_auth_endpoint                 = optional(string)
      www_authentication_disabled          = optional(bool, false)
    })), {})
    apple_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })), {})
    azure_static_web_app_v2 = optional(map(object({
      client_id = optional(string)
    })), {})
    custom_oidc_v2 = optional(map(object({
      authorisation_endpoint        = optional(string)
      certification_uri             = optional(string)
      client_credential_method      = optional(string)
      client_id                     = optional(string)
      client_secret_setting_name    = optional(string)
      issuer_endpoint               = optional(string)
      name                          = optional(string)
      name_claim_type               = optional(string)
      openid_configuration_endpoint = optional(string)
      scopes                        = optional(list(string))
      token_endpoint                = optional(string)
    })), {})
    facebook_v2 = optional(map(object({
      app_id                  = optional(string)
      app_secret_setting_name = optional(string)
      graph_api_version       = optional(string)
      login_scopes            = optional(list(string))
    })), {})
    github_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      login_scopes               = optional(list(string))
    })), {})
    google_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })), {})
    login = map(object({
      allowed_external_redirect_urls    = optional(list(string))
      cookie_expiration_convention      = optional(string, "FixedTime")
      cookie_expiration_time            = optional(string, "00:00:00")
      logout_endpoint                   = optional(string)
      nonce_expiration_time             = optional(string, "00:05:00")
      preserve_url_fragments_for_logins = optional(bool, false)
      token_refresh_extension_time      = optional(number, 72)
      token_store_enabled               = optional(bool, false)
      token_store_path                  = optional(string)
      token_store_sas_setting_name      = optional(string)
      validate_nonce                    = optional(bool, true)
    }))
    microsoft_v2 = optional(map(object({
      client_id                  = optional(string)
      client_secret_setting_name = optional(string)
      allowed_audiences          = optional(list(string))
      login_scopes               = optional(list(string))
    })), {})
    twitter_v2 = optional(map(object({
      consumer_key                 = optional(string)
      consumer_secret_setting_name = optional(string)
    })), {})

  }))
```

Default: `{}`

### <a name="input_auto_heal_setting"></a> [auto\_heal\_setting](#input\_auto\_heal\_setting)

Description:   To be removed, as Function App does not support auto heal.

Type:

```hcl
map(object({
    action = optional(object({
      action_type = string
      custom_action = optional(object({
        executable = string
        parameters = optional(string)
      }))
      minimum_process_execution_time = optional(string, "00:00:00")
    }))
    trigger = optional(object({
      private_memory_kb = optional(number)
      requests = optional(map(object({
        count    = number
        interval = string
      })), {})
      slow_request = optional(map(object({
        count      = number
        interval   = string
        take_taken = string
        path       = optional(string)
      })), {})
      slow_request_with_path = optional(map(object({
        count      = number
        interval   = string
        take_taken = string
        path       = optional(string)
      })), {})
      status_code = optional(map(object({
        count             = number
        interval          = string
        status_code_range = number
        path              = optional(string)
        sub_status        = optional(number)
        win32_status_code = optional(number)
      })), {})
    }))
  }))
```

Default: `{}`

### <a name="input_backup"></a> [backup](#input\_backup)

Description:   A map of backup settings to assign to the Function App.
  - `name` - (Optional) The name of the backup. One will be generated if not set.
  - `schedule` - (Optional) A map of backup schedule settings.
    - `frequency_interval` - (Optional) The frequency interval of the backup.
    - `frequency_unit` - (Optional) The frequency unit of the backup.
    - `keep_at_least_one_backup` - (Optional) Should at least one backup be kept?.
    - `retention_period_in_days` - (Optional) The retention period in days of the backup.
    - `start_time` - (Optional) The start time of the backup.
  - `storage_account_url` - (Optional) The URL of the Storage Account to store the backup in.
  - `enabled` - (Optional) Is the backup enabled? Defaults to `true`.

  ```terraform
  backup = {
    example = {
      name               = "example"
      schedule = {
        frequency_interval       = 1
        frequency_unit           = "Day"
        keep_at_least_one_backup = true
        retention_period_in_days = 7
        start_time               = "2020-01-01T00:00:00Z"
      }
      storage_account_url = "https://example.blob.core.windows.net/example"
      enabled             = true
    }
  }
```

Type:

```hcl
map(object({
    enabled             = optional(bool, true)
    name                = optional(string)
    storage_account_url = optional(string)
    schedule = optional(map(object({
      frequency_interval       = optional(number)
      frequency_unit           = optional(string)
      keep_at_least_one_backup = optional(bool)
      retention_period_days    = optional(number)
      start_time               = optional(string)
    })))
  }))
```

Default: `{}`

### <a name="input_builtin_logging_enabled"></a> [builtin\_logging\_enabled](#input\_builtin\_logging\_enabled)

Description: Should builtin logging be enabled for the Function App?

Type: `bool`

Default: `true`

### <a name="input_client_affinity_enabled"></a> [client\_affinity\_enabled](#input\_client\_affinity\_enabled)

Description: Should client affinity be enabled for the Function App?

Type: `bool`

Default: `false`

### <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled)

Description: Should client certificate be enabled for the Function App?

Type: `bool`

Default: `false`

### <a name="input_client_certificate_exclusion_paths"></a> [client\_certificate\_exclusion\_paths](#input\_client\_certificate\_exclusion\_paths)

Description: The client certificate exclusion paths for the Function App.

Type: `string`

Default: `null`

### <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode)

Description: The client certificate mode for the Function App.

Type: `string`

Default: `"Required"`

### <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings)

Description:   A map of connection strings to assign to the Function App.
  - `name` - (Optional) The name of the connection string.
  - `type` - (Optional) The type of the connection string.
  - `value` - (Optional) The value of the connection string.
  ```terraform
  connection_strings = {
    example = {
      name  = "example"
      type  = "example"
      value = "example"
    }
  }
```

Type:

```hcl
map(object({
    name  = optional(string)
    type  = optional(string)
    value = optional(string)
  }))
```

Default: `{}`

### <a name="input_content_share_force_disabled"></a> [content\_share\_force\_disabled](#input\_content\_share\_force\_disabled)

Description: Should content share be force disabled for the Function App?

Type: `bool`

Default: `false`

### <a name="input_create_secure_storage_account"></a> [create\_secure\_storage\_account](#input\_create\_secure\_storage\_account)

Description: Should a secure Storage Account be created for the Function App? Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_create_service_plan"></a> [create\_service\_plan](#input\_create\_service\_plan)

Description: Should a service plan be created for the Function App? Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_custom_domains"></a> [custom\_domains](#input\_custom\_domains)

Description:   A map of custom domains to assign to the Function App.
  - `slot_as_target` - (optional) Will this custom domain configuration be used for a App Service slot? Defaults to `false`.
  - `app_service_slot_key` - (Optional) The key of the App Service Slot to use as the target for the custom domain.
  - `app_service_plan_resource_id` - (Optional) The resource ID of the App Service Plan to use for the custom domain.
  - `key_vault_secret_id` - (Optional) The ID of the Key Vault Secret to use for the custom domain.
  - `create_certificate` - (Optional) Should a certificate be created for the custom domain? Defaults to `false`.
  - `create_txt_records` - (Optional) Should TXT records be created for the custom domain? Defaults to `false`.
  - `create_cname_records` - (Optional) Should CNAME records be created for the custom domain? Defaults to `false`.

  ```terraform
  custom_domains = {
    # Allows for the configuration of custom domains for the Function App
    # If not already set, the module allows for the creation of TXT and CNAME records

    custom_domain_1 = {

      zone_resource_group_name = "<zone_resource_group_name>"

      create_txt_records = true
      txt_name           = "asuid.<module.naming.function_app.name_unique>"
      txt_zone_name      = "<zone_name>"
      txt_records = {
        record = {
          value = "" # Leave empty as module will reference Function App ID after Function App creation
        }
      }

      create_cname_records = true
      cname_name           = "<module.naming.function_app.name_unique>"
      cname_zone_name      = "<zone_name>"
      cname_record         = "<module.naming.function_app.name_unique>-custom-domain.azurewebsites.net"

      create_certificate   = true
      certificate_name     = "<module.naming.function_app.name_unique>-<data.azurerm_key_vault_secret.stored_certificate.name>"
      certificate_location = azurerm_resource_group.example.location
      pfx_blob             = data.azurerm_key_vault_secret.stored_certificate.value

      app_service_name    = "<module.naming.function_app.name_unique>-custom-domain"
      hostname            = "<module.naming.function_app.name_unique>.<root_domain>"
      resource_group_name = azurerm_resource_group.example.name
      ssl_state           = "SniEnabled"
      thumbprint_key      = "custom_domain_1" # Currently the key of the custom domain
    }

  }
```

Type:

```hcl
map(object({
    slot_as_target               = optional(bool, false)
    app_service_slot_key         = optional(string)
    create_certificate           = optional(bool, false)
    certificate_name             = optional(string)
    certificate_location         = optional(string)
    pfx_blob                     = optional(string)
    pfx_password                 = optional(string)
    hostname                     = optional(string)
    app_service_name             = optional(string)
    app_service_plan_resource_id = optional(string)
    key_vault_secret_id          = optional(string)
    key_vault_id                 = optional(string)
    zone_resource_group_name     = optional(string)
    resource_group_name          = optional(string)
    ssl_state                    = optional(string)
    inherit_tags                 = optional(bool, true)
    tags                         = optional(map(any), {})
    thumbprint_key               = optional(string)
    thumbprint_value             = optional(string)
    ttl                          = optional(number, 300)
    validation_type              = optional(string, "cname-delegation")
    create_cname_records         = optional(bool, false)
    cname_name                   = optional(string)
    cname_zone_name              = optional(string)
    cname_record                 = optional(string)
    cname_target_resource_id     = optional(string)
    create_txt_records           = optional(bool, false)
    txt_name                     = optional(string)
    txt_zone_name                = optional(string)
    txt_records                  = optional(map(object({ value = string })))
  }))
```

Default: `{}`

### <a name="input_daily_memory_time_quota"></a> [daily\_memory\_time\_quota](#input\_daily\_memory\_time\_quota)

Description: (Optional) The amount of memory in gigabyte-seconds that your application is allowed to consume per day. Setting this value only affects Function Apps under the consumption plan. Defaults to `0`.

Type: `number`

Default: `0`

### <a name="input_deployment_slots"></a> [deployment\_slots](#input\_deployment\_slots)

Description:
  ```
  `auto_heal_setting` - To be removed, as Function App does not support auto heal.
```

Type:

```hcl
map(object({
    name                                           = optional(string)
    app_settings                                   = optional(map(string))
    builtin_logging_enabled                        = optional(bool, true)
    content_share_force_disabled                   = optional(bool, false)
    client_affinity_enabled                        = optional(bool, false)
    client_certificate_enabled                     = optional(bool, false)
    client_certificate_exclusion_paths             = optional(string, null)
    client_certificate_mode                        = optional(string, "Required")
    daily_memory_time_quota                        = optional(number, 0)
    enabled                                        = optional(bool, true)
    functions_extension_version                    = optional(string, "~4")
    ftp_publish_basic_authentication_enabled       = optional(bool, true)
    https_only                                     = optional(bool, false)
    key_vault_reference_identity_id                = optional(string, null)
    public_network_access_enabled                  = optional(bool, true)
    service_plan_id                                = optional(string, null)
    tags                                           = optional(map(string))
    virtual_network_subnet_id                      = optional(string, null)
    webdeploy_publish_basic_authentication_enabled = optional(bool, true)
    zip_deploy_file                                = optional(string, null)

    auth_settings = optional(map(object({
      additional_login_parameters    = optional(list(string))
      allowed_external_redirect_urls = optional(list(string))
      default_provider               = optional(string)
      enabled                        = optional(bool, false)
      issuer                         = optional(string)
      runtime_version                = optional(string)
      token_refresh_extension_hours  = optional(number, 72)
      token_store_enabled            = optional(bool, false)
      unauthenticated_client_action  = optional(string)
      active_directory = optional(map(object({
        client_id                  = optional(string)
        allowed_audiences          = optional(list(string))
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
      })))
      facebook = optional(map(object({
        app_id                  = optional(string)
        app_secret              = optional(string)
        app_secret_setting_name = optional(string)
        oauth_scopes            = optional(list(string))
      })))
      github = optional(map(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      })))
      google = optional(map(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      })))
      microsoft = optional(map(object({
        client_id                  = optional(string)
        client_secret              = optional(string)
        client_secret_setting_name = optional(string)
        oauth_scopes               = optional(list(string))
      })))
      twitter = optional(map(object({
        consumer_key                 = optional(string)
        consumer_secret              = optional(string)
        consumer_secret_setting_name = optional(string)
      })))
    })), {})

    auth_settings_v2 = optional(map(object({
      auth_enabled                            = optional(bool, false)
      config_file_path                        = optional(string)
      default_provider                        = optional(string)
      excluded_paths                          = optional(list(string))
      forward_proxy_convention                = optional(string, "NoProxy")
      forward_proxy_custom_host_header_name   = optional(string)
      forward_proxy_custom_scheme_header_name = optional(string)
      http_route_api_prefix                   = optional(string, "/.auth")
      require_authentication                  = optional(bool, false)
      require_https                           = optional(bool, true)
      runtime_version                         = optional(string, "~1")
      unauthenticated_action                  = optional(string, "RedirectToLoginPage")
      active_directory_v2 = optional(map(object({
        allowed_applications                 = optional(list(string))
        allowed_audiences                    = optional(list(string))
        allowed_groups                       = optional(list(string))
        allowed_identities                   = optional(list(string))
        client_id                            = optional(string)
        client_secret_certificate_thumbprint = optional(string)
        client_secret_setting_name           = optional(string)
        jwt_allowed_client_applications      = optional(list(string))
        jwt_allowed_groups                   = optional(list(string))
        login_parameters                     = optional(map(any))
        tenant_auth_endpoint                 = optional(string)
        www_authentication_disabled          = optional(bool, false)
      })), {})
      apple_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        login_scopes               = optional(list(string))
      })), {})
      azure_static_web_app_v2 = optional(map(object({
        client_id = optional(string)
      })), {})
      custom_oidc_v2 = optional(map(object({
        authorisation_endpoint        = optional(string)
        certification_uri             = optional(string)
        client_credential_method      = optional(string)
        client_id                     = optional(string)
        client_secret_setting_name    = optional(string)
        issuer_endpoint               = optional(string)
        name                          = optional(string)
        name_claim_type               = optional(string)
        openid_configuration_endpoint = optional(string)
        scopes                        = optional(list(string))
        token_endpoint                = optional(string)
      })), {})
      facebook_v2 = optional(map(object({
        app_id                  = optional(string)
        app_secret_setting_name = optional(string)
        graph_api_version       = optional(string)
        login_scopes            = optional(list(string))
      })), {})
      github_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        login_scopes               = optional(list(string))
      })), {})
      google_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      })), {})
      login = map(object({
        allowed_external_redirect_urls    = optional(list(string))
        cookie_expiration_convention      = optional(string, "FixedTime")
        cookie_expiration_time            = optional(string, "00:00:00")
        logout_endpoint                   = optional(string)
        nonce_expiration_time             = optional(string, "00:05:00")
        preserve_url_fragments_for_logins = optional(bool, false)
        token_refresh_extension_time      = optional(number, 72)
        token_store_enabled               = optional(bool, false)
        token_store_path                  = optional(string)
        token_store_sas_setting_name      = optional(string)
        validate_nonce                    = optional(bool, true)
      }))
      microsoft_v2 = optional(map(object({
        client_id                  = optional(string)
        client_secret_setting_name = optional(string)
        allowed_audiences          = optional(list(string))
        login_scopes               = optional(list(string))
      })), {})
      twitter_v2 = optional(map(object({
        consumer_key                 = optional(string)
        consumer_secret_setting_name = optional(string)
      })), {})
    })), {})

    auto_heal_setting = optional(map(object({
      action = optional(object({
        action_type = string
        custom_action = optional(object({
          executable = string
          parameters = optional(string)
        }))
        minimum_process_execution_time = optional(string, "00:00:00")
      }))
      trigger = optional(object({
        private_memory_kb = optional(number)
        requests = optional(map(object({
          count    = number
          interval = string
        })), {})
        slow_request = optional(map(object({
          count      = number
          interval   = string
          take_taken = string
          path       = optional(string)
        })), {})
        slow_request_with_path = optional(map(object({
          count      = number
          interval   = string
          take_taken = string
          path       = optional(string)
        })), {})
        status_code = optional(map(object({
          count             = number
          interval          = string
          status_code_range = number
          path              = optional(string)
          sub_status        = optional(number)
          win32_status_code = optional(number)
        })), {})
      }))
    })), {})

    backup = optional(map(object({
      enabled             = optional(bool, true)
      name                = optional(string)
      storage_account_url = optional(string)
      schedule = optional(map(object({
        frequency_interval       = optional(number)
        frequency_unit           = optional(string)
        keep_at_least_one_backup = optional(bool)
        retention_period_days    = optional(number)
        start_time               = optional(string)
      })))
    })), {})

    connection_strings = optional(map(object({
      name  = optional(string)
      type  = optional(string)
      value = optional(string)
    })), {})

    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)

    logs = optional(map(object({
      application_logs = optional(map(object({
        azure_blob_storage = optional(object({
          level             = optional(string, "Off")
          retention_in_days = optional(number, 0)
          sas_url           = string
        }))
        file_system_level = optional(string, "Off")
      })), {})
      detailed_error_messages = optional(bool, false)
      failed_request_tracing  = optional(bool, false)
      http_logs = optional(map(object({
        azure_blob_storage_http = optional(object({
          retention_in_days = optional(number, 0)
          sas_url           = string
        }))
        file_system = optional(object({
          retention_in_days = optional(number, 0)
          retention_in_mb   = number
        }))
      })), {})
    })), {})

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

    storage_shares_to_mount = optional(map(object({
      access_key   = string
      account_name = string
      mount_path   = string
      name         = string
      share_name   = string
      type         = optional(string, "AzureFiles")
    })), {})

    site_config = optional(object({
      always_on             = optional(bool, false) # when running in a Consumption or Premium Plan, `always_on` feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
      api_definition_url    = optional(string)      # (Optional) The URL of the OpenAPI (Swagger) definition that provides schema for the function's HTTP endpoints.
      api_management_api_id = optional(string)      # (Optional) The API Management API identifier.
      app_command_line      = optional(string)      # (Optional) The command line to launch the application.
      # auto_heal_enabled                             = optional(bool)        # (Optional) Should auto-heal be enabled for the Function App?
      app_scale_limit                               = optional(number) # (Optional) The maximum number of workers that the Function App can scale out to.
      application_insights_connection_string        = optional(string) # (Optional) The connection string of the Application Insights resource to send telemetry to.
      application_insights_key                      = optional(string) # (Optional) The instrumentation key of the Application Insights resource to send telemetry to.
      container_registry_managed_identity_client_id = optional(string)
      container_registry_use_managed_identity       = optional(bool)
      default_documents                             = optional(list(string))            #(Optional) Specifies a list of Default Documents for the Windows Function App.
      elastic_instance_minimum                      = optional(number)                  #(Optional) The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
      ftps_state                                    = optional(string, "Disabled")      #(Optional) State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
      health_check_eviction_time_in_min             = optional(number)                  #(Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path.
      health_check_path                             = optional(string)                  #(Optional) The path to be checked for this Windows Function App health.
      http2_enabled                                 = optional(bool, false)             #(Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to false.
      ip_restriction_default_action                 = optional(string, "Allow")         #(Optional) The default action for IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
      load_balancing_mode                           = optional(string, "LeastRequests") #(Optional) The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests if omitted.
      local_mysql_enabled                           = optional(bool, false)             #(Optional) Should local MySQL be enabled. Defaults to false.
      managed_pipeline_mode                         = optional(string, "Integrated")    #(Optional) Managed pipeline mode. Possible values include: Integrated, Classic. Defaults to Integrated.
      minimum_tls_version                           = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
      pre_warmed_instance_count                     = optional(number)                  #(Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
      remote_debugging_enabled                      = optional(bool, false)             #(Optional) Should Remote Debugging be enabled. Defaults to false.
      remote_debugging_version                      = optional(string)                  #(Optional) The Remote Debugging Version. Possible values include VS2017, VS2019, and VS2022.
      runtime_scale_monitoring_enabled              = optional(bool)                    #(Optional) Should runtime scale monitoring be enabled.
      scm_ip_restriction_default_action             = optional(string, "Allow")         #(Optional) The default action for SCM IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
      scm_minimum_tls_version                       = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests to Kudu. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
      scm_use_main_ip_restriction                   = optional(bool, false)             #(Optional) Should the SCM use the same IP restrictions as the main site. Defaults to false.
      use_32_bit_worker                             = optional(bool, false)             #(Optional) Should the 32-bit worker process be used. Defaults to false.
      vnet_route_all_enabled                        = optional(bool, false)             #(Optional) Should all traffic be routed to the virtual network. Defaults to false.
      websockets_enabled                            = optional(bool, false)             #(Optional) Should Websockets be enabled. Defaults to false.
      worker_count                                  = optional(number)                  #(Optional) The number of workers for this Windows Function App. Only affects apps on an Elastic Premium plan.
      app_service_logs = optional(map(object({
        disk_quota_mb         = optional(number, 35)
        retention_period_days = optional(number)
      })), {})
      application_stack = optional(map(object({
        dotnet_version              = optional(string)
        java_version                = optional(string)
        node_version                = optional(string)
        powershell_core_version     = optional(string)
        python_version              = optional(string)
        go_version                  = optional(string)
        ruby_version                = optional(string)
        java_server                 = optional(string)
        java_server_version         = optional(string)
        php_version                 = optional(string)
        use_custom_runtime          = optional(bool)
        use_dotnet_isolated_runtime = optional(bool)
        docker = optional(list(object({
          image_name        = string
          image_tag         = string
          registry_password = optional(string)
          registry_url      = string
          registry_username = optional(string)
        })))
        current_stack                = optional(string)
        docker_image_name            = optional(string)
        docker_registry_url          = optional(string)
        docker_registry_username     = optional(string)
        docker_registry_password     = optional(string)
        docker_container_name        = optional(string)
        docker_container_tag         = optional(string)
        java_embedded_server_enabled = optional(bool)
        tomcat_version               = optional(bool)
      })), {})
      cors = optional(map(object({
        allowed_origins     = optional(list(string))
        support_credentials = optional(bool, false)
      })), {}) #(Optional) A cors block as defined above.
      ip_restriction = optional(map(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(map(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string), ["1"])
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        })), {})
      })), {}) #(Optional) One or more ip_restriction blocks as defined above.
      scm_ip_restriction = optional(map(object({
        action                    = optional(string, "Allow")
        ip_address                = optional(string)
        name                      = optional(string)
        priority                  = optional(number, 65000)
        service_tag               = optional(string)
        virtual_network_subnet_id = optional(string)
        headers = optional(map(object({
          x_azure_fdid      = optional(list(string))
          x_fd_health_probe = optional(list(string), ["1"])
          x_forwarded_for   = optional(list(string))
          x_forwarded_host  = optional(list(string))
        })), {})
      })), {}) #(Optional) One or more scm_ip_restriction blocks as defined above.
      virtual_application = optional(map(object({
        physical_path   = optional(string, "site\\wwwroot")
        preload_enabled = optional(bool, false)
        virtual_directory = optional(map(object({
          physical_path = optional(string)
          virtual_path  = optional(string)
        })), {})
        virtual_path = optional(string, "/")
        })),
        {
          default = {
            physical_path   = "site\\wwwroot"
            preload_enabled = false
            virtual_path    = "/"
          }
        }
      )
    }), {})

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }), null)

  }))
```

Default: `{}`

### <a name="input_deployment_slots_inherit_lock"></a> [deployment\_slots\_inherit\_lock](#input\_deployment\_slots\_inherit\_lock)

Description: Whether to inherit the lock from the parent resource for the deployment slots. Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
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
  }))
```

Default: `{}`

### <a name="input_enable_application_insights"></a> [enable\_application\_insights](#input\_enable\_application\_insights)

Description: Should Application Insights be enabled for the Function App?

Type: `bool`

Default: `true`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description:   This variable controls whether or not telemetry is enabled for the module.  
  For more information see <https://aka.ms/avm/telemetryinfo>.  
  If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_ftp_publish_basic_authentication_enabled"></a> [ftp\_publish\_basic\_authentication\_enabled](#input\_ftp\_publish\_basic\_authentication\_enabled)

Description: Should basic authentication be enabled for FTP publish?

Type: `bool`

Default: `true`

### <a name="input_functions_extension_version"></a> [functions\_extension\_version](#input\_functions\_extension\_version)

Description: The version of the Azure Functions runtime to use. Defaults to `~4`.

Type: `string`

Default: `"~4"`

### <a name="input_https_only"></a> [https\_only](#input\_https\_only)

Description: Should the Function App only be accessible over HTTPS?

Type: `bool`

Default: `false`

### <a name="input_key_vault_reference_identity_id"></a> [key\_vault\_reference\_identity\_id](#input\_key\_vault\_reference\_identity\_id)

Description: The identity ID to use for Key Vault references.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply. Possible values are `CanNotDelete` and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = string
  })
```

Default: `null`

### <a name="input_logs"></a> [logs](#input\_logs)

Description:   
A map of logs to create on the Function App.

Type:

```hcl
map(object({
    application_logs = optional(map(object({
      azure_blob_storage = optional(object({
        level             = optional(string, "Off")
        retention_in_days = optional(number, 0)
        sas_url           = string
      }))
      file_system_level = optional(string, "Off")
    })), {})
    detailed_error_messages = optional(bool, false)
    failed_request_tracing  = optional(bool, false)
    http_logs = optional(map(object({
      azure_blob_storage_http = optional(object({
        retention_in_days = optional(number, 0)
        sas_url           = string
      }))
      file_system = optional(object({
        retention_in_days = optional(number, 0)
        retention_in_mb   = number
      }))
    })), {})
  }))
```

Default: `{}`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Managed identities to be created for the resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_new_service_plan"></a> [new\_service\_plan](#input\_new\_service\_plan)

Description:   DEPRECATED, use `create_service_plan` and `service_plan` instead.  

  A map of objects that represent a new App Service Plan to create for the Function App.

  - `name` - (Optional) The name of the App Service Plan.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the App Service Plan in.
  - `location` - (Optional) The Azure region where the App Service Plan will be deployed. Defaults to the location of the resource group.
  - `sku_name` - (Optional) The SKU name of the App Service Plan. Defaults to `P1v2`.
  - `app_service_environment_resource_id` - (Optional) The resource ID of the App Service Environment to deploy the App Service Plan in.
  - `maximum_elastic_worker_count` - (Optional) The maximum number of workers that can be allocated to this App Service Plan.
  - `worker_count` - (Optional) The number of workers to allocate to this App Service Plan.
  - `per_site_scaling_enabled` - (Optional) Should per site scaling be enabled for the App Service Plan? Defaults to `false`.
  - `zone_balancing_enabled` - (Optional) Should zone balancing be enabled for the App Service Plan? Changing this forces a new resource to be created.
  > **NOTE:** If this setting is set to `true` and the `worker_count` value is specified, it should be set to a multiple of the number of availability zones in the region. Please see the Azure documentation for the number of Availability Zones in your region.

Type:

```hcl
object({
    name                                = optional(string)
    resource_group_name                 = optional(string)
    location                            = optional(string)
    sku_name                            = optional(string, "P1v2")
    app_service_environment_resource_id = optional(string)
    maximum_elastic_worker_count        = optional(number)
    worker_count                        = optional(number, 3)
    per_site_scaling_enabled            = optional(bool, false)
    zone_balancing_enabled              = optional(bool, true)
  })
```

Default: `null`

### <a name="input_private_dns_zone_resource_group_name"></a> [private\_dns\_zone\_resource\_group\_name](#input\_private\_dns\_zone\_resource\_group\_name)

Description: resource group name where private DNS zones are registered

Type: `string`

Default: `null`

### <a name="input_private_dns_zone_subscription_id"></a> [private\_dns\_zone\_subscription\_id](#input\_private\_dns\_zone\_subscription\_id)

Description: subscription id where the Private DNS Zones are registered

Type: `string`

Default: `null`

### <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones)

Description: A map of private DNS zones to create and associate with the storage account and/or Function App.

Type:

```hcl
map(object({
    domain_name         = string
    resource_group_name = string
    a_records = optional(map(object({
      name                = string
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      records             = list(string)
      tags                = optional(map(string), null)
    })), {})
    aaaa_records = optional(map(object({
      name                = string
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      records             = list(string)
      tags                = optional(map(string), null)
    })), {})
    cname_records = optional(map(object({
      name                = string
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      record              = string
      tags                = optional(map(string), null)
    })), {})
    mx_records = optional(map(object({
      name                = optional(string, "@")
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      records = map(object({
        preference = number
        exchange   = string
      }))
      tags = optional(map(string), null)
    })), {})
    ptr_records = optional(map(object({
      name                = string
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      records             = list(string)
      tags                = optional(map(string), null)
    })), {})
    soa_record = optional(object({
      email        = string
      expire_time  = optional(number, 2419200)
      minimum_ttl  = optional(number, 10)
      refresh_time = optional(number, 3600)
      retry_time   = optional(number, 300)
      ttl          = optional(number, 3600)
      tags         = optional(map(string), null)
    }), null)
    srv_records = optional(map(object({
      name                = string
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      records = map(object({
        priority = number
        weight   = number
        port     = number
        target   = string
      }))
      tags = optional(map(string), null)
    })), {})
    tags = optional(map(string), null)
    txt_records = optional(map(object({
      name                = string
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      records = map(object({
        value = string
      }))
      tags = optional(map(string), null)
    })), {})
    virtual_network_links = optional(map(object({
      vnetlinkname     = string
      vnetid           = string
      autoregistration = optional(bool, false)
      tags             = optional(map(string), null)
    })), {})
  }))
```

Default: `{}`

### <a name="input_private_endpoint_subnet_resource_id"></a> [private\_endpoint\_subnet\_resource\_id](#input\_private\_endpoint\_subnet\_resource\_id)

Description: subnet for private endpoints

Type: `string`

Default: `null`

### <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints)

Description: A map of private endpoints to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the private endpoint. One will be generated if not set.
- `role_assignments` - (Optional) A map of role assignments to create on the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating private endpoints if the principal creating the assignment is constrained by RBAC rules that filters on the PrincipalType attribute.
- `lock` - (Optional) The lock level to apply to the private endpoint. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `tags` - (Optional) A mapping of tags to assign to the private endpoint.
- `subnet_resource_id` - The resource ID of the subnet to deploy the private endpoint in.
- `private_dns_zone_group_name` - (Optional) The name of the private DNS zone group. One will be generated if not set.
- `private_dns_zone_resource_ids` - (Optional) A set of resource IDs of private DNS zones to associate with the private endpoint. If not set, no zone groups will be created and the private endpoint will not be associated with any private DNS zones. DNS records must be managed external to this module.
- `application_security_group_resource_ids` - (Optional) A map of resource IDs of application security groups to associate with the private endpoint. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `private_service_connection_name` - (Optional) The name of the private service connection. One will be generated if not set.
- `network_interface_name` - (Optional) The name of the network interface. One will be generated if not set.
- `location` - (Optional) The Azure location where the resources will be deployed. Defaults to the location of the resource group.
- `resource_group_name` - (Optional) The resource group where the resources will be deployed. Defaults to the resource group of this resource.
- `ip_configurations` - (Optional) A map of IP configurations to create on the private endpoint. If not specified the platform will create one. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - The name of the IP configuration.
  - `private_ip_address` - The private IP address of the IP configuration.

Type:

```hcl
map(object({
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
  }))
```

Default: `{}`

### <a name="input_private_endpoints_inherit_lock"></a> [private\_endpoints\_inherit\_lock](#input\_private\_endpoints\_inherit\_lock)

Description: Should the private endpoints inherit the lock from the parent resource? Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_private_endpoints_manage_dns_zone_group"></a> [private\_endpoints\_manage\_dns\_zone\_group](#input\_private\_endpoints\_manage\_dns\_zone\_group)

Description: Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy.

Type: `bool`

Default: `true`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: Should the Function App be accessible from the public network? Defaults to `true`.

Type: `bool`

Default: `false`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_service_plan"></a> [service\_plan](#input\_service\_plan)

Description:   A map of objects that represent a new App Service Plan to create for the Function App.

  - `name` - (Optional) The name of the App Service Plan.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the App Service Plan in.
  - `location` - (Optional) The Azure region where the App Service Plan will be deployed. Defaults to the location of the resource group.
  - `sku_name` - (Optional) The SKU name of the App Service Plan. Defaults to `P1v2`.
  > Possible values include `B1`, `B2`, `B3`, `D1`, `F1`, `I1`, `I2`, `I3`, `I1v2`, `I2v2`, `I3v2`, `I4v2`, `I5v2`, `I6v2`, `P1v2`, `P2v2`, `P3v2`, `P0v3`, `P1v3`,`P2v3`, `P3v3`, `P1mv3`, `P2mv3`, `P3mv3`, `P4mv3`, `P5mv3`, `S1`, `S2`, `S3`, `SHARED`, `EP1`, `EP2`, `EP3`, `FC1`, `WS1`, `WS2`, `WS3`, and `Y1`.
  - `app_service_environment_resource_id` - (Optional) The resource ID of the App Service Environment to deploy the App Service Plan in.
  - `maximum_elastic_worker_count` - (Optional) The maximum number of workers that can be allocated to Elastic SKU Plan. Cannot be set unless using an Elastic SKU.
  - `worker_count` - (Optional) The number of workers to allocate to this App Service Plan. Defaults to `3`.
  - `per_site_scaling_enabled` - (Optional) Should per site scaling be enabled for the App Service Plan? Defaults to `false`.
  - `zone_balancing_enabled` - (Optional) Should zone balancing be enabled for the App Service Plan? Changing this forces a new resource to be created.
  > **NOTE:** If this setting is set to `true` and the `worker_count` value is specified, it should be set to a multiple of the number of availability zones in the region. Please see the Azure documentation for the number of Availability Zones in your region.

Type:

```hcl
object({
    name                                = optional(string)
    resource_group_name                 = optional(string)
    location                            = optional(string)
    sku_name                            = optional(string, "P1v2")
    app_service_environment_resource_id = optional(string)
    maximum_elastic_worker_count        = optional(number)
    worker_count                        = optional(number, 3)
    per_site_scaling_enabled            = optional(bool, false)
    zone_balancing_enabled              = optional(bool, true)
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
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
  })
```

Default: `{}`

### <a name="input_service_plan_resource_id"></a> [service\_plan\_resource\_id](#input\_service\_plan\_resource\_id)

Description: The resource ID of the App Service Plan to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_site_config"></a> [site\_config](#input\_site\_config)

Description:   An object that configures the Function App's `site_config` block.
 - `always_on` - (Optional) If this Linux Web App is Always On enabled. Defaults to `false`.
 - `api_definition_url` - (Optional) The URL of the API definition that describes this Linux Function App.
 - `api_management_api_id` - (Optional) The ID of the API Management API for this Linux Function App.
 - `app_command_line` - (Optional) The App command line to launch.
 - `app_scale_limit` - (Optional) The number of workers this function app can scale out to. Only applicable to apps on the Consumption and Premium plan.
 - `application_insights_connection_string` - (Optional) The Connection String for linking the Linux Function App to Application Insights.
 - `application_insights_key` - (Optional) The Instrumentation Key for connecting the Linux Function App to Application Insights.
 - `container_registry_managed_identity_client_id` - (Optional) The Client ID of the Managed Service Identity to use for connections to the Azure Container Registry.
 - `container_registry_use_managed_identity` - (Optional) Should connections for Azure Container Registry use Managed Identity.
 - `default_documents` - (Optional) Specifies a list of Default Documents for the Linux Web App.
 - `elastic_instance_minimum` - (Optional) The number of minimum instances for this Linux Function App. Only affects apps on Elastic Premium plans.
 - `ftps_state` - (Optional) State of FTP / FTPS service for this function app. Possible values include: `AllAllowed`, `FtpsOnly` and `Disabled`. Defaults to `Disabled`.
 - `health_check_eviction_time_in_min` - (Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between `2` and `10`. Only valid in conjunction with `health_check_path`.
 - `health_check_path` - (Optional) The path to be checked for this function app health.
 - `http2_enabled` - (Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to `false`.
 - `load_balancing_mode` - (Optional) The Site load balancing mode. Possible values include: `WeightedRoundRobin`, `LeastRequests`, `LeastResponseTime`, `WeightedTotalTraffic`, `RequestHash`, `PerSiteRoundRobin`. Defaults to `LeastRequests` if omitted.
 - `managed_pipeline_mode` - (Optional) Managed pipeline mode. Possible values include: `Integrated`, `Classic`. Defaults to `Integrated`.
 - `minimum_tls_version` - (Optional) The configures the minimum version of TLS required for SSL requests. Possible values include: `1.0`, `1.1`, and `1.2`. Defaults to `1.2`.
 - `pre_warmed_instance_count` - (Optional) The number of pre-warmed instances for this function app. Only affects apps on an Elastic Premium plan.
 - `remote_debugging_enabled` - (Optional) Should Remote Debugging be enabled. Defaults to `false`.
 - `remote_debugging_version` - (Optional) The Remote Debugging Version. Possible values include `VS2017`, `VS2019`, and `VS2022`.
 - `runtime_scale_monitoring_enabled` - (Optional) Should Scale Monitoring of the Functions Runtime be enabled?
 - `scm_minimum_tls_version` - (Optional) Configures the minimum version of TLS required for SSL requests to the SCM site Possible values include: `1.0`, `1.1`, and `1.2`. Defaults to `1.2`.
 - `scm_use_main_ip_restriction` - (Optional) Should the Linux Function App `ip_restriction` configuration be used for the SCM also.
 - `use_32_bit_worker` - (Optional) Should the Linux Web App use a 32-bit worker process. Defaults to `false`.
 - `vnet_route_all_enabled` - (Optional) Should all outbound traffic to have NAT Gateways, Network Security Groups and User Defined Routes applied? Defaults to `false`.
 - `websockets_enabled` - (Optional) Should Web Sockets be enabled. Defaults to `false`.
 - `worker_count` - (Optional) The number of Workers for this Linux Function App.

 ---
 `app_service_logs` block supports the following:
 - `disk_quota_mb` - (Optional) The amount of disk space to use for logs. Valid values are between `25` and `100`. Defaults to `35`.
 - `retention_period_days` - (Optional) The retention period for logs in days. Valid values are between `0` and `99999`.(never delete).

 ---
 `application_stack` block supports the following:
 - `dotnet_version` - (Optional) The version of .NET to use. Possible values include `3.1`, `6.0`, `7.0` and `8.0`.
 - `java_version` - (Optional) The Version of Java to use. Supported versions include `8`, `11` & `17`.
 - `node_version` - (Optional) The version of Node to run. Possible values include `12`, `14`, `16` and `18`.
 - `powershell_core_version` - (Optional) The version of PowerShell Core to run. Possible values are `7`, and `7.2`.
 - `python_version` - (Optional) The version of Python to run. Possible values are `3.12`, `3.11`, `3.10`, `3.9`, `3.8` and `3.7`.
 - `go_version` - (Optional) The version of Go to use. Possible values are `1.18`, and `1.19`.
 - `ruby_version` - (Optional) The version of Ruby to use. Possible values are `2.6`, and `2.7`.
 - `java_server` - (Optional) The Java server type. Possible values are `JAVA`, `TOMCAT`, and `JBOSSEAP`.
 - `java_server_version` - (Optional) The version of the Java server to use.
 - `php_version` - (Optional) The version of PHP to use. Possible values are `7.4`, `8.0`, `8.1`, and `8.2`.
 - `use_custom_runtime` - (Optional) Should the Linux Function App use a custom runtime?
 - `use_dotnet_isolated_runtime` - (Optional) Should the DotNet process use an isolated runtime. Defaults to `false`.

 ---
 `docker` block supports the following:
 - `image_name` - (Required) The name of the Docker image to use.
 - `image_tag` - (Required) The image tag of the image to use.
 - `registry_password` - (Optional) The password for the account to use to connect to the registry.
 - `registry_url` - (Required) The URL of the docker registry.
 - `registry_username` - (Optional) The username to use for connections to the registry.

 ---
 `cors` block supports the following:
 - `allowed_origins` - (Optional) Specifies a list of origins that should be allowed to make cross-origin calls.
 - `support_credentials` - (Optional) Are credentials allowed in CORS requests? Defaults to `false`.

 ---
 `ip_restriction` block supports the following:
 - `action` - (Optional) The action to take. Possible values are `Allow` or `Deny`. Defaults to `Allow`.
 - `ip_address` - (Optional) The CIDR notation of the IP or IP Range to match. For example: `10.0.0.0/24` or `192.168.10.1/32`
 - `name` - (Optional) The name which should be used for this `ip_restriction`.
 - `priority` - (Optional) The priority value of this `ip_restriction`. Defaults to `65000`.
 - `service_tag` - (Optional) The Service Tag used for this IP Restriction.
 - `virtual_network_subnet_id` - (Optional) The Virtual Network Subnet ID used for this IP Restriction.

 ---
 `headers` block supports the following:
 - `x_azure_fdid` - (Optional) Specifies a list of Azure Front Door IDs.
 - `x_fd_health_probe` - (Optional) Specifies if a Front Door Health Probe should be expected. The only possible value is `1`.
 - `x_forwarded_for` - (Optional) Specifies a list of addresses for which matching should be applied. Omitting this value means allow any.
 - `x_forwarded_host` - (Optional) Specifies a list of Hosts for which matching should be applied.

 ---
 `scm_ip_restriction` block supports the following:
 - `action` - (Optional) The action to take. Possible values are `Allow` or `Deny`. Defaults to `Allow`.
 - `ip_address` - (Optional) The CIDR notation of the IP or IP Range to match. For example: `10.0.0.0/24` or `192.168.10.1/32`
 - `name` - (Optional) The name which should be used for this `ip_restriction`.
 - `priority` - (Optional) The priority value of this `ip_restriction`. Defaults to `65000`.
 - `service_tag` - (Optional) The Service Tag used for this IP Restriction.
 - `virtual_network_subnet_id` - (Optional) The Virtual Network Subnet ID used for this IP Restriction.

 ---
 `headers` block supports the following:
 - `x_azure_fdid` - (Optional) Specifies a list of Azure Front Door IDs.
 - `x_fd_health_probe` - (Optional) Specifies if a Front Door Health Probe should be expected. The only possible value is `1`.
 - `x_forwarded_for` - (Optional) Specifies a list of addresses for which matching should be applied. Omitting this value means allow any.
 - `x_forwarded_host` - (Optional) Specifies a list of Hosts for which matching should be applied.

Type:

```hcl
object({
    always_on                                     = optional(bool, false) # when running in a Consumption or Premium Plan, `always_on` feature should be turned off. Please turn it off before upgrading the service plan from standard to premium.
    api_definition_url                            = optional(string)      # (Optional) The URL of the OpenAPI (Swagger) definition that provides schema for the function's HTTP endpoints.
    api_management_api_id                         = optional(string)      # (Optional) The API Management API identifier.
    app_command_line                              = optional(string)      # (Optional) The command line to launch the application.
    auto_heal_enabled                             = optional(bool)        # (Optional) Should auto-heal be enabled for the Function App?
    app_scale_limit                               = optional(number)      # (Optional) The maximum number of workers that the Function App can scale out to.
    application_insights_connection_string        = optional(string)      # (Optional) The connection string of the Application Insights resource to send telemetry to.
    application_insights_key                      = optional(string)      # (Optional) The instrumentation key of the Application Insights resource to send telemetry to.
    container_registry_managed_identity_client_id = optional(string)
    container_registry_use_managed_identity       = optional(bool)
    default_documents                             = optional(list(string))            #(Optional) Specifies a list of Default Documents for the Windows Function App.
    elastic_instance_minimum                      = optional(number)                  #(Optional) The number of minimum instances for this Windows Function App. Only affects apps on Elastic Premium plans.
    ftps_state                                    = optional(string, "Disabled")      #(Optional) State of FTP / FTPS service for this Windows Function App. Possible values include: AllAllowed, FtpsOnly and Disabled. Defaults to Disabled.
    health_check_eviction_time_in_min             = optional(number)                  #(Optional) The amount of time in minutes that a node can be unhealthy before being removed from the load balancer. Possible values are between 2 and 10. Only valid in conjunction with health_check_path.
    health_check_path                             = optional(string)                  #(Optional) The path to be checked for this Windows Function App health.
    http2_enabled                                 = optional(bool, false)             #(Optional) Specifies if the HTTP2 protocol should be enabled. Defaults to false.
    ip_restriction_default_action                 = optional(string, "Allow")         #(Optional) The default action for IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
    load_balancing_mode                           = optional(string, "LeastRequests") #(Optional) The Site load balancing mode. Possible values include: WeightedRoundRobin, LeastRequests, LeastResponseTime, WeightedTotalTraffic, RequestHash, PerSiteRoundRobin. Defaults to LeastRequests if omitted.
    local_mysql_enabled                           = optional(bool, false)             #(Optional) Should local MySQL be enabled. Defaults to false.
    managed_pipeline_mode                         = optional(string, "Integrated")    #(Optional) Managed pipeline mode. Possible values include: Integrated, Classic. Defaults to Integrated.
    minimum_tls_version                           = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
    pre_warmed_instance_count                     = optional(number)                  #(Optional) The number of pre-warmed instances for this Windows Function App. Only affects apps on an Elastic Premium plan.
    remote_debugging_enabled                      = optional(bool, false)             #(Optional) Should Remote Debugging be enabled. Defaults to false.
    remote_debugging_version                      = optional(string)                  #(Optional) The Remote Debugging Version. Possible values include VS2017, VS2019, and VS2022.
    runtime_scale_monitoring_enabled              = optional(bool)                    #(Optional) Should runtime scale monitoring be enabled.
    scm_ip_restriction_default_action             = optional(string, "Allow")         #(Optional) The default action for SCM IP restrictions. Possible values include: Allow and Deny. Defaults to Allow.
    scm_minimum_tls_version                       = optional(string, "1.2")           #(Optional) Configures the minimum version of TLS required for SSL requests to Kudu. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2.
    scm_use_main_ip_restriction                   = optional(bool, false)             #(Optional) Should the SCM use the same IP restrictions as the main site. Defaults to false.
    use_32_bit_worker                             = optional(bool, false)             #(Optional) Should the 32-bit worker process be used. Defaults to false.
    vnet_route_all_enabled                        = optional(bool, true)              #(Optional) Should all traffic be routed to the virtual network. Defaults to false.
    websockets_enabled                            = optional(bool, false)             #(Optional) Should Websockets be enabled. Defaults to false.
    worker_count                                  = optional(number)                  #(Optional) The number of workers for this Windows Function App. Only affects apps on an Elastic Premium plan.
    app_service_logs = optional(map(object({
      disk_quota_mb         = optional(number, 35)
      retention_period_days = optional(number)
    })), {})
    application_stack = optional(map(object({
      dotnet_version              = optional(string)
      java_version                = optional(string)
      node_version                = optional(string)
      powershell_core_version     = optional(string)
      python_version              = optional(string)
      go_version                  = optional(string)
      ruby_version                = optional(string)
      java_server                 = optional(string)
      java_server_version         = optional(string)
      php_version                 = optional(string)
      use_custom_runtime          = optional(bool)
      use_dotnet_isolated_runtime = optional(bool)
      docker = optional(list(object({
        image_name        = string
        image_tag         = string
        registry_password = optional(string)
        registry_url      = string
        registry_username = optional(string)
      })))
      current_stack                = optional(string)
      docker_image_name            = optional(string)
      docker_registry_url          = optional(string)
      docker_registry_username     = optional(string)
      docker_registry_password     = optional(string)
      docker_container_name        = optional(string)
      docker_container_tag         = optional(string)
      java_embedded_server_enabled = optional(bool)
      tomcat_version               = optional(bool)
    })), {})
    cors = optional(map(object({
      allowed_origins     = optional(list(string))
      support_credentials = optional(bool, false)
    })), {}) #(Optional) A cors block as defined above.
    ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {}) #(Optional) One or more ip_restriction blocks as defined above.
    scm_ip_restriction = optional(map(object({
      action                    = optional(string, "Allow")
      ip_address                = optional(string)
      name                      = optional(string)
      priority                  = optional(number, 65000)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
      headers = optional(map(object({
        x_azure_fdid      = optional(list(string))
        x_fd_health_probe = optional(list(string), ["1"])
        x_forwarded_for   = optional(list(string))
        x_forwarded_host  = optional(list(string))
      })), {})
    })), {}) #(Optional) One or more scm_ip_restriction blocks as defined above.
    virtual_application = optional(map(object({
      physical_path   = optional(string, "site\\wwwroot")
      preload_enabled = optional(bool, false)
      virtual_directory = optional(map(object({
        physical_path = optional(string)
        virtual_path  = optional(string)
      })), {})
      virtual_path = optional(string, "/")
      })),
      {
        default = {
          physical_path   = "site\\wwwroot"
          preload_enabled = false
          virtual_path    = "/"
        }
    }) #(Optional) One or more virtual_application blocks as defined above.
  })
```

Default: `{}`

### <a name="input_storage_account"></a> [storage\_account](#input\_storage\_account)

Description:   A map of objects that represent a Storage Account to mount to the Function App.

  - `name` - (Optional) The name of the Storage Account.
  - `resource_group_name` - (Optional) The name of the resource group to deploy the Storage Account in.
  - `account_replication_type` - (Optional) The replication type of the Storage Account. Defaults to `LRS`.

  ```terraform

```

Type:

```hcl
object({
    name                             = optional(string)
    resource_group_name              = optional(string)
    access_tier                      = optional(string, "Hot")
    account_kind                     = optional(string, "StorageV2")
    account_replication_type         = optional(string, "ZRS")
    allow_nested_items_to_be_public  = optional(bool, false)
    allowed_copy_scope               = optional(string, null)
    cross_tenant_replication_enabled = optional(bool, false)
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
      cors_rule = optional(list(object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })))
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
    queue_properties = optional(object({
      cors_rule = optional(list(object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })))
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
    }), null)
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
    static_website = optional(object({
      error_404_document = optional(string)
      index_document     = optional(string)
    }), null)
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
```

Default: `{}`

### <a name="input_storage_account_access_key"></a> [storage\_account\_access\_key](#input\_storage\_account\_access\_key)

Description: The access key of the Storage Account to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)

Description: The name of the existing Storage Account to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_storage_account_primary_connection_string"></a> [storage\_account\_primary\_connection\_string](#input\_storage\_account\_primary\_connection\_string)

Description: The primary connection string of the Storage Account to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_storage_contentshare_name"></a> [storage\_contentshare\_name](#input\_storage\_contentshare\_name)

Description: The name of the existing Storage Account Content Share for the Function App to use.

Type: `string`

Default: `null`

### <a name="input_storage_key_vault_secret_id"></a> [storage\_key\_vault\_secret\_id](#input\_storage\_key\_vault\_secret\_id)

Description: The ID of the secret in the key vault to use for the Storage Account access key.

Type: `string`

Default: `null`

### <a name="input_storage_shares_to_mount"></a> [storage\_shares\_to\_mount](#input\_storage\_shares\_to\_mount)

Description:   A map of objects that represent Storage Account FILE SHARES to mount to the Function App.  
  This functionality is only available for Linux Function Apps, via [documentation](https://learn.microsoft.com/en-us/azure/azure-functions/storage-considerations?tabs=azure-cli)

  The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `access_key` - (Optional) The access key of the Storage Account.
  - `account_name` - (Optional) The name of the Storage Account.
  - `name` - (Optional) The name of the Storage Account to mount.
  - `share_name` - (Optional) The name of the share to mount.
  - `type` - (Optional) The type of Storage Account. Currently, only a `type` of `AzureFiles` is supported. Defaults to `AzureFiles`.
  - `mount_path` - (Optional) The path to mount the Storage Account to.

  ```terraform
  storage_accounts = {
    storacc1 = {
      access_key   = "00000000-0000-0000-0000-000000000000"
      account_name = "example"
      name         = "example"
      share_name   = "example"
      type         = "AzureFiles"
      mount_path   = "/mnt/example"
    }
  }
```

Type:

```hcl
map(object({
    access_key   = string
    account_name = string
    mount_path   = string
    name         = string
    share_name   = string
    type         = optional(string, "AzureFiles")
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: The map of tags to be applied to the resource

Type: `map(string)`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: - `create` - (Defaults to 30 minutes) Used when creating the Linux Function App.
- `delete` - (Defaults to 30 minutes) Used when deleting the Linux Function App.
- `read` - (Defaults to 5 minutes) Used when retrieving the Linux Function App.
- `update` - (Defaults to 30 minutes) Used when updating the Linux Function App.

Type:

```hcl
object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
```

Default: `null`

### <a name="input_virtual_network_subnet_id"></a> [virtual\_network\_subnet\_id](#input\_virtual\_network\_subnet\_id)

Description: The ID of the subnet to deploy the Function App in.

Type: `string`

Default: `null`

### <a name="input_webdeploy_publish_basic_authentication_enabled"></a> [webdeploy\_publish\_basic\_authentication\_enabled](#input\_webdeploy\_publish\_basic\_authentication\_enabled)

Description: Should basic authentication be enabled for web deploy?

Type: `bool`

Default: `true`

### <a name="input_zip_deploy_file"></a> [zip\_deploy\_file](#input\_zip\_deploy\_file)

Description: The path to the zip file to deploy to the Function App.

Type: `string`

Default: `null`

### <a name="input_zone_key_for_link"></a> [zone\_key\_for\_link](#input\_zone\_key\_for\_link)

Description: The key of the zone to link the Function App to.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_deprecated_variables"></a> [deprecated\_variables](#output\_deprecated\_variables)

Description: The list of deprecated variables.

### <a name="output_function_app_private_dns_zone"></a> [function\_app\_private\_dns\_zone](#output\_function\_app\_private\_dns\_zone)

Description: The resource output for the private dns zone of the function app

### <a name="output_function_app_private_dns_zone_id"></a> [function\_app\_private\_dns\_zone\_id](#output\_function\_app\_private\_dns\_zone\_id)

Description: The resource output for the private dns zone of the function app

### <a name="output_name"></a> [name](#output\_name)

Description: This is the name of the resource.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: This is the full output for the resource.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This is the full output for the resource.

### <a name="output_service_plan_resource"></a> [service\_plan\_resource](#output\_service\_plan\_resource)

Description: This is the name of the service plan.

### <a name="output_storage_account_resource"></a> [storage\_account\_resource](#output\_storage\_account\_resource)

Description: This is the full output for the storage account.

## Modules

The following Modules are called:

### <a name="module_function_app"></a> [function\_app](#module\_function\_app)

Source: Azure/avm-res-web-site/azurerm

Version: 0.16.1

### <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone)

Source: Azure/avm-res-network-privatednszone/azurerm

Version: 0.3.2

### <a name="module_service_plan"></a> [service\_plan](#module\_service\_plan)

Source: Azure/avm-res-web-serverfarm/azurerm

Version: 0.4.0

### <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account)

Source: Azure/avm-res-storage-storageaccount/azurerm

Version: 0.5.0

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->