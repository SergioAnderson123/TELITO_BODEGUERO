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
}



