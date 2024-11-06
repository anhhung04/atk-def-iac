data "vultr_snapshot" "vulnbox" {
    filter {
        name   = "description"
        values = [var.snap_shot_description]
    }
}

output "vulnbox_snapshot_id" {
    value = data.vultr_snapshot.vulnbox.id
}