-- Script simple para verificar y actualizar contraseñas
USE telito_bodeguero;

-- Verificar usuarios existentes
SELECT id_usuario, nombres, apellidos, email, activo FROM usuarios LIMIT 5;

-- Actualizar contraseñas (ejecutar solo si es necesario)
-- UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'juan@empresa.com';
-- UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'maria@empresa.com';

-- Verificar que las contraseñas están encriptadas
SELECT id_usuario, email, 
       CASE 
           WHEN LENGTH(password) = 64 THEN 'Contraseña encriptada (SHA2)'
           ELSE 'Contraseña sin encriptar'
       END as estado_password
FROM usuarios LIMIT 5;

