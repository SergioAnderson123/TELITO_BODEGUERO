# Script rápido para subir cambios a EC2
# CONFIGURA ESTAS VARIABLES con tus datos:

$PEM_PATH = "C:\ruta\a\tu-clave.pem"  # Cambia esto
$EC2_IP = "tu-ip-publica"              # Cambia esto
$EC2_USER = "ec2-user"                 # Puede ser ec2-user, ubuntu, admin, etc.

# ============================================
# NO MODIFIQUES NADA MÁS DEBAJO DE ESTA LÍNEA
# ============================================

$PROJECT = "C:\Users\Soporte\TELITO_BODEGUERO"
$REMOTE = "~/TELITO_BODEGUERO"

Write-Host "Subiendo cambios a EC2..." -ForegroundColor Cyan
Write-Host ""

# Subir código Java
Write-Host "→ Subiendo código Java..." -ForegroundColor Yellow
scp -i "$PEM_PATH" -r "$PROJECT\src\main\java" "${EC2_USER}@${EC2_IP}:$REMOTE/src/main/" 2>&1 | Out-Null

# Subir recursos
Write-Host "→ Subiendo recursos (properties, xml)..." -ForegroundColor Yellow
scp -i "$PEM_PATH" -r "$PROJECT\src\main\resources" "${EC2_USER}@${EC2_IP}:$REMOTE/src/main/" 2>&1 | Out-Null

# Subir webapp
Write-Host "→ Subiendo archivos web (JSP, CSS, JS)..." -ForegroundColor Yellow
scp -i "$PEM_PATH" -r "$PROJECT\src\main\webapp" "${EC2_USER}@${EC2_IP}:$REMOTE/src/main/" 2>&1 | Out-Null

# Subir pom.xml por si cambió
Write-Host "→ Subiendo pom.xml..." -ForegroundColor Yellow
scp -i "$PEM_PATH" "$PROJECT\pom.xml" "${EC2_USER}@${EC2_IP}:$REMOTE/" 2>&1 | Out-Null

Write-Host ""
Write-Host "✓ Archivos subidos correctamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Ahora conecta a EC2 y ejecuta:" -ForegroundColor Cyan
Write-Host "  ssh -i `"$PEM_PATH`" $EC2_USER@$EC2_IP" -ForegroundColor White
Write-Host ""
Write-Host "Luego en EC2:" -ForegroundColor Cyan
Write-Host "  cd ~/TELITO_BODEGUERO" -ForegroundColor White
Write-Host "  mvn clean package -DskipTests" -ForegroundColor White
Write-Host "  pkill -f TELITO_BODEGUERO" -ForegroundColor White
Write-Host "  cd target" -ForegroundColor White
Write-Host "  nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &" -ForegroundColor White




