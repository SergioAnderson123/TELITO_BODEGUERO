-- Script para diagnosticar por qué no aparece el plan de transporte de "morocha"
-- en la tabla de planes de transporte del módulo de almacén

-- 1. Verificar si existe el plan de transporte para "morocha"
SELECT 
    pt.id_plan,
    pt.numero_plan,
    pt.estado,
    pt.lote_id,
    pt.conductor_id,
    pt.vehiculo_id,
    pt.distrito_id,
    pt.fecha_entrega,
    p.nombre AS nombre_producto,
    l.codigo_lote
FROM planes_transporte pt
LEFT JOIN lotes l ON pt.lote_id = l.id_lote
LEFT JOIN productos p ON l.producto_id = p.id_producto
WHERE p.nombre LIKE '%morocha%' OR l.codigo_lote LIKE '%0030%'
ORDER BY pt.id_plan DESC;

-- 2. Verificar todos los planes recientes (últimos 5)
SELECT 
    pt.id_plan,
    pt.numero_plan,
    pt.estado,
    p.nombre AS nombre_producto,
    l.codigo_lote,
    pt.fecha_entrega
FROM planes_transporte pt
LEFT JOIN lotes l ON pt.lote_id = l.id_lote
LEFT JOIN productos p ON l.producto_id = p.id_producto
ORDER BY pt.id_plan DESC
LIMIT 5;

-- 3. Verificar planes con estado 'Pendiente' o 'Salida' (los que deberían aparecer en almacén)
SELECT 
    pt.id_plan,
    pt.numero_plan,
    pt.estado,
    p.nombre AS nombre_producto,
    l.codigo_lote,
    c.nombre_completo AS conductor,
    v.placa AS vehiculo,
    d.nombre AS destino,
    pt.fecha_entrega
FROM planes_transporte pt
LEFT JOIN lotes l ON pt.lote_id = l.id_lote
LEFT JOIN productos p ON l.producto_id = p.id_producto
LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
LEFT JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
LEFT JOIN distritos d ON pt.distrito_id = d.idDistrito
WHERE pt.estado IN ('Pendiente', 'Salida')
ORDER BY pt.id_plan DESC;

-- 4. Verificar si hay problemas con las relaciones del plan más reciente
SELECT 
    pt.id_plan,
    pt.numero_plan,
    pt.estado,
    CASE 
        WHEN l.id_lote IS NULL THEN '❌ LOTE NO EXISTE'
        ELSE '✓ Lote existe'
    END AS estado_lote,
    CASE 
        WHEN p.id_producto IS NULL THEN '❌ PRODUCTO NO EXISTE'
        ELSE '✓ Producto existe'
    END AS estado_producto,
    CASE 
        WHEN c.id_conductor IS NULL THEN '❌ CONDUCTOR NO EXISTE'
        ELSE '✓ Conductor existe'
    END AS estado_conductor,
    CASE 
        WHEN v.id_vehiculo IS NULL THEN '❌ VEHICULO NO EXISTE'
        ELSE '✓ Vehículo existe'
    END AS estado_vehiculo,
    CASE 
        WHEN d.idDistrito IS NULL THEN '❌ DISTRITO NO EXISTE'
        ELSE '✓ Distrito existe'
    END AS estado_distrito
FROM planes_transporte pt
LEFT JOIN lotes l ON pt.lote_id = l.id_lote
LEFT JOIN productos p ON l.producto_id = p.id_producto
LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
LEFT JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
LEFT JOIN distritos d ON pt.distrito_id = d.idDistrito
WHERE pt.estado IN ('Pendiente', 'Salida')
ORDER BY pt.id_plan DESC
LIMIT 10;

-- 5. Verificar el lote L--0030 específicamente
SELECT 
    l.id_lote,
    l.codigo_lote,
    l.producto_id,
    l.stock_actual,
    l.estado AS estado_lote,
    p.nombre AS nombre_producto
FROM lotes l
LEFT JOIN productos p ON l.producto_id = p.id_producto
WHERE l.codigo_lote LIKE '%0030%' OR p.nombre LIKE '%morocha%';

-- 6. Ejecutar la consulta EXACTA que usa el DAO de almacén
SELECT 
    pt.id_plan,
    pt.numero_plan,
    p.nombre AS nombre_producto,
    l.codigo_lote,
    l.id_lote,
    l.stock_actual,
    CASE 
        WHEN pt.estado = 'Salida' THEN (
            SELECT FLOOR(mi.cantidad / p.unidades_por_paquete)
            FROM movimientos_inventario mi
            WHERE mi.lote_id = l.id_lote
            AND mi.tipo = 'Salida'
            AND mi.motivo LIKE CONCAT('Plan de transporte: ', pt.numero_plan)
            ORDER BY mi.fecha DESC
            LIMIT 1
        )
        ELSE FLOOR(l.stock_actual / p.unidades_por_paquete)
    END AS paquetes_disponibles,
    pt.estado,
    c.nombre_completo AS nombre_conductor,
    v.placa AS placa_vehiculo,
    DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
    d.nombre AS nombre_destino
FROM planes_transporte pt
LEFT JOIN lotes l ON pt.lote_id = l.id_lote
LEFT JOIN productos p ON l.producto_id = p.id_producto
LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
LEFT JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
LEFT JOIN distritos d ON pt.distrito_id = d.idDistrito
WHERE pt.estado IN ('Pendiente', 'Salida')
ORDER BY pt.id_plan DESC;

