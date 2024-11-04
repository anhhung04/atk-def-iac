terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.21.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}
