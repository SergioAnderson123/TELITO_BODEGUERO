# Script mejorado: Sincroniza recursos Y JSPs automáticamente
# Ejecutar ANTES de cada reinicio de Tomcat

Write-Host "================================" -ForegroundColor Cyan
Write-Host "SINCRONIZANDO PROYECTO" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$srcResources = "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\src\main\resources"
$srcWebapp = "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\src\main\webapp"
$artifactBase = "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\out\artifacts\TELITO_BODEGUERO-1.0-SNAPSHOT"

# 1. Copiar recursos (.properties, .xml)
Write-Host "1. Copiando archivos de configuracion..." -ForegroundColor Yellow

$resourceDests = @(
    "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\target\classes",
    "$artifactBase\WEB-INF\classes"
)

foreach ($dest in $resourceDests) {
    if (Test-Path $dest) {
        Copy-Item "$srcResources\*.properties" "$dest\" -Force -ErrorAction SilentlyContinue
        Copy-Item "$srcResources\*.xml" "$dest\" -Force -ErrorAction SilentlyContinue
        Write-Host "   OK: $dest" -ForegroundColor Green
    }
}

# 2. Sincronizar JSPs y archivos web
Write-Host ""
Write-Host "2. Sincronizando archivos JSP y web..." -ForegroundColor Yellow

if (Test-Path $artifactBase) {
    # Usar robocopy para sincronizar (más rápido que Copy-Item)
    $result = robocopy "$srcWebapp" "$artifactBase" /MIR /XD WEB-INF /NFL /NDL /NJH /NJS 2>&1
    if ($LASTEXITCODE -le 7) {
        Write-Host "   OK: Archivos JSP sincronizados" -ForegroundColor Green
    } else {
        Write-Host "   ADVERTENCIA: Algunos archivos no se copiaron" -ForegroundColor Yellow
    }
} else {
    Write-Host "   AVISO: Directorio artifact no existe" -ForegroundColor Yellow
    Write-Host "   Ejecuta Build > Build Project en IntelliJ primero" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "SINCRONIZACION COMPLETADA" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Siguiente paso: Reinicia Tomcat en IntelliJ" -ForegroundColor Cyan
Write-Host ""
