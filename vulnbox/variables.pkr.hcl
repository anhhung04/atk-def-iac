variable "proxmox_api_url" {
  type    = string
  default = env("PROXMOX_API_URL")
}

variable "proxmox_api_token_id" {
  type    = string
  default = env("PROXMOX_API_TOKEN_ID")
}

variable "proxmox_api_token_secret" {
  type      = string
  default   = env("PROXMOX_API_TOKEN_SECRET")
  sensitive = true
}

variable "vultr_api_key" {
  type = string
  sensitive = true
  default = env("VULTR_API_KEY")
}

variable "digitalocean_api_token" {
  type = string
  sensitive = true
  default = env("DIGITALOCEAN_API_TOKEN")
}

variable "region" {
  type = string
  default = "sgp1"
}

variable "plan" {
  type = string
  default = "s-2vcpu-4gb"
}

variable "os_id" {
  type = string
  default = "ubuntu-22-04-x64"
}