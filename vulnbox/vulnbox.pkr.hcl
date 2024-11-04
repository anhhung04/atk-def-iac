build {

  name    = "vulnbox"
  sources = ["source.proxmox-iso.vulnbox"]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install -y curl vim git ca-certificates",
    ]
  }

  provisioner "shell" {
    inline = [
      "for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done",
      "curl -fsSL https://get.docker.com | sh",
    ]
  }

  provisioner "file" {
    source      = "service-boot/game-service@.service"
    destination = "/tmp/game-service@.service"
  }
}
