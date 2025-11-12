package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.DistritoBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class DistritoDao extends DAOBase {

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
    
    // Listar distritos por zona
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
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si existe un distrito con el ID especificado
     */
    public boolean existeDistrito(int distritoId) {
        String sqlCount = "SELECT COUNT(*) FROM distritos WHERE idDistrito = ?";
        return count(sqlCount, distritoId) > 0;
    }
}