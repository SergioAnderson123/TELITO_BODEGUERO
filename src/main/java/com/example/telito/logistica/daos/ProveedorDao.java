package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ProveedorBean;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;

public class ProveedorDao {

    public ArrayList<ProveedorBean> listarProveedores() {
        ArrayList<ProveedorBean> listaProveedores = new ArrayList<>();
        String sql = "SELECT id_proveedor, nombre FROM proveedores ORDER BY nombre ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ProveedorBean proveedor = new ProveedorBean();
                proveedor.setId(rs.getInt("id_proveedor"));
                proveedor.setNombre(rs.getString("nombre"));
                listaProveedores.add(proveedor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaProveedores;
    }
    
    // Listar solo productores (usuarios con rol_id = 3) como proveedores
    public ArrayList<ProveedorBean> listarProductores() {
        ArrayList<ProveedorBean> listaProductores = new ArrayList<>();
        String sql = "SELECT u.id_usuario, CONCAT(u.nombres, ' ', u.apellidos) as nombre_completo " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "ORDER BY u.nombres ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ProveedorBean productor = new ProveedorBean();
                productor.setId(rs.getInt("id_usuario"));
                productor.setNombre(rs.getString("nombre_completo"));
                listaProductores.add(productor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaProductores;
    }
}