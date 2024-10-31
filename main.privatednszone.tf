module "private_dns_zone" {
  for_each = { for zone, zone_values in var.private_dns_zones : zone => zone_values if var.private_dns_zones != null || length(var.private_dns_zones) > 0 }

  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.1.2"

  enable_telemetry = var.enable_telemetry

  domain_name         = each.value.domain_name
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags

  a_records = each.value.a_records

  virtual_network_links = each.value.virtual_network_links

}
