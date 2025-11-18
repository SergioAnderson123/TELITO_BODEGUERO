-- =====================================================
-- Script para activar todas las cuentas existentes
-- =====================================================
-- Este script activa automáticamente todas las cuentas
-- que fueron creadas antes de implementar el sistema
-- de activación por email.
-- =====================================================

USE telito_bodeguero;

-- Activar todas las cuentas existentes que no estén activadas
-- y establecer la fecha de activación como la fecha actual
-- Usamos id_usuario en el WHERE para cumplir con el modo seguro de MySQL

-- OPCIÓN 1: Desactivar temporalmente el modo seguro (más simple)
SET SQL_SAFE_UPDATES = 0;

UPDATE usuarios 
SET 
    cuenta_activada = 1,
    fecha_activacion = NOW()
WHERE 
    cuenta_activada = 0 
    OR cuenta_activada IS NULL
    OR fecha_activacion IS NULL;

-- Reactivar el modo seguro
SET SQL_SAFE_UPDATES = 1;

-- Verificar el resultado
SELECT 
    id_usuario,
    email,
    nombres,
    apellidos,
    cuenta_activada,
    fecha_activacion,
    activo
FROM usuarios
ORDER BY id_usuario;

-- Mostrar resumen
SELECT 
    COUNT(*) AS total_usuarios,
    SUM(CASE WHEN cuenta_activada = 1 THEN 1 ELSE 0 END) AS usuarios_activados,
    SUM(CASE WHEN cuenta_activada = 0 OR cuenta_activada IS NULL THEN 1 ELSE 0 END) AS usuarios_no_activados
FROM usuarios;
