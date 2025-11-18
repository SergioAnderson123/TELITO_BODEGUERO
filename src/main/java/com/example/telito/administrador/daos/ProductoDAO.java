package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Producto;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class ProductoDAO extends DAOBase {

    // Para la tabla de inventario general, carga todos los productos.
    public ArrayList<Producto> listarProductos() {
        ArrayList<Producto> listaProductos = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre as categoria_nombre, " +
                "COALESCE(SUM(l.stock_actual), 0) as stock_total " +
                "FROM productos p " +
                "LEFT JOIN categorias c ON p.categoria_id = c.id_categoria " +
                "LEFT JOIN lotes l ON p.id_producto = l.producto_id " +
                "WHERE p.activo = 1 " +
                "GROUP BY p.id_producto " +
                "ORDER BY p.nombre";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("id_producto"));
                producto.setCodigoSku(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setDescripcion(rs.getString("descripcion"));
                producto.setPrecioActual(rs.getDouble("precio_actual"));
                producto.setStock(rs.getInt("stock_total")); // Stock calculado desde lotes
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                producto.setProductorId(rs.getInt("productor_id"));
                producto.setCategoriaId(rs.getInt("categoria_id"));
                producto.setCategoriaNombre(rs.getString("categoria_nombre"));
                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            logger.error("Error al listar productos", e);
            throw new RuntimeException("Error al listar productos", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return listaProductos;
    }

    // Permite cambiar el stock mínimo de un producto desde la tabla de inventario.
    public void actualizarStockMinimo(int productoId, int stockMinimo) {
        String sql = "UPDATE productos SET stock_minimo = ? WHERE id_producto = ?";
        executeUpdate(sql, stockMinimo, productoId);
    }

    // Este es para una de las alertas, cuenta productos con stock por debajo del mínimo.
    public int contarProductosConAlertaDeStock() {
        String sql = "SELECT COUNT(*) FROM productos WHERE stock <= stock_minimo AND stock_minimo > 0";
        return count(sql);
    }
    
    /**
     * Verifica si existe un producto activo con el SKU especificado.
     * @param codigoSKU Código SKU del producto
     * @return true si existe, false en caso contrario
     */
    public boolean existeProductoPorSKU(String codigoSKU) {
        String sql = "SELECT COUNT(*) FROM productos WHERE codigo_sku = ? AND activo = 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, codigoSKU);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            logger.error("Error al verificar existencia de producto por SKU: " + codigoSKU, e);
            throw new RuntimeException("Error al verificar existencia de producto", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return false;
    }
    
    /**
     * Obtiene un producto por su código SKU.
     * @param codigoSKU Código SKU del producto
     * @return Producto si existe, null en caso contrario
     */
    public com.example.telito.administrador.beans.Producto obtenerProductoPorSKU(String codigoSKU) {
        String sql = "SELECT * FROM productos WHERE codigo_sku = ? AND activo = 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, codigoSKU);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                com.example.telito.administrador.beans.Producto producto = new com.example.telito.administrador.beans.Producto();
                producto.setIdProducto(rs.getInt("id_producto"));
                producto.setCodigoSku(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setDescripcion(rs.getString("descripcion"));
                java.math.BigDecimal precio = rs.getBigDecimal("precio_actual");
                producto.setPrecioActual(precio != null ? precio.doubleValue() : 0.0);
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                producto.setProductorId(rs.getInt("productor_id"));
                producto.setCategoriaId(rs.getInt("categoria_id"));
                producto.setActivo(rs.getBoolean("activo"));
                return producto;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener producto por SKU: " + codigoSKU, e);
            throw new RuntimeException("Error al obtener producto por SKU", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return null;
    }
}