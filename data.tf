# This helps us get any managed identity information.
#  Assumptions:  In the same subscription as current function app.
data "azurerm_user_assigned_identity" "identities" {
  for_each            = local.managed_identities_parsed
  resource_group_name = each.value.parsed_id.resource_group_name
  name                = each.value.parsed_id.resource_name
}