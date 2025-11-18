-- Script de ANÁLISIS PREVIO - NO ELIMINA NADA
-- Ejecuta este script primero para ver qué se va a eliminar

USE telito_bodeguero;

-- ============================================
-- ANÁLISIS DE ZONAS
-- ============================================

SELECT '═══════════════════════════════════════════════════════════' AS '';
SELECT 'ANÁLISIS DE ZONAS' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';

-- 1. Todas las zonas actuales
SELECT '1. TODAS LAS ZONAS ACTUALES:' AS '';
SELECT idZona, nombre, 
       CASE 
           WHEN nombre IN ('Norte', 'Sur', 'Este', 'Oeste') THEN '✅ CORRECTA'
           ELSE '❌ INCORRECTA (se eliminará)'
       END AS estado
FROM zonas
ORDER BY idZona;

-- 2. Zonas duplicadas
SELECT '' AS '';
SELECT '2. ZONAS DUPLICADAS:' AS '';
SELECT nombre, COUNT(*) as cantidad, 
       GROUP_CONCAT(idZona ORDER BY idZona SEPARATOR ', ') as ids_duplicados,
       MIN(idZona) as id_a_mantener,
       GROUP_CONCAT(CASE WHEN idZona != MIN(idZona) THEN idZona END ORDER BY idZona SEPARATOR ', ') as ids_a_eliminar
FROM zonas
GROUP BY nombre
HAVING COUNT(*) > 1;

-- 3. Zonas incorrectas (que no deberían existir)
SELECT '' AS '';
SELECT '3. ZONAS INCORRECTAS (se eliminarán):' AS '';
SELECT idZona, nombre, 
       (SELECT COUNT(*) FROM distritos WHERE zona_id = zonas.idZona) as distritos_asignados
FROM zonas
WHERE nombre NOT IN ('Norte', 'Sur', 'Este', 'Oeste')
ORDER BY idZona;

-- ============================================
-- ANÁLISIS DE DISTRITOS
-- ============================================

SELECT '' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';
SELECT 'ANÁLISIS DE DISTRITOS' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';

-- 4. Distritos duplicados
SELECT '4. DISTRITOS DUPLICADOS:' AS '';
SELECT nombre, COUNT(*) as cantidad, 
       GROUP_CONCAT(idDistrito ORDER BY idDistrito SEPARATOR ', ') as ids_duplicados,
       MIN(idDistrito) as id_a_mantener,
       GROUP_CONCAT(CASE WHEN idDistrito != MIN(idDistrito) THEN idDistrito END ORDER BY idDistrito SEPARATOR ', ') as ids_a_eliminar
FROM distritos
GROUP BY nombre
HAVING COUNT(*) > 1;

-- 5. Distritos incorrectos (fuera de Lima)
SELECT '' AS '';
SELECT '5. DISTRITOS INCORRECTOS - FUERA DE LIMA (se eliminarán):' AS '';
SELECT idDistrito, nombre, zona_id,
       (SELECT nombre FROM zonas WHERE idZona = distritos.zona_id) as zona_actual
FROM distritos
WHERE nombre IN ('Ica', 'Arequipa', 'Cusco', 'Puno', 'Trujillo', 'Chiclayo', 'Tarapoto', 'Callao')
ORDER BY nombre;

-- 6. Distritos con zona_id incorrecto o inexistente
SELECT '' AS '';
SELECT '6. DISTRITOS CON ZONA_ID INCORRECTO:' AS '';
SELECT d.idDistrito, d.nombre, d.zona_id, 
       COALESCE(z.nombre, '❌ ZONA NO EXISTE') as zona_nombre,
       CASE 
           WHEN z.idZona IS NULL THEN '❌ Zona no existe'
           WHEN z.nombre NOT IN ('Norte', 'Sur', 'Este', 'Oeste') THEN '❌ Zona incorrecta'
           ELSE '✅ OK'
       END AS estado
FROM distritos d
LEFT JOIN zonas z ON d.zona_id = z.idZona
WHERE z.idZona IS NULL OR z.nombre NOT IN ('Norte', 'Sur', 'Este', 'Oeste')
ORDER BY d.zona_id, d.nombre;

