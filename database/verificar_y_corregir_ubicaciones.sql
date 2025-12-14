-- Script para corregir las ubicaciones "Cercado" y "Cercado de Lima"
-- Estas son ubicaciones geográficas (distritos), no ubicaciones físicas de almacén
-- Se migrarán todos los lotes a "Almacen Seco" (id 10) y se eliminarán estas ubicaciones incorrectas

-- ============================================
-- PASO 1: Verificar el estado actual
-- ============================================
SELECT 
    u.id_ubicacion,
    u.nombre AS nombre_ubicacion,
    COUNT(l.id_lote) AS total_lotes
FROM ubicaciones u
LEFT JOIN lotes l ON u.id_ubicacion = l.ubicacion_id
WHERE u.id_ubicacion IN (11, 12)
GROUP BY u.id_ubicacion, u.nombre;

-- ============================================
-- PASO 2: Migrar todos los lotes a "Almacen Seco" (id 10)
-- ============================================
-- "Almacen Seco" es una ubicación válida para almacenar productos que no requieren refrigeración
UPDATE lotes 
SET ubicacion_id = 10 
WHERE ubicacion_id IN (11, 12);

-- Verificar que la migración fue exitosa
SELECT 
    'Lotes migrados correctamente' AS resultado,
    COUNT(*) AS total_lotes_migrados
FROM lotes 
WHERE ubicacion_id = 10 
AND id_lote IN (
    SELECT id_lote FROM lotes WHERE ubicacion_id IN (11, 12)
);

-- ============================================
-- PASO 3: Eliminar las ubicaciones incorrectas
-- ============================================
-- IMPORTANTE: Solo ejecutar después de verificar que no hay lotes usando estas ubicaciones
DELETE FROM ubicaciones WHERE id_ubicacion IN (11, 12);

-- ============================================
-- PASO 4: Verificar el resultado final
-- ============================================
SELECT 
    'Ubicaciones restantes' AS tipo,
    id_ubicacion,
    nombre
FROM ubicaciones
ORDER BY id_ubicacion;

