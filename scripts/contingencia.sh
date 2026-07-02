#!/bin/bash
set -e

apt-get update
apt-get install -y nginx

cat <<'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>Mantenimiento</title></head>
<body>
  <h1>Error 503 - Sitio en Mantenimiento Programado</h1>
</body>
</html>
HTML

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
        return 503;
    }

    error_page 503 =503 /index.html;
}
CONF

systemctl restart nginx
systemctl enable nginx
