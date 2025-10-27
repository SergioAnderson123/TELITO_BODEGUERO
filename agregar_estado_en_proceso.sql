-- ==============================================
-- AGREGAR ESTADO 'En Proceso' A ordenes_compra
-- ==============================================

USE telito_bodeguero;

-- Modificar el ENUM para incluir 'En Proceso'
ALTER TABLE ordenes_compra 
MODIFY COLUMN estado ENUM('Pendiente','Aprobado','Rechazado','Recibido','En Proceso') NOT NULL;

SELECT '✓ Estado "En Proceso" agregado correctamente a ordenes_compra' AS resultado;

