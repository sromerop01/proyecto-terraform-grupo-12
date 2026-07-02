
resource "google_compute_instance" "principal" {
  name         = "vm-servicio-principal"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata_startup_script = file("${path.module}/scripts/principal.sh")
}

resource "google_compute_instance" "contingencia" {
  name         = "vm-servicio-contingencia"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata_startup_script = file("${path.module}/scripts/contingencia.sh")
}

resource "google_compute_instance_group" "principal" {
  name      = "ig-servicio-principal"
  zone      = var.zone
  instances = [google_compute_instance.principal.id]

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_instance_group" "contingencia" {
  name      = "ig-servicio-contingencia"
  zone      = var.zone
  instances = [google_compute_instance.contingencia.id]

  named_port {
    name = "http"
    port = 80
  }
}
