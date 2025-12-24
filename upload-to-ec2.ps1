# Script para subir cambios desde IntelliJ a EC2
# Uso: .\upload-to-ec2.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$PemPath,
    
    [Parameter(Mandatory=$true)]
    [string]$Ec2IP,
    
    [Parameter(Mandatory=$false)]
    [string]$User = "ec2-user",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "code", "resources", "webapp")]
    [string]$Type = "all"
)

$ProjectPath = "C:\Users\Soporte\TELITO_BODEGUERO"
$RemotePath = "~/TELITO_BODEGUERO"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Subiendo cambios a EC2" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que existe el archivo .pem
if (-not (Test-Path $PemPath)) {
    Write-Host "ERROR: No se encontró el archivo .pem en: $PemPath" -ForegroundColor Red
    exit 1
}

# Verificar que existe el proyecto
if (-not (Test-Path $ProjectPath)) {
    Write-Host "ERROR: No se encontró el proyecto en: $ProjectPath" -ForegroundColor Red
    exit 1
}

Write-Host "Proyecto local: $ProjectPath" -ForegroundColor Yellow
Write-Host "EC2 destino: $User@$Ec2IP:$RemotePath" -ForegroundColor Yellow
Write-Host ""

# Función para ejecutar SCP
function Upload-Files {
    param(
        [string]$LocalPath,
        [string]$RemotePath,
        [string]$Description
    )
    
    Write-Host "Subiendo $Description..." -ForegroundColor Yellow
    
    $scpCommand = "scp -i `"$PemPath`" -r `"$LocalPath`" $User@${Ec2IP}:$RemotePath"
    
    try {
        Invoke-Expression $scpCommand
        Write-Host "✓ $Description subido correctamente" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Error al subir $Description : $_" -ForegroundColor Red
        return $false
    }
}

$success = $true

# Subir según el tipo seleccionado
switch ($Type) {
    "code" {
        # Solo código Java
        $success = Upload-Files "$ProjectPath\src\main\java" "$RemotePath/src/main/" "código Java"
    }
    "resources" {
        # Solo recursos (properties, xml)
        $success = Upload-Files "$ProjectPath\src\main\resources" "$RemotePath/src/main/" "archivos de configuración"
    }
    "webapp" {
        # Solo webapp (JSPs, CSS, JS)
        $success = Upload-Files "$ProjectPath\src\main\webapp" "$RemotePath/src/main/" "archivos web (JSP, CSS, JS)"
    }
    "all" {
        # Subir todo el proyecto (sin target ni .git)
        Write-Host "Subiendo todo el proyecto (esto puede tardar)..." -ForegroundColor Yellow
        Write-Host "Excluyendo: target, .git, .idea, logs" -ForegroundColor Gray
        
        # Crear archivo temporal con exclusiones para rsync (si está disponible)
        # Si no, usar scp con exclusiones manuales
        
        # Opción 1: Subir directorios principales
        $dirs = @("src", "pom.xml", "mvnw", "mvnw.cmd")
        foreach ($dir in $dirs) {
            $localPath = Join-Path $ProjectPath $dir
            if (Test-Path $localPath) {
                $success = Upload-Files $localPath "$RemotePath/" $dir
            }
        }
    }
}

Write-Host ""
if ($success) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Archivos subidos correctamente" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Próximos pasos en EC2:" -ForegroundColor Cyan
    Write-Host "1. Conéctate: ssh -i `"$PemPath`" $User@$Ec2IP" -ForegroundColor White
    Write-Host "2. Compila: cd ~/TELITO_BODEGUERO && mvn clean package -DskipTests" -ForegroundColor White
    Write-Host "3. Reinicia: pkill -f TELITO_BODEGUERO && cd target && nohup java -Xms32m -Xmx128m -jar TELITO_BODEGUERO-1.0-SNAPSHOT.war --spring.profiles.active=prod > app.log 2>&1 &" -ForegroundColor White
} else {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  Hubo errores al subir archivos" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
}




