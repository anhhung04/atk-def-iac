output "vpc_id" {
  description = "ID of the created VPC"
  value       = digitalocean_vpc.main.id
}

output "vpc_urn" {
  description = "URN of the VPC in format do:vpc:<uuid>"
  value       = digitalocean_vpc.main.urn
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = digitalocean_vpc.main.name
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = digitalocean_vpc.main.ip_range
}
