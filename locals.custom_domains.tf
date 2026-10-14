locals {
  custom_domain_certificates = {
    for key, domain in var.custom_domains : key => domain if domain.create_certificate
  }
  custom_domain_bindings = {
    for key, domain in var.custom_domains : key => {
      hostname   = domain.hostname
      ssl_state  = domain.ssl_state
      thumbprint = domain.thumbprint_key == null ? domain.thumbprint_value : module.custom_domain_certificate[domain.thumbprint_key].thumbprint
    }
  }
  custom_domain_dns_tags = {
    for key, domain in var.custom_domains : key => domain.inherit_tags ? merge(domain.tags, var.tags) : domain.tags
  }
}
