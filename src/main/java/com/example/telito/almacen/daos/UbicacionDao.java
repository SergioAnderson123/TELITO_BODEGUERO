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
    
    /**
     * Verifica si existe una ubicación con el nombre especificado.
     * @param nombre Nombre de la ubicación
     * @return true si existe, false en caso contrario
     */
    public boolean existeUbicacionPorNombre(String nombre) {
        String sql = "SELECT COUNT(*) FROM ubicaciones WHERE nombre = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, nombre);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            logger.error("Error al verificar existencia de ubicación por nombre: " + nombre, e);
            throw new RuntimeException("Error al verificar existencia de ubicación", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return false;
    }
}