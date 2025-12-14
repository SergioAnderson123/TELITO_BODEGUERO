-- Script para verificar notificaciones en la base de datos
-- Ejecutar después de crear una orden de compra desde Logística

-- 1. Ver todas las notificaciones recientes (últimas 10)
SELECT 
    n.id_notificacion,
    n.usuario_id,
    u.nombres,
    u.apellidos,
    u.email,
    r.nombre AS rol,
    n.tipo_notificacion,
    n.titulo,
    n.mensaje,
    n.nivel_prioridad,
    n.leida,
    n.fecha_creacion,
    n.url_accion
FROM notificaciones_web n
INNER JOIN usuarios u ON n.usuario_id = u.id_usuario
INNER JOIN roles r ON u.rol_id = r.id_rol
ORDER BY n.fecha_creacion DESC
LIMIT 10;

-- 2. Ver notificaciones de tipo ORDEN_COMPRA_CREADA
SELECT 
    n.id_notificacion,
    n.usuario_id,
    u.nombres,
    u.apellidos,
    r.nombre AS rol,
    n.tipo_notificacion,
    n.titulo,
    n.mensaje,
    n.fecha_creacion,
    n.leida
FROM notificaciones_web n
INNER JOIN usuarios u ON n.usuario_id = u.id_usuario
INNER JOIN roles r ON u.rol_id = r.id_rol
WHERE n.tipo_notificacion = 'ORDEN_COMPRA_CREADA'
ORDER BY n.fecha_creacion DESC;

-- 3. Ver notificaciones no leídas de un productor específico (reemplazar USER_ID con el ID del productor)
-- SELECT * FROM notificaciones_web WHERE usuario_id = USER_ID AND leida = 0 ORDER BY fecha_creacion DESC;

-- 4. Contar notificaciones por tipo
SELECT 
    tipo_notificacion,
    COUNT(*) AS total,
    SUM(CASE WHEN leida = 0 THEN 1 ELSE 0 END) AS no_leidas
FROM notificaciones_web
GROUP BY tipo_notificacion
ORDER BY total DESC;

