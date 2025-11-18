-- Script para corregir problemas finales en distritos
-- Basado en el estado actual de la base de datos

USE telito_bodeguero;

-- ============================================
-- 1. IDENTIFICAR PROBLEMAS ACTUALES
-- ============================================

SELECT '=== DISTRITOS DUPLICADOS ===' AS info;
SELECT nombre, COUNT(*) as cantidad, GROUP_CONCAT(idDistrito ORDER BY idDistrito) as ids
FROM distritos
GROUP BY nombre
HAVING COUNT(*) > 1;

SELECT '=== DISTRITOS ACTUALES POR ZONA ===' AS info;
SELECT z.nombre AS zona, COUNT(d.idDistrito) as total, 
       GROUP_CONCAT(d.nombre ORDER BY d.nombre SEPARATOR ', ') AS distritos
FROM zonas z
LEFT JOIN distritos d ON z.idZona = d.zona_id
GROUP BY z.idZona, z.nombre
ORDER BY z.idZona;

SELECT '=== TOTAL DISTRITOS ACTUALES ===' AS info;
SELECT COUNT(*) AS total FROM distritos;

-- ============================================
-- 2. CORREGIR PROBLEMAS ESPECÍFICOS
-- ============================================

-- Problema 1: "Cercado" (idDistrito 21) es duplicado de "Cercado de Lima" (idDistrito 13)
-- Reasignar lotes, ordenes_compra y planes_transporte de "Cercado" a "Cercado de Lima"
UPDATE lotes l
INNER JOIN distritos d ON l.distrito_id = d.idDistrito
SET l.distrito_id = 13  -- Cercado de Lima
WHERE l.id_lote > 0
  AND d.idDistrito = 21;  -- Cercado

UPDATE ordenes_compra oc
INNER JOIN distritos d ON oc.distrito_id = d.idDistrito
SET oc.distrito_id = 13  -- Cercado de Lima
WHERE oc.id_orden_compra > 0
  AND d.idDistrito = 21;  -- Cercado

UPDATE planes_transporte pt
INNER JOIN distritos d ON pt.distrito_id = d.idDistrito
SET pt.distrito_id = 13  -- Cercado de Lima
WHERE pt.id_plan > 0
  AND d.idDistrito = 21;  -- Cercado

-- Eliminar el duplicado "Cercado"
DELETE FROM distritos 
WHERE idDistrito = 21;

-- Problema 2: "Surco" (idDistrito 3) debería ser "Santiago de Surco"
-- Verificar si ya existe "Santiago de Surco"
SELECT '=== VERIFICAR: ¿Existe Santiago de Surco? ===' AS info;
SELECT idDistrito, nombre, zona_id FROM distritos WHERE nombre LIKE '%Surco%';

SELECT '=== VERIFICAR: REFERENCIAS A SURCO ===' AS info;
SELECT 'lotes' AS tabla, COUNT(*) as referencias FROM lotes WHERE distrito_id IN (SELECT idDistrito FROM distritos WHERE nombre = 'Surco')
UNION ALL
SELECT 'ordenes_compra', COUNT(*) FROM ordenes_compra WHERE distrito_id IN (SELECT idDistrito FROM distritos WHERE nombre = 'Surco')
UNION ALL
SELECT 'planes_transporte', COUNT(*) FROM planes_transporte WHERE distrito_id IN (SELECT idDistrito FROM distritos WHERE nombre = 'Surco');

-- Si "Surco" existe y "Santiago de Surco" también existe, reasignar y eliminar "Surco"
-- Si solo existe "Surco", renombrarlo a "Santiago de Surco"
-- Primero verificar si existe "Santiago de Surco"
SET @id_santiago_surco = (SELECT MIN(idDistrito) FROM distritos WHERE nombre = 'Santiago de Surco');

-- Si existe "Santiago de Surco", reasignar referencias de "Surco" a "Santiago de Surco"
UPDATE lotes l
INNER JOIN distritos d ON l.distrito_id = d.idDistrito
SET l.distrito_id = @id_santiago_surco
WHERE l.id_lote > 0
  AND d.nombre = 'Surco'
  AND @id_santiago_surco IS NOT NULL;

