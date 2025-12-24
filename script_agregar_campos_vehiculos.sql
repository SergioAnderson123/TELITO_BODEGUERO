-- =============================================
-- SCRIPT PARA AGREGAR CAMPOS A LA TABLA VEHICULOS
-- =============================================

USE telito_bodeguero;

-- Agregar los nuevos campos a la tabla vehiculos
ALTER TABLE vehiculos 
ADD COLUMN año INT NULL AFTER capacidad_kg,
ADD COLUMN tipo_combustible VARCHAR(20) NULL AFTER año,
ADD COLUMN numero_serie_vin VARCHAR(50) NULL AFTER tipo_combustible,
ADD COLUMN fecha_ultima_revision DATE NULL AFTER numero_serie_vin,
ADD COLUMN fecha_vencimiento_soat DATE NULL AFTER fecha_ultima_revision;

-- Agregar índice único para número de serie/VIN (opcional, pero recomendado)
ALTER TABLE vehiculos 
ADD UNIQUE KEY unique_numero_serie_vin (numero_serie_vin);

-- Mensaje de confirmación
SELECT '✓ Campos agregados correctamente a la tabla vehiculos' AS resultado;
SELECT '  - año (INT)' AS campo1;
SELECT '  - tipo_combustible (VARCHAR(20))' AS campo2;
SELECT '  - numero_serie_vin (VARCHAR(50))' AS campo3;
SELECT '  - fecha_ultima_revision (DATE)' AS campo4;
SELECT '  - fecha_vencimiento_soat (DATE)' AS campo5;

