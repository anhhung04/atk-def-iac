build {

  name    = "vulnbox"
  sources = ["source.vultr.ubuntu"]

  provisioner "shell" {
    script = "scripts/install_docker.sh"
  }

  provisioner "file" {
    source   = "./services"
    destination = "/tmp"
  }

  provisioner "file" {
    source   = "./service-boot/game-service@.service"
    destination = "/tmp/game-service@.service"
  }

  provisioner "file" {
    source   = "./internal"
    destination = "/tmp"
  }

  provisioner "shell" {
    script = "./scripts/prepare_services.sh"
  }
}
