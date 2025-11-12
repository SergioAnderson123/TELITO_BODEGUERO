package com.example.telito.productor.daos;

import com.example.telito.productor.beans.Categoria;
import com.example.telito.productor.beans.Producto;
import com.example.telito.productor.beans.Usuario;
import com.example.telito.util.DAOBase;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * Esta clase se encarga de todas las operaciones relacionadas con
 * los productos en la base de datos.
 */
public class ProductoDao extends DAOBase {

    /**
     * Lista productos de un productor con paginación, incluyendo su categoría,
     * stock total y número de lotes. Optimizado para evitar consultas N+1.
     * @param productorId El ID del usuario productor.
     * @param offset Número de registros a saltar.
     * @param limit Número máximo de registros a retornar.
     * @return Una lista de objetos Producto.
     */
    public ArrayList<Producto> listarProductosPorProductor(int productorId, int offset, int limit) {
        ArrayList<Producto> listaProductos = new ArrayList<>();

        String sql = "SELECT p.*, c.id_categoria, c.nombre as categoria_nombre, " +
                "u.id_usuario, u.nombres, u.apellidos, " +
                "IFNULL(l_sum.stock_total, 0) as stock_total, " +
                "COUNT(DISTINCT CASE " +
                "    WHEN lotes.id_lote IS NOT NULL AND lotes.stock_actual > 0 " +
                "    THEN lotes.id_lote " +
                "END) as numero_lotes " +
                "FROM productos p " +
                "INNER JOIN categorias c ON (p.categoria_id = c.id_categoria) " +
                "INNER JOIN usuarios u ON (p.productor_id = u.id_usuario) " +
                "LEFT JOIN (SELECT producto_id, SUM(stock_actual) as stock_total FROM lotes WHERE stock_actual > 0 GROUP BY producto_id) l_sum ON (p.id_producto = l_sum.producto_id) " +
                "LEFT JOIN lotes ON p.id_producto = lotes.producto_id " +
                "WHERE p.productor_id = ? AND u.activo = 1 AND p.activo = 1 " +
                "GROUP BY p.id_producto " +
                "ORDER BY p.id_producto DESC " +
                "LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("id_producto"));
                producto.setCodigoSKU(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setDescripcion(rs.getString("descripcion"));
                producto.setPrecioActual(rs.getDouble("precio_actual"));
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));

                producto.setStockTotal(rs.getDouble("stock_total"));
                producto.setNumeroLotes(rs.getInt("numero_lotes"));

                Categoria categoria = new Categoria();
                categoria.setIdCategoria(rs.getInt("id_categoria"));
                categoria.setNombre(rs.getString("categoria_nombre"));
                producto.setCategoria(categoria);

                Usuario productor = new Usuario();
                productor.setIdUsuario(rs.getInt("id_usuario"));
                productor.setNombres(rs.getString("nombres"));
                productor.setApellidos(rs.getString("apellidos"));
                producto.setProductor(productor);

                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            logger.error("Error al listar los productos", e);
            throw new RuntimeException("Error al listar los productos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaProductos;
    }

