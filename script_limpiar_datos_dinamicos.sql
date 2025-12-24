-- =====================================================
-- SCRIPT: Limpiar Datos Dinámicos - Mantener Hardcodeados
-- =====================================================
-- Este script elimina todos los datos dinámicos del sistema
-- pero MANTIENE los datos hardcodeados (maestros):
--   - roles
--   - usuarios (SOLO el admin principal - id_usuario = 1)
--   - zonas
--   - distritos
--   - ubicaciones
--   - categorias
--   - clientes (NO hay clientes hardcodeados - se crean dinámicamente con pedidos)
--   - conductores (NO hardcodeados - se crean dinámicamente desde la interfaz)
--   - vehiculos (NO hardcodeados - se crean dinámicamente desde la interfaz)
--   - configuraciones del sistema (parametros_sistema)
--   - plantillas (plantillas_config, plantillas_mapeo_columnas)
-- =====================================================

USE telito_bodeguero;

-- Deshabilitar verificaciones de claves foráneas temporalmente
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- ELIMINAR DATOS DINÁMICOS (en orden correcto por dependencias)
-- =====================================================

-- 1. Eliminar movimientos de inventario (depende de lotes, pedidos, órdenes)
-- Usar WHERE con clave primaria para evitar error de Safe Update Mode
DELETE FROM movimientos_inventario WHERE id_movimiento > 0;

-- 2. Eliminar alertas generadas
DELETE FROM alertas_generadas WHERE id_alerta_generada > 0;

-- 3. Eliminar configuración de stock mínimo (depende de productos)
DELETE FROM stock_minimo_config WHERE id_stock_minimo > 0;

-- 4. Eliminar planes de transporte (depende de conductores, vehículos, pedidos)
DELETE FROM planes_transporte WHERE id_plan > 0;

-- 5. Eliminar items de pedidos (depende de pedidos y productos)
DELETE FROM pedido_items WHERE id_pedido_item > 0;

-- 6. Eliminar pedidos (depende de clientes)
DELETE FROM pedidos WHERE id_pedido > 0;

-- 6.5. Eliminar clientes también (NO se están usando en el flujo actual)
-- NOTA: Aunque existe soporte para pedidos en el código, en la interfaz solo se muestran
-- "Planes de Transporte" que NO usan clientes (usan distritos).
-- Los clientes solo se usarían si hubiera una tabla de "Pedidos" visible, pero no la hay.
DELETE FROM clientes WHERE id_cliente > 0;
ALTER TABLE clientes AUTO_INCREMENT = 1;

-- 7. Eliminar órdenes de compra (depende de productos, usuarios)
DELETE FROM ordenes_compra WHERE id_orden_compra > 0;

-- 8. Eliminar lotes (depende de productos, ubicaciones, distritos)
DELETE FROM lotes WHERE id_lote > 0;

-- 9. Eliminar productos (depende de categorias, usuarios/productores)
DELETE FROM productos WHERE id_producto > 0;

-- 10. Eliminar incidencias de almacén (depende de lotes)
DELETE FROM incidencias_almacen WHERE id_incidencia > 0;

-- 11. Eliminar alertas de configuración (OPCIONAL - descomenta si quieres eliminarlas también)
-- NOTA: Si las tienes hardcodeadas, déjalas comentadas
-- DELETE FROM alertas_configuracion;

-- 12. Eliminar ventas (si existen)
DELETE FROM ventas WHERE id_venta > 0;

-- 13. Limpiar tokens de recuperación y activación
DELETE FROM tokens_recuperacion WHERE id_token > 0;
DELETE FROM tokens_activacion WHERE id_token > 0;

-- 14. Limpiar auditoría (opcional - descomenta si quieres limpiar también)
-- DELETE FROM auditoria_tokens WHERE id_auditoria > 0;
-- DELETE FROM auditoria_sistema WHERE id_auditoria > 0;

-- 15. Limpiar notificaciones web (depende de usuarios)
DELETE FROM notificaciones_web WHERE id_notificacion > 0;

-- 16. Eliminar conductores (se crean dinámicamente desde la interfaz)
DELETE FROM conductores WHERE id_conductor > 0;
ALTER TABLE conductores AUTO_INCREMENT = 1;

-- 17. Eliminar vehículos (se crean dinámicamente desde la interfaz)
DELETE FROM vehiculos WHERE id_vehiculo > 0;
ALTER TABLE vehiculos AUTO_INCREMENT = 1;

