variable "private_dns_zones" {
  type = map(object({
    domain_name         = string
    resource_group_name = string
    tags                = optional(map(string), null)
    virtual_network_links = optional(map(object({
      vnetlinkname     = string
      vnetid           = string
      autoregistration = optional(bool, false)
      tags             = optional(map(string), null)
    })), {})
  }))
  default = {

  }
  description = "A map of private DNS zones to create and associate with the storage account and/or Function App."
}