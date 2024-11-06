locals {
  vpc_cidr = var.vpc_cidr
  vpc_cidr_split = split("/", var.vpc_cidr)
  vpc_subnet = local.vpc_cidr_split[0]
  vpc_subnet_mask = local.vpc_cidr_split[1]
}

resource "vultr_vpc2" "main" {
  region     = var.region
  description = var.vpc_name
  ip_block    = local.vpc_subnet
  prefix_length = tonumber(local.vpc_subnet_mask)
}
