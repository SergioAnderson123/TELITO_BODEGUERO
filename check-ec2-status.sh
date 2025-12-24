#!/bin/bash

# Script para verificar el estado de la aplicación en EC2
# Uso: ./check-ec2-status.sh

echo "=========================================="
echo "  Estado de Telito Bodeguero en EC2"
echo "=========================================="
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Verificar si la aplicación está corriendo
echo "1. ESTADO DE LA APLICACIÓN:"
echo "---------------------------"
if pgrep -f "TELITO_BODEGUERO" > /dev/null; then
    echo -e "${GREEN}✓ Aplicación está CORRIENDO${NC}"
    echo ""
    echo "Procesos Java encontrados:"
    ps aux | grep TELITO_BODEGUERO | grep -v grep
    echo ""
    echo "Puerto 8080:"
    if netstat -tlnp 2>/dev/null | grep -q ":8080" || ss -tlnp 2>/dev/null | grep -q ":8080"; then
        echo -e "${GREEN}✓ Puerto 8080 está escuchando${NC}"
        netstat -tlnp 2>/dev/null | grep ":8080" || ss -tlnp 2>/dev/null | grep ":8080"
    else
        echo -e "${RED}✗ Puerto 8080 NO está escuchando${NC}"
    fi
else
    echo -e "${RED}✗ Aplicación NO está corriendo${NC}"
fi
echo ""

# 2. Verificar ubicación del proyecto
echo "2. UBICACIÓN DEL PROYECTO:"
echo "---------------------------"
if [ -d ~/TELITO_BODEGUERO ]; then
    echo -e "${GREEN}✓ Proyecto encontrado en: ~/TELITO_BODEGUERO${NC}"
    cd ~/TELITO_BODEGUERO
    echo "Directorio actual: $(pwd)"
else
    echo -e "${RED}✗ No se encontró el proyecto en ~/TELITO_BODEGUERO${NC}"
    echo "Buscando en otros lugares..."
    find ~ -name "pom.xml" -type f 2>/dev/null | head -5
fi
echo ""

# 3. Verificar archivo WAR
echo "3. ARCHIVO WAR:"
echo "---------------"
if [ -f ~/TELITO_BODEGUERO/target/TELITO_BODEGUERO-1.0-SNAPSHOT.war ]; then
    echo -e "${GREEN}✓ WAR encontrado${NC}"
    ls -lh ~/TELITO_BODEGUERO/target/TELITO_BODEGUERO-1.0-SNAPSHOT.war
else
    echo -e "${YELLOW}⚠ WAR no encontrado. Necesitas compilar el proyecto.${NC}"
fi
echo ""

# 4. Verificar base de datos
echo "4. BASE DE DATOS:"
echo "-----------------"
if mysql -u root -p -e "USE telito_bodeguero;" 2>/dev/null; then
    echo -e "${GREEN}✓ Base de datos 'telito_bodeguero' existe${NC}"
    mysql -u root -p -e "SELECT COUNT(*) as 'Tablas' FROM information_schema.tables WHERE table_schema = 'telito_bodeguero';" 2>/dev/null
else
    echo -e "${RED}✗ No se puede conectar a la base de datos${NC}"
fi
echo ""

# 5. Verificar MySQL
echo "5. ESTADO DE MYSQL:"
echo "-------------------"
if systemctl is-active --quiet mysqld; then
    echo -e "${GREEN}✓ MySQL está corriendo${NC}"
else
    echo -e "${RED}✗ MySQL NO está corriendo${NC}"
    echo "Para iniciarlo: sudo systemctl start mysqld"
fi
echo ""

# 6. Ver logs recientes
echo "6. LOGS RECIENTES (últimas 20 líneas):"
echo "---------------------------------------"
if [ -f ~/TELITO_BODEGUERO/target/app.log ]; then
    tail -20 ~/TELITO_BODEGUERO/target/app.log
elif [ -f ~/TELITO_BODEGUERO/app.log ]; then
    tail -20 ~/TELITO_BODEGUERO/app.log
else
    echo -e "${YELLOW}⚠ No se encontraron logs${NC}"
fi
echo ""

# 7. Ver cambios recientes en el código
echo "7. CAMBIOS RECIENTES EN EL CÓDIGO:"
echo "-----------------------------------"
if [ -d ~/TELITO_BODEGUERO/.git ]; then
    cd ~/TELITO_BODEGUERO
    echo "Últimos commits:"
    git log --oneline -5 2>/dev/null || echo "No hay historial de Git"
    echo ""
    echo "Archivos modificados (sin commit):"
    git status --short 2>/dev/null || echo "No hay cambios pendientes"
else
    echo -e "${YELLOW}⚠ No es un repositorio Git${NC}"
    echo "Archivos modificados recientemente:"
    find ~/TELITO_BODEGUERO/src -type f -mtime -7 -ls 2>/dev/null | head -10
fi
echo ""

# 8. Ver IP pública
echo "8. INFORMACIÓN DE RED:"
echo "----------------------"
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)
if [ ! -z "$PUBLIC_IP" ]; then
    echo "IP Pública: $PUBLIC_IP"
    echo "URL de acceso: http://$PUBLIC_IP:8080"
else
    echo "IP Local: $(hostname -I | awk '{print $1}')"
fi
echo ""

# 9. Comandos útiles
echo "=========================================="
echo "  COMANDOS ÚTILES:"
echo "=========================================="
echo ""
echo "Para INICIAR la aplicación:"
echo "  cd ~/TELITO_BODEGUERO/target"
echo "  nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &"
echo ""
echo "Para DETENER la aplicación:"
echo "  pkill -f TELITO_BODEGUERO"
echo ""
echo "Para VER LOGS en tiempo real:"
echo "  tail -f ~/TELITO_BODEGUERO/target/app.log"
echo ""
echo "Para COMPILAR el proyecto:"
echo "  cd ~/TELITO_BODEGUERO"
echo "  mvn clean package -DskipTests"
echo ""


