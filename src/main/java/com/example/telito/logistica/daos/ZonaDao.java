package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ZonaBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class ZonaDao extends DAOBase {

    public ArrayList<ZonaBean> listarZonas() {
        ArrayList<ZonaBean> lista = new ArrayList<>();
        String sql = "SELECT idZona, nombre FROM zonas ORDER BY nombre ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ZonaBean zona = new ZonaBean();
                zona.setId(rs.getInt("idZona"));
                zona.setNombre(rs.getString("nombre"));
                lista.add(zona);
            }
        } catch (SQLException e) {
            logger.error("Error al listar zonas", e);
            throw new RuntimeException("Error al listar zonas", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
    
    /**
     * Busca zonas por texto (para autocompletado)
     * @param busqueda Texto de búsqueda (nombre de zona)
     * @param limit Límite de resultados (máximo 10)
     * @return Lista de zonas que coinciden con la búsqueda
     */
    public ArrayList<ZonaBean> buscarZonas(String busqueda, int limit) {
        ArrayList<ZonaBean> lista = new ArrayList<>();
        String sql = "SELECT idZona, nombre FROM zonas " +
                     "WHERE nombre LIKE ? " +
                     "ORDER BY nombre ASC " +
                     "LIMIT ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            String searchPattern = "%" + (busqueda != null ? busqueda.trim() : "") + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setInt(2, limit > 0 && limit <= 10 ? limit : 10);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ZonaBean zona = new ZonaBean();
                zona.setId(rs.getInt("idZona"));
                zona.setNombre(rs.getString("nombre"));
                lista.add(zona);
            }
        } catch (SQLException e) {
            logger.error("Error al buscar zonas: " + busqueda, e);
            throw new RuntimeException("Error al buscar zonas", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}



