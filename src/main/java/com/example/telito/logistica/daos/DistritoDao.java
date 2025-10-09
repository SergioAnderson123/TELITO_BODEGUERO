package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.DistritoBean;

import java.sql.*;
import java.util.ArrayList;

public class DistritoDao {

    public ArrayList<DistritoBean> listarDistritos() {
        ArrayList<DistritoBean> lista = new ArrayList<>();
        String sql = "SELECT idDistrito, nombre FROM distritos ORDER BY nombre ASC";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                DistritoBean distrito = new DistritoBean();
                distrito.setId(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                lista.add(distrito);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}