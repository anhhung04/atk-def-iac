module "game-network" {
  source = "./modules/network"

  region = var.region
  vpc_name = "game"
  vpc_cidr = "10.80.0.0/16"
}

resource "vultr_instance" "vulnbox" {
  count             = 3
  region            = var.region
  plan              = "vc2-4c-8gb"
  label             = "vulnbox-${count.index + 1}"
  vpc_ids           = [ module.game-network.vpc_id ]
  firewall_group_id = module.open-firewall.firewall_group_id
  backups = "disabled"
  hostname = "team-${count.index + 1}"
  tags = ["vulnbox", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  snapshot_id = data.vultr_snapshot.vulnbox.id
}

resource "vultr_instance" "vulnbox-bot" {
  region            = var.region
  plan              = "vc2-2c-4gb"
  label             = "vulnbox-bot"
  vpc_ids           = [ module.game-network.vpc_id ]
  firewall_group_id = module.open-firewall.firewall_group_id
  backups = "disabled"
  hostname = "team-bot"
  tags = ["vulnbox", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  snapshot_id = data.vultr_snapshot.vulnbox.id
}

resource "vultr_instance" "game-master" {
  region            = var.region
  plan              = "vc2-6c-16gb"
  label             = "game-master"
  vpc_ids           = [ module.game-network.vpc_id ]
  firewall_group_id = module.open-firewall.firewall_group_id
  backups = "disabled"
  hostname = "game-master"
  tags = ["game-master", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  os_id = "1723"
}


# resource "local_file" "inventory" {
#   content = <<-EOF
# [machine]
# %{ for instance_ip in module.instance.instance_ips ~}
# ${instance_ip}
# %{ endfor ~}
# EOF

#   filename = "${path.module}/../ansible/inventory.cfg"
# }


