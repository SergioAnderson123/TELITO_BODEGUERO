package com.example.telito.administrador.daos;

import com.example.telito.util.DAOBase;
import com.example.telito.util.DatabaseConnection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// DAO para gestionar notificaciones web en tiempo real
public class NotificacionDAO extends DAOBase {
    
    private static final Logger logger = LoggerFactory.getLogger(NotificacionDAO.class);

    // Crea nueva notificación para un usuario
    public boolean crearNotificacion(
            int usuarioId,
            String tipoNotificacion,
            String titulo,
            String mensaje,
            String nivelPrioridad,
            Integer productoId,
            Integer loteId,
            Integer pedidoId,
            Integer ordenCompraId,
            String urlAccion
    ) {
        String sql = "INSERT INTO notificaciones_web " +
                "(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, " +
                "producto_id, lote_id, pedido_id, orden_compra_id, url_accion) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            logger.debug("Intentando crear notificación - Usuario ID: {}, Tipo: {}, Título: {}", 
                        usuarioId, tipoNotificacion, titulo);
            
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, usuarioId);
            pstmt.setString(2, tipoNotificacion);
            pstmt.setString(3, titulo);
            pstmt.setString(4, mensaje);
            pstmt.setString(5, nivelPrioridad);
            pstmt.setObject(6, productoId);
            pstmt.setObject(7, loteId);
            pstmt.setObject(8, pedidoId);
            pstmt.setObject(9, ordenCompraId);
            pstmt.setString(10, urlAccion);

            int filasAfectadas = pstmt.executeUpdate();
            
            if (filasAfectadas > 0) {
                logger.info("✓ Notificación creada exitosamente - Usuario ID: {}, Tipo: {}", usuarioId, tipoNotificacion);
            } else {
                logger.warn("⚠ No se insertó ninguna fila - Usuario ID: {}, Tipo: {}", usuarioId, tipoNotificacion);
            }
            
            return filasAfectadas > 0;

        } catch (SQLException e) {
            logger.error("Error al crear notificación - Usuario ID: {}, Tipo: {}", usuarioId, tipoNotificacion, e);
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Crea notificaciones masivas para múltiples usuarios (con todos los parámetros)
    public int crearNotificacionesMasivas(
            List<Integer> usuariosIds,
            String tipoNotificacion,
            String titulo,
            String mensaje,
            String nivelPrioridad,
            Integer productoId,
            Integer loteId,
            Integer pedidoId,
            Integer ordenCompraId,
            String urlAccion
    ) {
        if (usuariosIds == null || usuariosIds.isEmpty()) {
            return 0;
        }
        
        String sql = "INSERT INTO notificaciones_web " +
                "(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, " +
                "producto_id, lote_id, pedido_id, orden_compra_id, url_accion) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        int notificacionesCreadas = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            for (Integer usuarioId : usuariosIds) {
                pstmt.setInt(1, usuarioId);
                pstmt.setString(2, tipoNotificacion);
                pstmt.setString(3, titulo);
                pstmt.setString(4, mensaje);
                pstmt.setString(5, nivelPrioridad);
                pstmt.setObject(6, productoId);
                pstmt.setObject(7, loteId);
                pstmt.setObject(8, pedidoId);
                pstmt.setObject(9, ordenCompraId);
                pstmt.setString(10, urlAccion);
                
                pstmt.addBatch();
            }

            int[] resultados = pstmt.executeBatch();
            for (int resultado : resultados) {
                if (resultado > 0) {
                    notificacionesCreadas++;
                }
            }

            logger.info("Se crearon {} notificaciones masivas", notificacionesCreadas);
            return notificacionesCreadas;

        } catch (SQLException e) {
            logger.error("Error al crear notificaciones masivas", e);
            return notificacionesCreadas;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Obtiene todas las notificaciones de un usuario con paginación
    public List<Map<String, Object>> obtenerNotificacionesPorUsuario(
            int usuarioId, int limit, int offset, boolean soloNoLeidas
    ) {
        List<Map<String, Object>> notificaciones = new ArrayList<>();
        
        String sql = "SELECT n.*, " +
                "p.nombre AS producto_nombre, " +
                "l.codigo_lote AS lote_codigo, " +
                "pe.id_pedido AS pedido_numero, " +
                "oc.numero_Orden AS orden_compra_numero " +
                "FROM notificaciones_web n " +
                "LEFT JOIN productos p ON n.producto_id = p.id_producto " +
                "LEFT JOIN lotes l ON n.lote_id = l.id_lote " +
                "LEFT JOIN pedidos pe ON n.pedido_id = pe.id_pedido " +
                "LEFT JOIN ordenes_compra oc ON n.orden_compra_id = oc.id_orden_compra " +
                "WHERE n.usuario_id = ? ";
        
        if (soloNoLeidas) {
            sql += "AND n.leida = 0 ";
        }
        
        sql += "ORDER BY n.fecha_creacion DESC LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, usuarioId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> notificacion = new HashMap<>();
                notificacion.put("id", rs.getInt("id_notificacion"));
                notificacion.put("tipo", rs.getString("tipo_notificacion"));
                notificacion.put("titulo", rs.getString("titulo"));
                notificacion.put("mensaje", rs.getString("mensaje"));
                notificacion.put("nivel", rs.getString("nivel_prioridad"));
                notificacion.put("leida", rs.getBoolean("leida"));
                notificacion.put("fechaCreacion", rs.getTimestamp("fecha_creacion").getTime());
                notificacion.put("urlAccion", rs.getString("url_accion"));
                
                // Datos relacionados (pueden ser null)
                notificacion.put("productoNombre", rs.getString("producto_nombre"));
                notificacion.put("loteCodigo", rs.getString("lote_codigo"));
                notificacion.put("pedidoNumero", rs.getObject("pedido_numero"));
                notificacion.put("ordenCompraNumero", rs.getString("orden_compra_numero"));
                Integer ordenCompraId = rs.getObject("orden_compra_id") != null ? rs.getInt("orden_compra_id") : null;
                notificacion.put("ordenCompraId", ordenCompraId);
                
                notificaciones.add(notificacion);
            }

        } catch (SQLException e) {
            logger.error("Error al obtener notificaciones", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        return notificaciones;
    }

    // Obtiene últimas N notificaciones no leídas (para el dropdown)
    public List<Map<String, Object>> obtenerNotificacionesRecientes(int usuarioId, int limite) {
        List<Map<String, Object>> notificaciones = new ArrayList<>();
        
        String sql = "SELECT n.*, " +
                "p.nombre AS producto_nombre, " +
                "l.codigo_lote AS lote_codigo, " +
                "n.orden_compra_id AS orden_compra_id " +
                "FROM notificaciones_web n " +
                "LEFT JOIN productos p ON n.producto_id = p.id_producto " +
                "LEFT JOIN lotes l ON n.lote_id = l.id_lote " +
                "WHERE n.usuario_id = ? AND n.leida = 0 " +
                "ORDER BY n.fecha_creacion DESC LIMIT ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, usuarioId);
            pstmt.setInt(2, limite);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> notificacion = new HashMap<>();
                notificacion.put("id", rs.getInt("id_notificacion"));
                notificacion.put("idNotificacion", rs.getInt("id_notificacion"));
                notificacion.put("tipo", rs.getString("tipo_notificacion"));
                notificacion.put("tipoNotificacion", rs.getString("tipo_notificacion"));
                notificacion.put("titulo", rs.getString("titulo"));
                notificacion.put("mensaje", rs.getString("mensaje"));
                notificacion.put("nivel", rs.getString("nivel_prioridad"));
                notificacion.put("nivelPrioridad", rs.getString("nivel_prioridad"));
                
                // Manejar fecha_creacion (puede ser null)
                Timestamp fechaCreacion = rs.getTimestamp("fecha_creacion");
                if (fechaCreacion != null) {
                    notificacion.put("fechaCreacion", fechaCreacion.getTime());
                    notificacion.put("fechaCreacionStr", fechaCreacion.toString());
                } else {
                    notificacion.put("fechaCreacion", System.currentTimeMillis());
                    notificacion.put("fechaCreacionStr", new Timestamp(System.currentTimeMillis()).toString());
                }
                
                notificacion.put("urlAccion", rs.getString("url_accion"));
                notificacion.put("productoNombre", rs.getString("producto_nombre"));
                notificacion.put("loteCodigo", rs.getString("lote_codigo"));
                Integer ordenCompraId = rs.getObject("orden_compra_id") != null ? rs.getInt("orden_compra_id") : null;
                notificacion.put("ordenCompraId", ordenCompraId);
                
                // Como la consulta filtra solo no leídas (leida = 0), todas son no leídas
                notificacion.put("leida", false);
                
                notificaciones.add(notificacion);
            }

        } catch (SQLException e) {
            logger.error("Error al obtener notificaciones recientes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        return notificaciones;
    }

    // Cuenta notificaciones no leídas de un usuario
    public int contarNotificacionesNoLeidas(int usuarioId) {
        String sql = "SELECT COUNT(*) as total FROM notificaciones_web " +
                "WHERE usuario_id = ? AND leida = 0";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, usuarioId);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            logger.error("Error al contar notificaciones no leídas", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        return 0;
    }

    // Cuenta todas las notificaciones de un usuario
    public int contarNotificacionesPorUsuario(int usuarioId) {
        String sql = "SELECT COUNT(*) as total FROM notificaciones_web WHERE usuario_id = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, usuarioId);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            logger.error("Error al contar notificaciones", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        return 0;
    }

    // Marca notificación como leída
    public boolean marcarComoLeida(int idNotificacion) {
        String sql = "UPDATE notificaciones_web SET leida = 1, fecha_lectura = CURRENT_TIMESTAMP " +
                "WHERE id_notificacion = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, idNotificacion);
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            logger.error("Error al marcar notificación como leída", e);
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Marca todas las notificaciones de un usuario como leídas
    public int marcarTodasComoLeidas(int usuarioId) {
        String sql = "UPDATE notificaciones_web SET leida = 1, fecha_lectura = CURRENT_TIMESTAMP " +
                "WHERE usuario_id = ? AND leida = 0";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, usuarioId);
            return pstmt.executeUpdate();

        } catch (SQLException e) {
            logger.error("Error al marcar todas como leídas", e);
            return 0;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Elimina notificación específica
    public boolean eliminarNotificacion(int idNotificacion) {
        String sql = "DELETE FROM notificaciones_web WHERE id_notificacion = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, idNotificacion);
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            logger.error("Error al eliminar notificación", e);
            return false;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Elimina todas las notificaciones leídas de un usuario
    public int eliminarNotificacionesLeidas(int usuarioId) {
        String sql = "DELETE FROM notificaciones_web WHERE usuario_id = ? AND leida = 1";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, usuarioId);
            return pstmt.executeUpdate();

        } catch (SQLException e) {
            logger.error("Error al eliminar notificaciones leídas", e);
            return 0;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Verifica si notificación pertenece a un usuario
    public boolean notificacionPerteneceAUsuario(int idNotificacion, int usuarioId) {
        String sql = "SELECT COUNT(*) as existe FROM notificaciones_web " +
                "WHERE id_notificacion = ? AND usuario_id = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setInt(1, idNotificacion);
            pstmt.setInt(2, usuarioId);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("existe") > 0;
            }

        } catch (SQLException e) {
            logger.error("Error al verificar pertenencia de notificación", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        return false;
    }

    // Obtiene IDs de usuarios de un rol específico (activos)
    public List<Integer> obtenerUsuariosPorRol(String nombreRol) {
        List<Integer> usuariosIds = new ArrayList<>();
        
        String sql = "SELECT u.id_usuario FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                "WHERE UPPER(r.nombre) = UPPER(?) AND u.activo = 1";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, nombreRol);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                usuariosIds.add(rs.getInt("id_usuario"));
            }

        } catch (SQLException e) {
            logger.error("Error al obtener usuarios por rol: " + nombreRol, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        return usuariosIds;
    }
    
    // Obtiene el ID del gerente de tienda asignado a un distrito específico (activo)
    public Integer obtenerGerenteTiendaPorDistrito(int distritoId) {
        Integer gerenteId = null;
        
        String sql = "SELECT u.id_usuario FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                "WHERE UPPER(r.nombre) = UPPER('Gerente de Tienda') " +
                "AND u.distrito_id = ? AND u.activo = 1 " +
                "LIMIT 1";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, distritoId);

            rs = pstmt.executeQuery();
            if (rs.next()) {
                gerenteId = rs.getInt("id_usuario");
            }

        } catch (SQLException e) {
            logger.error("Error al obtener gerente de tienda por distrito ID: " + distritoId, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        return gerenteId;
    }

    // Elimina notificaciones antiguas (más de 30 días y leídas)
    public int limpiarNotificacionesAntiguas() {
        String sql = "DELETE FROM notificaciones_web " +
                "WHERE leida = 1 AND fecha_creacion < DATE_SUB(NOW(), INTERVAL 30 DAY)";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            int eliminadas = pstmt.executeUpdate();
            if (eliminadas > 0) {
                logger.info("Se eliminaron {} notificaciones antiguas", eliminadas);
            }
            return eliminadas;

        } catch (SQLException e) {
            logger.error("Error al limpiar notificaciones antiguas", e);
            return 0;
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
}
