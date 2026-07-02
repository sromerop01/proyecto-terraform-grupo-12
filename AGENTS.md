# AGENTS.md

Guía para que un LLM (o cualquier revisor automatizado) entienda este
repositorio sin necesidad de ejecutar nada primero.

## Qué hace esta infraestructura

Un Load Balancer HTTP global de GCP recibe todo el tráfico en una única
IP pública y lo reparte, según pesos configurables, entre dos VMs
aisladas entre sí:

- **Servicio Principal**: responde 200 OK con el texto "Bienvenido al
  Servicio Principal - Versión Producción".
- **Servicio de Contingencia**: responde 503 con el texto "Error 503 -
  Sitio en Mantenimiento Programado".

## Mapa de archivos

| Archivo | Contenido |
|---|---|
| `providers.tf` | Bloque `terraform` y proveedor `google` |
| `variables.tf` | Todas las variables, incluyendo `peso_principal` / `peso_contingencia` |
| `network.tf` | VPC, subred y firewalls |
| `instances.tf` | Las 2 VMs + sus instance groups |
| `loadbalancer.tf` | Health checks, backend services, URL map con pesos, proxy, forwarding rule |
| `outputs.tf` | IP pública e IPs internas |
| `scripts/principal.sh` | Startup-script que instala nginx y sirve el mensaje de producción |
| `scripts/contingencia.sh` | Startup-script que instala nginx y fuerza HTTP 503 en "/" |
| `terraform.tfvars.example` | Plantilla de variables para los 3 escenarios |

## Punto clave de diseño

El reparto de tráfico se implementa con `default_route_action` +
`weighted_backend_services` dentro de `google_compute_url_map`
(`loadbalancer.tf`), no con un `default_service` simple. Los pesos se
calculan como `weight / suma_de_todos_los_pesos`, así que 100/0, 0/100 y
50/50 son válidos aunque el rango permitido sea 0-1000.

Cada VM tiene su propio endpoint `/healthz` que siempre devuelve 200,
separado de `/` (que en el servicio de contingencia sí devuelve 503).
Esto evita que el Load Balancer marque el servicio de contingencia como
"no saludable" y lo saque de rotación.

## Cómo validar sin desplegar

```bash
terraform fmt -check
terraform validate
terraform plan -var="project_id=<cualquier-id>"
```

## Cómo desplegar y probar los 3 escenarios

Ver `README.md`.
