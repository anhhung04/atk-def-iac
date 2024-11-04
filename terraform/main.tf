# Common configurations
locals {
  common_tags = ["attack-defense", "managed-by-terraform"]
  
  droplet_common_config = {
    region     = var.region
    ssh_keys   = local.ssh_key_ids
    tags       = local.common_tags
  }
  
  vpc_config = {
    infra = {
      name = "infra"
      cidr = "10.10.10.0/24"
    }
    vulnbox = {
      name = "vulnbox"
      cidr = "10.80.0.0/16"
    }
  }
}

# Network Configuration
module "infra-network" {
  source = "./modules/network"

  region    = var.region
  vpc_name  = local.vpc_config.infra.name
  vpc_cidr  = local.vpc_config.infra.cidr
}

module "vulnbox-network" {
  source = "./modules/network"

  region    = var.region
  vpc_name  = local.vpc_config.vulnbox.name
  vpc_cidr  = local.vpc_config.vulnbox.cidr
}

# DNS Configuration
module "dns" {
  source = "./modules/dns"

  domain_name = var.domain_name
  zone_id    = var.cloudflare_zone_id
}

# SSH Key Management
data "digitalocean_ssh_key" "existing" {
  name = "attack-defense"
}

# Game Master Instance
resource "digitalocean_droplet" "master" {
  name     = "game-master"
  size     = var.game_master_droplet_size
  image    = "ubuntu-22-04-x64"
  
  vpc_uuid = module.infra-network.vpc_id
  monitoring = true
  
  dynamic "lifecycle_policy" {
    for_each = var.enable_backups ? [1] : []
    content {
      backup_retention_days = 7
    }
  }

  # Use common config
  region   = local.droplet_common_config.region
  ssh_keys = local.droplet_common_config.ssh_keys
  tags     = concat(local.droplet_common_config.tags, ["game-master"])

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      tags,
      image
    ]
  }
}

# VPN Instance
resource "digitalocean_droplet" "vpn" {
  name     = "vpn"
  size     = var.vpn_droplet_size
  image    = "ubuntu-22-04-x64"
  
  vpc_uuid = module.infra-network.vpc_id
  monitoring = true
  
  # Use common config
  region   = local.droplet_common_config.region
  ssh_keys = local.droplet_common_config.ssh_keys
  tags     = concat(local.droplet_common_config.tags, ["vpn"])

  lifecycle {
    ignore_changes = [
      tags,
      image
    ]
  }
}

# Vulnbox Instances
resource "digitalocean_droplet" "vulnbox" {
  count    = var.num_vulnbox
  name     = format("vulnbox-%03d", count.index + 1)  # Better formatting for names
  size     = var.vulnbox_droplet_size
  image    = data.digitalocean_snapshot.vulnbox.id
  
  vpc_uuid = module.vulnbox-network.vpc_id
  monitoring = true
  
  # Use common config
  region   = local.droplet_common_config.region
  ssh_keys = local.droplet_common_config.ssh_keys
  tags     = concat(local.droplet_common_config.tags, ["vulnbox"])

  lifecycle {
    ignore_changes = [
      tags,
      image
    ]
  }
}

