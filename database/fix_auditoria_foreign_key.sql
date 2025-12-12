-- =====================================================
-- FIX: Permitir NULL en usuario_id de auditoria_sistema
-- =====================================================
-- Esto permite registrar acciones de auditoría cuando el usuario
-- no está autenticado (ej: intentos de login fallidos)
-- =====================================================

USE telito_bodeguero;

-- Primero, verificar el tipo de dato de id_usuario en la tabla usuarios
-- para asegurarnos de que coincidan exactamente
SELECT 
    COLUMN_TYPE, 
    IS_NULLABLE, 
    COLUMN_KEY,
    EXTRA
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'telito_bodeguero' 
  AND TABLE_NAME = 'usuarios' 
  AND COLUMN_NAME = 'id_usuario';

-- 1. Eliminar la constraint de foreign key si existe
SET @constraint_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
    WHERE TABLE_SCHEMA = 'telito_bodeguero' 
      AND TABLE_NAME = 'auditoria_sistema' 
      AND CONSTRAINT_NAME = 'auditoria_sistema_ibfk_1'
      AND CONSTRAINT_TYPE = 'FOREIGN KEY'
);

-- Solo eliminar si existe
SET @drop_fk = IF(@constraint_exists > 0, 
    'ALTER TABLE auditoria_sistema DROP FOREIGN KEY auditoria_sistema_ibfk_1', 
    'SELECT "FK ya no existe" AS mensaje'
);
PREPARE stmt FROM @drop_fk;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Modificar la columna usuario_id para permitir NULL y que coincida exactamente con id_usuario
-- INT UNSIGNED para coincidir con la tabla usuarios (AUTO_INCREMENT generalmente es UNSIGNED)
ALTER TABLE `auditoria_sistema` 
MODIFY COLUMN `usuario_id` INT UNSIGNED NULL;

-- 3. Recrear la constraint de foreign key con soporte para NULL
ALTER TABLE `auditoria_sistema` 
ADD CONSTRAINT `auditoria_sistema_ibfk_1` 
FOREIGN KEY (`usuario_id`) 
REFERENCES `usuarios` (`id_usuario`) 
ON DELETE SET NULL;

-- 4. Actualizar registros existentes con usuario_id = 0 a NULL
UPDATE `auditoria_sistema` 
SET `usuario_id` = NULL 
WHERE `usuario_id` = 0;

-- Verificar los cambios
SELECT 
    COLUMN_NAME, 
    IS_NULLABLE, 
    COLUMN_TYPE,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'telito_bodeguero' 
  AND TABLE_NAME = 'auditoria_sistema' 
  AND COLUMN_NAME = 'usuario_id';

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'telito_bodeguero' 
  AND TABLE_NAME = 'auditoria_sistema'
  AND CONSTRAINT_TYPE = 'FOREIGN KEY';