UPDATE ordenes_compra oc
INNER JOIN distritos d ON oc.distrito_id = d.idDistrito
SET oc.distrito_id = @id_santiago_surco
WHERE oc.id_orden_compra > 0
  AND d.nombre = 'Surco'
  AND @id_santiago_surco IS NOT NULL;

UPDATE planes_transporte pt
INNER JOIN distritos d ON pt.distrito_id = d.idDistrito
SET pt.distrito_id = @id_santiago_surco
WHERE pt.id_plan > 0
  AND d.nombre = 'Surco'
  AND @id_santiago_surco IS NOT NULL;

-- Si existe "Surco" y no existe "Santiago de Surco", renombrarlo
-- Usar variable para verificar si existe "Santiago de Surco"
SET @existe_santiago_surco = (SELECT COUNT(*) FROM distritos WHERE nombre = 'Santiago de Surco');

-- Si no existe "Santiago de Surco", renombrar "Surco"
UPDATE distritos 
SET nombre = 'Santiago de Surco'
WHERE idDistrito > 0
  AND nombre = 'Surco'
  AND @existe_santiago_surco = 0;

-- Si ambos existen, eliminar "Surco" después de reasignar
-- Primero verificar si existe "Santiago de Surco"
SET @existe_santiago_surco = (SELECT COUNT(*) FROM distritos WHERE nombre = 'Santiago de Surco');

-- Eliminar "Surco" solo si existe "Santiago de Surco" y ya se reasignaron las referencias
-- Primero verificar que no haya referencias pendientes
SET @referencias_surco = (
    SELECT COUNT(*) FROM (
        SELECT distrito_id FROM lotes WHERE distrito_id IN (SELECT idDistrito FROM distritos WHERE nombre = 'Surco')
        UNION ALL
        SELECT distrito_id FROM ordenes_compra WHERE distrito_id IN (SELECT idDistrito FROM distritos WHERE nombre = 'Surco')
        UNION ALL
        SELECT distrito_id FROM planes_transporte WHERE distrito_id IN (SELECT idDistrito FROM distritos WHERE nombre = 'Surco')
    ) AS refs
);

-- Si no hay referencias y existe "Santiago de Surco", eliminar "Surco"
DELETE d FROM distritos d
INNER JOIN distritos d2 ON d2.nombre = 'Santiago de Surco'
WHERE d.idDistrito > 0
  AND d.nombre = 'Surco'
  AND @existe_santiago_surco > 0
  AND @referencias_surco = 0
  AND d.idDistrito != d2.idDistrito;

-- ============================================
-- 3. VERIFICAR DISTRITOS FALTANTES
-- ============================================

SELECT '=== DISTRITOS REQUERIDOS QUE FALTAN ===' AS info;

-- Crear tabla temporal con distritos requeridos
CREATE TEMPORARY TABLE IF NOT EXISTS distritos_requeridos (
    nombre VARCHAR(100),
    zona_nombre VARCHAR(50)
);

INSERT INTO distritos_requeridos (nombre, zona_nombre) VALUES
-- NORTE (8)
('Ancon', 'Norte'),
('Santa Rosa', 'Norte'),
('Carabayllo', 'Norte'),
('Puente Piedra', 'Norte'),
('Comas', 'Norte'),
('Los Olivos', 'Norte'),
('San Martín de Porres', 'Norte'),
('Independencia', 'Norte'),
-- SUR (10)
('San Juan de Miraflores', 'Sur'),
('Villa María del Triunfo', 'Sur'),
('Villa el Salvador', 'Sur'),
('Pachacamac', 'Sur'),
('Lurin', 'Sur'),
('Punta Hermosa', 'Sur'),
('Punta Negra', 'Sur'),
('San Bartolo', 'Sur'),
('Santa María del Mar', 'Sur'),
('Pucusana', 'Sur'),
-- ESTE (7)
('San Juan de Lurigancho', 'Este'),
('Lurigancho', 'Este'),
('Ate', 'Este'),
('El Agustino', 'Este'),
('Santa Anita', 'Este'),
('La Molina', 'Este'),
('Cieneguilla', 'Este'),
-- OESTE (16)
('Rimac', 'Oeste'),
('Cercado de Lima', 'Oeste'),
('Breña', 'Oeste'),
('Pueblo Libre', 'Oeste'),
('Magdalena', 'Oeste'),
('Jesus María', 'Oeste'),
('La Victoria', 'Oeste'),
('Lince', 'Oeste'),
('San Isidro', 'Oeste'),
('San Miguel', 'Oeste'),
('Surquillo', 'Oeste'),
('San Borja', 'Oeste'),
('Santiago de Surco', 'Oeste'),
('Barranco', 'Oeste'),
('Chorrillos', 'Oeste'),
('San Luis', 'Oeste'),
('Miraflores', 'Oeste');

