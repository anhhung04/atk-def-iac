variable "domain_name" {
  description = "The domain name to manage in Cloudflare"
  type        = string
}

variable "zone_id" {
  description = "The Cloudflare Zone ID for the domain"
  type        = string
}

variable "a_records" {
  description = "Map of A records to create. The key will be used as the record name."
  type = map(object({
    name     = string
    value    = string
    ttl      = optional(number, 1) # 1 = automatic
    proxied  = optional(bool, true) # Enable Cloudflare proxy by default
    priority = optional(number)
  }))
  default = {}
}

variable "cname_records" {
  description = "Map of CNAME records to create. The key will be used as the record name."
  type = map(object({
    name     = string
    value    = string
    ttl      = optional(number, 1) # 1 = automatic
    proxied  = optional(bool, true) # Enable Cloudflare proxy by default
    priority = optional(number)
  }))
  default = {}
}

variable "enable_proxy_default" {
  description = "Default setting for Cloudflare proxy (orange cloud). Can be overridden per record."
  type        = bool
  default     = true
}

variable "ttl" {
  description = "Default TTL for DNS records (in seconds). Set to 1 for automatic."
  type        = number
  default     = 1

  validation {
    condition     = var.ttl == 1 || (var.ttl >= 120 && var.ttl <= 2147483647)
    error_message = "TTL must be either 1 (automatic) or between 120 and 2147483647 seconds"
  }
}
