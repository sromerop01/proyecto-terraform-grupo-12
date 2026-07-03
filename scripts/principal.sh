#!/bin/bash
set -e

# Esperar a que la red esté lista
sleep 20

# Evitar prompts interactivos durante instalación
export DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar nginx con reintentos
for i in 1 2 3; do
  apt-get update -y && break
  echo "Intento $i fallido, reintentando en 10s..."
  sleep 10
done

apt-get install -y nginx

# Crear página principal
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>Servicio Principal</title></head>
<body>
  <h1>Bienvenido al Servicio Principal - Versión Producción</h1>
</body>
</html>
HTML

# Configurar nginx con endpoint /healthz
cat > /etc/nginx/sites-available/default << 'CONF'
server {
    listen 80 default_server;
    root /var/www/html;
    index index.html;

    location /healthz {
        default_type text/plain;
        return 200 "OK";
    }

    location / {
        try_files $uri $uri/ =404;
    }
}
CONF

# Iniciar nginx
systemctl enable nginx
systemctl restart nginx

echo "Startup script completado exitosamente"