-- =============================================
-- SCRIPT PARA AGREGAR CAMPOS A LA TABLA CONDUCTORES
-- =============================================

USE telito_bodeguero;

-- Agregar los nuevos campos a la tabla conductores
ALTER TABLE conductores 
ADD COLUMN telefono VARCHAR(20) NULL AFTER licencia,
ADD COLUMN email VARCHAR(255) NULL AFTER telefono,
ADD COLUMN dni VARCHAR(20) NULL AFTER email,
ADD COLUMN tipo_licencia VARCHAR(10) NULL AFTER dni,
ADD COLUMN fecha_vencimiento_licencia DATE NULL AFTER tipo_licencia;

-- Agregar índice único para DNI (opcional, pero recomendado)
ALTER TABLE conductores 
ADD UNIQUE KEY unique_dni (dni);

-- Agregar índice único para email (opcional, pero recomendado)
ALTER TABLE conductores 
ADD UNIQUE KEY unique_email (email);

-- Mensaje de confirmación
SELECT '✓ Campos agregados correctamente a la tabla conductores' AS resultado;
SELECT '  - telefono (VARCHAR(20))' AS campo1;
SELECT '  - email (VARCHAR(255))' AS campo2;
SELECT '  - dni (VARCHAR(20))' AS campo3;
SELECT '  - tipo_licencia (VARCHAR(10))' AS campo4;
SELECT '  - fecha_vencimiento_licencia (DATE)' AS campo5;

