locals {
  slot_auth_v1 = {
    for key in keys(var.deployment_slots) : key => local.auth_settings_adapted["slot:${key}"]
    if local.auth_settings_adapted["slot:${key}"] != null && local.auth_settings_v2_adapted["slot:${key}"] == null
  }
  slot_auth_v2 = {
    for key in keys(var.deployment_slots) : key => local.auth_settings_v2_adapted["slot:${key}"]
    if local.auth_settings_v2_adapted["slot:${key}"] != null
  }
  slot_auth_v1_properties = {
    for key, auth in local.slot_auth_v1 : key => {
      enabled                                 = auth.enabled
      runtimeVersion                          = auth.runtime_version
      tokenStoreEnabled                       = auth.token_store_enabled
      tokenRefreshExtensionHours              = auth.token_refresh_extension_hours
      unauthenticatedClientAction             = auth.unauthenticated_client_action
      issuer                                  = auth.issuer
      allowedExternalRedirectUrls             = auth.allowed_external_redirect_urls
      additionalLoginParams                   = auth.additional_login_parameters
      defaultProvider                         = auth.default_provider
      clientId                                = try(auth.active_directory.client_id, null)
      allowedAudiences                        = try(auth.active_directory.allowed_audiences, null)
      clientSecret                            = try(auth.active_directory.client_secret, null)
      clientSecretSettingName                 = try(auth.active_directory.client_secret_setting_name, null)
      facebookAppId                           = try(auth.facebook.app_id, null)
      facebookAppSecret                       = try(auth.facebook.app_secret, null)
      facebookAppSecretSettingName            = try(auth.facebook.app_secret_setting_name, null)
      facebookOAuthScopes                     = try(auth.facebook.oauth_scopes, null)
      gitHubClientId                          = try(auth.github.client_id, null)
      gitHubClientSecret                      = try(auth.github.client_secret, null)
      gitHubClientSecretSettingName           = try(auth.github.client_secret_setting_name, null)
      gitHubOAuthScopes                       = try(auth.github.oauth_scopes, null)
      googleClientId                          = try(auth.google.client_id, null)
      googleClientSecret                      = try(auth.google.client_secret, null)
      googleClientSecretSettingName           = try(auth.google.client_secret_setting_name, null)
      googleOAuthScopes                       = try(auth.google.oauth_scopes, null)
      microsoftAccountClientId                = try(auth.microsoft.client_id, null)
      microsoftAccountClientSecret            = try(auth.microsoft.client_secret, null)
      microsoftAccountClientSecretSettingName = try(auth.microsoft.client_secret_setting_name, null)
      microsoftAccountOAuthScopes             = try(auth.microsoft.oauth_scopes, null)
      twitterConsumerKey                      = try(auth.twitter.consumer_key, null)
      twitterConsumerSecret                   = try(auth.twitter.consumer_secret, null)
      twitterConsumerSecretSettingName        = try(auth.twitter.consumer_secret_setting_name, null)
    }
  }
  slot_auth_social_providers = {
    for key, auth in local.slot_auth_v2 : key => {
      apple                  = auth.identity_providers.apple
      facebook               = auth.identity_providers.facebook
      gitHub                 = auth.identity_providers.github
      google                 = auth.identity_providers.google
      legacyMicrosoftAccount = auth.identity_providers.legacy_microsoft_account
      twitter                = auth.identity_providers.twitter
    }
  }
  slot_auth_v2_providers = {
    for key, auth in local.slot_auth_v2 : key => merge(
      merge([
        for provider_name, provider in local.slot_auth_social_providers[key] : provider == null ? {} : {
          (provider_name) = merge({
            enabled = provider.enabled
            registration = provider_name == "twitter" ? {
              consumerKey               = provider.registration.consumer_key
              consumerSecretSettingName = provider.registration.consumer_secret_setting_name
              } : provider_name == "facebook" ? {
              appId                = provider.registration.app_id
              appSecretSettingName = provider.registration.app_secret_setting_name
              } : {
              clientId                = provider.registration.client_id
              clientSecretSettingName = provider.registration.client_secret_setting_name
            }
            },
            provider_name == "twitter" ? {} : { login = provider.login },
            provider_name == "facebook" ? { graphApiVersion = provider.graph_api_version } : {},
            contains(["google", "legacyMicrosoftAccount"], provider_name) ? {
              validation = { allowedAudiences = provider.validation.allowed_audiences }
            } : {}
          )
        }
      ]...),
      auth.identity_providers.azure_active_directory == null ? {} : {
        azureActiveDirectory = {
          enabled = auth.identity_providers.azure_active_directory.enabled
          registration = {
            clientId                          = auth.identity_providers.azure_active_directory.registration.client_id
            clientSecretCertificateThumbprint = auth.identity_providers.azure_active_directory.registration.client_secret_certificate_thumbprint
            clientSecretSettingName           = auth.identity_providers.azure_active_directory.registration.client_secret_setting_name
            openIdIssuer                      = auth.identity_providers.azure_active_directory.registration.open_id_issuer
          }
          login = {
            disableWWWAuthenticate = auth.identity_providers.azure_active_directory.login.disable_www_authenticate
            loginParameters        = auth.identity_providers.azure_active_directory.login.login_parameters
          }
          validation = {
            allowedAudiences = auth.identity_providers.azure_active_directory.validation.allowed_audiences
            defaultAuthorizationPolicy = {
              allowedApplications = auth.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_applications
              allowedPrincipals = {
                groups     = auth.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.groups
                identities = auth.identity_providers.azure_active_directory.validation.default_authorization_policy.allowed_principals.identities
              }
            }
            jwtClaimChecks = {
              allowedClientApplications = auth.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_client_applications
              allowedGroups             = auth.identity_providers.azure_active_directory.validation.jwt_claim_checks.allowed_groups
            }
          }
        }
      },
      auth.identity_providers.azure_static_web_apps == null ? {} : {
        azureStaticWebApps = {
          enabled      = auth.identity_providers.azure_static_web_apps.enabled
          registration = { clientId = auth.identity_providers.azure_static_web_apps.registration.client_id }
        }
      },
      {
        customOpenIdConnectProviders = {
          for provider_key, provider in auth.identity_providers.custom_open_id_connect_providers : provider_key => {
            enabled = provider.enabled
            login = {
              nameClaimType = provider.login.name_claim_type
              scopes        = provider.login.scopes
            }
            registration = {
              clientId = provider.registration.client_id
              clientCredential = {
                method                  = provider.registration.client_credential.method
                clientSecretSettingName = provider.registration.client_credential.client_secret_setting_name
              }
              openIdConnectConfiguration = {
                authorizationEndpoint        = provider.registration.open_id_connect_configuration.authorization_endpoint
                certificationUri             = provider.registration.open_id_connect_configuration.certification_uri
                issuer                       = provider.registration.open_id_connect_configuration.issuer
                tokenEndpoint                = provider.registration.open_id_connect_configuration.token_endpoint
                wellKnownOpenIdConfiguration = provider.registration.open_id_connect_configuration.well_known_open_id_configuration
              }
            }
          }
        }
      }
    )
  }
  slot_auth_v2_properties = {
    for key, auth in local.slot_auth_v2 : key => merge({
      platform = {
        enabled        = auth.auth_enabled
        runtimeVersion = auth.runtime_version
        configFilePath = auth.config_file_path
      }
      globalValidation = {
        excludedPaths               = auth.excluded_paths
        redirectToProvider          = auth.redirect_to_provider
        requireAuthentication       = auth.require_authentication
        unauthenticatedClientAction = auth.unauthenticated_client_action
      }
      httpSettings = merge({
        requireHttps = auth.require_https
        routes       = { apiPrefix = auth.http_route_api_prefix }
        },
        auth.forward_proxy_convention == "NoProxy" ? {} : {
          forwardProxy = {
            convention            = auth.forward_proxy_convention
            customHostHeaderName  = auth.forward_proxy_custom_host_header_name
            customProtoHeaderName = auth.forward_proxy_custom_proto_header_name
          }
        }
      )
      identityProviders = local.slot_auth_v2_providers[key]
      },
      auth.login == null ? {} : {
        login = {
          allowedExternalRedirectUrls   = auth.login.allowed_external_redirect_urls
          preserveUrlFragmentsForLogins = auth.login.preserve_url_fragments_for_logins
          cookieExpiration = {
            convention       = auth.login.cookie_expiration.convention
            timeToExpiration = auth.login.cookie_expiration.time_to_expiration
          }
          nonce = {
            nonceExpirationInterval = auth.login.nonce.nonce_expiration_interval
            validateNonce           = auth.login.nonce.validate_nonce
          }
          routes = { logoutEndpoint = auth.login.routes.logout_endpoint }
          tokenStore = {
            enabled                    = auth.login.token_store.enabled
            tokenRefreshExtensionHours = auth.login.token_store.token_refresh_extension_hours
            azureBlobStorage           = { sasUrlSettingName = auth.login.token_store.azure_blob_storage.sas_url_setting_name }
            fileSystem                 = { directory = auth.login.token_store.file_system.directory }
          }
        }
      }
    )
  }
}
