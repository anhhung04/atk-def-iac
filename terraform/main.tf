module "game-network" {
  source = "./modules/network"

  region = var.region
  vpc_name = "game"
  vpc_cidr = "10.80.0.0/16"
}

resource "vultr_instance" "game-master" {
  region            = var.region
  plan              = "vc2-6c-16gb"
  label             = "game-master"
  vpc_ids           = [ module.game-network.vpc_id ]
  backups = "disabled"
  hostname = "game-master"
  tags = ["game-master", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  os_id = 1743
}

resource "vultr_instance" "vulnbox" {
  count             = 3
  region            = var.region
  plan              = "vc2-4c-8gb"
  label             = "vulnbox-${count.index + 1}"
  vpc_ids           = [module.game-network.vpc_id]
  backups           = "disabled"
  hostname          = "team-${count.index + 1}"
  tags              = ["vulnbox", "attack-defense"]
  ssh_key_ids       = [data.vultr_ssh_key.exist_key.id]
  snapshot_id       = data.vultr_snapshot.vulnbox.id
  user_data         = <<-EOF
timezone: Asia/Ho_Chi_Minh
package_update: true
package_upgrade: true
packages:
  - sudo
users:
  - name: ubuntu
    groups: [adm, sudo]
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    passwd: $6$xyz$ShNnbwk5fmsyVIlzOf8zEg4YdEH2aWRSuY4rJHbzLZRlWcoXbxxoI0hfn0mdXiJCdBJ/lTpKjk.vu5NZOv0UM0
ssh:
  install-server: true
  allow-pw: true
  permit_root_login: true
write_files:
  - path: /etc/netplan/99-custom-network.yaml
    content: |
      network:
        version: 2
        ethernets:
          ens3:
            dhcp4: no
            addresses: [10.80.0.1${count.index + 1}/16]
            gateway4: 10.80.0.1
            nameservers:
              addresses: [8.8.8.8, 8.8.4.4]
runcmd:
  - netplan apply
EOF
}


resource "vultr_instance" "vulnbox-bot" {
  region            = var.region
  plan              = "vc2-2c-4gb"
  label             = "vulnbox-bot"
  vpc_ids           = [ module.game-network.vpc_id ]
  backups = "disabled"
  hostname = "team-bot"
  tags = ["vulnbox", "attack-defense"]
  ssh_key_ids = [data.vultr_ssh_key.exist_key.id]
  snapshot_id = data.vultr_snapshot.vulnbox.id
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


