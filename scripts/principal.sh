#!/bin/bash
set -e

apt-get update
apt-get install -y nginx

cat <<'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>Servicio Principal</title></head>
<body>
  <h1>Bienvenido al Servicio Principal - Versión Producción</h1>
</body>
</html>
HTML

# Endpoint de salud para el Load Balancer
cat <<'CONF' > /etc/nginx/sites-available/default
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

systemctl restart nginx
systemctl enable nginx
