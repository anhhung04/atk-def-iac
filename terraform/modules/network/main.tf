locals {
  vpc_name = var.vpc_name != "" ? var.vpc_name : "vpc-${var.region}"
}

resource "digitalocean_vpc" "main" {
  name        = local.vpc_name
  region      = var.region
  ip_range    = var.vpc_cidr
  description = "VPC for ${local.vpc_name}"
}
