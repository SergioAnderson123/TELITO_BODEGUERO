-- Script para actualizar las contraseñas de los usuarios con SHA2
-- Ejecutar este script después de crear la base de datos

USE telito_bodeguero;

-- Actualizar contraseñas de usuarios existentes con SHA2
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'juan@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'maria@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'carlos@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'ana@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'luis@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'pedro@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'carmen@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'ricardo@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'sofia@empresa.com';
UPDATE usuarios SET password = SHA2('1234', 256) WHERE email = 'jorge@empresa.com';

-- Verificar que las contraseñas se actualizaron correctamente
SELECT id_usuario, nombres, apellidos, email, 
       CASE 
           WHEN password = SHA2('1234', 256) THEN 'Contraseña correcta'
           ELSE 'Contraseña incorrecta'
       END as estado_password
FROM usuarios 
WHERE email IN ('juan@empresa.com', 'maria@empresa.com', 'carlos@empresa.com', 'ana@empresa.com', 'luis@empresa.com');

SELECT 'Contraseñas actualizadas exitosamente' as mensaje;

