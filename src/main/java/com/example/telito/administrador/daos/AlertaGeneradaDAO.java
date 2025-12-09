package com.example.telito.administrador.daos;

import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * DAO para gestionar las alertas generadas (historial de alertas).
 */
public class AlertaGeneradaDAO extends DAOBase {
    
    /**
     * Obtiene todas las alertas activas (no leídas).
     */
    public ArrayList<Map<String, Object>> listarAlertasActivas(int limit) {
        ArrayList<Map<String, Object>> alertas = new ArrayList<>();
        String sql = """
            SELECT ag.*, ac.nombre AS nombre_regla, ac.tipo_alerta,
                   p.nombre AS nombre_producto, l.codigo_lote
            FROM alertas_generadas ag
            INNER JOIN alertas_configuracion ac ON ag.alerta_config_id = ac.id_alerta_config
            LEFT JOIN productos p ON ag.producto_id = p.id_producto
            LEFT JOIN lotes l ON ag.lote_id = l.id_lote
            WHERE ag.leida = 0
            ORDER BY ag.fecha_generacion DESC
            LIMIT ?
            """;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> alerta = new HashMap<>();
                alerta.put("id", rs.getInt("id_alerta_generada"));
                alerta.put("alerta_config_id", rs.getInt("alerta_config_id"));
                alerta.put("nombre_regla", rs.getString("nombre_regla"));
                alerta.put("tipo_alerta", rs.getString("tipo_alerta"));
                alerta.put("nivel", rs.getString("nivel"));
                alerta.put("mensaje", rs.getString("mensaje"));
                alerta.put("producto_id", rs.getObject("producto_id"));
                alerta.put("lote_id", rs.getObject("lote_id"));
                alerta.put("nombre_producto", rs.getString("nombre_producto"));
                alerta.put("codigo_lote", rs.getString("codigo_lote"));
                alerta.put("fecha_generacion", rs.getTimestamp("fecha_generacion"));
                alertas.add(alerta);
            }
        } catch (SQLException e) {
            logger.error("Error al listar alertas activas", e);
            throw new RuntimeException("Error al listar alertas activas", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return alertas;
    }
    
    /**
     * Cuenta alertas por nivel de prioridad.
     */
    public Map<String, Integer> contarAlertasPorNivel() {
        Map<String, Integer> conteo = new HashMap<>();
        String sql = """
            SELECT nivel, COUNT(*) as total
            FROM alertas_generadas
            WHERE leida = 0
            GROUP BY nivel
            """;
        
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                conteo.put(rs.getString("nivel"), rs.getInt("total"));
            }
        } catch (SQLException e) {
            logger.error("Error al contar alertas por nivel", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        
        // Asegurar que todos los niveles existan
        conteo.putIfAbsent("INFO", 0);
        conteo.putIfAbsent("WARNING", 0);
        conteo.putIfAbsent("CRITICAL", 0);
        
        return conteo;
    }
    
    /**
     * Cuenta alertas por tipo.
     */
    public Map<String, Integer> contarAlertasPorTipo() {
        Map<String, Integer> conteo = new HashMap<>();
        String sql = """
            SELECT ac.tipo_alerta, COUNT(*) as total
            FROM alertas_generadas ag
            INNER JOIN alertas_configuracion ac ON ag.alerta_config_id = ac.id_alerta_config
            WHERE ag.leida = 0
            GROUP BY ac.tipo_alerta
            """;
        
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                conteo.put(rs.getString("tipo_alerta"), rs.getInt("total"));
            }
        } catch (SQLException e) {
            logger.error("Error al contar alertas por tipo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        
        return conteo;
    }
    
    /**
     * Marca una alerta como leída.
     */
    public void marcarComoLeida(int idAlerta) {
        String sql = "UPDATE alertas_generadas SET leida = 1, fecha_lectura = CURRENT_TIMESTAMP WHERE id_alerta_generada = ?";
        executeUpdate(sql, idAlerta);
    }
    
    /**
     * Obtiene el total de alertas activas.
     */
    public int contarAlertasActivas() {
        String sql = "SELECT COUNT(*) FROM alertas_generadas WHERE leida = 0";
        return count(sql);
    }
}

