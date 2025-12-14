-- Script para actualizar y expandir las categorías de productos
-- Este script agrega categorías más completas y mejor organizadas

USE telito_bodeguero;

-- ============================================
-- 1. ELIMINAR CATEGORÍAS ANTIGUAS (opcional, solo si quieres empezar desde cero)
-- ============================================
-- NOTA: Si ya tienes productos asignados a categorías, NO ejecutes esta sección
-- En su lugar, actualiza las categorías existentes o agrega nuevas

-- ============================================
-- 2. ACTUALIZAR CATEGORÍAS EXISTENTES
-- ============================================
-- Actualizar nombres de categorías existentes si es necesario
UPDATE categorias SET nombre = 'Bebidas y Refrescos' WHERE id_categoria = 1;
UPDATE categorias SET nombre = 'Snacks y Golosinas' WHERE id_categoria = 2;
UPDATE categorias SET nombre = 'Lácteos y Derivados' WHERE id_categoria = 3;
UPDATE categorias SET nombre = 'Conservas y Enlatados' WHERE id_categoria = 4;
UPDATE categorias SET nombre = 'Productos de Limpieza' WHERE id_categoria = 5;
UPDATE categorias SET nombre = 'Higiene Personal' WHERE id_categoria = 6;
UPDATE categorias SET nombre = 'Cereales y Granos' WHERE id_categoria = 7;
UPDATE categorias SET nombre = 'Carnes y Embutidos' WHERE id_categoria = 8;
UPDATE categorias SET nombre = 'Verduras y Hortalizas' WHERE id_categoria = 9;
UPDATE categorias SET nombre = 'Frutas Frescas' WHERE id_categoria = 10;

-- ============================================
-- 3. AGREGAR NUEVAS CATEGORÍAS
-- ============================================
-- Agregar categorías adicionales para una mejor organización

INSERT INTO categorias (nombre) VALUES
-- Alimentos básicos
('Aceites y Vinagres'),
('Condimentos y Especias'),
('Harinas y Pastas'),
('Azúcares y Endulzantes'),
('Salsas y Aderezos'),

-- Bebidas
('Bebidas Alcohólicas'),
('Bebidas Energéticas'),
('Agua y Bebidas Naturales'),
('Café y Té'),

-- Productos frescos
('Huevos y Aves'),
('Pescados y Mariscos'),
('Panadería y Pastelería'),
('Helados y Postres'),

-- Productos procesados
('Dulces y Chocolates'),
('Galletas y Bizcochos'),

-- Productos no alimentarios
('Cuidado del Bebé'),
('Cuidado del Hogar'),
('Papelería y Oficina'),
('Otros Productos');

-- ============================================
-- 4. ELIMINAR "Cereales para Desayuno" SI EXISTE
-- ============================================
-- Obtener el ID de la categoría a eliminar
SET @categoria_id_eliminar = (SELECT id_categoria FROM categorias WHERE nombre = 'Cereales para Desayuno' LIMIT 1);

-- Si existe, actualizar productos asignados a esta categoría
UPDATE productos 
SET categoria_id = 7  -- ID de "Cereales y Granos"
WHERE categoria_id = @categoria_id_eliminar;

-- Eliminar la categoría usando el ID (requerido para safe update mode)
DELETE FROM categorias 
WHERE id_categoria = @categoria_id_eliminar;

-- ============================================
-- 5. VERIFICAR CATEGORÍAS ACTUALIZADAS
-- ============================================
SELECT id_categoria, nombre 
FROM categorias 
ORDER BY nombre ASC;

-- ============================================
-- NOTAS IMPORTANTES:
-- ============================================
-- 1. Este script NO elimina categorías existentes para evitar problemas con productos ya asignados
-- 2. Si quieres eliminar categorías antiguas, primero verifica que no tengan productos asignados:
--    SELECT c.id_categoria, c.nombre, COUNT(p.id_producto) as productos_asignados
--    FROM categorias c
--    LEFT JOIN productos p ON c.id_categoria = p.categoria_id
--    GROUP BY c.id_categoria, c.nombre;
-- 3. Si una categoría tiene productos asignados, actualiza los productos antes de eliminar la categoría
-- 4. Las nuevas categorías se agregan con IDs automáticos (11, 12, 13, etc.)

