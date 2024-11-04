output "domain_id" {
  description = "The ID of the created domain"
  value       = data.vultr_dns_domain.domain.id
}

output "a_record_ids" {
  description = "The IDs of the created A records"
  value       = vultr_dns_record.a_record[*].id
}

output "cname_record_ids" {
  description = "The IDs of the created CNAME records"
  value       = vultr_dns_record.cname_record[*].id
}

output "zone_id" {
  description = "The Cloudflare Zone ID"
  value       = data.cloudflare_zone.domain.id
}

output "domain_name" {
  description = "The domain name being managed"
  value       = data.cloudflare_zone.domain.name
}

output "a_records" {
  description = "Map of created A records"
  value = {
    for k, record in cloudflare_record.a_records : k => {
      fqdn    = "${record.name}.${data.cloudflare_zone.domain.name}"
      value   = record.value
      ttl     = record.ttl
      proxied = record.proxied
    }
  }
}

output "cname_records" {
  description = "Map of created CNAME records"
  value = {
    for k, record in cloudflare_record.cname_records : k => {
      fqdn    = "${record.name}.${data.cloudflare_zone.domain.name}"
      value   = record.value
      ttl     = record.ttl
      proxied = record.proxied
    }
  }
}
