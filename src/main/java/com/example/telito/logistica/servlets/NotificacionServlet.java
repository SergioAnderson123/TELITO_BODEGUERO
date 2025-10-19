package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet para manejar notificaciones en el módulo de logística.
 * Muestra alertas dirigidas al rol de logística y permite marcarlas como leídas.
 */
@WebServlet(name = "NotificacionServlet", value = "/logistica/NotificacionServlet")
public class NotificacionServlet extends HttpServlet {

    private String user = "root";
    private String pass = "root";
    private String url = "jdbc:mysql://localhost:3306/telito_bodeguero";

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        return DriverManager.getConnection(url, user, pass);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        HttpSession session = request.getSession();
        RequestDispatcher view;

        switch (action) {
            case "listar":
                // Obtener notificaciones para logística (asumiendo que el rol de logística tiene ID 3)
                ArrayList<Map<String, Object>> notificaciones = obtenerNotificacionesParaLogistica();
                request.setAttribute("notificaciones", notificaciones);
                
                // Contar notificaciones no leídas
                int noLeidas = contarNotificacionesNoLeidas();
                request.setAttribute("noLeidas", noLeidas);
                
                view = request.getRequestDispatcher("/logistica/notificaciones.jsp");
                view.forward(request, response);
                break;
                
            case "marcarLeida":
                try {
                    int eventoId = Integer.parseInt(request.getParameter("id"));
                    marcarComoLeida(eventoId);
                    session.setAttribute("successMsg", "Notificación marcada como leída.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "ID de notificación inválido.");
                }
                response.sendRedirect(request.getContextPath() + "/logistica/NotificacionServlet");
                break;
                
            case "marcarTodasLeidas":
                marcarTodasComoLeidas();
                session.setAttribute("successMsg", "Todas las notificaciones han sido marcadas como leídas.");
                response.sendRedirect(request.getContextPath() + "/logistica/NotificacionServlet");
                break;
                
            case "contar":
                // Endpoint para obtener el conteo de notificaciones no leídas (JSON)
                int count = contarNotificacionesNoLeidas();
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"count\": " + count + "}");
                return;

            case "contarStockOut":
                // Endpoint para obtener el conteo de eventos CRÍTICOS de stock (sin stock)
                int stockOut = contarStockOutNoLeidas();
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"count\": " + stockOut + "}");
                return;

            case "checkAdminPush":
                // Retorna si existe al menos un ADMIN_PUSH no leído
                int adminPush = contarAdminPushNoLeido();
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"count\": " + adminPush + "}");
                return;

            case "ackAdminPush":
                // Marca como leído el último ADMIN_PUSH no leído
                marcarAdminPushComoLeido();
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"ok\": true}");
                return;
        }
    }

    /**
     * Obtiene las notificaciones dirigidas al rol de logística.
     */
    private ArrayList<Map<String, Object>> obtenerNotificacionesParaLogistica() {
        ArrayList<Map<String, Object>> notificaciones = new ArrayList<>();
        
        // Asumiendo que el rol de logística tiene ID 3 (ajustar según tu configuración)
        String sql = "SELECT ae.*, p.nombre as producto_nombre, p.codigo_sku, " +
                    "c.nombre as categoria_nombre, l.numero_lote " +
                    "FROM alertas_evento ae " +
                    "LEFT JOIN productos p ON ae.producto_id = p.id_producto " +
                    "LEFT JOIN categorias c ON ae.categoria_id = c.id_categoria " +
                    "LEFT JOIN lotes l ON ae.lote_id = l.id_lote " +
                    "WHERE ae.rol_destino_id = 3 " + // Rol de logística
                    "ORDER BY ae.creado_en DESC, ae.severidad DESC";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> notificacion = new HashMap<>();
                notificacion.put("id", rs.getInt("id_alerta_evento"));
                notificacion.put("tipo", rs.getString("tipo_alerta"));
                notificacion.put("mensaje", rs.getString("mensaje"));
                notificacion.put("severidad", rs.getString("severidad"));
                notificacion.put("leido", rs.getBoolean("leido"));
                notificacion.put("creadoEn", rs.getTimestamp("creado_en"));
                notificacion.put("leidoEn", rs.getTimestamp("leido_en"));
                notificacion.put("productoNombre", rs.getString("producto_nombre"));
                notificacion.put("codigoSku", rs.getString("codigo_sku"));
                notificacion.put("categoriaNombre", rs.getString("categoria_nombre"));
                notificacion.put("numeroLote", rs.getString("numero_lote"));
                
                notificaciones.add(notificacion);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return notificaciones;
    }

    /**
     * Cuenta las notificaciones no leídas para logística.
     */
    private int contarNotificacionesNoLeidas() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM alertas_evento WHERE rol_destino_id = 3 AND leido = 0";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return count;
    }

    /**
     * Cuenta notificaciones no leídas de tipo STOCK_MINIMO con severidad CRITICO (sin stock) para logística.
     */
    private int contarStockOutNoLeidas() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM alertas_evento " +
                     "WHERE rol_destino_id = 3 AND leido = 0 " +
                     "AND tipo_alerta = 'STOCK_MINIMO' AND severidad = 'CRITICO'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return count;
    }

    private int contarAdminPushNoLeido() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM alertas_evento " +
                     "WHERE rol_destino_id = 3 AND leido = 0 AND tipo_alerta = 'ADMIN_PUSH'";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    private void marcarAdminPushComoLeido() {
        String sql = "UPDATE alertas_evento SET leido = 1, leido_en = NOW() " +
                     "WHERE rol_destino_id = 3 AND leido = 0 AND tipo_alerta = 'ADMIN_PUSH' " +
                     "ORDER BY creado_en DESC LIMIT 1";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Marca una notificación específica como leída.
     */
    private void marcarComoLeida(int eventoId) {
        String sql = "UPDATE alertas_evento SET leido = 1, leido_en = NOW() WHERE id_alerta_evento = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, eventoId);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Marca todas las notificaciones de logística como leídas.
     */
    private void marcarTodasComoLeidas() {
        String sql = "UPDATE alertas_evento SET leido = 1, leido_en = NOW() WHERE rol_destino_id = 3 AND leido = 0";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
