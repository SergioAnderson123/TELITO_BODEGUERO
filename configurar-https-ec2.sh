#!/bin/bash
# Script para configurar HTTPS con Let's Encrypt (Certbot)

echo "=== Configurando HTTPS con Let's Encrypt ==="

# 1. Instalar certbot
echo "1. Instalando certbot..."
sudo yum install -y certbot python3-certbot-nginx

# 2. Obtener certificado SSL
echo "2. Obteniendo certificado SSL..."
echo "IMPORTANTE: Asegúrate de que:"
echo "- El dominio telitobodeguero.com apunta a esta IP (3.213.47.70)"
echo "- El Security Group permite tráfico en el puerto 80 y 443"
echo ""
read -p "Presiona Enter para continuar..."

# Obtener certificado
sudo certbot --nginx -d telitobodeguero.com -d www.telitobodeguero.com --non-interactive --agree-tos --email telitobodeguero@gmail.com --redirect

# 3. Verificar renovación automática
echo "3. Configurando renovación automática..."
sudo certbot renew --dry-run

# 4. Verificar estado de nginx
echo "4. Verificando estado de nginx..."
sudo systemctl status nginx --no-pager

echo ""
echo "=== Configuración completada ==="
echo "Ahora puedes acceder a:"
echo "- https://telitobodeguero.com"
echo "- https://www.telitobodeguero.com"
echo ""
echo "El certificado se renovará automáticamente cada 90 días"








