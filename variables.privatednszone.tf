variable "private_dns_zones" {
  type = map(object({
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
    # aaaa_records = optional(map(object({
    #   name                = string
    #   resource_group_name = string
    #   zone_name           = string
    #   ttl                 = number
    #   records             = list(string)
    #   tags                = optional(map(string), null)
    # })), {})
    cname_records = optional(map(object({
      name                = string
      resource_group_name = string
      zone_name           = string
      ttl                 = number
      record              = string
      tags                = optional(map(string), null)
    })), {})
    # mx_records = optional(map(object({
    #   name                = optional(string, "@")
    #   resource_group_name = string
    #   zone_name           = string
    #   ttl                 = number
    #   records = map(object({
    #     preference = number
    #     exchange   = string
    #   }))
    #   tags = optional(map(string), null)
    # })), {})
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
    # srv_records = optional(map(object({
    #   name                = string
    #   resource_group_name = string
    #   zone_name           = string
    #   ttl                 = number
    #   records = map(object({
    #     priority = number
    #     weight   = number
    #     port     = number
    #     target   = string
    #   }))
    #   tags = optional(map(string), null)
    # })), {})
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
  default = {

  }
  description = "A map of private DNS zones to create and associate with the storage account and/or Function App."
}

variable "use_external_managed_dns_for_storage" {
  type        = bool
  default     = false
  description = "Should the module reference an externally managed DNS zone? If true, private DNS zones will not be created by this module."
}
