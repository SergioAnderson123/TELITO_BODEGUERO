-- Script para eliminar la categoría "Congelados"
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
WHERE c.nombre = 'Congelados'
GROUP BY c.id_categoria, c.nombre;

-- ============================================
-- 2. OBTENER EL ID DE LA CATEGORÍA A ELIMINAR
-- ============================================
SET @categoria_id = (SELECT id_categoria FROM categorias WHERE nombre = 'Congelados' LIMIT 1);

-- ============================================
-- 3. SI HAY PRODUCTOS ASIGNADOS, ACTUALIZARLOS A OTRA CATEGORÍA
-- ============================================
-- Primero, actualizar productos a "Conservas y Enlatados" (id_categoria = 4)
-- O puedes cambiar a otra categoría según prefieras
UPDATE productos 
SET categoria_id = 4  -- ID de "Conservas y Enlatados"
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
WHERE nombre = 'Congelados';
-- No debería devolver ningún resultado

-- ============================================
-- NOTA IMPORTANTE:
-- ============================================
-- Si la categoría tiene productos asignados, primero se actualizan a "Conservas y Enlatados"
-- Si prefieres otra categoría, cambia el id_categoria en el UPDATE anterior

