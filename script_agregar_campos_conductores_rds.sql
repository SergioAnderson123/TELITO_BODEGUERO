-- =============================================
-- SCRIPT PARA AGREGAR CAMPOS A LA TABLA CONDUCTORES EN RDS
-- Base de datos: BaseTelito
-- =============================================

USE BaseTelito;

-- Verificar estructura actual (opcional, para ver qué columnas existen)
-- DESCRIBE conductores;

-- Agregar los nuevos campos a la tabla conductores (uno por uno para evitar errores si ya existen)
-- Ejecuta cada ALTER TABLE individualmente

-- 1. Agregar columna telefono
ALTER TABLE conductores 
ADD COLUMN telefono VARCHAR(20) NULL AFTER licencia;

-- 2. Agregar columna email
ALTER TABLE conductores 
ADD COLUMN email VARCHAR(255) NULL AFTER telefono;

-- 3. Agregar columna dni
ALTER TABLE conductores 
ADD COLUMN dni VARCHAR(20) NULL AFTER email;

-- 4. Agregar columna tipo_licencia
ALTER TABLE conductores 
ADD COLUMN tipo_licencia VARCHAR(10) NULL AFTER dni;

-- 5. Agregar columna fecha_vencimiento_licencia
ALTER TABLE conductores 
ADD COLUMN fecha_vencimiento_licencia DATE NULL AFTER tipo_licencia;

-- Agregar índice único para DNI (ejecuta solo si no existe)
-- ALTER TABLE conductores 
-- ADD UNIQUE KEY unique_dni (dni);

-- Agregar índice único para email (ejecuta solo si no existe)
-- ALTER TABLE conductores 
-- ADD UNIQUE KEY unique_email (email);

-- Mensaje de confirmación
SELECT '✓ Campos agregados correctamente a la tabla conductores' AS resultado;
SELECT '  - telefono (VARCHAR(20))' AS campo1;
SELECT '  - email (VARCHAR(255))' AS campo2;
SELECT '  - dni (VARCHAR(20))' AS campo3;
SELECT '  - tipo_licencia (VARCHAR(10))' AS campo4;
SELECT '  - fecha_vencimiento_licencia (DATE)' AS campo5;

