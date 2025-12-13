-- ============================================================================
-- Script de Verificación y Prueba - Sistema de Limpieza de Auditoría
-- ============================================================================
-- 
-- Este script te permite:
-- 1. Verificar el estado actual de los registros de auditoría
-- 2. Ver la distribución por antigüedad
-- 3. Simular qué registros se eliminarían
-- 4. Generar datos de prueba (opcional)
--
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. ESTADÍSTICAS ACTUALES DE AUDITORÍA
-- ----------------------------------------------------------------------------

-- Total de registros en auditoría
SELECT 
    COUNT(*) as total_registros,
    COUNT(*) * 2.5 / 1024 as espacio_aproximado_MB
FROM auditoria_sistema;

-- Distribución por estado
SELECT 
    estado,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM auditoria_sistema), 2) as porcentaje
FROM auditoria_sistema
GROUP BY estado
ORDER BY cantidad DESC;

-- Distribución por módulo
SELECT 
    modulo,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM auditoria_sistema), 2) as porcentaje
FROM auditoria_sistema
GROUP BY modulo
ORDER BY cantidad DESC;

-- ----------------------------------------------------------------------------
-- 2. ANÁLISIS DE ANTIGÜEDAD DE REGISTROS
-- ----------------------------------------------------------------------------

-- Registros por rango de antigüedad
SELECT 
    CASE 
        WHEN DATEDIFF(NOW(), fecha_accion) <= 7 THEN '0-7 días'
        WHEN DATEDIFF(NOW(), fecha_accion) <= 14 THEN '8-14 días'
        WHEN DATEDIFF(NOW(), fecha_accion) <= 30 THEN '15-30 días'
        WHEN DATEDIFF(NOW(), fecha_accion) <= 60 THEN '31-60 días'
        WHEN DATEDIFF(NOW(), fecha_accion) <= 90 THEN '61-90 días'
        ELSE 'Más de 90 días'
    END as rango_antiguedad,
    COUNT(*) as cantidad,
    MIN(fecha_accion) as fecha_mas_antigua,
    MAX(fecha_accion) as fecha_mas_reciente
FROM auditoria_sistema
GROUP BY rango_antiguedad
ORDER BY MIN(DATEDIFF(NOW(), fecha_accion));

-- Registro más antiguo
SELECT 
    id_auditoria,
    usuario_nombre,
    accion,
    modulo,
    fecha_accion,
    DATEDIFF(NOW(), fecha_accion) as dias_antiguedad
FROM auditoria_sistema
ORDER BY fecha_accion ASC
LIMIT 1;

-- ----------------------------------------------------------------------------
-- 3. SIMULACIÓN DE LIMPIEZA (30 DÍAS)
-- ----------------------------------------------------------------------------

-- ¿Cuántos registros se eliminarían con el límite de 30 días?
SELECT 
    COUNT(*) as registros_a_eliminar,
    COUNT(*) * 2.5 / 1024 as espacio_liberar_MB,
    (SELECT COUNT(*) FROM auditoria_sistema) as total_actual,
    (SELECT COUNT(*) FROM auditoria_sistema) - COUNT(*) as registros_restantes
FROM auditoria_sistema
WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Vista previa de registros que se eliminarían (primeros 20)
SELECT 
    id_auditoria,
    usuario_nombre,
    accion,
    modulo,
    descripcion,
    fecha_accion,
    estado,
    DATEDIFF(NOW(), fecha_accion) as dias_antiguedad
FROM auditoria_sistema
WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY fecha_accion ASC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- 4. REGISTROS RECIENTES (LOS QUE SE MANTENDRÍAN)
-- ----------------------------------------------------------------------------

-- Vista de registros recientes (últimos 30 días)
SELECT 
    DATE(fecha_accion) as fecha,
    COUNT(*) as cantidad,
    SUM(CASE WHEN estado = 'EXITOSO' THEN 1 ELSE 0 END) as exitosos,
    SUM(CASE WHEN estado = 'FALLIDO' THEN 1 ELSE 0 END) as fallidos
FROM auditoria_sistema
WHERE fecha_accion >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(fecha_accion)
ORDER BY fecha DESC;

-- ----------------------------------------------------------------------------
-- 5. ANÁLISIS DE USUARIOS MÁS ACTIVOS (ÚLTIMOS 30 DÍAS)
-- ----------------------------------------------------------------------------

