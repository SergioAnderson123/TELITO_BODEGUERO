package com.example.telito.almacen.daos;


import com.example.telito.almacen.beans.Ubicacion;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;

public class UbicacionDao {
    // Las credenciales ahora están centralizadas en DatabaseConnection

    public ArrayList<Ubicacion> listar() {
        ArrayList<Ubicacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM ubicaciones";

        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Ubicacion ubicacion = new Ubicacion();
                ubicacion.setIdUbicacion(rs.getInt("id_ubicacion"));
                ubicacion.setNombre(rs.getString("nombre")); // Asume que la columna se llama 'nombre'
                lista.add(ubicacion);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar ubicaciones", e);
        }
        return lista;
    }
}