-- 18. Resetear usuarios (OPCIÓN A ACTIVADA)
-- =====================================================
-- Eliminar TODOS los usuarios excepto el admin principal (id_usuario = 1)
-- Esta opción mantiene solo el admin hardcodeado y elimina todos los demás usuarios
-- =====================================================

DELETE FROM usuarios WHERE id_usuario != 1;
ALTER TABLE usuarios AUTO_INCREMENT = 2;  -- Empieza desde 2 porque el admin es 1

-- OPCIÓN B: Eliminar usuarios según rol específico
-- Por ejemplo, eliminar solo usuarios de ciertos roles pero mantener otros:
-- DELETE FROM usuarios 
-- WHERE id_usuario != 1 
-- AND rol_id IN (
--     SELECT id_rol FROM roles 
--     WHERE nombre IN ('Productor', 'Logística', 'Almacenero', 'Conductor')
-- );
-- ALTER TABLE usuarios AUTO_INCREMENT = 2;

-- OPCIÓN C: Mantener TODOS los usuarios (COMPORTAMIENTO POR DEFECTO)
-- Si no descomentas ninguna opción, todos los usuarios se mantendrán intactos

-- =====================================================
-- RESETEAR AUTO_INCREMENT (opcional - para que los IDs empiecen desde 1)
-- =====================================================

ALTER TABLE movimientos_inventario AUTO_INCREMENT = 1;
ALTER TABLE alertas_generadas AUTO_INCREMENT = 1;
ALTER TABLE stock_minimo_config AUTO_INCREMENT = 1;
ALTER TABLE planes_transporte AUTO_INCREMENT = 1;
ALTER TABLE pedido_items AUTO_INCREMENT = 1;
ALTER TABLE pedidos AUTO_INCREMENT = 1;
ALTER TABLE ordenes_compra AUTO_INCREMENT = 1;
ALTER TABLE lotes AUTO_INCREMENT = 1;
ALTER TABLE productos AUTO_INCREMENT = 1;
ALTER TABLE incidencias_almacen AUTO_INCREMENT = 1;
ALTER TABLE ventas AUTO_INCREMENT = 1;
ALTER TABLE notificaciones_web AUTO_INCREMENT = 1;
ALTER TABLE conductores AUTO_INCREMENT = 1;
ALTER TABLE vehiculos AUTO_INCREMENT = 1;

-- Rehabilitar verificaciones de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- NOTAS IMPORTANTES:
-- =====================================================
-- 1. CLIENTES: Se eliminan porque NO se están usando en el flujo actual
--    Aunque existe código para pedidos, en la interfaz solo se muestran "Planes de Transporte"
--    que NO requieren clientes (usan distritos como destino)
-- 2. CONDUCTORES y VEHÍCULOS: Se eliminan porque se crean dinámicamente desde la interfaz
-- 3. Las PLANTILLAS y CONFIGURACIONES se mantienen intactas
-- 4. Si quieres eliminar también ALERTAS_CONFIGURACION, descomenta la línea 59
-- 5. Si quieres eliminar también AUDITORÍA, descomenta las líneas 70-71
-- 6. USUARIOS: Se eliminan todos excepto el admin principal (id_usuario = 1) - Líneas 77-78
-- =====================================================
-- VERIFICACIÓN: Mostrar qué datos se mantuvieron
-- =====================================================

SELECT '✓ Datos dinámicos eliminados exitosamente' AS mensaje;
SELECT '✓ Datos hardcodeados mantenidos:' AS mensaje;
SELECT CONCAT('  - Roles: ', COUNT(*)) AS info FROM roles;
SELECT CONCAT('  - Usuarios: ', COUNT(*)) AS info FROM usuarios;
SELECT CONCAT('  - Zonas: ', COUNT(*)) AS info FROM zonas;
SELECT CONCAT('  - Distritos: ', COUNT(*)) AS info FROM distritos;
SELECT CONCAT('  - Ubicaciones: ', COUNT(*)) AS info FROM ubicaciones;
SELECT CONCAT('  - Categorías: ', COUNT(*)) AS info FROM categorias;
SELECT CONCAT('  - Clientes: ', COUNT(*), ' (eliminados - no se usan en el flujo actual)') AS info FROM clientes;
SELECT CONCAT('  - Conductores: ', COUNT(*), ' (eliminados - se crean dinámicamente)') AS info FROM conductores;
SELECT CONCAT('  - Vehículos: ', COUNT(*), ' (eliminados - se crean dinámicamente)') AS info FROM vehiculos;

SELECT '✓ Base de datos limpiada. Los datos hardcodeados se mantienen intactos.' AS mensaje_final;

