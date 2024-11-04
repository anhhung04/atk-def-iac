variable "region" {
  description = "The DigitalOcean region to deploy to (e.g., nyc1, sfo2, lon1)"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC. If empty, will be generated based on region"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., 10.10.10.0/24)"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block"
  }

  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 24
    error_message = "VPC CIDR block must have a subnet mask between /16 and /24"
  }
}
