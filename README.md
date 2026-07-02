# Proyecto Terraform — Servicios en la Nube 2026-01

Infraestructura en GCP con un único punto de entrada (IP pública) que
distribuye tráfico entre un Servicio Principal y un Servicio de
Contingencia, en instancias de cómputo completamente independientes.

## Requisitos

- Terraform >= 1.3
- Cuenta de GCP con un proyecto creado y facturación habilitada
- `gcloud` CLI autenticado (`gcloud auth application-default login`)

## Despliegue

```bash
cp terraform.tfvars.example terraform.tfvars
# editar terraform.tfvars con tu project_id

terraform init
terraform apply
```

## Cómo activar cada escenario de evaluación

Todos los cambios se hacen **únicamente** en `terraform.tfvars`, editando
`peso_principal` y `peso_contingencia`. Después de cambiar los valores:

```bash
terraform apply
```

| Escenario | peso_principal | peso_contingencia | Resultado esperado |
|---|---|---|---|
| 1 — Producción Activa | 100 | 0 | 100% de las visitas ven el Servicio Principal |
| 2 — Mantenimiento Total | 0 | 100 | 100% de las visitas ven el Error 503 |
| 3 — Balance equitativo | 50 | 50 | Las visitas alternan entre ambos servicios |

Prueba con:

```bash
curl -i http://<IP_PUBLICA_DEL_OUTPUT>
```

(usa `terraform output ip_publica` para obtener la IP)

## Cierre del proyecto

```bash
terraform destroy
```

<!-- TODO: agregar capturas de pantalla / logs de los 3 escenarios y del
     destroy exitoso antes de la entrega. -->
