-- Script para eliminar la categoría "Cereales para Desayuno"
-- Ejecutar este script si ya se agregó esa categoría y quieres eliminarla

USE telito_bodeguero;

-- ============================================
-- 1. VERIFICAR SI EXISTE LA CATEGORÍA Y SI TIENE PRODUCTOS
-- ============================================
SELECT 
    c.id_categoria, 
    c.nombre, 
    COUNT(p.id_producto) as productos_asignados
FROM categorias c
LEFT JOIN productos p ON c.id_categoria = p.categoria_id
WHERE c.nombre = 'Cereales para Desayuno'
GROUP BY c.id_categoria, c.nombre;

-- ============================================
-- 2. OBTENER EL ID DE LA CATEGORÍA A ELIMINAR
-- ============================================
SET @categoria_id = (SELECT id_categoria FROM categorias WHERE nombre = 'Cereales para Desayuno' LIMIT 1);

-- ============================================
-- 3. SI HAY PRODUCTOS ASIGNADOS, ACTUALIZARLOS A OTRA CATEGORÍA
-- ============================================
-- Primero, actualizar productos a "Cereales y Granos" (id_categoria = 7)
UPDATE productos 
SET categoria_id = 7  -- ID de "Cereales y Granos"
WHERE categoria_id = @categoria_id;

-- ============================================
-- 4. ELIMINAR LA CATEGORÍA (usando el ID para evitar error de safe update mode)
-- ============================================
DELETE FROM categorias 
WHERE id_categoria = @categoria_id;

-- ============================================
-- 5. VERIFICAR QUE SE ELIMINÓ CORRECTAMENTE
-- ============================================
SELECT id_categoria, nombre 
FROM categorias 
WHERE id_categoria = @categoria_id;
-- No debería devolver ningún resultado

-- También verificar por nombre
SELECT id_categoria, nombre 
FROM categorias 
WHERE nombre = 'Cereales para Desayuno';
-- No debería devolver ningún resultado

-- ============================================
-- NOTA IMPORTANTE:
-- ============================================
-- Si la categoría tiene productos asignados, primero se actualizan a "Cereales y Granos"
-- Si prefieres otra categoría, cambia el id_categoria en el UPDATE anterior

