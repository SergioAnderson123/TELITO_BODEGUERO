-- Script de VERIFICACIÓN FINAL de zonas y distritos
-- Ejecuta este script para verificar que todo esté correcto

USE telito_bodeguero;

SELECT '═══════════════════════════════════════════════════════════' AS '';
SELECT 'VERIFICACIÓN FINAL: ZONAS Y DISTRITOS' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';

-- 1. Verificar zonas (deben ser solo 4)
SELECT '' AS '';
SELECT '1. ZONAS (deben ser 4: Norte, Sur, Este, Oeste)' AS '';
SELECT idZona, nombre FROM zonas ORDER BY idZona;

SELECT '' AS '';
SELECT CASE 
    WHEN COUNT(*) = 4 THEN '✅ CORRECTO: Hay 4 zonas'
    ELSE CONCAT('❌ ERROR: Hay ', COUNT(*), ' zonas (deben ser 4)')
END AS estado
FROM zonas;

-- 2. Verificar distritos por zona
SELECT '' AS '';
SELECT '2. DISTRITOS POR ZONA' AS '';
SELECT 
    z.nombre AS zona,
    COUNT(d.idDistrito) AS total_distritos,
    CASE 
        WHEN z.nombre = 'Norte' AND COUNT(d.idDistrito) = 8 THEN '✅'
        WHEN z.nombre = 'Sur' AND COUNT(d.idDistrito) = 10 THEN '✅'
        WHEN z.nombre = 'Este' AND COUNT(d.idDistrito) = 7 THEN '✅'
        WHEN z.nombre = 'Oeste' AND COUNT(d.idDistrito) = 16 THEN '✅'
        ELSE '❌'
    END AS estado,
    GROUP_CONCAT(d.nombre ORDER BY d.nombre SEPARATOR ', ') AS distritos
FROM zonas z
LEFT JOIN distritos d ON z.idZona = d.zona_id
GROUP BY z.idZona, z.nombre
ORDER BY z.idZona;

-- 3. Verificar total de distritos (debe ser 41)
SELECT '' AS '';
SELECT '3. TOTAL DE DISTRITOS' AS '';
SELECT 
    COUNT(*) AS total_distritos,
    CASE 
        WHEN COUNT(*) = 41 THEN '✅ CORRECTO: Hay 41 distritos'
        ELSE CONCAT('❌ ERROR: Hay ', COUNT(*), ' distritos (deben ser 41)')
    END AS estado
FROM distritos;

-- 4. Verificar duplicados (no debe haber)
SELECT '' AS '';
SELECT '4. DISTRITOS DUPLICADOS' AS '';
SELECT nombre, COUNT(*) as cantidad, GROUP_CONCAT(idDistrito ORDER BY idDistrito) as ids
FROM distritos
GROUP BY nombre
HAVING COUNT(*) > 1;

SELECT '' AS '';
SELECT CASE 
    WHEN COUNT(*) = 0 THEN '✅ CORRECTO: No hay distritos duplicados'
    ELSE CONCAT('❌ ERROR: Hay ', COUNT(*), ' distrito(s) duplicado(s)')
END AS estado
FROM (
    SELECT nombre, COUNT(*) as cantidad
    FROM distritos
    GROUP BY nombre
    HAVING COUNT(*) > 1
) AS duplicados;

-- 5. Listar todos los distritos requeridos y verificar cuáles faltan
SELECT '' AS '';
SELECT '5. DISTRITOS REQUERIDOS - VERIFICACIÓN' AS '';

-- NORTE (8 distritos)
SELECT 'NORTE (8 distritos requeridos):' AS zona;
SELECT 
    d.nombre,
    CASE WHEN d.idDistrito IS NOT NULL THEN '✅' ELSE '❌ FALTA' END AS estado
FROM (
    SELECT 'Ancon' AS nombre UNION ALL
    SELECT 'Santa Rosa' UNION ALL
    SELECT 'Carabayllo' UNION ALL
    SELECT 'Puente Piedra' UNION ALL
    SELECT 'Comas' UNION ALL
    SELECT 'Los Olivos' UNION ALL
    SELECT 'San Martín de Porres' UNION ALL
    SELECT 'Independencia'
) AS requeridos
LEFT JOIN distritos d ON requeridos.nombre = d.nombre
ORDER BY requeridos.nombre;

-- SUR (10 distritos)
SELECT '' AS '';
SELECT 'SUR (10 distritos requeridos):' AS zona;
SELECT 
    d.nombre,
    CASE WHEN d.idDistrito IS NOT NULL THEN '✅' ELSE '❌ FALTA' END AS estado
