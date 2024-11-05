module "dns" {
  source = "./modules/dns"

  domain_name = var.domain_name
  a_records = [
    {
      name = "game"
      ip   = vultr_instance.game-master.main_ip
    }
  ]
}
