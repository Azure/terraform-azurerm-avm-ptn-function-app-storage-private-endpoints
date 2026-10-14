module "custom_domain_certificate" {
  source   = "Azure/avm-res-web-site/azurerm//modules/certificate"
  version  = "0.24.1"
  for_each = local.custom_domain_certificates

  location              = coalesce(each.value.certificate_location, var.location)
  name                  = each.value.certificate_name
  parent_id             = "/subscriptions/${data.azapi_client_config.function_app.subscription_id}/resourceGroups/${coalesce(each.value.resource_group_name, var.resource_group_name)}"
  server_farm_id        = each.value.app_service_plan_resource_id != null ? each.value.app_service_plan_resource_id : (var.create_service_plan ? module.service_plan[0].resource_id : var.service_plan_resource_id)
  key_vault_id          = each.value.key_vault_id
  key_vault_secret_name = each.value.key_vault_secret_id == null ? null : split("/", each.value.key_vault_secret_id)[4]
  password              = each.value.pfx_password
  pfx_blob              = each.value.pfx_blob
  retry                 = var.retry
  tags                  = local.custom_domain_dns_tags[each.key]
  timeouts              = var.timeouts
}

resource "azapi_resource" "custom_domain_cname" {
  for_each = { for key, domain in var.custom_domains : key => domain if domain.create_cname_records }

  name      = each.value.cname_name
  parent_id = "/subscriptions/${data.azapi_client_config.function_app.subscription_id}/resourceGroups/${coalesce(each.value.zone_resource_group_name, var.resource_group_name)}/providers/Microsoft.Network/dnsZones/${each.value.cname_zone_name}"
  type      = var.resource_types.network_dns_zones_cname
  body = {
    properties = {
      TTL            = each.value.ttl
      metadata       = local.custom_domain_dns_tags[each.key]
      CNAMERecord    = each.value.cname_record == null ? null : { cname = each.value.cname_record }
      targetResource = each.value.cname_target_resource_id == null ? null : { id = each.value.cname_target_resource_id }
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_dns_zones_cname) == 0 ? null : var.ignore_body_changes.network_dns_zones_cname
  ignore_null_property   = true
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azapi_resource" "custom_domain_txt" {
  for_each = { for key, domain in var.custom_domains : key => domain if domain.create_txt_records }

  name      = each.value.txt_name
  parent_id = "/subscriptions/${data.azapi_client_config.function_app.subscription_id}/resourceGroups/${coalesce(each.value.zone_resource_group_name, var.resource_group_name)}/providers/Microsoft.Network/dnsZones/${each.value.txt_zone_name}"
  type      = var.resource_types.network_dns_zones_txt
  body = {
    properties = {
      TTL      = each.value.ttl
      metadata = local.custom_domain_dns_tags[each.key]
      TXTRecords = [
        for record in each.value.txt_records : {
          value = [record.value != "" ? record.value : module.function_app.custom_domain_verification_id]
        }
      ]
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.network_dns_zones_txt) == 0 ? null : var.ignore_body_changes.network_dns_zones_txt
  response_export_values = []
  retry                  = var.retry

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}
