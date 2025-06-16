module "service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "0.4.0"
  count   = var.create_service_plan ? 1 : 0

  location                     = coalesce(var.service_plan.location, var.location)
  name                         = coalesce(var.service_plan.name, "${var.name}-asp")
  os_type                      = var.os_type
  resource_group_name          = coalesce(var.service_plan.resource_group_name, var.resource_group_name)
  app_service_environment_id   = var.service_plan.app_service_environment_resource_id
  enable_telemetry             = var.enable_telemetry
  lock                         = var.service_plan.lock
  maximum_elastic_worker_count = var.service_plan.maximum_elastic_worker_count
  per_site_scaling_enabled     = var.service_plan.per_site_scaling_enabled
  role_assignments             = var.service_plan.role_assignments
  sku_name                     = var.service_plan.sku_name
  tags                         = var.tags
  worker_count                 = var.service_plan.worker_count
  zone_balancing_enabled       = var.service_plan.zone_balancing_enabled
}