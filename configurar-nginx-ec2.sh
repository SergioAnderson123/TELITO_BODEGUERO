#!/bin/bash
# Script para configurar nginx como reverse proxy para eliminar el puerto 8080

echo "=== Configurando Nginx como Reverse Proxy ==="

# 1. Instalar nginx
echo "1. Instalando nginx..."
sudo yum update -y
sudo yum install -y nginx

# 2. Crear configuración de nginx
echo "2. Creando configuración de nginx..."
sudo tee /etc/nginx/conf.d/telitobodeguero.conf > /dev/null <<EOF
server {
    listen 80;
    server_name telitobodeguero.com www.telitobodeguero.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Logs
    access_log /var/log/nginx/telitobodeguero-access.log;
    error_log /var/log/nginx/telitobodeguero-error.log;
}
EOF

# 3. Verificar configuración
echo "3. Verificando configuración de nginx..."
sudo nginx -t

# 4. Iniciar y habilitar nginx
echo "4. Iniciando nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# 5. Verificar estado
echo "5. Verificando estado de nginx..."
sudo systemctl status nginx --no-pager

echo ""
echo "=== Configuración completada ==="
echo "Recuerda:"
echo "1. Verificar que el Security Group de EC2 permita tráfico en el puerto 80"
echo "2. La aplicación debe seguir corriendo en el puerto 8080"
echo "3. Ahora puedes acceder a: http://telitobodeguero.com (sin :8080)"








