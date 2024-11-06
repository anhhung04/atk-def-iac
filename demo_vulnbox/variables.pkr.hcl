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

variable "region" {
  type = string
  default = "sgp"
}

variable "plan" {
  type = string
  default = "vc2-1c-2gb"
}

variable "os_id" {
  type = number
  default = 1743
}