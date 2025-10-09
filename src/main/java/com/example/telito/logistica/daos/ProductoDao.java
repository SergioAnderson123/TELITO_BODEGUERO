package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ProductoBean;
import java.sql.*;
import java.util.ArrayList;

public class ProductoDao {

    public ArrayList<ProductoBean> listarProductos() {
        // Añadimos la lógica de conexión igual que en tus otros DAOs
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        ArrayList<ProductoBean> listaProductos = new ArrayList<>();
        String sql = "SELECT id_producto, nombre, precio_unitario FROM productos ORDER BY nombre ASC";

        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ProductoBean producto = new ProductoBean();
                producto.setId(rs.getInt("id_producto"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecio(rs.getBigDecimal("precio_unitario"));
                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaProductos;
    }
}