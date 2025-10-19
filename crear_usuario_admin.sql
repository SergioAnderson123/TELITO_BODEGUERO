-- Script SQL SIMPLE para crear usuarios de prueba
-- Ejecutar este script en MySQL

-- 1. Crear roles básicos
INSERT IGNORE INTO roles (id_rol, nombre) VALUES 
(1, 'Administrador'),
(2, 'Logística'),
(3, 'Productor'),
(4, 'Almacén');

-- 2. Crear un usuario administrador de prueba
INSERT IGNORE INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES 
('Admin', 'Sistema', 'admin@telito.com', SHA2('admin123', 256), 1, 1);

-- 3. Verificar que se creó
SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.activo, r.nombre as rol
FROM usuarios u 
INNER JOIN roles r ON u.rol_id = r.id_rol 
WHERE u.email = 'admin@telito.com';
