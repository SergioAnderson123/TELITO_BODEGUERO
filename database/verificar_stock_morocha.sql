-- Script para verificar el stock de morocha y entender por qué muestra 0 paquetes

-- 1. Verificar el lote L--0030 de morocha
SELECT 
    l.id_lote,
    l.codigo_lote,
    l.stock_actual,
    l.estado AS estado_lote,
    p.nombre AS nombre_producto,
    p.unidades_por_paquete,
    FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes_calculados,
    u.nombre AS ubicacion
FROM lotes l
INNER JOIN productos p ON l.producto_id = p.id_producto
LEFT JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion
WHERE l.codigo_lote = 'L--0030' OR p.nombre LIKE '%morocha%';

-- 2. Verificar movimientos de inventario para el lote L--0030
SELECT 
    mi.id_movimiento,
    mi.tipo,
    mi.cantidad,
    mi.motivo,
    mi.fecha,
    DATE_FORMAT(mi.fecha, '%d/%m/%Y %H:%i:%s') AS fecha_formateada
FROM movimientos_inventario mi
INNER JOIN lotes l ON mi.lote_id = l.id_lote
WHERE l.codigo_lote = 'L--0030'
ORDER BY mi.fecha DESC;

-- 3. Verificar el plan de transporte PT012 y su relación con el stock
SELECT 
    pt.id_plan,
    pt.numero_plan,
    pt.estado AS estado_plan,
    l.codigo_lote,
    l.stock_actual,
    p.nombre AS nombre_producto,
    p.unidades_por_paquete,
    FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes_actuales,
    CASE 
        WHEN pt.estado = 'Salida' THEN (
            SELECT mi.cantidad
            FROM movimientos_inventario mi
            WHERE mi.lote_id = l.id_lote
            AND mi.tipo = 'Salida'
            AND mi.motivo LIKE CONCAT('Plan de transporte: ', pt.numero_plan)
            ORDER BY mi.fecha DESC
            LIMIT 1
        )
        ELSE NULL
    END AS cantidad_despachada
FROM planes_transporte pt
INNER JOIN lotes l ON pt.lote_id = l.id_lote
INNER JOIN productos p ON l.producto_id = p.id_producto
WHERE pt.numero_plan = 'PT012' OR l.codigo_lote = 'L--0030';

-- 4. Verificar el historial completo del lote L--0030 (entradas y salidas)
SELECT 
    'Entrada' AS tipo_operacion,
    mi.fecha,
    mi.cantidad,
    mi.motivo,
    'Stock después: ' || (SELECT stock_actual FROM lotes WHERE id_lote = mi.lote_id) AS stock_despues
FROM movimientos_inventario mi
INNER JOIN lotes l ON mi.lote_id = l.id_lote
WHERE l.codigo_lote = 'L--0030' AND mi.tipo = 'Entrada'
UNION ALL
SELECT 
    'Salida' AS tipo_operacion,
    mi.fecha,
    mi.cantidad,
    mi.motivo,
    'Stock después: ' || (SELECT stock_actual FROM lotes WHERE id_lote = mi.lote_id) AS stock_despues
FROM movimientos_inventario mi
INNER JOIN lotes l ON mi.lote_id = l.id_lote
WHERE l.codigo_lote = 'L--0030' AND mi.tipo = 'Salida'
ORDER BY fecha DESC;

