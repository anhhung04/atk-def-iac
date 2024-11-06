output "game_vpc_id" {
  description = "ID of the created game VPC"
  value       = module.vulnbox-network.vpc_id
}

output "infra_vpc_id" {
  description = "ID of the created vpc VPC"
  value       = module.infra-network.vpc_id
}

output "instance_ids" {
  description = "IDs of the created instances"
  value       = concat([
    for instance in vultr_instance.vulnbox : instance.id
  ],[
    vultr_instance.vulnbox-bot.id,
    vultr_instance.master.id
  ])
}

output "instance_ips" {
  description = "Public IPs of the created instances"
  value       = concat([
    for instance in vultr_instance.vulnbox : instance.main_ip
  ] , [
    vultr_instance.vulnbox-bot.main_ip,
    vultr_instance.master.main_ip
  ])
}

output "domain_id" {
  description = "The ID of the created domain"
  value       = module.dns.domain_id
}

output "a_record_ids" {
  description = "The IDs of the created A records"
  value       = module.dns.a_record_ids
}

output "cname_record_ids" {
  description = "The IDs of the created CNAME records"
  value       = module.dns.cname_record_ids
}
