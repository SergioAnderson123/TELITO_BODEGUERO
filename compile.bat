@echo off
echo Compilando proyecto TELITO_BODEGUERO...
echo.

REM Verificar si Maven wrapper existe
if exist "mvnw.cmd" (
    echo Usando Maven wrapper...
    call mvnw.cmd clean compile
) else (
    echo Maven wrapper no encontrado, usando Maven global...
    mvn clean compile
)

echo.
echo Compilacion completada.
pause
