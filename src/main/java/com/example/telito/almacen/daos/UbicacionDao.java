package com.example.inventario.daos;

import com.example.inventario.beans.Ubicacion;
import java.sql.*;
import java.util.ArrayList;

public class UbicacionDao {

    private String url = "jdbc:mysql://localhost:3306/telito4";
    private String user = "root";
    private String pass = "chupamela2005";

    public ArrayList<Ubicacion> listar() {
        ArrayList<Ubicacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM ubicaciones";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Ubicacion ubicacion = new Ubicacion();
                ubicacion.setIdUbicacion(rs.getInt("id_ubicacion"));
                ubicacion.setPasillo(rs.getString("nombre"));
                lista.add(ubicacion);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return lista;
    }
}