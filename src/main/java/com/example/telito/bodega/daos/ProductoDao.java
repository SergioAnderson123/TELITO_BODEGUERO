package com.example.telito.bodega.daos;

import com.example.telito.bodega.beans.Categoria;
import com.example.telito.bodega.beans.Producto;
import com.example.telito.bodega.beans.Usuario;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

/**
 * Esta clase se encarga de todas las operaciones relacionadas con
 * los productos en la base de datos.
 */
public class ProductoDao {

    private final String user = "root";
    private final String pass = "root";
    private final String url = "jdbc:mysql://localhost:3306/telito_bodeguero";

    // --- MEJORA: Carga del driver una sola vez para toda la aplicación ---
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error al cargar el driver de MySQL", e);
        }
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
                "COUNT(DISTINCT lotes.id_lote) as numero_lotes " +
                "FROM productos p " +
                "INNER JOIN categorias c ON (p.categoria_id = c.id_categoria) " +
                "INNER JOIN usuarios u ON (p.productor_id = u.id_usuario) " +
                "LEFT JOIN (SELECT producto_id, SUM(stock_actual) as stock_total FROM lotes GROUP BY producto_id) l_sum ON (p.id_producto = l_sum.producto_id) " +
                "LEFT JOIN lotes ON p.id_producto = lotes.producto_id " +
                "WHERE p.productor_id = ? AND u.activo = 1 AND p.activo = 1 " +
                "GROUP BY p.id_producto";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productorId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Producto producto = new Producto();
                    producto.setIdProducto(rs.getInt("id_producto"));
                    producto.setCodigoSKU(rs.getString("codigo_sku"));
                    producto.setNombre(rs.getString("nombre"));
                    producto.setDescripcion(rs.getString("descripcion"));
                    producto.setPrecioActual(rs.getDouble("precio_actual"));

                    // Asegúrate de que tu clase Producto.java tenga estos campos y sus setters.
                    producto.setStockTotal(rs.getInt("stock_total"));
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
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar los productos", e);
        }
        return listaProductos;
    }

    /**
     * Inserta un nuevo producto en la base de datos.
     * @param producto Objeto Producto con todos los datos necesarios.
     */
    public void crearProducto(Producto producto) {
        String sql = "INSERT INTO productos (codigo_sku, nombre, descripcion, precio_actual, productor_id, categoria_id) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, producto.getCodigoSKU());
            pstmt.setString(2, producto.getNombre());
            pstmt.setString(3, producto.getDescripcion());
            pstmt.setDouble(4, producto.getPrecioActual());
            pstmt.setInt(5, producto.getProductor().getIdUsuario());
            pstmt.setInt(6, producto.getCategoria().getIdCategoria());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error al crear el producto", e);
        }
    }

    public int contarTotalProductos(int productorId) {
        String sql = "SELECT COUNT(*) FROM productos p JOIN usuarios u ON p.productor_id = u.id_usuario WHERE productor_id = ? AND u.activo = 1 AND p.activo = 1";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al contar total de productos", e);
        }
        return 0;
    }

    public int contarTotalCategorias(int productorId) {
        String sql = "SELECT COUNT(DISTINCT categoria_id) FROM productos p JOIN usuarios u WHERE p.productor_id = ? AND u.activo = 1 AND p.activo = 1";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al contar categorías", e);
        }
        return 0;
    }

    public int contarProductosFueraDeStock(int productorId) {
        String sql = "SELECT COUNT(DISTINCT p.id_producto) " +
                "FROM productos p " +
                "JOIN usuarios u ON p.productor_id = u.id_usuario " +
                "LEFT JOIN (SELECT producto_id, SUM(stock_actual) as stock_total FROM lotes GROUP BY producto_id) l " +
                "ON (p.id_producto = l.producto_id) " +
                "WHERE p.productor_id = ? AND u.activo = 1 AND p.activo = 1 AND (l.stock_total IS NULL OR l.stock_total = 0)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al contar productos sin stock", e);
        }
        return 0;
    }

    public Producto obtenerProductoPorSku(String sku) {
        String sql = "SELECT * FROM productos p JOIN usuarios u ON p.productor_id = u.id_usuario WHERE codigo_sku = ? AND activo = 1";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sku);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Producto producto = new Producto();
                    producto.setIdProducto(rs.getInt("id_producto"));
                    producto.setNombre(rs.getString("nombre"));
                    producto.setPrecioActual(rs.getDouble("precio_actual"));
                    return producto;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al obtener producto por SKU", e);
        }
        return null;
    }

    public void actualizarPrecio(int idProducto, double nuevoPrecio) {
        String sql = "UPDATE productos SET precio_actual = ? WHERE id_producto = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setDouble(1, nuevoPrecio);
            pstmt.setInt(2, idProducto);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error al actualizar precio", e);
        }
    }

    /**
     * Desactiva un producto (soft delete) cambiando activo = 0.
     * @param idProducto El ID del producto a desactivar.
     * @return true si la operación fue exitosa, false en caso contrario.
     */
    public boolean desactivarProducto(int idProducto) {
        String sql = "UPDATE productos SET activo = 0 WHERE id_producto = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idProducto);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: Error al desactivar producto: " + e.getMessage());
            return false;
        }
    }

    /**
     * Obtiene todas las categorías disponibles para poblar dropdowns.
     * @return Una lista de objetos Categoria.
     */
    public ArrayList<Categoria> listarTodasLasCategorias() {
        ArrayList<Categoria> categorias = new ArrayList<>();
        String sql = "SELECT id_categoria, nombre FROM categorias ORDER BY nombre ASC";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Categoria categoria = new Categoria();
                    categoria.setIdCategoria(rs.getInt("id_categoria"));
                    categoria.setNombre(rs.getString("nombre"));
                    categorias.add(categoria);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar todas las categorías", e);
        }
        return categorias;
    }
}