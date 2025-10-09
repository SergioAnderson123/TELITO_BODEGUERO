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

    // Datos de conexión. Es una buena práctica tenerlos como atributos de la clase.
    private String user = "root";
    private String pass = "root"; // ¡Asegúrate de que sea tu contraseña de MySQL!
    private String url = "jdbc:mysql://127.0.0.1:3306/telito4?useSSL=false&serverTimezone=UTC";

    // --- MÉTODO PARA LISTAR PRODUCTOS ---
    public ArrayList<Producto> listarProductosPorProductor(int productorId) {

        ArrayList<Producto> listaProductos = new ArrayList<>();

        try { // Paso 1: Cargar el driver de MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        // Consulta SQL que une productos, categorías y calcula el stock desde lotes
        String sql = "SELECT p.*, c.id_categoria, c.nombre as categoria_nombre, u.id_usuario, u.nombres, u.apellidos, IFNULL(l.stock_total, 0) as stock_total " +
                "FROM productos p " +
                "INNER JOIN categorias c ON (p.categoria_id = c.id_categoria) " +
                "INNER JOIN usuarios u ON (p.productor_id = u.id_usuario) " +
                "LEFT JOIN (SELECT producto_id, SUM(stock_actual) as stock_total FROM lotes GROUP BY producto_id) l " +
                "ON (p.id_producto = l.producto_id) " +
                "WHERE p.productor_id = ? AND p.activo = 1";

        // Paso 2: Conectar a la BD y ejecutar la consulta
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productorId);

            try (ResultSet rs = pstmt.executeQuery()) {
                // Paso 3: Llenar la lista con los resultados
                while (rs.next()) {
                    Producto producto = new Producto();
                    producto.setIdProducto(rs.getInt("id_producto"));
                    producto.setCodigoSKU(rs.getString("codigo_sku"));
                    producto.setNombre(rs.getString("nombre"));
                    producto.setPrecioActual(rs.getDouble("precio_actual"));
                    //producto.setStock(rs.getInt("stock_total"));

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
            e.printStackTrace();
        }
        return listaProductos;
    }

    // --- MÉTODO PARA CREAR PRODUCTO ---
    public void crearProducto(Producto producto) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        // El SQL para insertar un nuevo producto. Los '?' son placeholders.
        String sql = "INSERT INTO productos (codigo_sku, nombre, descripcion, precio_actual, productor_id, categoria_id, activo) VALUES (?, ?, ?, ?, ?, ?, 1)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Asignamos los valores del objeto 'producto' a los '?' del SQL.
            pstmt.setString(1, producto.getCodigoSKU());
            pstmt.setString(2, producto.getNombre());
            pstmt.setString(3, producto.getDescripcion());
            pstmt.setDouble(4, producto.getPrecioActual());

            // Obtenemos los IDs de los objetos anidados
            pstmt.setInt(5, producto.getProductor().getIdUsuario());
            pstmt.setInt(6, producto.getCategoria().getIdCategoria());

            // Ejecutamos la sentencia de inserción.
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // --- MÉTODO PARA LA TARJETA "TOTAL DE PRODUCTOS" ---
    public int contarTotalProductos(int productorId) {
        int total = 0;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String sql = "SELECT COUNT(*) FROM productos WHERE productor_id = ? AND activo = 1";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productorId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1); // El resultado es un solo número en la primera columna
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // --- MÉTODO PARA LA TARJETA "CATEGORÍAS" ---
    public int contarTotalCategorias(int productorId) {
        int total = 0;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String sql = "SELECT COUNT(DISTINCT categoria_id) FROM productos WHERE productor_id = ? AND activo = 1";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productorId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // --- MÉTODO PARA LA TARJETA "FUERA DE STOCK" ---
    public int contarProductosFueraDeStock(int productorId) {
        int total = 0;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        // Consulta que busca productos sin lotes o con stock total = 0
        String sql = "SELECT COUNT(DISTINCT p.id_producto) " +
                "FROM productos p " +
                "LEFT JOIN (SELECT producto_id, SUM(stock_actual) as stock_total FROM lotes GROUP BY producto_id) l " +
                "ON (p.id_producto = l.producto_id) " +
                "WHERE p.productor_id = ? AND p.activo = 1 AND (l.stock_total IS NULL OR l.stock_total = 0)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productorId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // --- MÉTODO PARA BUSCAR UN PRODUCTO POR SKU ---
    public Producto obtenerProductoPorSku(String sku) {
        Producto producto = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String sql = "SELECT * FROM productos WHERE codigo_sku = ? AND activo = 1";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, sku);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    producto = new Producto();
                    producto.setIdProducto(rs.getInt("id_producto"));
                    producto.setNombre(rs.getString("nombre"));
                    producto.setPrecioActual(rs.getDouble("precio_actual"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return producto;
    }

    // --- MÉTODO PARA ACTUALIZAR EL PRECIO DE UN PRODUCTO ---
    public void actualizarPrecio(int idProducto, double nuevoPrecio) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String sql = "UPDATE productos SET precio_actual = ? WHERE id_producto = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setDouble(1, nuevoPrecio);
            pstmt.setInt(2, idProducto);
            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Desactiva un producto (soft delete) cambiando activo = 0
     */
    public boolean desactivarProducto(int idProducto) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String sql = "UPDATE productos SET activo = 0 WHERE id_producto = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);
            int filasAfectadas = pstmt.executeUpdate();
            System.out.println("DEBUG: Producto desactivado. Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.out.println("ERROR: Error al desactivar producto: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Obtiene el número de lotes asociados a un producto
     */
    public int contarLotesPorProducto(int idProducto) {
        int totalLotes = 0;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String sql = "SELECT COUNT(*) as total_lotes FROM lotes WHERE producto_id = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    totalLotes = rs.getInt("total_lotes");
                }
            }
        } catch (SQLException e) {
            System.out.println("ERROR: Error al contar lotes del producto: " + e.getMessage());
            e.printStackTrace();
        }
        
        return totalLotes;
    }

    /**
     * Obtiene todas las categorías disponibles
     */
    public ArrayList<Categoria> listarTodasLasCategorias() {
        ArrayList<Categoria> categorias = new ArrayList<>();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

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
            System.out.println("ERROR: Error al listar categorías: " + e.getMessage());
            e.printStackTrace();
        }
        
        return categorias;
    }

}