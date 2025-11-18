-- =====================================================
-- SISTEMA DE ACTIVACIÓN DE CUENTAS Y RECUPERACIÓN DE CONTRASEÑAS
-- Versión mejorada que supera a TELITO_RRHH
-- =====================================================

USE telito_bodeguero;

-- =====================================================
-- 1. AGREGAR CAMPOS DE ACTIVACIÓN A TABLA USUARIOS
-- =====================================================
-- Nota: MySQL no soporta IF NOT EXISTS en ALTER TABLE ADD COLUMN
-- Si las columnas ya existen, este script dará error. En ese caso, comenta estas líneas.

-- Verificar y agregar cuenta_activada
SET @dbname = DATABASE();
SET @tablename = 'usuarios';
SET @columnname = 'cuenta_activada';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' BOOLEAN NOT NULL DEFAULT FALSE COMMENT ''Indica si la cuenta ha sido activada por email''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Verificar y agregar fecha_activacion
SET @columnname = 'fecha_activacion';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' TIMESTAMP NULL COMMENT ''Fecha y hora en que se activó la cuenta''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Verificar y agregar intentos_activacion
SET @columnname = 'intentos_activacion';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' INT NOT NULL DEFAULT 0 COMMENT ''Número de intentos de activación fallidos''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Verificar y agregar ultimo_intento_activacion
SET @columnname = 'ultimo_intento_activacion';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' TIMESTAMP NULL COMMENT ''Último intento de activación''')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- =====================================================
-- 2. TABLA DE TOKENS DE ACTIVACIÓN
-- =====================================================
DROP TABLE IF EXISTS tokens_activacion;
CREATE TABLE tokens_activacion (
    id_token INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNSIGNED NOT NULL,
    token VARCHAR(128) NOT NULL UNIQUE COMMENT 'Token único de activación (hash SHA-256)',
    token_original VARCHAR(255) NOT NULL COMMENT 'Token original antes del hash (para comparación)',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL COMMENT 'Token expira en 48 horas',
    usado BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Indica si el token ya fue usado',
    fecha_uso TIMESTAMP NULL COMMENT 'Fecha en que se usó el token',
    ip_creacion VARCHAR(45) NULL COMMENT 'IP desde donde se creó el token',
    user_agent VARCHAR(500) NULL COMMENT 'User agent del navegador',
    INDEX idx_token (token),
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_fecha_expiracion (fecha_expiracion),
    INDEX idx_usado (usado),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_fecha_expiracion CHECK (fecha_expiracion > fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla para gestionar tokens de activación de cuentas con seguridad mejorada';

-- =====================================================
-- 3. TABLA DE TOKENS DE RECUPERACIÓN DE CONTRASEÑA
-- =====================================================
DROP TABLE IF EXISTS tokens_recuperacion;
CREATE TABLE tokens_recuperacion (
    id_token INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT UNSIGNED NOT NULL,
    token VARCHAR(128) NOT NULL UNIQUE COMMENT 'Token único de recuperación (hash SHA-256)',
    token_original VARCHAR(255) NOT NULL COMMENT 'Token original antes del hash',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP NOT NULL COMMENT 'Token expira en 1 hora',
    usado BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Indica si el token ya fue usado',
    fecha_uso TIMESTAMP NULL COMMENT 'Fecha en que se usó el token',
    ip_solicitud VARCHAR(45) NULL COMMENT 'IP desde donde se solicitó la recuperación',
    ip_uso VARCHAR(45) NULL COMMENT 'IP desde donde se usó el token',
    user_agent VARCHAR(500) NULL COMMENT 'User agent del navegador',
    intentos_uso INT NOT NULL DEFAULT 0 COMMENT 'Número de intentos de uso del token',
    INDEX idx_token (token),
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_fecha_expiracion (fecha_expiracion),
    INDEX idx_usado (usado),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    CONSTRAINT chk_fecha_expiracion_recuperacion CHECK (fecha_expiracion > fecha_creacion),
    CONSTRAINT chk_intentos_uso CHECK (intentos_uso >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla para gestionar tokens de recuperación de contraseña con seguridad mejorada';

-- =====================================================
-- 4. TABLA DE AUDITORÍA DE ACTIVACIONES Y RECUPERACIONES
-- =====================================================
DROP TABLE IF EXISTS auditoria_tokens;
CREATE TABLE auditoria_tokens (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tipo_token ENUM('ACTIVACION', 'RECUPERACION') NOT NULL,
    usuario_id INT UNSIGNED NULL COMMENT 'NULL si el usuario no existe',
    email_solicitado VARCHAR(100) NULL COMMENT 'Email usado en la solicitud',
    token_id INT NULL COMMENT 'ID del token relacionado',
    accion ENUM('CREADO', 'USADO', 'EXPIRADO', 'INVALIDO', 'BLOQUEADO') NOT NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(500) NULL,
    fecha_accion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    detalles TEXT NULL COMMENT 'Detalles adicionales de la acción',
    INDEX idx_tipo_token (tipo_token),
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_fecha_accion (fecha_accion),
    INDEX idx_accion (accion),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Auditoría completa de todas las operaciones con tokens';

-- =====================================================
-- 5. PROCEDIMIENTO PARA LIMPIAR TOKENS EXPIRADOS
-- =====================================================
DROP PROCEDURE IF EXISTS limpiar_tokens_expirados;
DELIMITER //
CREATE PROCEDURE limpiar_tokens_expirados()
BEGIN
    -- Marcar tokens de activación expirados como usados (para evitar reutilización)
    UPDATE tokens_activacion 
    SET usado = TRUE, 
        fecha_uso = NOW()
    WHERE usado = FALSE 
      AND fecha_expiracion < NOW();
    
    -- Marcar tokens de recuperación expirados como usados
    UPDATE tokens_recuperacion 
    SET usado = TRUE, 
        fecha_uso = NOW()
    WHERE usado = FALSE 
      AND fecha_expiracion < NOW();
    
    -- Registrar en auditoría
    INSERT INTO auditoria_tokens (tipo_token, token_id, accion, fecha_accion, detalles)
    SELECT 'ACTIVACION', id_token, 'EXPIRADO', NOW(), 'Token expirado automáticamente'
    FROM tokens_activacion 
    WHERE usado = TRUE 
      AND fecha_expiracion < NOW()
      AND fecha_uso = NOW();
    
    INSERT INTO auditoria_tokens (tipo_token, token_id, accion, fecha_accion, detalles)
    SELECT 'RECUPERACION', id_token, 'EXPIRADO', NOW(), 'Token expirado automáticamente'
    FROM tokens_recuperacion 
    WHERE usado = TRUE 
      AND fecha_expiracion < NOW()
      AND fecha_uso = NOW();
END //
DELIMITER ;

-- =====================================================
-- 6. EVENTO PARA LIMPIAR TOKENS EXPIRADOS CADA HORA
-- =====================================================
-- Activar el programador de eventos (ejecutar solo si tienes permisos)
-- SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS evento_limpiar_tokens_expirados;
CREATE EVENT IF NOT EXISTS evento_limpiar_tokens_expirados
ON SCHEDULE EVERY 1 HOUR
DO
  CALL limpiar_tokens_expirados();

-- =====================================================
-- 7. VISTA PARA ESTADÍSTICAS DE ACTIVACIONES
-- =====================================================
DROP VIEW IF EXISTS vista_estadisticas_activaciones;
CREATE VIEW vista_estadisticas_activaciones AS
SELECT 
    COUNT(*) AS total_tokens_creados,
    SUM(CASE WHEN usado = TRUE THEN 1 ELSE 0 END) AS tokens_usados,
    SUM(CASE WHEN usado = FALSE AND fecha_expiracion > NOW() THEN 1 ELSE 0 END) AS tokens_pendientes,
    SUM(CASE WHEN usado = FALSE AND fecha_expiracion < NOW() THEN 1 ELSE 0 END) AS tokens_expirados,
    COUNT(DISTINCT usuario_id) AS usuarios_con_tokens
FROM tokens_activacion;

-- =====================================================
-- 8. VISTA PARA ESTADÍSTICAS DE RECUPERACIONES
-- =====================================================
DROP VIEW IF EXISTS vista_estadisticas_recuperaciones;
CREATE VIEW vista_estadisticas_recuperaciones AS
SELECT 
    COUNT(*) AS total_tokens_creados,
    SUM(CASE WHEN usado = TRUE THEN 1 ELSE 0 END) AS tokens_usados,
    SUM(CASE WHEN usado = FALSE AND fecha_expiracion > NOW() THEN 1 ELSE 0 END) AS tokens_pendientes,
    SUM(CASE WHEN usado = FALSE AND fecha_expiracion < NOW() THEN 1 ELSE 0 END) AS tokens_expirados,
    COUNT(DISTINCT usuario_id) AS usuarios_con_tokens,
    AVG(intentos_uso) AS promedio_intentos_uso
FROM tokens_recuperacion;

-- =====================================================
-- 9. ACTUALIZAR USUARIOS EXISTENTES (OPCIONAL)
-- =====================================================
-- Si quieres que los usuarios existentes estén activados por defecto:
-- UPDATE usuarios SET cuenta_activada = TRUE, fecha_activacion = NOW() WHERE cuenta_activada = FALSE;

-- =====================================================
-- FIN DEL SCRIPT
-- =====================================================

