variable "ignore_body_changes" {
  type = object({
    web_sites               = optional(list(string), [])
    web_sites_slots_config  = optional(list(string), [])
    network_dns_zones_cname = optional(list(string), [])
    network_dns_zones_txt   = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Body-relative dot-notation paths to ignore on directly owned resources. Changes take effect after apply; ignored configuration is not sent to Azure until the path is removed.

- `web_sites` - Unsupported on the content-share update resource; a non-empty value fails explicitly.
- `web_sites_slots_config` - Unsupported on slot authentication update resources; a non-empty value fails explicitly.
- `network_dns_zones_cname` - Paths ignored on custom-domain CNAME records.
- `network_dns_zones_txt` - Paths ignored on custom-domain TXT records.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    web_sites               = optional(string, "Microsoft.Web/sites@2022-03-01")
    web_sites_slots_config  = optional(string, "Microsoft.Web/sites/slots/config@2025-03-01")
    network_dns_zones_cname = optional(string, "Microsoft.Network/dnsZones/CNAME@2018-05-01")
    network_dns_zones_txt   = optional(string, "Microsoft.Network/dnsZones/TXT@2018-05-01")
  })
  default     = {}
  description = <<DESCRIPTION
Resource types and API versions for resources directly owned by the pattern.

- `web_sites` - Function App content-share routing update.
- `web_sites_slots_config` - Slot authentication configuration.
- `network_dns_zones_cname` - Custom-domain CNAME records.
- `network_dns_zones_txt` - Custom-domain verification TXT records.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = "Retry settings for supported AzAPI resources owned by the pattern and the current web-site module."
}
