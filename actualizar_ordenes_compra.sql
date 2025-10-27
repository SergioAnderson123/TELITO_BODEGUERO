-- =====================================================
-- SCRIPT PARA CORREGIR LA TABLA ordenes_compra
-- Cambia proveedor_id a productor_id y apunta a usuarios
-- =====================================================

USE telito_bodeguero;

-- Deshabilitar verificaciones de claves foráneas temporalmente
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Eliminar la foreign key incorrecta
ALTER TABLE ordenes_compra 
DROP FOREIGN KEY fk_oc_proveedor;

-- 2. Renombrar la columna de proveedor_id a productor_id
ALTER TABLE ordenes_compra 
CHANGE COLUMN proveedor_id productor_id INT UNSIGNED NOT NULL;

-- 3. Agregar la columna distrito_id si no existe
ALTER TABLE ordenes_compra 
ADD COLUMN distrito_id INT UNSIGNED NOT NULL AFTER lote_id;

-- 4. Crear la nueva foreign key que apunta a usuarios
ALTER TABLE ordenes_compra 
ADD CONSTRAINT fk_oc_productor 
FOREIGN KEY (productor_id) REFERENCES usuarios (id_usuario);

-- 5. Crear la foreign key para distrito_id
ALTER TABLE ordenes_compra 
ADD CONSTRAINT fk_oc_distrito 
FOREIGN KEY (distrito_id) REFERENCES distritos (idDistrito);

-- Habilitar verificaciones de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

SELECT '✓ Tabla ordenes_compra actualizada correctamente' AS mensaje;
SELECT '✓ proveedor_id → productor_id (apunta a usuarios)' AS detalle_1;
SELECT '✓ Agregada columna distrito_id' AS detalle_2;

