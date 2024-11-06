module "infra-network" {
  source = "./modules/network"

  region = var.region
  vpc_name = "infra"
  vpc_cidr = "10.10.10.0/24"
}


module "vulnbox-network" {
  source = "./modules/network"

  region = var.region
  vpc_name = "vulnbox"
  vpc_cidr = "10.80.0.0/16"
}

resource "vultr_instance" "master" {
  region            = var.region
  plan              = var.game_master_plan
  label             = "game-master"
  vpc_ids           = [ module.infra-network.vpc_id ]
  backups = "disabled"
  hostname = "game-master"
  tags = ["game-master", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  os_id = 1743
}

resource "vultr_instance" "vpn" {
  region            = var.region
  plan              = var.game_vpn_plan
  label             = "game-vpn"
  vpc_ids           = [ module.infra-network.vpc_id, module.vulnbox-network.vpc_id ]
  backups = "disabled"
  hostname = "game-vpn"
  tags = ["game-vpn", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  os_id = 1743

  connection {
    type = "ssh"
    host = self.main_ip
    user = "root"
    password = self.default_password
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf",
      "echo 'net.ipv4.conf.all.accept_redirects=0' >> /etc/sysctl.conf",
      "sysctl -p"
    ]
  }
}

resource "vultr_instance" "vulnbox" {
  count             = var.num_vulnbox
  region            = var.region
  plan              = var.vulnbox_plan
  label             = "vulnbox-${count.index + 1}"
  vpc_ids        = [module.vulnbox-network.vpc_id]
  backups           = "disabled"
  hostname          = "team-${count.index + 1}"
  tags              = ["vulnbox", "attack-defense"]
  ssh_key_ids       = [data.vultr_ssh_key.exist_key.id]
  snapshot_id       = data.vultr_snapshot.vulnbox.id
  user_data = templatefile("./template/user-data", { 
    password = "@dm1n@101"
  })
}

resource "vultr_instance" "vulnbox-bot" {
  region            = var.region
  plan              = var.vulnbox_bot_plan
  label             = "vulnbox-bot"
  vpc_ids           = [ module.vulnbox-network.vpc_id ]
  backups = "disabled"
  hostname = "team-bot"
  tags = ["vulnbox", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  snapshot_id = data.vultr_snapshot.vulnbox.id
  user_data = templatefile("./template/user-data", { 
    password = "@dm1n@101"
  })
}

resource "local_file" "inventory" {
  filename = "../ansible/inventory.cfg"
  content = templatefile("./template/inventory", {
    master_ip = vultr_instance.master.main_ip,
    vpn_ip = vultr_instance.vpn.main_ip
  })
}

