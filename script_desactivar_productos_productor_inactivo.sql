USE telito_bodeguero;

-- =====================================================
-- TRIGGER: Desactivar productos cuando productor se desactiva
-- =====================================================

-- Eliminar trigger si existe
DROP TRIGGER IF EXISTS trg_desactivar_productos_productor_inactivo;

-- Crear trigger que se ejecuta DESPUÉS de actualizar un usuario
DELIMITER $$

CREATE TRIGGER trg_desactivar_productos_productor_inactivo
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    -- Si el usuario es un productor y se desactivó (activo cambió de 1 a 0)
    IF NEW.activo = 0 AND OLD.activo = 1 THEN
        -- Verificar si el usuario tiene rol de productor
        IF EXISTS (
            SELECT 1 FROM roles r 
            INNER JOIN usuarios u ON r.id_rol = u.rol_id 
            WHERE u.id_usuario = NEW.id_usuario 
            AND r.nombre = 'Productor'
        ) THEN
            -- Desactivar todos los productos del productor
            UPDATE productos 
            SET activo = 0 
            WHERE productor_id = NEW.id_usuario 
            AND activo = 1;
        END IF;
    END IF;
END$$

DELIMITER ;

SELECT '✓ Trigger creado: Los productos se desactivarán automáticamente cuando su productor se desactive.' AS mensaje;

