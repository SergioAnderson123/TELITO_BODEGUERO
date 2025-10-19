-- Script SQL para crear usuarios de prueba en TELITO_BODEGUERO
-- Ejecutar este script en la base de datos MySQL

-- Primero, asegurémonos de que existan los roles básicos
INSERT IGNORE INTO roles (id_rol, nombre) VALUES 
(1, 'Administrador'),
(2, 'Logística'),
(3, 'Productor'),
(4, 'Almacén');

-- Crear usuarios de prueba con contraseñas hasheadas con SHA-256
-- Las contraseñas se hashean automáticamente usando SHA2(?, 256)

-- Usuario Administrador
INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES 
('Juan', 'Administrador', 'admin@telito.com', SHA2('admin123', 256), 1, 1);

-- Usuario de Logística
INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES 
('María', 'Logística', 'logistica@telito.com', SHA2('logistica123', 256), 1, 2);

-- Usuario Productor
INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES 
('Carlos', 'Productor', 'productor@telito.com', SHA2('productor123', 256), 1, 3);

-- Usuario Almacén
INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES 
('Ana', 'Almacén', 'almacen@telito.com', SHA2('almacen123', 256), 1, 4);

-- Usuario de prueba adicional
INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES 
('Pedro', 'Prueba', 'test@telito.com', SHA2('test123', 256), 1, 1);

-- Verificar que los usuarios se crearon correctamente
SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.activo, r.nombre as rol
FROM usuarios u 
INNER JOIN roles r ON u.rol_id = r.id_rol 
ORDER BY u.id_usuario;
