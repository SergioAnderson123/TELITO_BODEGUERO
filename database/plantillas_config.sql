-- Script para crear las tablas de plantillas de configuración
-- Este script crea las tablas necesarias para el sistema de plantillas de carga de datos

USE telito_bodeguero;

-- Eliminar tablas si existen (para idempotencia)
DROP TABLE IF EXISTS plantillas_mapeo_columnas;
DROP TABLE IF EXISTS plantillas_config;

-- Tabla principal de plantillas
CREATE TABLE plantillas_config (
    id_plantilla INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL COMMENT 'Nombre descriptivo de la plantilla',
    tipo_carga VARCHAR(50) NOT NULL COMMENT 'Tipo de carga: productos, lotes, etc.',
    activo BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica si la plantilla está activa',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación de la plantilla',
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    INDEX idx_tipo_carga (tipo_carga),
    INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla para almacenar las configuraciones de plantillas de carga de datos';

-- Tabla de mapeo de columnas de Excel a campos de la base de datos
CREATE TABLE plantillas_mapeo_columnas (
    id_mapeo INT AUTO_INCREMENT PRIMARY KEY,
    plantilla_id INT NOT NULL COMMENT 'ID de la plantilla a la que pertenece este mapeo',
    columna_excel VARCHAR(100) NOT NULL COMMENT 'Nombre de la columna en el archivo Excel',
    campo_destino VARCHAR(100) NOT NULL COMMENT 'Nombre del campo en la base de datos destino',
    orden INT NOT NULL DEFAULT 0 COMMENT 'Orden de la columna en el mapeo',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del mapeo',
    FOREIGN KEY (plantilla_id) REFERENCES plantillas_config(id_plantilla) ON DELETE CASCADE,
    INDEX idx_plantilla_id (plantilla_id),
    INDEX idx_orden (orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabla para almacenar el mapeo de columnas de Excel a campos de la base de datos';

-- Insertar algunas plantillas de ejemplo (opcional)
-- INSERT INTO plantillas_config (nombre, tipo_carga, activo) VALUES
-- ('Plantilla Productos', 'productos', TRUE),
-- ('Plantilla Lotes', 'lotes', TRUE);

