package com.example.telito.almacen.daos;


import com.example.telito.almacen.beans.Ubicacion;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class UbicacionDao extends DAOBase {

    public ArrayList<Ubicacion> listar() {
        ArrayList<Ubicacion> lista = new ArrayList<>();
        String sql = "SELECT * FROM ubicaciones";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Ubicacion ubicacion = new Ubicacion();
                ubicacion.setIdUbicacion(rs.getInt("id_ubicacion"));
                ubicacion.setNombre(rs.getString("nombre")); // Asume que la columna se llama 'nombre'
                lista.add(ubicacion);
            }
        } catch (SQLException e) {
            logger.error("Error al listar ubicaciones", e);
            throw new RuntimeException("Error al listar ubicaciones", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return lista;
    }
}