package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Distrito; // Necesitarás crear este bean
import java.sql.*;
import java.util.ArrayList;

public class DistritoDao {
    private final String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
    private final String user = "root";
    private final String pass = "root";

    public ArrayList<Distrito> listar() {
        ArrayList<Distrito> lista = new ArrayList<>();
        String sql = "SELECT * FROM distritos";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Distrito distrito = new Distrito();
                distrito.setIdDistrito(rs.getInt("id_distrito"));
                distrito.setNombre(rs.getString("nombre"));
                lista.add(distrito);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar distritos", e);
        }
        return lista;
    }
}