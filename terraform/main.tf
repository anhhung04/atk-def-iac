module "vulnbox-network" {
  source = "./modules/network"

  region = var.region
  vpc_name = "vulnbox"
  vpc_cidr = "10.80.0.0/16"
}


module "infra-network" {
  source = "./modules/network"

  region = var.region
  vpc_name = "infra"
  vpc_cidr = "10.10.10.0/24"
}

resource "vultr_instance" "game-master" {
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

resource "vultr_instance" "vulnbox" {
  count             = var.num_vulnbox
  region            = var.region
  plan              = var.vulnbox_plan
  label             = "vulnbox-${count.index + 1}"
  vpc_ids           = [module.game-network.vpc_id]
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
  vpc_ids           = [ module.game-network.vpc_id ]
  backups = "disabled"
  hostname = "team-bot"
  tags = ["vulnbox", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  snapshot_id = data.vultr_snapshot.vulnbox.id
  user_data = templatefile("./template/user-data", { 
    password = "@dm1n@101"
  })
}

