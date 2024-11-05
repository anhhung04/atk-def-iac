module "open-firewall" {
  source = "./modules/firewall"

  firewall_group_description = "${var.environment} firewall group"
  inbound_rules = [
    {
      protocol    = "tcp"
      port_range  = "22"
      subnet      = "0.0.0.0"
      subnet_size = 0
      notes       = "Allow SSH from anywhere"
    },
    {
        protocol    = "tcp"
        port_range  = "1-65535"
        subnet      = "10.80.0.0"
        subnet_size = 16
        notes       = "Allow TCP from VPC"
    },
    {
        protocol    = "udp"
        port_range  = "1-65535"
        subnet      = "10.80.0.0"
        subnet_size = 16
        notes       = "Allow UDP from VPC"
    }
  ]
  outbound_rules = [
    {
      protocol    = "tcp"
      port_range  = "1-65535"
      subnet      = "0.0.0.0"
      subnet_size = 0
      notes       = "Allow all outbound TCP traffic"
    },
    {
      protocol    = "udp"
      port_range  = "1-65535"
      subnet      = "0.0.0.0"
      subnet_size = 0
      notes       = "Allow all outbound UDP traffic"
    }
  ]
}