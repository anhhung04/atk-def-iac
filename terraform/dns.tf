module "dns" {
  source = "./modules/dns"

  domain_name = var.domain_name
  zone_id    = var.cloudflare_zone_id
  
  a_records = {
    game = {
      name  = "game"
      value = digitalocean_droplet.master.ipv4_address
      proxied = true
    },
    vpn = {
      name  = "vpn"
      value = digitalocean_droplet.vpn.ipv4_address
      proxied = false  # VPN needs direct connection
    }
  }

  # Enable Cloudflare proxy by default for better security
  enable_proxy_default = true
  
  # Use automatic TTL for proxied records
  ttl = 1
}
