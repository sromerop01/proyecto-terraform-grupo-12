# ---------------------------------------------------------------------------
# Health checks — apuntan a /healthz, NUNCA a "/", porque el servicio de
# contingencia devuelve 503 en "/" a propósito.
# ---------------------------------------------------------------------------

resource "google_compute_health_check" "principal" {
  name                = "hc-servicio-principal"
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/healthz"
  }
}

resource "google_compute_health_check" "contingencia" {
  name                = "hc-servicio-contingencia"
  timeout_sec         = 5
  check_interval_sec  = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/healthz"
  }
}

# ---------------------------------------------------------------------------
# Backend services — session_affinity = NONE es clave para el Escenario 3:
# sin esto, el LB podría "pegar" a un usuario siempre al mismo backend en
# vez de alternar en cada refresh.
# ---------------------------------------------------------------------------

resource "google_compute_backend_service" "principal" {
  name                  = "backend-servicio-principal"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  session_affinity      = "NONE"
  health_checks         = [google_compute_health_check.principal.id]

  backend {
    group = google_compute_instance_group.principal.id
  }
}

resource "google_compute_backend_service" "contingencia" {
  name                  = "backend-servicio-contingencia"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  session_affinity      = "NONE"
  health_checks         = [google_compute_health_check.contingencia.id]

  backend {
    group = google_compute_instance_group.contingencia.id
  }
}

# ---------------------------------------------------------------------------
# URL Map — aquí es donde vive el "reparto" de tráfico. Los pesos vienen
# directo de variables.tf / terraform.tfvars, nunca hardcodeados.
# ---------------------------------------------------------------------------

resource "google_compute_url_map" "default" {
  name = "url-map-proyecto-terraform"

  default_route_action {
    weighted_backend_services {
      backend_service = google_compute_backend_service.principal.id
      weight          = var.peso_principal
    }

    weighted_backend_services {
      backend_service = google_compute_backend_service.contingencia.id
      weight          = var.peso_contingencia
    }
  }
}

resource "google_compute_target_http_proxy" "default" {
  name    = "target-proxy-proyecto-terraform"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_address" "default" {
  name = "ip-proyecto-terraform"
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "forwarding-rule-proyecto-terraform"
  ip_address            = google_compute_global_address.default.address
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
