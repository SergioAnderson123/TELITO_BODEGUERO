package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.ConfiguracionSistema;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * DAO para gestionar las configuraciones del sistema.
 */
public class ConfiguracionSistemaDAO extends DAOBase {
    
    /**
     * Obtiene una configuración por su clave.
     */
    public ConfiguracionSistema obtenerPorClave(String clave) {
        String sql = "SELECT * FROM configuracion_sistema WHERE clave = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, clave);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapearConfiguracion(rs);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener configuración: " + clave, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    
    /**
     * Obtiene todas las configuraciones agrupadas por categoría.
     */
    public Map<String, ArrayList<ConfiguracionSistema>> listarPorCategoria() {
        Map<String, ArrayList<ConfiguracionSistema>> configs = new HashMap<>();
        String sql = "SELECT * FROM configuracion_sistema ORDER BY categoria, clave";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ConfiguracionSistema config = mapearConfiguracion(rs);
                String categoria = config.getCategoria();
                
                configs.computeIfAbsent(categoria, k -> new ArrayList<>()).add(config);
            }
        } catch (SQLException e) {
            logger.error("Error al listar configuraciones", e);
            throw new RuntimeException("Error al listar configuraciones", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return configs;
    }
    
    /**
     * Lista todas las configuraciones.
     */
    public ArrayList<ConfiguracionSistema> listarTodas() {
        ArrayList<ConfiguracionSistema> lista = new ArrayList<>();
        String sql = "SELECT * FROM configuracion_sistema ORDER BY categoria, clave";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                lista.add(mapearConfiguracion(rs));
            }
        } catch (SQLException e) {
            logger.error("Error al listar configuraciones", e);
            throw new RuntimeException("Error al listar configuraciones", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return lista;
    }
    
    /**
     * Actualiza una configuración.
     */
    public boolean actualizar(String clave, String valor, Integer usuarioId) {
        String sql = """
            UPDATE configuracion_sistema 
            SET valor = ?, usuario_actualizacion = ?, fecha_actualizacion = NOW()
            WHERE clave = ? AND editable = TRUE
            """;
        
        int rows = executeUpdate(sql, valor, usuarioId, clave);
        return rows > 0;
    }
    
    /**
     * Actualiza múltiples configuraciones.
     */
    public void actualizarMultiples(Map<String, String> configuraciones, Integer usuarioId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            beginTransaction(conn);
            
            String sql = """
                UPDATE configuracion_sistema 
                SET valor = ?, usuario_actualizacion = ?, fecha_actualizacion = NOW()
                WHERE clave = ? AND editable = TRUE
                """;
            
            pstmt = conn.prepareStatement(sql);
            
            for (Map.Entry<String, String> entry : configuraciones.entrySet()) {
                pstmt.setString(1, entry.getValue());
                pstmt.setObject(2, usuarioId);
                pstmt.setString(3, entry.getKey());
                pstmt.addBatch();
            }
            
            pstmt.executeBatch();
            commitTransaction(conn);
            
        } catch (SQLException e) {
            rollbackTransaction(conn);
            logger.error("Error al actualizar configuraciones", e);
            throw new RuntimeException("Error al actualizar configuraciones", e);
        } finally {
            closePreparedStatement(pstmt);
            closeConnection(conn);
        }
    }
    
    /**
     * Obtiene el valor de una configuración como String.
     */
    public String obtenerValor(String clave) {
        ConfiguracionSistema config = obtenerPorClave(clave);
        return config != null ? config.getValor() : null;
    }
    
    /**
     * Obtiene el valor de una configuración como int.
     */
    public int obtenerValorInt(String clave, int defaultValue) {
        String valor = obtenerValor(clave);
        if (valor == null) return defaultValue;
        try {
            return Integer.parseInt(valor);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    /**
     * Obtiene el valor de una configuración como boolean.
     */
    public boolean obtenerValorBoolean(String clave, boolean defaultValue) {
        String valor = obtenerValor(clave);
        if (valor == null) return defaultValue;
        return "true".equalsIgnoreCase(valor) || "1".equals(valor);
    }
    
    /**
     * Mapea un ResultSet a un objeto ConfiguracionSistema.
     */
    private ConfiguracionSistema mapearConfiguracion(ResultSet rs) throws SQLException {
        ConfiguracionSistema config = new ConfiguracionSistema();
        config.setIdConfig(rs.getInt("id_config"));
        config.setClave(rs.getString("clave"));
        config.setValor(rs.getString("valor"));
        config.setTipo(rs.getString("tipo"));
        config.setCategoria(rs.getString("categoria"));
        config.setDescripcion(rs.getString("descripcion"));
        config.setEditable(rs.getBoolean("editable"));
        config.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
        config.setFechaActualizacion(rs.getTimestamp("fecha_actualizacion"));
        
        Object usuarioActualizacion = rs.getObject("usuario_actualizacion");
        if (usuarioActualizacion != null) {
            if (usuarioActualizacion instanceof Long) {
                config.setUsuarioActualizacion(((Long) usuarioActualizacion).intValue());
            } else if (usuarioActualizacion instanceof Integer) {
                config.setUsuarioActualizacion((Integer) usuarioActualizacion);
            }
        }
        
        return config;
    }
}

