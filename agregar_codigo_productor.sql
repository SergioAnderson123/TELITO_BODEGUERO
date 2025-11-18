-- =====================================================
-- Script para agregar campo código_productor a usuarios
-- =====================================================

-- 1. Agregar columna codigo_productor a la tabla usuarios
ALTER TABLE `usuarios` 
ADD COLUMN `codigo_productor` VARCHAR(50) NULL DEFAULT NULL AFTER `email`,
ADD UNIQUE KEY `unique_codigo_productor` (`codigo_productor`);

-- 2. Generar códigos automáticos para productores existentes
-- Formato: PROD-0001, PROD-0002, etc.
UPDATE `usuarios` u
INNER JOIN `roles` r ON u.rol_id = r.id_rol
SET u.`codigo_productor` = CONCAT('PROD-', LPAD(u.id_usuario, 4, '0'))
WHERE r.nombre = 'Productor' 
AND u.`codigo_productor` IS NULL;

-- 3. Crear trigger para generar código automático al crear nuevos productores
DELIMITER $$

CREATE TRIGGER `generar_codigo_productor` 
BEFORE INSERT ON `usuarios`
FOR EACH ROW
BEGIN
    -- Si el usuario es productor y no tiene código, generarlo automáticamente
    IF NEW.rol_id = 3 AND (NEW.codigo_productor IS NULL OR NEW.codigo_productor = '') THEN
        -- Obtener el siguiente número de productor
        SET @next_num = (
            SELECT COALESCE(MAX(CAST(SUBSTRING(codigo_productor, 6) AS UNSIGNED)), 0) + 1
            FROM usuarios
            WHERE codigo_productor LIKE 'PROD-%'
        );
        SET NEW.codigo_productor = CONCAT('PROD-', LPAD(@next_num, 4, '0'));
    END IF;
END$$

DELIMITER ;

-- 4. Verificar que los códigos se generaron correctamente
SELECT id_usuario, nombres, apellidos, email, codigo_productor, r.nombre as rol
FROM usuarios u
INNER JOIN roles r ON u.rol_id = r.id_rol
WHERE r.nombre = 'Productor'
ORDER BY id_usuario;

