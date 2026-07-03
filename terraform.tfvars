
project_id = "proyecto-terraform-grupo-12"
region     = "us-central1"
zone       = "us-central1-a"

# --- Escenario 1: Producción Activa (100% - 0%) ---
# peso_principal    = 100
# peso_contingencia = 0

# --- Escenario 2: Mantenimiento Total (0% - 100%) ---
# peso_principal    = 0
#p eso_contingencia = 100

# --- Escenario 3: Balance equitativo (50% - 50%) ---
peso_principal    = 50
peso_contingencia = 50
