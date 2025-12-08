#!/bin/bash

# Script para iniciar la aplicación Spring Boot en producción
# Uso: ./start-app.sh

# Configurar variables de entorno para Java (límites muy bajos para servidor con poca memoria)
export _JAVA_OPTIONS="-Xms32m -Xmx128m -XX:MaxMetaspaceSize=64m -XX:+UseSerialGC -Djava.util.concurrent.ForkJoinPool.common.parallelism=1"
export JAVA_OPTS="-Xms32m -Xmx128m -XX:MaxMetaspaceSize=64m -XX:+UseSerialGC -Djava.util.concurrent.ForkJoinPool.common.parallelism=1"

# Nombre del archivo WAR (ajustar según el nombre generado)
WAR_FILE="TELITO_BODEGUERO-1.0-SNAPSHOT.war"

# Archivo de propiedades de producción
PROPERTIES_FILE="application-prod.properties"

# Verificar que el WAR existe
if [ ! -f "$WAR_FILE" ]; then
    echo "Error: No se encontró el archivo $WAR_FILE"
    echo "Asegúrate de haber generado el WAR con: mvn clean package"
    exit 1
fi

# Verificar que el archivo de propiedades existe
if [ ! -f "$PROPERTIES_FILE" ]; then
    echo "Advertencia: No se encontró $PROPERTIES_FILE, usando configuración por defecto"
    java $JAVA_OPTS -jar "$WAR_FILE" --spring.main.allow-bean-definition-overriding=true
else
    echo "Iniciando aplicación con configuración de producción..."
    java $JAVA_OPTS -jar "$WAR_FILE" --spring.profiles.active=prod --spring.config.location=file:"$PROPERTIES_FILE" --spring.main.allow-bean-definition-overriding=true
fi

