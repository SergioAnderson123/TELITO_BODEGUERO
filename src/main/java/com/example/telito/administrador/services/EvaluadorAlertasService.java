package com.example.telito.administrador.services;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.administrador.daos.AlertaDAO;

import java.sql.*;
import java.util.ArrayList;
import java.util.Date;

/**
 * Servicio para evaluar las reglas de alerta y generar eventos de notificación.
 * Este servicio puede ser llamado manualmente o programáticamente.
 */
public class EvaluadorAlertasService {

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

    /**
     * Evalúa todas las reglas de alerta activas y genera eventos correspondientes.
     * @return Número de eventos generados
     */
    public int evaluarTodasLasAlertas() {
        int eventosGenerados = 0;
        AlertaDAO alertaDAO = new AlertaDAO();
        ArrayList<AlertaConfig> reglasActivas = alertaDAO.listarAlertas();
        
        // Filtrar solo las reglas activas
        reglasActivas.removeIf(alerta -> !alerta.isActivo());
        
        for (AlertaConfig regla : reglasActivas) {
            eventosGenerados += evaluarRegla(regla);
        }
        
        return eventosGenerados;
    }

    /**
     * Evalúa una regla específica y genera eventos si encuentra condiciones de alerta.
     * @param regla La regla de alerta a evaluar
     * @return Número de eventos generados para esta regla
     */
    private int evaluarRegla(AlertaConfig regla) {
        int eventosGenerados = 0;
        String tipoAlerta = regla.getTipoAlerta();
        Integer categoriaId = regla.getCategoria() != null ? regla.getCategoria().getIdCategoria() : null;
        Integer rolDestinoId = regla.getRolANotificar().getIdRol();

        try (Connection conn = getConnection()) {
            if ("STOCK_MINIMO".equals(tipoAlerta)) {
                eventosGenerados = evaluarStockMinimo(conn, categoriaId, rolDestinoId);
            } else if ("PROXIMO_A_VENCER".equals(tipoAlerta)) {
                Integer umbralDias = regla.getUmbralDias();
                if (umbralDias != null) {
                    eventosGenerados = evaluarProximoAVencer(conn, categoriaId, rolDestinoId, umbralDias);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return eventosGenerados;
    }

    /**
     * Evalúa productos con stock mínimo y genera eventos.
     */
    private int evaluarStockMinimo(Connection conn, Integer categoriaId, Integer rolDestinoId) throws SQLException {
        int eventosGenerados = 0;
        
        String sql = "SELECT p.id_producto, p.nombre, p.codigo_sku, p.stock, p.stock_minimo, p.categoria_id " +
                    "FROM productos p WHERE p.stock <= p.stock_minimo";
        
        if (categoriaId != null) {
            sql += " AND p.categoria_id = ?";
        }

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (categoriaId != null) {
                pstmt.setInt(1, categoriaId);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    int productoId = rs.getInt("id_producto");
                    String nombre = rs.getString("nombre");
                    String codigoSku = rs.getString("codigo_sku");
                    int stock = rs.getInt("stock");
                    int stockMinimo = rs.getInt("stock_minimo");
                    
                    // Determinar severidad
                    String severidad = stock == 0 ? "CRITICO" : "WARN";
                    
                    // Crear mensaje
                    String mensaje = String.format("Producto '%s' (SKU: %s) tiene stock %d, por debajo del mínimo %d", 
                                                 nombre, codigoSku, stock, stockMinimo);
                    
                    // Insertar evento
                    if (insertarEventoAlerta(conn, "STOCK_MINIMO", productoId, null, categoriaId, 
                                           mensaje, severidad, rolDestinoId)) {
                        eventosGenerados++;
                    }
                }
            }
        }
        
        return eventosGenerados;
    }

    /**
     * Evalúa lotes próximos a vencer y genera eventos.
     */
    private int evaluarProximoAVencer(Connection conn, Integer categoriaId, Integer rolDestinoId, int umbralDias) throws SQLException {
        int eventosGenerados = 0;
        
        String sql = "SELECT l.id_lote, l.fecha_vencimiento, p.nombre, p.codigo_sku, p.categoria_id " +
                    "FROM lotes l " +
                    "JOIN productos p ON l.producto_id = p.id_producto " +
                    "WHERE DATEDIFF(l.fecha_vencimiento, CURDATE()) BETWEEN 0 AND ?";
        
        if (categoriaId != null) {
            sql += " AND p.categoria_id = ?";
        }

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, umbralDias);
            if (categoriaId != null) {
                pstmt.setInt(2, categoriaId);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    int loteId = rs.getInt("id_lote");
                    Date fechaVencimiento = rs.getDate("fecha_vencimiento");
                    String nombreProducto = rs.getString("nombre");
                    String codigoSku = rs.getString("codigo_sku");
                    int productoId = rs.getInt("producto_id");
                    
                    // Calcular días restantes
                    long diasRestantes = (fechaVencimiento.getTime() - System.currentTimeMillis()) / (1000 * 60 * 60 * 24);
                    
                    // Determinar severidad
                    String severidad = diasRestantes <= 3 ? "CRITICO" : "WARN";
                    
                    // Crear mensaje
                    String mensaje = String.format("Lote %d del producto '%s' (SKU: %s) vence en %d días (%s)", 
                                                 loteId, nombreProducto, codigoSku, diasRestantes, fechaVencimiento);
                    
                    // Insertar evento
                    if (insertarEventoAlerta(conn, "PROXIMO_A_VENCER", productoId, loteId, categoriaId, 
                                           mensaje, severidad, rolDestinoId)) {
                        eventosGenerados++;
                    }
                }
            }
        }
        
        return eventosGenerados;
    }

    /**
     * Inserta un evento de alerta en la base de datos.
     * Evita duplicados verificando si ya existe un evento similar reciente.
     */
    private boolean insertarEventoAlerta(Connection conn, String tipoAlerta, Integer productoId, Integer loteId, 
                                       Integer categoriaId, String mensaje, String severidad, Integer rolDestinoId) throws SQLException {
        
        // Verificar si ya existe un evento similar en las últimas 24 horas
        String sqlVerificacion = "SELECT COUNT(*) FROM alertas_evento " +
                                "WHERE tipo_alerta = ? AND rol_destino_id = ? AND leido = 0 " +
                                "AND creado_en >= DATE_SUB(NOW(), INTERVAL 24 HOUR)";
        
        if (productoId != null) {
            sqlVerificacion += " AND producto_id = ?";
        }
        if (loteId != null) {
            sqlVerificacion += " AND lote_id = ?";
        }

        try (PreparedStatement pstmt = conn.prepareStatement(sqlVerificacion)) {
            int paramIndex = 1;
            pstmt.setString(paramIndex++, tipoAlerta);
            pstmt.setInt(paramIndex++, rolDestinoId);
            if (productoId != null) {
                pstmt.setInt(paramIndex++, productoId);
            }
            if (loteId != null) {
                pstmt.setInt(paramIndex++, loteId);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // Ya existe un evento similar reciente, no duplicar
                    return false;
                }
            }
        }

        // Insertar nuevo evento
        String sqlInsert = "INSERT INTO alertas_evento (tipo_alerta, producto_id, lote_id, categoria_id, " +
                          "mensaje, severidad, rol_destino_id) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(sqlInsert)) {
            pstmt.setString(1, tipoAlerta);
            pstmt.setObject(2, productoId);
            pstmt.setObject(3, loteId);
            pstmt.setObject(4, categoriaId);
            pstmt.setString(5, mensaje);
            pstmt.setString(6, severidad);
            pstmt.setInt(7, rolDestinoId);
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Método para limpiar eventos antiguos (más de 30 días).
     */
    public int limpiarEventosAntiguos() {
        String sql = "DELETE FROM alertas_evento WHERE creado_en < DATE_SUB(NOW(), INTERVAL 30 DAY)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }
}
