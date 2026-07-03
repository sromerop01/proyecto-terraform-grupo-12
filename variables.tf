
# Variables de infraestructura
variable "project_id" {
  description = "ID del proyecto de GCP donde se desplegará la infraestructura"
  type        = string
}

variable "region" {
  description = "Región de GCP para los recursos regionales"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona de GCP para las instancias de Compute Engine"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "Tipo de máquina para las instancias (e2-micro entra en el free tier)"
  type        = string
  default     = "e2-micro"
}

# Control de tráfico
# Son las variables que cambian entre los 3 escenarios de evaluación (100-0, 0-100, 50-50)
variable "peso_principal" {
  description = "Peso relativo del tráfico hacia el Servicio Principal (0-1000)"
  type        = number
  default     = 100

  validation {
    condition     = var.peso_principal >= 0 && var.peso_principal <= 1000
    error_message = "peso_principal debe estar entre 0 y 1000."
  }
}

variable "peso_contingencia" {
  description = "Peso relativo del tráfico hacia el Servicio de Contingencia (0-1000)"
  type        = number
  default     = 0

  validation {
    condition     = var.peso_contingencia >= 0 && var.peso_contingencia <= 1000
    error_message = "peso_contingencia debe estar entre 0 y 1000."
  }

  validation {
    condition     = var.peso_principal > 0 || var.peso_contingencia > 0
    error_message = "peso_principal y peso_contingencia no pueden ser ambos 0 al mismo tiempo: el sistema quedaría sin servir tráfico a ningún backend."
  }
}
