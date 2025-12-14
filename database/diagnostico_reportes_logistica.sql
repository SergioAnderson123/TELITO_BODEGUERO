-- ============================================================
-- QUERIES DE DIAGNÓSTICO PARA REPORTES DE LOGÍSTICA
-- ============================================================
-- Estos queries te ayudarán a identificar por qué no aparecen datos
-- en los reportes de "Rendimiento de Conductores" y 
-- "Historial de Pedidos Despachados"
-- ============================================================

-- ============================================================
-- 1. DIAGNÓSTICO: RENDIMIENTO DE CONDUCTORES
-- ============================================================

-- 1.1 Ver todos los estados posibles de planes_transporte
SELECT DISTINCT estado, COUNT(*) as cantidad
FROM planes_transporte
GROUP BY estado
ORDER BY cantidad DESC;

-- 1.2 Ver planes de transporte con sus conductores (todos los estados)
SELECT 
    pt.id_plan,
    pt.numero_plan,
    pt.estado,
    c.id_conductor,
    c.nombre_completo,
    pt.fecha_entrega,
    CASE 
        WHEN c.id_conductor IS NULL THEN 'SIN CONDUCTOR'
        WHEN pt.estado = 'Entregado' THEN 'ENTREGADO'
        ELSE 'OTRO ESTADO'
    END as diagnostico
FROM planes_transporte pt
LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
ORDER BY pt.fecha_entrega DESC, pt.id_plan DESC
LIMIT 20;

-- 1.3 Ver planes con estado "Entregado" (exacto)
SELECT 
    pt.id_plan,
    pt.numero_plan,
    pt.estado,
    c.nombre_completo,
    pt.fecha_entrega
FROM planes_transporte pt
LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
WHERE pt.estado = 'Entregado'
ORDER BY pt.fecha_entrega DESC;

-- 1.4 Query exacto que usa el reporte (para comparar)
SELECT 
    c.nombre_completo, 
    COUNT(pt.id_plan) AS entregas 
FROM planes_transporte pt 
JOIN conductores c ON pt.conductor_id = c.id_conductor 
WHERE pt.estado = 'Entregado' 
GROUP BY c.nombre_completo 
ORDER BY entregas DESC 
LIMIT 5;

-- 1.5 Ver si hay planes con estados similares a "Entregado"
SELECT 
    estado,
    COUNT(*) as cantidad,
    GROUP_CONCAT(DISTINCT numero_plan SEPARATOR ', ') as ejemplos
FROM planes_transporte
WHERE estado LIKE '%entreg%' OR estado LIKE '%Entreg%' OR estado LIKE '%ENTREG%'
GROUP BY estado;

-- ============================================================
-- 2. DIAGNÓSTICO: HISTORIAL DE PEDIDOS DESPACHADOS
-- ============================================================

-- 2.1 Ver todos los estados posibles de pedidos
SELECT DISTINCT estado_preparacion, COUNT(*) as cantidad
FROM pedidos
GROUP BY estado_preparacion
ORDER BY cantidad DESC;

-- 2.1.1 Verificar si hay pedidos en la tabla (diagnóstico adicional)
SELECT 
    'Total de pedidos' as tipo,
    COUNT(*) as cantidad
FROM pedidos
UNION ALL
SELECT 
    'Pedidos con estado Despachado' as tipo,
    COUNT(*) as cantidad
FROM pedidos
WHERE estado_preparacion = 'Despachado'
UNION ALL
SELECT 
    'Pedidos últimos 6 meses' as tipo,
    COUNT(*) as cantidad
FROM pedidos
WHERE fecha_creacion >= DATE_SUB(NOW(), INTERVAL 6 MONTH);

-- 2.2 Ver pedidos con estado "Despachado" (exacto)
SELECT 
    id_pedido,
    numero_pedido,
    estado_preparacion,
    fecha_creacion,
    DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes
FROM pedidos
WHERE estado_preparacion = 'Despachado'
ORDER BY fecha_creacion DESC
LIMIT 20;

-- 2.3 Ver pedidos de los últimos 6 meses (todos los estados)
SELECT 
    DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes,
    estado_preparacion,
    COUNT(*) as cantidad
FROM pedidos
WHERE fecha_creacion >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
GROUP BY mes, estado_preparacion
ORDER BY mes DESC, cantidad DESC;

-- 2.4 Query exacto que usa el reporte (para comparar)
SELECT 
    DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes, 
    COUNT(*) AS cantidad 
