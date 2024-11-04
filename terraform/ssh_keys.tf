locals {
  ssh_key_names = ["id_ed25519.pub", "attack-defense"]  # Add all possible key names
}

data "digitalocean_ssh_key" "keys" {
  for_each = toset(local.ssh_key_names)
  name     = each.value
}

locals {
  ssh_key_ids = [for key in data.digitalocean_ssh_key.keys : key.id]
}

output "existing_ssh_key_id" {
  value = data.vultr_ssh_key.exist_key.id
}
