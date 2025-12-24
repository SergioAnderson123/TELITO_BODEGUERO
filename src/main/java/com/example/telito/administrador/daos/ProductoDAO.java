package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Producto;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de productos
public class ProductoDAO extends DAOBase {

    // Lista todos los productos activos con stock total calculado desde lotes
    // Solo muestra productos de productores activos
    public ArrayList<Producto> listarProductos() {
        ArrayList<Producto> listaProductos = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre as categoria_nombre, " +
                "COALESCE(SUM(l.stock_actual), 0) as stock_total " +
                "FROM productos p " +
                "INNER JOIN usuarios u ON p.productor_id = u.id_usuario " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                "LEFT JOIN categorias c ON p.categoria_id = c.id_categoria " +
                "LEFT JOIN lotes l ON p.id_producto = l.producto_id " +
                "WHERE p.activo = 1 AND u.activo = 1 AND r.nombre = 'Productor' " +
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
                producto.setStock(rs.getInt("stock_total")); // Stock sumado desde lotes
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

    // Actualiza el stock mínimo de un producto
    public void actualizarStockMinimo(int productoId, int stockMinimo) {
        String sql = "UPDATE productos SET stock_minimo = ? WHERE id_producto = ?";
        executeUpdate(sql, stockMinimo, productoId);
    }

    // Cuenta productos con stock por debajo del mínimo (para alertas)
    public int contarProductosConAlertaDeStock() {
        String sql = "SELECT COUNT(*) FROM productos WHERE stock <= stock_minimo AND stock_minimo > 0";
        return count(sql);
    }
    
    // Verifica si existe un producto activo con el SKU dado
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

    /**
     * Lista todos los productos de un productor específico con stock total calculado desde lotes.
     * @param productorId ID del productor
     * @return Lista de productos del productor
     */
    public ArrayList<Producto> listarProductosPorProductor(int productorId) {
        ArrayList<Producto> listaProductos = new ArrayList<>();
        String sql = "SELECT p.*, c.nombre as categoria_nombre, " +
                "COALESCE(SUM(l.stock_actual), 0) as stock_total " +
                "FROM productos p " +
                "LEFT JOIN categorias c ON p.categoria_id = c.id_categoria " +
                "LEFT JOIN lotes l ON p.id_producto = l.producto_id " +
                "WHERE p.activo = 1 AND p.productor_id = ? " +
                "GROUP BY p.id_producto " +
                "ORDER BY p.nombre";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("id_producto"));
                producto.setCodigoSku(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setDescripcion(rs.getString("descripcion"));
                producto.setPrecioActual(rs.getDouble("precio_actual"));
                producto.setStock(rs.getInt("stock_total")); // Stock sumado desde lotes
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));
                producto.setProductorId(rs.getInt("productor_id"));
                producto.setCategoriaId(rs.getInt("categoria_id"));
                producto.setCategoriaNombre(rs.getString("categoria_nombre"));
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

    /**
     * Busca productos por SKU o nombre (búsqueda parcial).
     * Solo retorna productos del productor especificado.
     * @param termino Término de búsqueda (SKU o nombre)
     * @param productorId ID del productor
     * @return Lista de productos que coinciden
     */
    public ArrayList<com.example.telito.administrador.beans.Producto> buscarProductosPorSKUoNombre(String termino, int productorId) {
        ArrayList<com.example.telito.administrador.beans.Producto> lista = new ArrayList<>();
        
        String sql = "SELECT p.*, c.nombre as categoria_nombre, " +
                "(SELECT COUNT(*) FROM lotes WHERE producto_id = p.id_producto AND estado = 'Disponible') as numero_lotes " +
                "FROM productos p " +
                "LEFT JOIN categorias c ON p.categoria_id = c.id_categoria " +
                "WHERE (p.codigo_sku LIKE ? OR p.nombre LIKE ?) " +
                "AND p.productor_id = ? " +
                "AND p.activo = 1 " +
                "ORDER BY p.nombre";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            String pattern = "%" + termino + "%";
            pstmt.setString(1, pattern);
            pstmt.setString(2, pattern);
            pstmt.setInt(3, productorId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
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
                producto.setCategoriaNombre(rs.getString("categoria_nombre"));
                producto.setNumeroLotes(rs.getInt("numero_lotes"));
                
                // Crear objeto Categoria si existe
                String catNombre = rs.getString("categoria_nombre");
                if (catNombre != null && !catNombre.isEmpty()) {
                    com.example.telito.administrador.beans.Categoria categoria = new com.example.telito.administrador.beans.Categoria();
                    categoria.setIdCategoria(rs.getInt("categoria_id"));
                    categoria.setNombre(catNombre);
                    producto.setCategoria(categoria);
                }
                
                lista.add(producto);
            }
        } catch (SQLException e) {
            logger.error("Error al buscar productos por SKU o nombre: " + termino, e);
            throw new RuntimeException("Error al buscar productos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return lista;
    }
    
    // Contar total de productos activos (de productores activos)
    public int contarProductosActivos() {
        String sql = "SELECT COUNT(*) as total " +
                    "FROM productos p " +
                    "INNER JOIN usuarios u ON p.productor_id = u.id_usuario " +
                    "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                    "WHERE p.activo = 1 AND u.activo = 1 AND r.nombre = 'Productor'";
        
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            logger.error("Error al contar productos activos", e);
            throw new RuntimeException("Error al contar productos activos", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }
    
    // Contar productos activos sin configuración de stock mínimo
    public int contarProductosSinConfiguracion() {
        String sql = "SELECT COUNT(*) as total " +
                    "FROM productos p " +
                    "INNER JOIN usuarios u ON p.productor_id = u.id_usuario " +
                    "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                    "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                    "WHERE p.activo = 1 AND u.activo = 1 AND r.nombre = 'Productor' " +
                    "AND smc.id_stock_minimo IS NULL";
        
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            logger.error("Error al contar productos sin configuración", e);
            throw new RuntimeException("Error al contar productos sin configuración", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }
}
