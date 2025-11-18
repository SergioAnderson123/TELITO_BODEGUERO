-- Tabla para registrar incidencias de inventario (faltantes y sobrantes)
CREATE TABLE IF NOT EXISTS incidencias_almacen (
    id_incidencia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    lote_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    tipo_incidencia ENUM('Faltante', 'Sobrante') NOT NULL,
    cantidad_reportada INT UNSIGNED NOT NULL,
    cantidad_sistema INT UNSIGNED NOT NULL,
    diferencia INT NOT NULL COMMENT 'cantidad_reportada - cantidad_sistema (puede ser negativo)',
    motivo TEXT NOT NULL,
    descripcion TEXT,
    estado ENUM('Pendiente', 'En Revisión', 'Resuelta', 'Cerrada') DEFAULT 'Pendiente',
    usuario_reporte_id INT UNSIGNED NOT NULL COMMENT 'Usuario de almacén que reportó',
    usuario_resolucion_id INT UNSIGNED COMMENT 'Administrador que resolvió',
    fecha_reporte TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion TIMESTAMP NULL,
    observaciones_resolucion TEXT,
    
    INDEX idx_lote (lote_id),
    INDEX idx_producto (producto_id),
    INDEX idx_usuario_reporte (usuario_reporte_id),
    INDEX idx_estado (estado),
    INDEX idx_fecha_reporte (fecha_reporte),
    INDEX idx_tipo (tipo_incidencia),
    
    FOREIGN KEY (lote_id) REFERENCES lotes(id_lote) ON DELETE RESTRICT,
    FOREIGN KEY (producto_id) REFERENCES productos(id_producto) ON DELETE RESTRICT,
    FOREIGN KEY (usuario_reporte_id) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
    FOREIGN KEY (usuario_resolucion_id) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

