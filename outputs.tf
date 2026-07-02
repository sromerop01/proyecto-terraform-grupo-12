output "ip_publica" {
  description = "IP pública única de entrada al sistema"
  value       = google_compute_global_address.default.address
}

output "vm_principal_ip_interna" {
  description = "IP interna de la VM del Servicio Principal (solo referencia)"
  value       = google_compute_instance.principal.network_interface[0].network_ip
}

output "vm_contingencia_ip_interna" {
  description = "IP interna de la VM del Servicio de Contingencia (solo referencia)"
  value       = google_compute_instance.contingencia.network_interface[0].network_ip
}
