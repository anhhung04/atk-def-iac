data "vultr_snapshot" "vulnbox" {
    filter {
        name   = "description"
        values = ["Vulnbox with Ubuntu Base 2024-11-05 11-22"]
    }
}

output "vulnbox_snapshot_id" {
    value = data.vultr_snapshot.vulnbox.id
}