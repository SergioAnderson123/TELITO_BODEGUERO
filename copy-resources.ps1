# Script para copiar recursos a todos los directorios necesarios
# Ejecutar antes de cada despliegue si IntelliJ no lo hace automáticamente

$srcResources = "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\src\main\resources"
$destinations = @(
    "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\target\classes",
    "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\out\artifacts\TELITO_BODEGUERO-1.0-SNAPSHOT\WEB-INF\classes",
    "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\target\TELITO_BODEGUERO-1.0-SNAPSHOT\WEB-INF\classes",
    "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\target\TELITO_BODEGUERO\WEB-INF\classes"
)

Write-Host "🔄 Copiando recursos..." -ForegroundColor Cyan

foreach ($dest in $destinations) {
    if (Test-Path $dest) {
        Copy-Item "$srcResources\*.properties" "$dest\" -Force -ErrorAction SilentlyContinue
        Copy-Item "$srcResources\*.xml" "$dest\" -Force -ErrorAction SilentlyContinue
        Write-Host "Copiado a: $dest" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Recursos sincronizados en todos los directorios" -ForegroundColor Green

