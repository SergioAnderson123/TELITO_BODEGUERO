@echo off
echo Insertando notificaciones de prueba...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -proot telito_bodeguero < "C:\Users\sergi\IdeaProjects\TELITO_BODEGUERO\database\insertar_notificaciones_prueba.sql"
if %ERRORLEVEL% EQU 0 (
    echo Notificaciones insertadas correctamente
) else (
    echo Error al insertar notificaciones
)
pause
