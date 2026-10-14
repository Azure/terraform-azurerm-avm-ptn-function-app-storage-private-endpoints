module "custom_domain_binding" {
  source   = "Azure/avm-res-web-site/azurerm//modules/hostname_binding"
  version  = "0.24.1"
  for_each = var.custom_domains

  hostname = each.value.hostname
  parent_id = each.value.slot_as_target ? module.function_app.deployment_slots[each.value.app_service_slot_key].resource_id : (
    each.value.app_service_name == null ? module.function_app.resource_id :
    "/subscriptions/${data.azapi_client_config.function_app.subscription_id}/resourceGroups/${coalesce(each.value.resource_group_name, var.resource_group_name)}/providers/Microsoft.Web/sites/${each.value.app_service_name}"
  )
  retry      = var.retry
  ssl_state  = each.value.ssl_state
  thumbprint = local.custom_domain_bindings[each.key].thumbprint
  timeouts   = var.timeouts

  depends_on = [
    azapi_resource.custom_domain_cname,
    azapi_resource.custom_domain_txt
  ]
}
