variable "region" {
  description = "The DigitalOcean region to deploy to"
  type        = string
  default     = "sfo3"
}

variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
}

variable "domain_name" {
  description = "The domain name to manage"
  type        = string
}

variable "num_vulnbox" {
  description = "The number of vulnbox instances to deploy"
  type        = number
}

variable "snap_shot_description" {
  description = "The description of the snapshot to use for the vulnbox"
  type        = string 
}

variable "game_master_droplet_size" {
  description = "The size slug for the game master droplet"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "vulnbox_droplet_size" {
  description = "The size slug for the vulnbox droplets"
  type        = string
  default     = "s-2vcpu-2gb"
}

variable "vpn_droplet_size" {
  description = "The size slug for the VPN droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "enable_backups" {
  description = "Enable automatic backups for critical instances"
  type        = bool
  default     = true
}

variable "monitoring_alert_email" {
  description = "Email address for monitoring alerts"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Name of the project for resource organization"
  type        = string
  default     = "attack-defense"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
  default     = "prod"
}

variable "generate_inventory" {
  description = "Whether to generate the Ansible inventory file"
  type        = bool
  default     = true
}