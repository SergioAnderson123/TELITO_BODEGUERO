package com.example.telito.administrador.daos;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO para gestionar las notificaciones web en tiempo real.
 * Maneja operaciones CRUD sobre la tabla notificaciones_web.
 */
public class NotificacionDAO {

    private static final String URL = "jdbc:mysql://localhost:3306/telito_bodeguero";
    private static final String USER = "root";
    private static final String PASSWORD = "root";

    /**
     * Crea una nueva notificación para un usuario
     */
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

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

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
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("ERROR al crear notificación: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Crea notificaciones masivas para múltiples usuarios
     */
    public int crearNotificacionesMasivas(
            List<Integer> usuariosIds,
            String tipoNotificacion,
            String titulo,
            String mensaje,
            String nivelPrioridad,
            Integer productoId,
            Integer loteId,
            String urlAccion
    ) {
        String sql = "INSERT INTO notificaciones_web " +
                "(usuario_id, tipo_notificacion, titulo, mensaje, nivel_prioridad, " +
                "producto_id, lote_id, url_accion) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        int notificacionesCreadas = 0;

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (Integer usuarioId : usuariosIds) {
                pstmt.setInt(1, usuarioId);
                pstmt.setString(2, tipoNotificacion);
                pstmt.setString(3, titulo);
                pstmt.setString(4, mensaje);
                pstmt.setString(5, nivelPrioridad);
                pstmt.setObject(6, productoId);
                pstmt.setObject(7, loteId);
                pstmt.setString(8, urlAccion);
                
                pstmt.addBatch();
            }

            int[] resultados = pstmt.executeBatch();
            for (int resultado : resultados) {
                if (resultado > 0) {
                    notificacionesCreadas++;
                }
            }

            System.out.println("✓ Se crearon " + notificacionesCreadas + " notificaciones masivas");
            return notificacionesCreadas;

        } catch (SQLException e) {
            System.err.println("ERROR al crear notificaciones masivas: " + e.getMessage());
            e.printStackTrace();
            return notificacionesCreadas;
        }
    }

    /**
     * Obtiene todas las notificaciones de un usuario con paginación
     */
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

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
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
                    
