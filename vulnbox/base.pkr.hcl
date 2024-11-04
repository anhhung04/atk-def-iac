source "proxmox-iso" "ubuntu" {

  proxmox_url = "${var.proxmox_api_url}"
  username    = "${var.proxmox_api_token_id}"
  token       = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify = true

  node                 = "prx1"
  vm_name              = "vulnbox-template"
  template_description = "Vulnbox Image"
  pool                 = "BKISC"

  iso_file = "local:iso/ubuntu-22.04.1-live-server-amd64.iso"
  # iso_url          = "https://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04.1-live-server-amd64.iso"
  # iso_checksum     = "10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
  iso_storage_pool = "local"
  unmount_iso      = true
  os               = "l26"

  qemu_agent = true

  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "20G"
    storage_pool = "lvm-thin"
    type         = "virtio"
  }

  cores   = 1
  sockets = 2

  memory = 4096

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  cloud_init              = true
  cloud_init_storage_pool = "lvm-thin"

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://185.111.159.172:3000/ ---<wait>",
    "<f10><wait>"
  ]
  boot      = "c"
  boot_wait = "5s"

  http_directory = "data"
  http_port_min = 3000
  http_port_max = 3000

  ssh_username = "ubuntu"
  ssh_password = "password"
  ssh_timeout = "60m"
}

source "vultr" "ubuntu" {
  api_key = var.vultr_api_key
  region = var.region
  plan = var.plan
  os_id = var.os_id
  snapshot_description = "Vulnbox with Ubuntu Base ${formatdate("YYYY-MM-DD", timestamp())}"
  ssh_username = "root"
}