#!/bin/bash
# Script para limpiar la caché de Maven y resolver problemas de dependencias

echo "Limpiando caché de Maven..."
rm -rf ~/.m2/repository/com/sun/mail/jakarta.mail

echo "Limpiando proyecto..."
cd ~/TELITO_BODEGUERO
mvn clean

echo "Forzando actualización de dependencias..."
mvn dependency:purge-local-repository -DreResolve=false

echo "Intentando compilar nuevamente..."
mvn clean package -DskipTests -U








