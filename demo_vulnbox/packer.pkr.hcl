packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source = "github.com/hashicorp/proxmox"
    }
    vultr = {
      version = ">= 2.3.0"
      source  = "github.com/vultr/vultr"
    }
  }
}
