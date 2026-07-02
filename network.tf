resource "google_compute_network" "vpc" {
  name                    = "vpc-proyecto-terraform"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-proyecto-terraform"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Permite el tráfico HTTP de los health checkers y del balanceador de carga de Google.
resource "google_compute_firewall" "allow_lb_and_health_check" {
  name    = "allow-lb-and-health-check"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-server"]
}

# Permite SSH solo para depuración manual del equipo (no se usa para
# configurar los servidores, eso lo hace el startup-script).
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

