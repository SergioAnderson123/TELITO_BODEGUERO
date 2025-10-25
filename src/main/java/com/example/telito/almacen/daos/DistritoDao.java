package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Distrito;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;

public class DistritoDao {
    // Las credenciales ahora están centralizadas en DatabaseConnection

    public ArrayList<Distrito> listar() {
        ArrayList<Distrito> lista = new ArrayList<>();
        String sql = "SELECT * FROM distritos";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Distrito distrito = new Distrito();
                distrito.setIdDistrito(rs.getInt("idDistrito"));
                distrito.setNombre(rs.getString("nombre"));
                lista.add(distrito);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar distritos", e);
        }
        return lista;
    }
}