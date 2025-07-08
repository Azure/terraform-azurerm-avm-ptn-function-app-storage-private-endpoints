module "private_dns_zone" {
  source   = "Azure/avm-res-network-privatednszone/azurerm"
  version  = "0.3.4"
  for_each = { for zone, zone_values in var.private_dns_zones : zone => zone_values if var.private_dns_zones != null || length(var.private_dns_zones) > 0 }

  domain_name           = each.value.domain_name
  resource_group_name   = each.value.resource_group_name
  a_records             = each.value.a_records
  enable_telemetry      = var.enable_telemetry
  tags                  = each.value.tags
  virtual_network_links = each.value.virtual_network_links
}
