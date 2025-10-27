package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ProductoBean;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;

public class ProductoDao {

    public ArrayList<ProductoBean> listarProductos() {
        // Conexión centralizada

        ArrayList<ProductoBean> listaProductos = new ArrayList<>();
        String sql = "SELECT id_producto, nombre, precio_actual FROM productos WHERE activo = 1 ORDER BY nombre ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ProductoBean producto = new ProductoBean();
                producto.setId(rs.getInt("id_producto"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecio(rs.getDouble("precio_actual"));
                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaProductos;
    }
    
    // Listar productos de un productor específico
    public ArrayList<ProductoBean> listarProductosPorProductor(int productorId) {
        ArrayList<ProductoBean> listaProductos = new ArrayList<>();
        String sql = "SELECT id_producto, codigo_sku, nombre, precio_actual, unidades_por_paquete " +
                     "FROM productos " +
                     "WHERE productor_id = ? AND activo = 1 " +
                     "ORDER BY nombre ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productorId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ProductoBean producto = new ProductoBean();
                    producto.setId(rs.getInt("id_producto"));
                    producto.setCodigo(rs.getString("codigo_sku"));
                    producto.setNombre(rs.getString("nombre"));
                    producto.setPrecio(rs.getDouble("precio_actual"));
                    producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                    listaProductos.add(producto);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaProductos;
    }
}