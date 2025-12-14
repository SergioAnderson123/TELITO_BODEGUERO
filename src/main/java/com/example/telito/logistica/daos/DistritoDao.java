package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.DistritoBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de distritos
public class DistritoDao extends DAOBase {

    // Lista todos los distritos ordenados por nombre
    public ArrayList<DistritoBean> listarDistritos() {
        ArrayList<DistritoBean> lista = new ArrayList<>();
        String sql = "SELECT idDistrito, nombre FROM distritos ORDER BY nombre ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                DistritoBean distrito = new DistritoBean();
                distrito.setId(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                lista.add(distrito);
            }
        } catch (SQLException e) {
            logger.error("Error al listar distritos", e);
            throw new RuntimeException("Error al listar distritos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
    
    // Lista distritos filtrados por zona
    public ArrayList<DistritoBean> listarDistritosPorZona(int zonaId) {
        ArrayList<DistritoBean> lista = new ArrayList<>();
        String sql = "SELECT idDistrito, nombre FROM distritos WHERE zona_id = ? ORDER BY nombre ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, zonaId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                DistritoBean distrito = new DistritoBean();
                distrito.setId(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                lista.add(distrito);
            }
        } catch (SQLException e) {
            logger.error("Error al listar distritos por zona: " + zonaId, e);
            throw new RuntimeException("Error al listar distritos por zona", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
    
    /**
     * Busca distritos por texto (para autocompletado)
     * @param busqueda Texto de búsqueda (nombre de distrito)
     * @param limit Límite de resultados (máximo 20)
     * @return Lista de distritos que coinciden con la búsqueda
     */
    public ArrayList<DistritoBean> buscarDistritos(String busqueda, int limit) {
        ArrayList<DistritoBean> lista = new ArrayList<>();
        String sql = "SELECT d.idDistrito, d.nombre, z.nombre as zona_nombre " +
                     "FROM distritos d " +
                     "INNER JOIN zonas z ON d.zona_id = z.idZona " +
                     "WHERE d.nombre LIKE ? " +
                     "ORDER BY d.nombre ASC " +
                     "LIMIT ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            String searchPattern = "%" + (busqueda != null ? busqueda.trim() : "") + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setInt(2, limit > 0 && limit <= 20 ? limit : 20);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                DistritoBean distrito = new DistritoBean();
                distrito.setId(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                // Si DistritoBean tiene un campo para zona, lo podemos agregar
                lista.add(distrito);
            }
        } catch (SQLException e) {
            logger.error("Error al buscar distritos: " + busqueda, e);
            throw new RuntimeException("Error al buscar distritos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
    
    // Obtiene un distrito por su ID
    public DistritoBean obtenerDistritoPorId(int distritoId) {
        String sql = "SELECT idDistrito, nombre FROM distritos WHERE idDistrito = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, distritoId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                DistritoBean distrito = new DistritoBean();
                distrito.setId(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                return distrito;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener distrito por ID: " + distritoId, e);
            throw new RuntimeException("Error al obtener distrito por ID", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si existe un distrito con el ID especificado
     */
    public boolean existeDistrito(int distritoId) {
        String sqlCount = "SELECT COUNT(*) FROM distritos WHERE idDistrito = ?";
        return count(sqlCount, distritoId) > 0;
    }
}