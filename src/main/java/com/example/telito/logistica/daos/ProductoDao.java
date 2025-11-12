package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ProductoBean;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class ProductoDao extends DAOBase {

    public ArrayList<ProductoBean> listarProductos() {
        // Conexión centralizada

        ArrayList<ProductoBean> listaProductos = new ArrayList<>();
        String sql = "SELECT id_producto, nombre, precio_actual FROM productos WHERE activo = 1 ORDER BY nombre ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProductoBean producto = new ProductoBean();
                producto.setId(rs.getInt("id_producto"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecio(rs.getDouble("precio_actual"));
                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            logger.error("Error al listar productos", e);
            throw new RuntimeException("Error al listar productos", e);
        } finally {
            closeResources(conn, pstmt, rs);
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

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProductoBean producto = new ProductoBean();
                producto.setId(rs.getInt("id_producto"));
                producto.setCodigo(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecio(rs.getDouble("precio_actual"));
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            logger.error("Error al listar productos por productor: " + productorId, e);
            throw new RuntimeException("Error al listar productos por productor", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaProductos;
    }
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si existe un producto con el ID especificado
     */
    public boolean existeProducto(int productoId) {
        String sql = "SELECT COUNT(*) as total FROM productos WHERE id_producto = ? AND activo = 1";
        
        return count(sql, productoId) > 0;
    }
    
    /**
     * Verifica si un producto pertenece a un productor específico
     */
    public boolean productoPerteneceAProductor(int productoId, int productorId) {
        String sql = "SELECT COUNT(*) as total FROM productos " +
                     "WHERE id_producto = ? AND productor_id = ? AND activo = 1";
        
        return count(sql, productoId, productorId) > 0;
    }
    
    /**
     * Obtiene un producto completo por su ID
     */
    public ProductoBean obtenerProductoPorId(int productoId) {
        String sql = "SELECT id_producto, codigo_sku, nombre, precio_actual, unidades_por_paquete " +
                     "FROM productos WHERE id_producto = ? AND activo = 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                ProductoBean producto = new ProductoBean();
                producto.setId(rs.getInt("id_producto"));
                producto.setCodigo(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecio(rs.getDouble("precio_actual"));
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                return producto;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener producto por ID: " + productoId, e);
            throw new RuntimeException("Error al obtener producto por ID", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }
}