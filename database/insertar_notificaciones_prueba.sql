-- Script para insertar notificaciones de prueba en el sistema
-- Ejecutar después de crear la tabla notificaciones_web

USE telito_bodeguero;

-- Obtener el ID del primer usuario administrador activo (rol_id = 1 es Administrador)
SET @admin_id = (SELECT id_usuario FROM usuarios WHERE rol_id = 1 AND activo = TRUE LIMIT 1);

-- Verificar que existe un administrador
SELECT @admin_id as 'ID Administrador encontrado';

-- Notificación de ALERTA DEL SISTEMA (prioridad INFO) - MÁS RECIENTE
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, leida, fecha_creacion)
VALUES 
(@admin_id, 'ALERTA_SISTEMA', 'Sistema de notificaciones activado', 
'El sistema de notificaciones web está activo. Recibirás alertas sobre stock, vencimientos y eventos importantes.',
'INFO', FALSE, NOW());

-- Notificación de STOCK CRÍTICO (prioridad CRITICAL) - HACE 15 MIN
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, url_accion, leida, fecha_creacion)
VALUES 
(@admin_id, 'STOCK_CRITICO', 'Stock Crítico Detectado', 
'Se han detectado productos con stock crítico. Revisa el inventario urgentemente.',
'CRITICAL', '/TELITO_BODEGUERO/administrador/inventario-general.jsp', FALSE, DATE_SUB(NOW(), INTERVAL 15 MINUTE));

-- Notificación de VENCIMIENTO PRÓXIMO (prioridad WARNING) - HACE 1 HORA
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, url_accion, leida, fecha_creacion)
VALUES 
(@admin_id, 'VENCIMIENTO_PROXIMO', 'Productos próximos a vencer', 
'Hay lotes con fecha de vencimiento en los próximos 15 días. Revisar inventario.',
'WARNING', '/TELITO_BODEGUERO/administrador/inventario-general.jsp', FALSE, DATE_SUB(NOW(), INTERVAL 1 HOUR));

-- Notificación de PEDIDO PENDIENTE (prioridad WARNING) - HACE 2 HORAS
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, url_accion, leida, fecha_creacion)
VALUES 
(@admin_id, 'PEDIDO_PENDIENTE', 'Pedidos pendientes de revisión', 
'Tienes 3 pedidos pendientes que requieren tu atención y aprobación.',
'WARNING', '/TELITO_BODEGUERO/administrador/gestion-usuarios.jsp', FALSE, DATE_SUB(NOW(), INTERVAL 2 HOUR));

-- Notificación de MOVIMIENTO CRÍTICO (prioridad WARNING) - HACE 4 HORAS
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, leida, fecha_creacion)
VALUES 
(@admin_id, 'MOVIMIENTO_CRITICO', 'Movimiento importante registrado', 
'Se ha registrado un movimiento significativo de inventario. Verifica la auditoría.',
'WARNING', FALSE, DATE_SUB(NOW(), INTERVAL 4 HOUR));

-- Notificación de ORDEN_COMPRA_APROBADA (prioridad INFO) - HACE 6 HORAS
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, url_accion, leida, fecha_creacion)
VALUES 
(@admin_id, 'ORDEN_COMPRA_APROBADA', 'Orden de compra procesada', 
'Una orden de compra ha sido aprobada y está lista para ser procesada por el productor.',
'INFO', '/TELITO_BODEGUERO/administrador/inventario-general.jsp', FALSE, DATE_SUB(NOW(), INTERVAL 6 HOUR));

-- Notificación de STOCK MÍNIMO (prioridad WARNING) - HACE 1 DÍA - LEÍDA
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, url_accion, leida, fecha_creacion, fecha_lectura)
VALUES 
(@admin_id, 'STOCK_MINIMO', 'Stock en nivel mínimo', 
'Varios productos han alcanzado su stock mínimo. Considera realizar pedidos de reabastecimiento.',
'WARNING', '/TELITO_BODEGUERO/administrador/inventario-general.jsp', TRUE, 
DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 12 HOUR));

-- Notificación de INCIDENCIA_REPORTADA (prioridad WARNING) - HACE 2 DÍAS - LEÍDA
INSERT INTO notificaciones_web 
(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, leida, fecha_creacion, fecha_lectura)
VALUES 
(@admin_id, 'INCIDENCIA_REPORTADA', 'Incidencia resuelta', 
'La incidencia reportada en el almacén ha sido resuelta exitosamente.',
'INFO', TRUE, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY));

-- Verificar notificaciones creadas
SELECT 
    id_notificacion,
    tipo_notificacion,
    titulo,
    nivel_prioridad,
    leida,
    DATE_FORMAT(fecha_creacion, '%d/%m/%Y %H:%i') as fecha_creacion
FROM notificaciones_web
WHERE usuario_id = @admin_id
ORDER BY fecha_creacion DESC
LIMIT 10;

-- Verificar contador de notificaciones no leídas
SELECT COUNT(*) as notificaciones_no_leidas
FROM notificaciones_web
WHERE usuario_id = @admin_id AND leida = FALSE;
