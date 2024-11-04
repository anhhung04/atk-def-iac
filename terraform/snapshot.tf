data "digitalocean_snapshot" "vulnbox" {
  name_regex  = var.snap_shot_description
  region      = var.region
  most_recent = true
}

output "vulnbox_snapshot_id" {
  description = "ID of the vulnbox snapshot"
  value       = data.digitalocean_snapshot.vulnbox.id
}