FROM (
    SELECT 'San Juan de Miraflores' AS nombre UNION ALL
    SELECT 'Villa María del Triunfo' UNION ALL
    SELECT 'Villa el Salvador' UNION ALL
    SELECT 'Pachacamac' UNION ALL
    SELECT 'Lurin' UNION ALL
    SELECT 'Punta Hermosa' UNION ALL
    SELECT 'Punta Negra' UNION ALL
    SELECT 'San Bartolo' UNION ALL
    SELECT 'Santa María del Mar' UNION ALL
    SELECT 'Pucusana'
) AS requeridos
LEFT JOIN distritos d ON requeridos.nombre = d.nombre
ORDER BY requeridos.nombre;

-- ESTE (7 distritos)
SELECT '' AS '';
SELECT 'ESTE (7 distritos requeridos):' AS zona;
SELECT 
    d.nombre,
    CASE WHEN d.idDistrito IS NOT NULL THEN '✅' ELSE '❌ FALTA' END AS estado
FROM (
    SELECT 'San Juan de Lurigancho' AS nombre UNION ALL
    SELECT 'Lurigancho' UNION ALL
    SELECT 'Ate' UNION ALL
    SELECT 'El Agustino' UNION ALL
    SELECT 'Santa Anita' UNION ALL
    SELECT 'La Molina' UNION ALL
    SELECT 'Cieneguilla'
) AS requeridos
LEFT JOIN distritos d ON requeridos.nombre = d.nombre
ORDER BY requeridos.nombre;

-- OESTE (16 distritos)
SELECT '' AS '';
SELECT 'OESTE (16 distritos requeridos):' AS zona;
SELECT 
    d.nombre,
    CASE WHEN d.idDistrito IS NOT NULL THEN '✅' ELSE '❌ FALTA' END AS estado
FROM (
    SELECT 'Rimac' AS nombre UNION ALL
    SELECT 'Cercado de Lima' UNION ALL
    SELECT 'Breña' UNION ALL
    SELECT 'Pueblo Libre' UNION ALL
    SELECT 'Magdalena' UNION ALL
    SELECT 'Jesus María' UNION ALL
    SELECT 'La Victoria' UNION ALL
    SELECT 'Lince' UNION ALL
    SELECT 'San Isidro' UNION ALL
    SELECT 'San Miguel' UNION ALL
    SELECT 'Surquillo' UNION ALL
    SELECT 'San Borja' UNION ALL
    SELECT 'Santiago de Surco' UNION ALL
    SELECT 'Barranco' UNION ALL
    SELECT 'Chorrillos' UNION ALL
    SELECT 'San Luis' UNION ALL
    SELECT 'Miraflores'
) AS requeridos
LEFT JOIN distritos d ON requeridos.nombre = d.nombre
ORDER BY requeridos.nombre;

-- 6. Resumen final
SELECT '' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';
SELECT 'RESUMEN FINAL' AS '';
SELECT '═══════════════════════════════════════════════════════════' AS '';

SELECT 
    'Total zonas' AS concepto,
    COUNT(*) AS valor,
    CASE WHEN COUNT(*) = 4 THEN '✅' ELSE '❌' END AS estado
FROM zonas
UNION ALL
SELECT 
    'Total distritos',
    COUNT(*),
    CASE WHEN COUNT(*) = 41 THEN '✅' ELSE '❌' END
FROM distritos
UNION ALL
SELECT 
    'Distritos duplicados',
    COUNT(*),
    CASE WHEN COUNT(*) = 0 THEN '✅' ELSE '❌' END
FROM (
    SELECT nombre, COUNT(*) as cantidad
    FROM distritos
    GROUP BY nombre
    HAVING COUNT(*) > 1
) AS duplicados
UNION ALL
SELECT 
    'Distritos del Norte',
    COUNT(*),
    CASE WHEN COUNT(*) = 8 THEN '✅' ELSE '❌' END
FROM distritos d
INNER JOIN zonas z ON d.zona_id = z.idZona
WHERE z.nombre = 'Norte'
UNION ALL
SELECT 
    'Distritos del Sur',
    COUNT(*),
    CASE WHEN COUNT(*) = 10 THEN '✅' ELSE '❌' END
FROM distritos d
INNER JOIN zonas z ON d.zona_id = z.idZona
WHERE z.nombre = 'Sur'
UNION ALL
SELECT 
    'Distritos del Este',
    COUNT(*),
    CASE WHEN COUNT(*) = 7 THEN '✅' ELSE '❌' END
FROM distritos d
INNER JOIN zonas z ON d.zona_id = z.idZona
WHERE z.nombre = 'Este'
UNION ALL
SELECT 
    'Distritos del Oeste',
    COUNT(*),
    CASE WHEN COUNT(*) = 16 THEN '✅' ELSE '❌' END
FROM distritos d
INNER JOIN zonas z ON d.zona_id = z.idZona
WHERE z.nombre = 'Oeste';

