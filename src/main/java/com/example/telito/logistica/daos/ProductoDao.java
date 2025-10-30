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
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si existe un producto con el ID especificado
     */
    public boolean existeProducto(int productoId) {
        String sql = "SELECT COUNT(*) as total FROM productos WHERE id_producto = ? AND activo = 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al verificar existencia de producto: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Verifica si un producto pertenece a un productor específico
     */
    public boolean productoPerteneceAProductor(int productoId, int productorId) {
        String sql = "SELECT COUNT(*) as total FROM productos " +
                     "WHERE id_producto = ? AND productor_id = ? AND activo = 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productoId);
            pstmt.setInt(2, productorId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al verificar producto-productor: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Obtiene un producto completo por su ID
     */
    public ProductoBean obtenerProductoPorId(int productoId) {
        String sql = "SELECT id_producto, codigo_sku, nombre, precio_actual, unidades_por_paquete " +
                     "FROM productos WHERE id_producto = ? AND activo = 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ProductoBean producto = new ProductoBean();
                    producto.setId(rs.getInt("id_producto"));
                    producto.setCodigo(rs.getString("codigo_sku"));
                    producto.setNombre(rs.getString("nombre"));
                    producto.setPrecio(rs.getDouble("precio_actual"));
                    producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                    return producto;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener producto por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}