FROM pedidos 
WHERE estado_preparacion = 'Despachado' 
AND fecha_creacion >= DATE_SUB(NOW(), INTERVAL 6 MONTH) 
GROUP BY mes 
ORDER BY mes ASC;

-- 2.5 Ver si hay pedidos con estados similares a "Despachado"
SELECT 
    estado_preparacion,
    COUNT(*) as cantidad,
    GROUP_CONCAT(DISTINCT numero_pedido SEPARATOR ', ') as ejemplos
FROM pedidos
WHERE estado_preparacion LIKE '%despach%' 
   OR estado_preparacion LIKE '%Despach%' 
   OR estado_preparacion LIKE '%DESPACH%'
GROUP BY estado_preparacion;

-- 2.6 Ver estructura de la tabla pedidos (para verificar campos)
DESCRIBE pedidos;

-- ============================================================
-- 3. VERIFICACIÓN DE DATOS RELACIONADOS
-- ============================================================

-- 3.1 Ver movimientos de inventario relacionados con pedidos
SELECT 
    p.id_pedido,
    p.numero_pedido,
    p.estado_preparacion,
    mi.tipo,
    mi.fecha,
    mi.cantidad
FROM pedidos p
LEFT JOIN movimientos_inventario mi ON mi.pedido_id = p.id_pedido
WHERE p.estado_preparacion LIKE '%despach%'
ORDER BY p.fecha_creacion DESC
LIMIT 20;

-- 3.2 Ver planes de transporte relacionados con pedidos (a través de movimientos y lotes)
SELECT 
    p.id_pedido,
    p.numero_pedido,
    p.estado_preparacion,
    pt.id_plan,
    pt.numero_plan,
    pt.estado as estado_plan,
    mi.tipo as tipo_movimiento,
    l.codigo_lote
FROM pedidos p
LEFT JOIN movimientos_inventario mi ON mi.pedido_id = p.id_pedido
LEFT JOIN lotes l ON mi.lote_id = l.id_lote
LEFT JOIN planes_transporte pt ON pt.lote_id = l.id_lote
WHERE p.estado_preparacion LIKE '%despach%'
ORDER BY p.fecha_creacion DESC
LIMIT 20;

-- ============================================================
-- 4. QUERIES ALTERNATIVOS (por si los estados son diferentes)
-- ============================================================

-- 4.1 Rendimiento de conductores - versión más flexible
SELECT 
    c.nombre_completo, 
    COUNT(pt.id_plan) AS entregas 
FROM planes_transporte pt 
JOIN conductores c ON pt.conductor_id = c.id_conductor 
WHERE pt.estado LIKE '%entreg%' OR pt.estado = 'Completado'
GROUP BY c.nombre_completo 
ORDER BY entregas DESC 
LIMIT 5;

-- 4.2 Historial de pedidos - versión más flexible
SELECT 
    DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes, 
    COUNT(*) AS cantidad 
FROM pedidos 
WHERE (estado_preparacion LIKE '%despach%' 
       OR estado_preparacion = 'Completado'
       OR estado_preparacion = 'Enviado')
AND fecha_creacion >= DATE_SUB(NOW(), INTERVAL 6 MONTH) 
GROUP BY mes 
ORDER BY mes ASC;

-- ============================================================
-- 5. RESUMEN GENERAL
-- ============================================================

-- 5.1 Resumen de planes de transporte
SELECT 
    'Total planes' as tipo,
    COUNT(*) as cantidad
FROM planes_transporte
UNION ALL
SELECT 
    'Planes con estado Entregado' as tipo,
    COUNT(*) as cantidad
FROM planes_transporte
WHERE estado = 'Entregado'
UNION ALL
SELECT 
    'Planes con conductor asignado' as tipo,
    COUNT(*) as cantidad
FROM planes_transporte
WHERE conductor_id IS NOT NULL;

-- 5.2 Resumen de pedidos
SELECT 
    'Total pedidos' as tipo,
    COUNT(*) as cantidad
FROM pedidos
UNION ALL
SELECT 
    'Pedidos Despachados' as tipo,
    COUNT(*) as cantidad
FROM pedidos
WHERE estado_preparacion = 'Despachado'
UNION ALL
SELECT 
    'Pedidos últimos 6 meses' as tipo,
    COUNT(*) as cantidad
FROM pedidos
WHERE fecha_creacion >= DATE_SUB(NOW(), INTERVAL 6 MONTH);

