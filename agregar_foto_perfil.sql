-- =============================================
-- SCRIPT PARA AGREGAR COLUMNA foto_perfil A LA TABLA usuarios
-- =============================================

USE telito_bodeguero;

-- Agregar la columna foto_perfil a la tabla usuarios
ALTER TABLE usuarios 
ADD COLUMN foto_perfil VARCHAR(500) NULL AFTER activo;

-- Mensaje de confirmación
SELECT '✓ Columna foto_perfil agregada correctamente a la tabla usuarios' AS mensaje;