-- 7. Resumen de distritos por zona actual
SELECT '' AS '';
SELECT '7. RESUMEN ACTUAL DE DISTRITOS POR ZONA:' AS '';
SELECT 
    COALESCE(z.nombre, '❌ ZONA NO EXISTE') as zona,
    z.idZona,
    COUNT(d.idDistrito) as total_distritos,
    GROUP_CONCAT(d.nombre ORDER BY d.nombre SEPARATOR ', ') as distritos
FROM zonas z
LEFT JOIN distritos d ON z.idZona = d.zona_id
GROUP BY z.idZona, z.nombre
ORDER BY z.idZona;

-- 8. Distritos que deberían estar en cada zona (según nombre)
SELECT '' AS '';
SELECT '8. DISTRIBUCIÓN ESPERADA DE DISTRITOS:' AS '';

SELECT 'NORTE (8 distritos):' AS zona_esperada;
SELECT idDistrito, nombre, zona_id, 
       CASE WHEN zona_id IN (1, 11) THEN '✅' ELSE '❌ Reasignar a zona 1' END AS estado
FROM distritos
WHERE nombre IN ('Ancon', 'Santa Rosa', 'Carabayllo', 'Puente Piedra', 'Comas', 'Los Olivos', 'San Martín de Porres', 'Independencia')
ORDER BY nombre;

SELECT '' AS '';
SELECT 'SUR (10 distritos):' AS zona_esperada;
SELECT idDistrito, nombre, zona_id,
       CASE WHEN zona_id IN (2, 12) THEN '✅' ELSE '❌ Reasignar a zona 2' END AS estado
FROM distritos
WHERE nombre IN ('San Juan de Miraflores', 'Villa María del Triunfo', 'Villa el Salvador', 'Pachacamac', 
                 'Lurin', 'Punta Hermosa', 'Punta Negra', 'San Bartolo', 'Santa María del Mar', 'Pucusana')
ORDER BY nombre;

SELECT '' AS '';
SELECT 'ESTE (7 distritos):' AS zona_esperada;
SELECT idDistrito, nombre, zona_id,
       CASE WHEN zona_id IN (3, 13) THEN '✅' ELSE '❌ Reasignar a zona 3' END AS estado
FROM distritos
WHERE nombre IN ('San Juan de Lurigancho', 'Lurigancho', 'Ate', 'El Agustino', 'Santa Anita', 'La Molina', 'Cieneguilla')
ORDER BY nombre;

SELECT '' AS '';
SELECT 'OESTE (16 distritos):' AS zona_esperada;
SELECT idDistrito, nombre, zona_id,
       CASE WHEN zona_id IN (4, 14) THEN '✅' ELSE '❌ Reasignar a zona 4' END AS estado
FROM distritos
WHERE nombre IN ('Rimac', 'Cercado de Lima', 'Breña', 'Pueblo Libre', 'Magdalena', 'Jesus María', 
                 'La Victoria', 'Lince', 'San Isidro', 'San Miguel', 'Surquillo', 'San Borja', 
                 'Santiago de Surco', 'Barranco', 'Chorrillos', 'San Luis', 'Miraflores')
ORDER BY nombre;

-- 9. Resumen final
SELECT '' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';
SELECT 'RESUMEN FINAL' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';

SELECT 
    'Total zonas actuales' AS concepto,
    COUNT(*) AS cantidad
FROM zonas
UNION ALL
SELECT 
    'Zonas correctas (Norte, Sur, Este, Oeste)',
    COUNT(*)
FROM zonas
WHERE nombre IN ('Norte', 'Sur', 'Este', 'Oeste')
UNION ALL
SELECT 
    'Zonas a eliminar',
    COUNT(*)
FROM zonas
WHERE nombre NOT IN ('Norte', 'Sur', 'Este', 'Oeste')
UNION ALL
SELECT 
    'Total distritos actuales',
    COUNT(*)
FROM distritos
UNION ALL
SELECT 
    'Distritos duplicados',
    COUNT(*) - COUNT(DISTINCT nombre)
FROM distritos
UNION ALL
SELECT 
    'Distritos incorrectos (fuera de Lima)',
    COUNT(*)
FROM distritos
WHERE nombre IN ('Ica', 'Arequipa', 'Cusco', 'Puno', 'Trujillo', 'Chiclayo', 'Tarapoto', 'Callao')
UNION ALL
SELECT 
    'Distritos esperados (41)',
    41;

