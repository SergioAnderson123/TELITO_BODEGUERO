#!/bin/bash

# Script de despliegue automatizado para EC2
# Uso: ./deploy-ec2.sh

set -e  # Salir si hay algún error

echo "=========================================="
echo "  Despliegue de Telito Bodeguero en EC2  "
echo "=========================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "pom.xml" ]; then
    print_error "No se encontró pom.xml. Asegúrate de estar en el directorio raíz del proyecto."
    exit 1
fi

# 1. Verificar dependencias
print_info "Verificando dependencias..."

if ! command -v java &> /dev/null; then
    print_error "Java no está instalado. Instálalo con: sudo yum install -y java-17-amazon-corretto-devel"
    exit 1
fi
print_success "Java encontrado: $(java -version 2>&1 | head -n 1)"

if ! command -v mvn &> /dev/null; then
    print_error "Maven no está instalado. Instálalo con: sudo yum install -y maven"
    exit 1
fi
print_success "Maven encontrado: $(mvn -version | head -n 1)"

if ! command -v mysql &> /dev/null; then
    print_error "MySQL no está instalado. Instálalo con: sudo yum install -y mysql-server"
    exit 1
fi
print_success "MySQL encontrado"

# 2. Detener aplicación anterior si está corriendo
print_info "Verificando si hay una instancia anterior corriendo..."
if pgrep -f "TELITO_BODEGUERO" > /dev/null; then
    print_info "Deteniendo aplicación anterior..."
    pkill -f "TELITO_BODEGUERO"
    sleep 2
    print_success "Aplicación anterior detenida"
else
    print_info "No hay instancia anterior corriendo"
fi

# 3. Limpiar compilaciones anteriores
print_info "Limpiando compilaciones anteriores..."
mvn clean
print_success "Limpieza completada"

# 4. Compilar el proyecto
print_info "Compilando el proyecto (esto puede tardar varios minutos)..."
mvn package -DskipTests
if [ $? -eq 0 ]; then
    print_success "Compilación exitosa"
else
    print_error "Error en la compilación"
    exit 1
fi

# 5. Verificar que el WAR se generó
WAR_FILE="target/TELITO_BODEGUERO-1.0-SNAPSHOT.war"
if [ ! -f "$WAR_FILE" ]; then
    print_error "No se encontró el archivo WAR: $WAR_FILE"
    exit 1
fi
print_success "WAR generado: $WAR_FILE"

# 6. Verificar configuración de producción
PROD_PROPERTIES="src/main/resources/application-prod.properties"
if [ ! -f "$PROD_PROPERTIES" ]; then
    print_info "No se encontró application-prod.properties, usando configuración por defecto"
    print_info "Se recomienda crear application-prod.properties para producción"
fi

# 7. Verificar conexión a base de datos
print_info "Verificando conexión a base de datos..."
if mysql -u root -p -e "USE telito_bodeguero;" 2>/dev/null; then
    print_success "Conexión a base de datos exitosa"
else
    print_error "No se pudo conectar a la base de datos"
    print_info "Asegúrate de que MySQL esté corriendo y la BD exista"
    print_info "Puedes crear la BD con: mysql -u root -p < telito_bodeguero.sql"
fi

# 8. Configurar variables de entorno para Java (optimizado para EC2 pequeño)
export _JAVA_OPTIONS="-Xms32m -Xmx128m -XX:MaxMetaspaceSize=64m -XX:+UseSerialGC -Djava.util.concurrent.ForkJoinPool.common.parallelism=1"
export JAVA_OPTS="-Xms32m -Xmx128m -XX:MaxMetaspaceSize=64m -XX:+UseSerialGC -Djava.util.concurrent.ForkJoinPool.common.parallelism=1"

# 9. Iniciar la aplicación
print_info "Iniciando la aplicación..."
cd target

# Crear directorio de logs si no existe
mkdir -p logs

# Iniciar en segundo plano
nohup java $JAVA_OPTS -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &
APP_PID=$!

# Esperar un momento para que inicie
sleep 5

# Verificar que el proceso está corriendo
if ps -p $APP_PID > /dev/null; then
    print_success "Aplicación iniciada con PID: $APP_PID"
    print_info "Logs disponibles en: target/app.log"
    print_info "Para ver los logs en tiempo real: tail -f target/app.log"
else
    print_error "La aplicación no se inició correctamente"
    print_info "Revisa los logs: cat target/app.log"
    exit 1
fi

# 10. Verificar que el puerto está escuchando
print_info "Verificando que el puerto 8080 está escuchando..."
sleep 3
if netstat -tlnp 2>/dev/null | grep -q ":8080" || ss -tlnp 2>/dev/null | grep -q ":8080"; then
    print_success "Puerto 8080 está escuchando"
else
    print_error "El puerto 8080 no está escuchando. Revisa los logs."
fi

# 11. Información final
echo ""
echo "=========================================="
echo "  Despliegue completado"
echo "=========================================="
echo ""
print_info "Aplicación corriendo en: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || hostname -I | awk '{print $1}'):8080"
print_info "PID del proceso: $APP_PID"
print_info "Para detener la aplicación: kill $APP_PID"
print_info "Para ver logs: tail -f target/app.log"
echo ""


