variable "region" {
  description = "The Vultr region to deploy to"
  type        = string
}

variable "vultr_api_key" {
  description = "Vultr API Key"
  type        = string
  sensitive   = true
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

variable "game_master_plan" {
  description = "The plan to use for the game master"
  type        = string
}

variable "vulnbox_plan" {
  description = "The plan to use for the vulnbox instances"
  type        = string
}

variable "vulnbox_bot_plan" {
  description = "The plan to use for the vulnbox bot"
  type        = string
}

variable "game_vpn_plan" {
  description = "The plan to use for the game vpn"
  type        = string
}