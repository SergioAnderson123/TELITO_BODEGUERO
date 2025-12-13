-- Script para agregar el rol de Gerente de Tienda y el campo distrito_id a usuarios
-- Ejecutar este script en la base de datos telito_bodeguero

USE telito_bodeguero;

-- ============================================
-- 1. AGREGAR ROL "GERENTE DE TIENDA"
-- ============================================
INSERT INTO roles (id_rol, nombre) VALUES (7, 'Gerente de Tienda')
ON DUPLICATE KEY UPDATE nombre = 'Gerente de Tienda';

-- ============================================
-- 2. AGREGAR CAMPO distrito_id A LA TABLA usuarios
-- ============================================
-- Verificar si el campo ya existe antes de agregarlo
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'telito_bodeguero' 
    AND TABLE_NAME = 'usuarios' 
    AND COLUMN_NAME = 'distrito_id'
);

SET @sql = IF(@col_exists = 0,
    'ALTER TABLE usuarios ADD COLUMN distrito_id INT UNSIGNED NULL AFTER rol_id,
     ADD KEY fk_usuario_distrito (distrito_id),
     ADD CONSTRAINT fk_usuario_distrito FOREIGN KEY (distrito_id) REFERENCES distritos (idDistrito) ON DELETE SET NULL',
    'SELECT "El campo distrito_id ya existe en la tabla usuarios" AS mensaje'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ============================================
-- 3. VERIFICAR CAMBIOS
-- ============================================
SELECT 'Rol Gerente de Tienda agregado' AS mensaje;
SELECT id_rol, nombre FROM roles WHERE nombre = 'Gerente de Tienda';

SELECT 'Campo distrito_id agregado a usuarios' AS mensaje;
SHOW COLUMNS FROM usuarios LIKE 'distrito_id';

