-- =====================================================
-- SCRIPT PARA AGREGAR ESTADO 'Salida' A planes_transporte
-- =====================================================

USE telito_bodeguero;

-- Modificar el ENUM para agregar el estado 'Salida'
ALTER TABLE planes_transporte 
MODIFY COLUMN estado ENUM('Pendiente','En Ruta','Entregado','Cancelado','Salida') NOT NULL;

SELECT '✓ Estado "Salida" agregado correctamente a la tabla planes_transporte' AS resultado;

