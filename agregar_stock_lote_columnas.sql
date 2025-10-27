-- =====================================================
-- Script para agregar columnas de Stock por Lote
-- a la tabla stock_minimo_config
-- =====================================================

USE telito_bodeguero;

-- Renombrar columnas existentes para mayor claridad
ALTER TABLE stock_minimo_config 
CHANGE COLUMN stock_minimo stock_minimo_producto INT UNSIGNED NOT NULL DEFAULT 10,
CHANGE COLUMN stock_critico stock_critico_producto INT UNSIGNED NOT NULL DEFAULT 5;

-- Agregar las nuevas columnas para control por lote
ALTER TABLE stock_minimo_config
ADD COLUMN stock_minimo_lote INT UNSIGNED NOT NULL DEFAULT 10 AFTER stock_critico_producto,
ADD COLUMN stock_critico_lote INT UNSIGNED NOT NULL DEFAULT 5 AFTER stock_minimo_lote;

-- Verificar la estructura actualizada
DESCRIBE stock_minimo_config;

SELECT '✓ Columnas agregadas exitosamente a stock_minimo_config' AS resultado;

