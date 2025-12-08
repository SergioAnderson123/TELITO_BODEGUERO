@echo off
REM Script para limpiar DEFINER de vistas en archivo SQL (Windows)
REM Elimina las referencias a DEFINER='root'@'localhost' que causan problemas en cPanel

if "%1"=="" (
    echo Uso: fix-sql-definer.bat ^<archivo_entrada.sql^> [archivo_salida.sql]
    echo Ejemplo: fix-sql-definer.bat base_datos.sql base_datos_fixed.sql
    exit /b 1
)

set INPUT_FILE=%1
set OUTPUT_FILE=%2

if "%OUTPUT_FILE%"=="" (
    set OUTPUT_FILE=%INPUT_FILE:.sql=_fixed.sql%
)

echo Procesando archivo: %INPUT_FILE%
echo Archivo de salida: %OUTPUT_FILE%

REM Usar PowerShell para hacer el reemplazo
powershell -Command "(Get-Content '%INPUT_FILE%' -Raw) -replace '/\*!50013\s+DEFINER=`root`@`localhost`\s+SQL SECURITY DEFINER\s+\*/', '/*!50013 SQL SECURITY DEFINER */' -replace 'DEFINER=`root`@`localhost`', '' | Set-Content '%OUTPUT_FILE%' -Encoding UTF8"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✓ Archivo corregido guardado en: %OUTPUT_FILE%
    echo ✓ Todas las referencias a DEFINER='root'@'localhost' han sido eliminadas
) else (
    echo.
    echo ✗ Error al procesar el archivo
    exit /b 1
)


