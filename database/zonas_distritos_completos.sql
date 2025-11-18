-- Script para crear/verificar zonas y distritos completos según requerimientos
-- Este script asegura que todos los 41 distritos requeridos estén en la base de datos

USE telito_bodeguero;

-- ============================================
-- 1. CREAR TABLA DE ZONAS (si no existe)
-- ============================================
CREATE TABLE IF NOT EXISTS zonas (
    idZona INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 2. INSERTAR ZONAS (si no existen)
-- ============================================
INSERT IGNORE INTO zonas (nombre) VALUES
('Norte'),
('Sur'),
('Este'),
('Oeste');

-- ============================================
-- 3. CREAR TABLA DE DISTRITOS (si no existe)
-- ============================================
CREATE TABLE IF NOT EXISTS distritos (
    idDistrito INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    zona_id INT NOT NULL,
    INDEX idx_nombre (nombre),
    INDEX idx_zona (zona_id),
    FOREIGN KEY (zona_id) REFERENCES zonas(idZona) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- 4. INSERTAR DISTRITOS POR ZONA
-- ============================================

-- NORTE (8 distritos) - zona_id = 1
INSERT IGNORE INTO distritos (nombre, zona_id) VALUES
('Ancon', 1),
('Santa Rosa', 1),
('Carabayllo', 1),
('Puente Piedra', 1),
('Comas', 1),
('Los Olivos', 1),
('San Martín de Porres', 1),
('Independencia', 1);

-- SUR (10 distritos) - zona_id = 2
INSERT IGNORE INTO distritos (nombre, zona_id) VALUES
('San Juan de Miraflores', 2),
('Villa María del Triunfo', 2),
('Villa el Salvador', 2),
('Pachacamac', 2),
('Lurin', 2),
('Punta Hermosa', 2),
('Punta Negra', 2),
('San Bartolo', 2),
('Santa María del Mar', 2),
('Pucusana', 2);

-- ESTE (7 distritos) - zona_id = 3
INSERT IGNORE INTO distritos (nombre, zona_id) VALUES
('San Juan de Lurigancho', 3),
('Lurigancho', 3),  -- También conocido como Chosica
('Ate', 3),
('El Agustino', 3),
('Santa Anita', 3),
('La Molina', 3),
('Cieneguilla', 3);

-- OESTE (16 distritos) - zona_id = 4
INSERT IGNORE INTO distritos (nombre, zona_id) VALUES
('Rimac', 4),
('Cercado de Lima', 4),
('Breña', 4),
('Pueblo Libre', 4),
('Magdalena', 4),
('Jesus María', 4),
('La Victoria', 4),
('Lince', 4),
('San Isidro', 4),
('San Miguel', 4),
('Surquillo', 4),
('San Borja', 4),
('Santiago de Surco', 4),
('Barranco', 4),
('Chorrillos', 4),
('San Luis', 4),
('Miraflores', 4);

-- ============================================
-- 5. VERIFICACIÓN
-- ============================================
-- Ejecutar estas consultas para verificar:

-- Ver todas las zonas
-- SELECT * FROM zonas ORDER BY idZona;

-- Ver todos los distritos por zona
-- SELECT z.nombre AS zona, d.nombre AS distrito 
-- FROM distritos d 
-- INNER JOIN zonas z ON d.zona_id = z.idZona 
-- ORDER BY z.idZona, d.nombre;

-- Contar distritos por zona
-- SELECT z.nombre AS zona, COUNT(d.idDistrito) AS total_distritos
-- FROM zonas z
-- LEFT JOIN distritos d ON z.idZona = d.zona_id
-- GROUP BY z.idZona, z.nombre
-- ORDER BY z.idZona;

-- Total de distritos (debe ser 41)
-- SELECT COUNT(*) AS total_distritos FROM distritos;

