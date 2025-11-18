-- Script para agregar el campo costo_produccion a la tabla lotes
-- Este campo almacena el costo de producción por unidad del lote

ALTER TABLE lotes 
ADD COLUMN costo_produccion DECIMAL(10, 2) NULL COMMENT 'Costo de producción por unidad del lote' 
AFTER stock_actual;

-- Actualizar lotes existentes con un valor por defecto si es necesario
-- UPDATE lotes SET costo_produccion = 0.00 WHERE costo_produccion IS NULL;

