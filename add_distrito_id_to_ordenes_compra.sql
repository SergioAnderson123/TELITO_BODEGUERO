-- Script para agregar el campo distrito_id a la tabla ordenes_compra
-- Ejecutar este script en la base de datos telito_bodeguero

USE telito_bodeguero;

-- Agregar columna distrito_id si no existe
ALTER TABLE ordenes_compra 
ADD COLUMN IF NOT EXISTS distrito_id INT UNSIGNED NULL AFTER monto_total,
ADD KEY IF NOT EXISTS fk_oc_distrito (distrito_id),
ADD CONSTRAINT IF NOT EXISTS fk_oc_distrito FOREIGN KEY (distrito_id) REFERENCES distritos (idDistrito);

-- Verificar la estructura actualizada
DESCRIBE ordenes_compra;



