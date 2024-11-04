data "cloudflare_zone" "domain" {
  zone_id = var.zone_id
}

resource "cloudflare_record" "a_records" {
  for_each = var.a_records

  zone_id  = data.cloudflare_zone.domain.id
  type     = "A"
  name     = each.value.name
  value    = each.value.value
  ttl      = lookup(each.value, "ttl", var.ttl)
  proxied  = lookup(each.value, "proxied", var.enable_proxy_default)
  priority = lookup(each.value, "priority", null)

  lifecycle {
    # Prevent unnecessary updates when priority is not set
    ignore_changes = [
      priority
    ]
  }
}

resource "cloudflare_record" "cname_records" {
  for_each = var.cname_records

  zone_id  = data.cloudflare_zone.domain.id
  type     = "CNAME"
  name     = each.value.name
  value    = each.value.value
  ttl      = lookup(each.value, "ttl", var.ttl)
  proxied  = lookup(each.value, "proxied", var.enable_proxy_default)
  priority = lookup(each.value, "priority", null)

  lifecycle {
    # Prevent unnecessary updates when priority is not set
    ignore_changes = [
      priority
    ]
  }
}
