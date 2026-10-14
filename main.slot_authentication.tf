resource "azapi_update_resource" "slot_auth_settings" {
  for_each = local.slot_auth_v1

  name                   = "authsettings"
  parent_id              = module.function_app.deployment_slots[each.key].resource_id
  type                   = var.resource_types.web_sites_slots_config
  body                   = { properties = local.slot_auth_v1_properties[each.key] }
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

  lifecycle {
    precondition {
      condition     = length(var.ignore_body_changes.web_sites_slots_config) == 0
      error_message = "ignore_body_changes.web_sites_slots_config is unsupported on slot authentication update resources."
    }
  }
}

resource "azapi_update_resource" "slot_auth_settings_v2" {
  for_each = local.slot_auth_v2

  name                   = "authsettingsV2"
  parent_id              = module.function_app.deployment_slots[each.key].resource_id
  type                   = var.resource_types.web_sites_slots_config
  body                   = { properties = local.slot_auth_v2_properties[each.key] }
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

  lifecycle {
    precondition {
      condition     = length(var.ignore_body_changes.web_sites_slots_config) == 0
      error_message = "ignore_body_changes.web_sites_slots_config is unsupported on slot authentication update resources."
    }
  }
}