-- Mostrar distritos que faltan
SELECT dr.nombre, dr.zona_nombre
FROM distritos_requeridos dr
LEFT JOIN distritos d ON dr.nombre = d.nombre
WHERE d.idDistrito IS NULL
ORDER BY dr.zona_nombre, dr.nombre;

-- ============================================
-- 4. INSERTAR DISTRITOS FALTANTES
-- ============================================

-- Insertar distritos faltantes del Norte
INSERT INTO distritos (nombre, zona_id)
SELECT dr.nombre, z.idZona
FROM distritos_requeridos dr
INNER JOIN zonas z ON z.nombre = dr.zona_nombre
LEFT JOIN distritos d ON dr.nombre = d.nombre
WHERE d.idDistrito IS NULL
  AND dr.zona_nombre = 'Norte';

-- Insertar distritos faltantes del Sur
INSERT INTO distritos (nombre, zona_id)
SELECT dr.nombre, z.idZona
FROM distritos_requeridos dr
INNER JOIN zonas z ON z.nombre = dr.zona_nombre
LEFT JOIN distritos d ON dr.nombre = d.nombre
WHERE d.idDistrito IS NULL
  AND dr.zona_nombre = 'Sur';

-- Insertar distritos faltantes del Este
INSERT INTO distritos (nombre, zona_id)
SELECT dr.nombre, z.idZona
FROM distritos_requeridos dr
INNER JOIN zonas z ON z.nombre = dr.zona_nombre
LEFT JOIN distritos d ON dr.nombre = d.nombre
WHERE d.idDistrito IS NULL
  AND dr.zona_nombre = 'Este';

-- Insertar distritos faltantes del Oeste
INSERT INTO distritos (nombre, zona_id)
SELECT dr.nombre, z.idZona
FROM distritos_requeridos dr
INNER JOIN zonas z ON z.nombre = dr.zona_nombre
LEFT JOIN distritos d ON dr.nombre = d.nombre
WHERE d.idDistrito IS NULL
  AND dr.zona_nombre = 'Oeste';

-- Limpiar tabla temporal
DROP TEMPORARY TABLE IF EXISTS distritos_requeridos;

-- ============================================
-- 5. VERIFICACIÓN FINAL
-- ============================================

SELECT '=== VERIFICACIÓN FINAL: DISTRITOS POR ZONA ===' AS info;
SELECT z.nombre AS zona, COUNT(d.idDistrito) as total_distritos,
       GROUP_CONCAT(d.nombre ORDER BY d.nombre SEPARATOR ', ') AS distritos
FROM zonas z
LEFT JOIN distritos d ON z.idZona = d.zona_id
GROUP BY z.idZona, z.nombre
ORDER BY z.idZona;

SELECT '=== VERIFICACIÓN: TOTAL DISTRITOS (debe ser 41) ===' AS info;
SELECT COUNT(*) AS total_distritos FROM distritos;

SELECT '=== VERIFICACIÓN: DISTRITOS DUPLICADOS (debe estar vacío) ===' AS info;
SELECT nombre, COUNT(*) as cantidad
FROM distritos
GROUP BY nombre
HAVING COUNT(*) > 1;