                    notificaciones.add(notificacion);
                }
            }

        } catch (SQLException e) {
            System.err.println("ERROR al obtener notificaciones: " + e.getMessage());
            e.printStackTrace();
        }

        return notificaciones;
    }

    /**
     * Obtiene las últimas N notificaciones no leídas (para el dropdown)
     */
    public List<Map<String, Object>> obtenerNotificacionesRecientes(int usuarioId, int limite) {
        List<Map<String, Object>> notificaciones = new ArrayList<>();
        
        String sql = "SELECT n.*, " +
                "p.nombre AS producto_nombre, " +
                "l.codigo_lote AS lote_codigo " +
                "FROM notificaciones_web n " +
                "LEFT JOIN productos p ON n.producto_id = p.id_producto " +
                "LEFT JOIN lotes l ON n.lote_id = l.id_lote " +
                "WHERE n.usuario_id = ? AND n.leida = 0 " +
                "ORDER BY n.fecha_creacion DESC LIMIT ?";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);
            pstmt.setInt(2, limite);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> notificacion = new HashMap<>();
                    notificacion.put("id", rs.getInt("id_notificacion"));
                    notificacion.put("tipo", rs.getString("tipo_notificacion"));
                    notificacion.put("titulo", rs.getString("titulo"));
                    notificacion.put("mensaje", rs.getString("mensaje"));
                    notificacion.put("nivel", rs.getString("nivel_prioridad"));
                    notificacion.put("fechaCreacion", rs.getTimestamp("fecha_creacion").getTime());
                    notificacion.put("urlAccion", rs.getString("url_accion"));
                    notificacion.put("productoNombre", rs.getString("producto_nombre"));
                    notificacion.put("loteCodigo", rs.getString("lote_codigo"));
                    
                    notificaciones.add(notificacion);
                }
            }

        } catch (SQLException e) {
            System.err.println("ERROR al obtener notificaciones recientes: " + e.getMessage());
            e.printStackTrace();
        }

        return notificaciones;
    }

    /**
     * Cuenta las notificaciones no leídas de un usuario
     */
    public int contarNotificacionesNoLeidas(int usuarioId) {
        String sql = "SELECT COUNT(*) as total FROM notificaciones_web " +
                "WHERE usuario_id = ? AND leida = 0";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }

        } catch (SQLException e) {
            System.err.println("ERROR al contar notificaciones no leídas: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Cuenta todas las notificaciones de un usuario
     */
    public int contarNotificacionesPorUsuario(int usuarioId) {
        String sql = "SELECT COUNT(*) as total FROM notificaciones_web WHERE usuario_id = ?";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }

        } catch (SQLException e) {
            System.err.println("ERROR al contar notificaciones: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Marca una notificación como leída
     */
    public boolean marcarComoLeida(int idNotificacion) {
        String sql = "UPDATE notificaciones_web SET leida = 1, fecha_lectura = CURRENT_TIMESTAMP " +
                "WHERE id_notificacion = ?";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idNotificacion);
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("ERROR al marcar notificación como leída: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Marca todas las notificaciones de un usuario como leídas
     */
    public int marcarTodasComoLeidas(int usuarioId) {
        String sql = "UPDATE notificaciones_web SET leida = 1, fecha_lectura = CURRENT_TIMESTAMP " +
                "WHERE usuario_id = ? AND leida = 0";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);
            return pstmt.executeUpdate();

        } catch (SQLException e) {
            System.err.println("ERROR al marcar todas como leídas: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Elimina una notificación específica
     */
    public boolean eliminarNotificacion(int idNotificacion) {
        String sql = "DELETE FROM notificaciones_web WHERE id_notificacion = ?";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idNotificacion);
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("ERROR al eliminar notificación: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Elimina todas las notificaciones leídas de un usuario
     */
    public int eliminarNotificacionesLeidas(int usuarioId) {
        String sql = "DELETE FROM notificaciones_web WHERE usuario_id = ? AND leida = 1";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);
            return pstmt.executeUpdate();

        } catch (SQLException e) {
            System.err.println("ERROR al eliminar notificaciones leídas: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Verifica si una notificación pertenece a un usuario
     */
    public boolean notificacionPerteneceAUsuario(int idNotificacion, int usuarioId) {
        String sql = "SELECT COUNT(*) as existe FROM notificaciones_web " +
                "WHERE id_notificacion = ? AND usuario_id = ?";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idNotificacion);
            pstmt.setInt(2, usuarioId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("existe") > 0;
                }
            }

        } catch (SQLException e) {
            System.err.println("ERROR al verificar pertenencia de notificación: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * Obtiene los IDs de usuarios de un rol específico
     */
    public List<Integer> obtenerUsuariosPorRol(String nombreRol) {
        List<Integer> usuariosIds = new ArrayList<>();
        
        String sql = "SELECT u.id_usuario FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                "WHERE r.nombre = ? AND u.activo = 1";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nombreRol);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    usuariosIds.add(rs.getInt("id_usuario"));
                }
            }

        } catch (SQLException e) {
            System.err.println("ERROR al obtener usuarios por rol: " + e.getMessage());
            e.printStackTrace();
        }

        return usuariosIds;
    }

    /**
     * Elimina notificaciones antiguas (más de 30 días y leídas)
     */
    public int limpiarNotificacionesAntiguas() {
        String sql = "DELETE FROM notificaciones_web " +
                "WHERE leida = 1 AND fecha_creacion < DATE_SUB(NOW(), INTERVAL 30 DAY)";

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int eliminadas = pstmt.executeUpdate();
            if (eliminadas > 0) {
                System.out.println("✓ Se eliminaron " + eliminadas + " notificaciones antiguas");
            }
            return eliminadas;

        } catch (SQLException e) {
            System.err.println("ERROR al limpiar notificaciones antiguas: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
}
