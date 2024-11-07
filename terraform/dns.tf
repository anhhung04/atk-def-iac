module "dns" {
  source = "./modules/dns"

  domain_name = var.domain_name
  ttl = 0
  a_records = [
    {
      name = "game"
      ip   = vultr_instance.master.main_ip
    },
    {
      name = "vpn"
      ip   = vultr_instance.vpn.main_ip
    }
  ]
}
