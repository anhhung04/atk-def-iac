resource "digitalocean_monitor_alert" "cpu_alert" {
  alerts {
    email = [var.monitoring_alert_email]
  }
  window      = "5m"
  type        = "v1/insights/droplet/cpu"
  compare     = "GreaterThan"
  value       = 90
  enabled     = var.monitoring_alert_email != ""
  
  entities = concat(
    [digitalocean_droplet.master.id, digitalocean_droplet.vpn.id],
    digitalocean_droplet.vulnbox[*].id
  )

  description = "CPU usage alert for ${var.project_name} droplets"
}

resource "digitalocean_monitor_alert" "memory_alert" {
  alerts {
    email = [var.monitoring_alert_email]
  }
  window      = "5m"
  type        = "v1/insights/droplet/memory_utilization_percent"
  compare     = "GreaterThan"
  value       = 90
  enabled     = var.monitoring_alert_email != ""
  
  entities = concat(
    [digitalocean_droplet.master.id, digitalocean_droplet.vpn.id],
    digitalocean_droplet.vulnbox[*].id
  )

  description = "Memory usage alert for ${var.project_name} droplets"
}

resource "digitalocean_monitor_alert" "disk_alert" {
  alerts {
    email = [var.monitoring_alert_email]
  }
  window      = "5m"
  type        = "v1/insights/droplet/disk_utilization_percent"
  compare     = "GreaterThan"
  value       = 85
  enabled     = var.monitoring_alert_email != ""
  
  entities = concat(
    [digitalocean_droplet.master.id, digitalocean_droplet.vpn.id],
    digitalocean_droplet.vulnbox[*].id
  )

  description = "Disk usage alert for ${var.project_name} droplets"
}