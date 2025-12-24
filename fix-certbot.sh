#!/bin/bash
# Script para limpiar y reintentar certificado SSL

echo "=== Limpiando estado previo de certbot ==="

# 1. Limpiar estado previo
sudo rm -rf /var/log/letsencrypt/letsencrypt.log
sudo certbot delete --cert-name telitobodeguero.com 2>/dev/null || echo "No hay certificado previo para eliminar"

# 2. Verificar que nginx esté configurado correctamente
echo ""
echo "=== Verificando configuración de nginx ==="
sudo cat /etc/nginx/conf.d/telitobodeguero.conf

# 3. Verificar que nginx escuche en el puerto 80
echo ""
echo "=== Verificando puerto 80 ==="
sudo netstat -tlnp | grep :80

# 4. Verificar resolución DNS
echo ""
echo "=== Verificando DNS ==="
dig +short telitobodeguero.com
dig +short www.telitobodeguero.com

# 5. Probar acceso HTTP al dominio
echo ""
echo "=== Probando acceso HTTP ==="
curl -I http://telitobodeguero.com 2>&1 | head -5

echo ""
echo "=== Si todo está bien, ejecuta: ==="
echo "sudo certbot --nginx -d telitobodeguero.com -d www.telitobodeguero.com --non-interactive --agree-tos --email telitobodeguero@gmail.com --redirect"








