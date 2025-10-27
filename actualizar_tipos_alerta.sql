-- =====================================================
-- SCRIPT: ACTUALIZAR TIPOS DE ALERTA
-- Propósito: Agregar nuevos tipos de alerta diferenciados
--           para alertas por lote (Almacén) y por producto total (Logística)
-- =====================================================

USE telito_bodeguero;

-- Desactivar safe update mode temporalmente
SET SQL_SAFE_UPDATES = 0;

-- Modificar el ENUM de tipo_alerta para incluir los nuevos tipos
ALTER TABLE alertas_configuracion 
MODIFY COLUMN tipo_alerta ENUM(
    'STOCK_MINIMO_LOTE',      -- Alerta cuando un lote individual está bajo
    'STOCK_CRITICO_LOTE',     -- Alerta crítica para un lote individual
    'STOCK_MINIMO_TOTAL',     -- Alerta cuando el total de un producto está bajo
    'STOCK_CRITICO_TOTAL',    -- Alerta crítica para el total de un producto
    'VENCIMIENTO',            -- Alerta de productos próximos a vencer
    'MOVIMIENTO',             -- Alerta de movimientos de inventario
    'STOCK_MINIMO',           -- LEGACY - mantener por compatibilidad
    'STOCK_CRITICO'           -- LEGACY - mantener por compatibilidad
) NOT NULL;

-- Actualizar alertas existentes con los nuevos tipos
-- Convertir las alertas STOCK_MINIMO legacy a STOCK_MINIMO_TOTAL
UPDATE alertas_configuracion 
SET tipo_alerta = 'STOCK_MINIMO_TOTAL' 
WHERE tipo_alerta = 'STOCK_MINIMO';

-- Convertir las alertas STOCK_CRITICO legacy a STOCK_CRITICO_TOTAL
UPDATE alertas_configuracion 
SET tipo_alerta = 'STOCK_CRITICO_TOTAL' 
WHERE tipo_alerta = 'STOCK_CRITICO';

-- Reactivar safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Mensaje de confirmación
SELECT '✓ Tipos de alerta actualizados correctamente' AS resultado;
SELECT '✓ Ahora puedes crear alertas diferenciadas para:' AS info;
SELECT '  - Lotes individuales (vista Almacén)' AS detalle1;
SELECT '  - Productos agrupados (vista Logística)' AS detalle2;