    /**
     * Lista todos los productos de un productor específico, incluyendo su categoría,
     * stock total y número de lotes. Optimizado para evitar consultas N+1.
     * @param productorId El ID del usuario productor.
     * @return Una lista de objetos Producto.
     */
    public ArrayList<Producto> listarProductosPorProductor(int productorId) {
        ArrayList<Producto> listaProductos = new ArrayList<>();

        String sql = "SELECT p.*, c.id_categoria, c.nombre as categoria_nombre, " +
                "u.id_usuario, u.nombres, u.apellidos, " +
                "IFNULL(l_sum.stock_total, 0) as stock_total, " +
                "COUNT(DISTINCT CASE " +
                "    WHEN lotes.id_lote IS NOT NULL AND lotes.stock_actual > 0 " +
                "    THEN lotes.id_lote " +
                "END) as numero_lotes " +
                "FROM productos p " +
                "INNER JOIN categorias c ON (p.categoria_id = c.id_categoria) " +
                "INNER JOIN usuarios u ON (p.productor_id = u.id_usuario) " +
                "LEFT JOIN (SELECT producto_id, SUM(stock_actual) as stock_total FROM lotes WHERE stock_actual > 0 GROUP BY producto_id) l_sum ON (p.id_producto = l_sum.producto_id) " +
                "LEFT JOIN lotes ON p.id_producto = lotes.producto_id " +
                "WHERE p.productor_id = ? AND u.activo = 1 AND p.activo = 1 " +
                "GROUP BY p.id_producto";

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
                producto.setCodigoSKU(rs.getString("codigo_sku"));
                producto.setNombre(rs.getString("nombre"));
                producto.setDescripcion(rs.getString("descripcion"));
                producto.setPrecioActual(rs.getDouble("precio_actual"));
                producto.setUnidadesPorPaquete(rs.getInt("unidades_por_paquete"));

                // Asegúrate de que tu clase Producto.java tenga estos campos y sus setters.
                producto.setStockTotal(rs.getDouble("stock_total"));
                producto.setNumeroLotes(rs.getInt("numero_lotes"));

                Categoria categoria = new Categoria();
                categoria.setIdCategoria(rs.getInt("id_categoria"));
                categoria.setNombre(rs.getString("categoria_nombre"));
                producto.setCategoria(categoria);

                Usuario productor = new Usuario();
                productor.setIdUsuario(rs.getInt("id_usuario"));
                productor.setNombres(rs.getString("nombres"));
                productor.setApellidos(rs.getString("apellidos"));
                producto.setProductor(productor);

                listaProductos.add(producto);
            }
        } catch (SQLException e) {
            logger.error("Error al listar los productos", e);
            throw new RuntimeException("Error al listar los productos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaProductos;
    }

    /**
     * Genera un nuevo SKU automático en formato SKU001, SKU002, etc.
     * Busca el último SKU registrado y genera el siguiente número correlativo.
     * @return String con el nuevo SKU generado (ej: "SKU015")
     */
    public String generarNuevoSKU() {
        String sql = "SELECT codigo_sku FROM productos WHERE codigo_sku LIKE 'SKU%' ORDER BY id_producto DESC LIMIT 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String ultimoSKU = rs.getString("codigo_sku");
                // Extraer el número del SKU (ej: "SKU015" -> 15)
                String numeroStr = ultimoSKU.replaceAll("[^0-9]", "");
                
                if (!numeroStr.isEmpty()) {
                    int ultimoNumero = Integer.parseInt(numeroStr);
                    int nuevoNumero = ultimoNumero + 1;
                    // Formatear con ceros a la izquierda (3 dígitos)
                    return String.format("SKU%03d", nuevoNumero);
                }
            }
            
            // Si no hay SKUs previos, empezar desde SKU001
            return "SKU001";
            
        } catch (SQLException e) {
            logger.error("Error al generar nuevo SKU", e);
            // En caso de error, generar un SKU con timestamp para evitar conflictos
            return "SKU" + System.currentTimeMillis();
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    /**
     * Inserta un nuevo producto en la base de datos.
     * @param producto Objeto Producto con todos los datos necesarios.
     */
    public void crearProducto(Producto producto) {
        String sql = "INSERT INTO productos (codigo_sku, nombre, descripcion, precio_actual, unidades_por_paquete, productor_id, categoria_id) VALUES (?, ?, ?, ?, ?, ?, ?)";

        executeUpdate(sql,
            producto.getCodigoSKU(),
            producto.getNombre(),
            producto.getDescripcion(),
            producto.getPrecioActual(),
            producto.getUnidadesPorPaquete(),
            producto.getProductor().getIdUsuario(),
            producto.getCategoria().getIdCategoria());
    }

    public int contarTotalProductos(int productorId) {
        String sql = "SELECT COUNT(*) FROM productos p JOIN usuarios u ON p.productor_id = u.id_usuario WHERE productor_id = ? AND u.activo = 1 AND p.activo = 1";
        return count(sql, productorId);
    }

    public int contarTotalCategorias(int productorId) {
        String sql = "SELECT COUNT(DISTINCT categoria_id) FROM productos p JOIN usuarios u WHERE p.productor_id = ? AND u.activo = 1 AND p.activo = 1";
        return count(sql, productorId);
    }

    public int contarProductosFueraDeStock(int productorId) {
        String sql = "SELECT COUNT(DISTINCT p.id_producto) " +
                "FROM productos p " +
                "JOIN usuarios u ON p.productor_id = u.id_usuario " +
                "LEFT JOIN (SELECT producto_id, SUM(stock_actual) as stock_total FROM lotes GROUP BY producto_id) l " +
                "ON (p.id_producto = l.producto_id) " +
                "WHERE p.productor_id = ? AND u.activo = 1 AND p.activo = 1 AND (l.stock_total IS NULL OR l.stock_total = 0)";
        return count(sql, productorId);
    }

    public Producto obtenerProductoPorSku(String sku) {
        String sql = "SELECT p.* FROM productos p JOIN usuarios u ON p.productor_id = u.id_usuario WHERE p.codigo_sku = ? AND p.activo = 1 AND u.activo = 1";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, sku);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Producto producto = new Producto();
                producto.setIdProducto(rs.getInt("id_producto"));
                producto.setNombre(rs.getString("nombre"));
                producto.setPrecioActual(rs.getDouble("precio_actual"));
                return producto;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener producto por SKU: " + sku, e);
            throw new RuntimeException("Error al obtener producto por SKU", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }

    public void actualizarPrecio(int idProducto, double nuevoPrecio) {
        String sql = "UPDATE productos SET precio_actual = ? WHERE id_producto = ?";
        executeUpdate(sql, nuevoPrecio, idProducto);
    }

    /**
     * Desactiva un producto (soft delete) cambiando activo = 0.
     * @param idProducto El ID del producto a desactivar.
     * @return true si la operación fue exitosa, false en caso contrario.
     */
    public boolean desactivarProducto(int idProducto) {
        String sql = "UPDATE productos SET activo = 0 WHERE id_producto = ?";
        int filasAfectadas = executeUpdate(sql, idProducto);
        return filasAfectadas > 0;
    }

    /**
     * Obtiene todas las categorías disponibles para poblar dropdowns.
     * @return Una lista de objetos Categoria.
     */
    public ArrayList<Categoria> listarTodasLasCategorias() {
        ArrayList<Categoria> categorias = new ArrayList<>();
        String sql = "SELECT id_categoria, nombre FROM categorias ORDER BY nombre ASC";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Categoria categoria = new Categoria();
                categoria.setIdCategoria(rs.getInt("id_categoria"));
                categoria.setNombre(rs.getString("nombre"));
                categorias.add(categoria);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todas las categorías", e);
            throw new RuntimeException("Error al listar todas las categorías", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return categorias;
    }
}

