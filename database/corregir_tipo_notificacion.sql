-- Script para corregir el tamaño de la columna tipo_notificacion
-- El error indica que la columna es demasiado pequeña para valores como 'ORDEN_COMPRA_CREADA' (20 caracteres)

USE telito_bodeguero;

-- 1. Verificar el tamaño actual de la columna
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'telito_bodeguero'
  AND TABLE_NAME = 'notificaciones_web'
  AND COLUMN_NAME = 'tipo_notificacion';

-- 2. Verificar el tipo más largo que necesitamos
-- Los tipos más largos son:
-- - ORDEN_COMPRA_CREADA (20 caracteres)
-- - PLAN_TRANSPORTE_CREADO (22 caracteres)
-- - VENCIMIENTO_7_DIAS (16 caracteres)
-- - VENCIMIENTO_3_DIAS (16 caracteres)
-- - ORDEN_LISTA_PRODUCTOR (21 caracteres)
-- - INCIDENCIA_REPORTADA (20 caracteres)
-- - AJUSTE_INVENTARIO (18 caracteres)
-- - ENTRADA_REGISTRADA (18 caracteres)
-- - PEDIDO_COMPLETADO (18 caracteres)
-- - PEDIDO_RECHAZADO (17 caracteres)
-- - ORDEN_CONFIRMADA (17 caracteres)
-- - ORDEN_RECHAZADA (16 caracteres)
-- - PRODUCTO_NUEVO (14 caracteres)
-- - USUARIO_CREADO (14 caracteres)
-- - ALERTA_CONFIGURADA (19 caracteres)
-- - STOCK_CRITICO (13 caracteres)
-- - STOCK_MINIMO (13 caracteres)
-- - LOTE_VENCIDO (13 caracteres)

-- El más largo es PLAN_TRANSPORTE_CREADO con 22 caracteres
-- Vamos a usar VARCHAR(50) para tener margen

-- 3. Modificar la columna para aumentar su tamaño
ALTER TABLE notificaciones_web 
MODIFY COLUMN tipo_notificacion VARCHAR(50) NOT NULL;

-- 4. Verificar que el cambio se aplicó correctamente
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'telito_bodeguero'
  AND TABLE_NAME = 'notificaciones_web'
  AND COLUMN_NAME = 'tipo_notificacion';

-- 5. Verificar que no hay datos truncados (opcional)
SELECT 
    tipo_notificacion,
    LENGTH(tipo_notificacion) AS longitud,
    COUNT(*) AS cantidad
FROM notificaciones_web
GROUP BY tipo_notificacion
ORDER BY longitud DESC;

