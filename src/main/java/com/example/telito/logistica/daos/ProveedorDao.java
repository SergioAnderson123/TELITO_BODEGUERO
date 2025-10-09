package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ProveedorBean;
import java.sql.*;
import java.util.ArrayList;

public class ProveedorDao {

    public ArrayList<ProveedorBean> listarProveedores() {
        // Añadimos la lógica de conexión igual que en tus otros DAOs
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        ArrayList<ProveedorBean> listaProveedores = new ArrayList<>();
        String sql = "SELECT id_proveedor, nombre FROM proveedores ORDER BY nombre ASC";

        try (Connection conn = DriverManager.getConnection(url, username, password);
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
}