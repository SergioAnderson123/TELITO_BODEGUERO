package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ConductorBean;
import com.example.telito.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;

public class ConductorDao {

    public ArrayList<ConductorBean> listarConductores() {
        ArrayList<ConductorBean> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, nombre_completo FROM conductores ORDER BY nombre_completo ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ConductorBean conductor = new ConductorBean();
                conductor.setId(rs.getInt("id_conductor"));
                conductor.setNombreCompleto(rs.getString("nombre_completo"));
                lista.add(conductor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}