SELECT 
    usuario_nombre,
    COUNT(*) as total_acciones,
    SUM(CASE WHEN estado = 'EXITOSO' THEN 1 ELSE 0 END) as exitosas,
    SUM(CASE WHEN estado = 'FALLIDO' THEN 1 ELSE 0 END) as fallidas,
    MAX(fecha_accion) as ultima_accion
FROM auditoria_sistema
WHERE fecha_accion >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY usuario_nombre
ORDER BY total_acciones DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- 6. VERIFICAR CONFIGURACIÓN DEL SISTEMA
-- ----------------------------------------------------------------------------

-- Verificar que la tabla existe y tiene la estructura correcta
DESCRIBE auditoria_sistema;

-- Verificar índices para performance
SHOW INDEX FROM auditoria_sistema;

-- ----------------------------------------------------------------------------
-- 7. [OPCIONAL] GENERAR DATOS DE PRUEBA
-- ----------------------------------------------------------------------------
-- 
-- ADVERTENCIA: Ejecutar SOLO en ambiente de desarrollo/pruebas
-- NO EJECUTAR EN PRODUCCIÓN
--

/*
-- Insertar registros antiguos para probar la limpieza (60 días atrás)
INSERT INTO auditoria_sistema 
(usuario_id, usuario_nombre, accion, modulo, descripcion, ip_address, user_agent, fecha_accion, estado)
SELECT 
    1,
    'Usuario Prueba',
    'TEST_LIMPIEZA',
    'SISTEMA',
    CONCAT('Registro de prueba antiguo #', n),
    '127.0.0.1',
    'Test Browser',
    DATE_SUB(NOW(), INTERVAL (60 + n) DAY),
    IF(n % 10 = 0, 'FALLIDO', 'EXITOSO')
FROM (
    SELECT @rownum := @rownum + 1 AS n
    FROM (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
         (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
          UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
         (SELECT @rownum := 0) r
    LIMIT 100
) numbers;

-- Verificar que se insertaron
SELECT COUNT(*) as registros_prueba_insertados
FROM auditoria_sistema
WHERE accion = 'TEST_LIMPIEZA';
*/

-- ----------------------------------------------------------------------------
-- 8. [OPCIONAL] ELIMINAR DATOS DE PRUEBA
-- ----------------------------------------------------------------------------

/*
-- Eliminar registros de prueba
DELETE FROM auditoria_sistema
WHERE accion = 'TEST_LIMPIEZA';

-- Verificar eliminación
SELECT COUNT(*) as registros_prueba_restantes
FROM auditoria_sistema
WHERE accion = 'TEST_LIMPIEZA';
*/

-- ----------------------------------------------------------------------------
-- 9. [AVANZADO] LIMPIEZA MANUAL DE EMERGENCIA
-- ----------------------------------------------------------------------------

/*
-- Si necesitas limpiar manualmente registros muy antiguos (90+ días)
-- PRECAUCIÓN: Esta acción NO SE PUEDE DESHACER

-- Paso 1: Verificar cuántos se eliminarían
SELECT 
    COUNT(*) as registros_a_eliminar,
    MIN(fecha_accion) as mas_antiguo,
    MAX(fecha_accion) as mas_reciente
FROM auditoria_sistema
WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Paso 2: Si estás SEGURO, descomentar y ejecutar:
-- DELETE FROM auditoria_sistema
-- WHERE fecha_accion < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Paso 3: Verificar resultado
SELECT 
    COUNT(*) as registros_restantes,
    MIN(fecha_accion) as registro_mas_antiguo
FROM auditoria_sistema;
*/

-- ----------------------------------------------------------------------------
-- 10. MÉTRICAS DE RENDIMIENTO
-- ----------------------------------------------------------------------------

-- Tamaño de la tabla
SELECT 
    table_name AS 'Tabla',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Tamaño (MB)',
    table_rows AS 'Filas (aprox.)'
FROM information_schema.TABLES
WHERE table_schema = DATABASE()
  AND table_name = 'auditoria_sistema';

-- Últimas acciones registradas (para verificar que el sistema está funcionando)
SELECT 
    id_auditoria,
    usuario_nombre,
    accion,
    modulo,
    fecha_accion,
    estado
FROM auditoria_sistema
ORDER BY fecha_accion DESC
LIMIT 10;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
