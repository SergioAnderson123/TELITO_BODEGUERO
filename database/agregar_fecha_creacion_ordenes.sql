-- =====================================================
-- Agregar columna fecha_creacion a ordenes_compra
-- =====================================================
-- Esto permite registrar cuándo se creó cada orden de compra
-- y generar estadísticas por fecha
-- =====================================================

USE telito_bodeguero;

-- Agregar la columna fecha_creacion con valor por defecto CURRENT_TIMESTAMP
ALTER TABLE `ordenes_compra` 
ADD COLUMN `fecha_creacion` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
AFTER `distrito_id`;

-- Opcional: Agregar índice para mejorar consultas por fecha
CREATE INDEX `idx_fecha_creacion` ON `ordenes_compra` (`fecha_creacion`);

-- Verificar que se agregó correctamente
SELECT 
    COLUMN_NAME, 
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'telito_bodeguero' 
  AND TABLE_NAME = 'ordenes_compra' 
  AND COLUMN_NAME = 'fecha_creacion';

-- Ver algunas órdenes con la nueva columna
SELECT id_orden_compra, numero_Orden, estado, fecha_creacion 
FROM ordenes_compra 
ORDER BY id_orden_compra DESC 
LIMIT 10;
