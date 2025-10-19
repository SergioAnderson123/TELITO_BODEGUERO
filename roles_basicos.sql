-- Script SQL para crear roles básicos en TELITO_BODEGUERO
-- Ejecutar este script en la base de datos MySQL antes de crear usuarios

-- Crear roles básicos (ignorar si ya existen)
INSERT IGNORE INTO roles (id_rol, nombre) VALUES 
(1, 'Administrador'),
(2, 'Logística'),
(3, 'Productor'),
(4, 'Almacén');

-- Verificar que los roles se crearon
SELECT * FROM roles ORDER BY id_rol;
