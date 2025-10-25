package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ZonaBean;
import com.example.telito.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;

public class ZonaDao {

    public ArrayList<ZonaBean> listarZonas() {
        ArrayList<ZonaBean> lista = new ArrayList<>();
        String sql = "SELECT idZona, nombre FROM zonas ORDER BY nombre ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ZonaBean zona = new ZonaBean();
                zona.setId(rs.getInt("idZona"));
                zona.setNombre(rs.getString("nombre"));
                lista.add(zona);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}



