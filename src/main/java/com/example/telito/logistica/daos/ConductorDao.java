package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ConductorBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class ConductorDao extends DAOBase {

    public ArrayList<ConductorBean> listarConductores() {
        ArrayList<ConductorBean> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, nombre_completo FROM conductores ORDER BY nombre_completo ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ConductorBean conductor = new ConductorBean();
                conductor.setId(rs.getInt("id_conductor"));
                conductor.setNombreCompleto(rs.getString("nombre_completo"));
                lista.add(conductor);
            }
        } catch (SQLException e) {
            logger.error("Error al listar conductores", e);
            throw new RuntimeException("Error al listar conductores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}