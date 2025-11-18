-- Tabla para registrar acciones importantes del sistema (Auditoría)
CREATE TABLE IF NOT EXISTS auditoria_sistema (
    id_auditoria INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNSIGNED NOT NULL,
    usuario_nombre VARCHAR(255) NOT NULL,
    accion VARCHAR(100) NOT NULL COMMENT 'Tipo de acción: CREAR_USUARIO, EDITAR_USUARIO, ELIMINAR_USUARIO, BANEAR_USUARIO, CREAR_PRODUCTO, etc.',
    modulo VARCHAR(50) NOT NULL COMMENT 'Módulo donde se realizó la acción: USUARIOS, PRODUCTOS, INVENTARIO, etc.',
    descripcion TEXT COMMENT 'Descripción detallada de la acción',
    datos_anteriores JSON COMMENT 'Datos antes del cambio (para ediciones)',
    datos_nuevos JSON COMMENT 'Datos después del cambio (para ediciones)',
    ip_address VARCHAR(45) COMMENT 'Dirección IP del usuario',
    user_agent VARCHAR(500) COMMENT 'User agent del navegador',
    fecha_accion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'EXITOSO' COMMENT 'EXITOSO, FALLIDO, ERROR',
    mensaje_error TEXT COMMENT 'Mensaje de error si la acción falló',
    
    INDEX idx_usuario (usuario_id),
    INDEX idx_accion (accion),
    INDEX idx_modulo (modulo),
    INDEX idx_fecha (fecha_accion),
    INDEX idx_estado (estado),
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla para configuración del sistema
CREATE TABLE IF NOT EXISTS configuracion_sistema (
    id_config INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(100) NOT NULL UNIQUE COMMENT 'Clave única de la configuración',
    valor TEXT COMMENT 'Valor de la configuración',
    tipo VARCHAR(50) NOT NULL DEFAULT 'STRING' COMMENT 'STRING, NUMBER, BOOLEAN, JSON',
    categoria VARCHAR(50) NOT NULL COMMENT 'EMAIL, SISTEMA, NOTIFICACIONES, SEGURIDAD, etc.',
    descripcion TEXT COMMENT 'Descripción de qué hace esta configuración',
    editable BOOLEAN DEFAULT TRUE COMMENT 'Si el administrador puede editar este valor',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    usuario_actualizacion INT UNSIGNED COMMENT 'Usuario que actualizó por última vez',
    
    INDEX idx_clave (clave),
    INDEX idx_categoria (categoria),
    
    FOREIGN KEY (usuario_actualizacion) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertar configuraciones por defecto
INSERT INTO configuracion_sistema (clave, valor, tipo, categoria, descripcion, editable) VALUES
-- Configuración de Email
('email.smtp.host', 'smtp.gmail.com', 'STRING', 'EMAIL', 'Servidor SMTP para envío de correos', TRUE),
('email.smtp.port', '587', 'NUMBER', 'EMAIL', 'Puerto SMTP', TRUE),
('email.from', '', 'STRING', 'EMAIL', 'Email remitente por defecto', TRUE),
('email.from.name', 'TELITO BODEGUERO', 'STRING', 'EMAIL', 'Nombre del remitente', TRUE),
('email.enabled', 'true', 'BOOLEAN', 'EMAIL', 'Habilitar/deshabilitar envío de correos', TRUE),

-- Configuración de Notificaciones
('notificaciones.bienvenida.enabled', 'true', 'BOOLEAN', 'NOTIFICACIONES', 'Enviar correo de bienvenida a nuevos usuarios', TRUE),
('notificaciones.actualizacion.enabled', 'true', 'BOOLEAN', 'NOTIFICACIONES', 'Enviar correo cuando se actualiza un usuario', TRUE),
('notificaciones.alertas.enabled', 'true', 'BOOLEAN', 'NOTIFICACIONES', 'Enviar correos de alertas automáticas', TRUE),
('notificaciones.reportes.enabled', 'true', 'BOOLEAN', 'NOTIFICACIONES', 'Permitir envío de reportes por correo', TRUE),

-- Configuración del Sistema
('sistema.nombre', 'TELITO BODEGUERO', 'STRING', 'SISTEMA', 'Nombre del sistema', TRUE),
('sistema.timezone', 'America/Lima', 'STRING', 'SISTEMA', 'Zona horaria del sistema', TRUE),
('sistema.idioma', 'es', 'STRING', 'SISTEMA', 'Idioma por defecto', TRUE),
('sistema.paginacion.size', '10', 'NUMBER', 'SISTEMA', 'Tamaño de página por defecto', TRUE),
('sistema.auditoria.enabled', 'true', 'BOOLEAN', 'SISTEMA', 'Habilitar registro de auditoría', TRUE),
('sistema.auditoria.retention.days', '365', 'NUMBER', 'SISTEMA', 'Días de retención de registros de auditoría', TRUE),

-- Configuración de Seguridad
('seguridad.password.min.length', '8', 'NUMBER', 'SEGURIDAD', 'Longitud mínima de contraseña', TRUE),
('seguridad.password.require.uppercase', 'false', 'BOOLEAN', 'SEGURIDAD', 'Requerir mayúsculas en contraseña', TRUE),
('seguridad.password.require.numbers', 'false', 'BOOLEAN', 'SEGURIDAD', 'Requerir números en contraseña', TRUE),
('seguridad.session.timeout', '30', 'NUMBER', 'SEGURIDAD', 'Timeout de sesión en minutos', TRUE),
('seguridad.max.login.attempts', '5', 'NUMBER', 'SEGURIDAD', 'Intentos máximos de login antes de bloquear', TRUE),

-- Configuración de Reportes
('reportes.excel.max.rows', '10000', 'NUMBER', 'REPORTES', 'Máximo de filas en reportes Excel', TRUE),
('reportes.email.max.size.mb', '10', 'NUMBER', 'REPORTES', 'Tamaño máximo de adjuntos en MB', TRUE);

