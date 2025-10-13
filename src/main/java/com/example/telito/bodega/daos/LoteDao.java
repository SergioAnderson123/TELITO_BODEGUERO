package com.example.telito.bodega.daos;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Esta clase se encarga de todas las operaciones relacionadas con
 * los lotes en la base de datos.
 */
public class LoteDao {

    // Datos de conexión
    private String user = "root";
    private String pass = "root";
    private String url = "jdbc:mysql://localhost:3306/telito_bodeguero";

    /**
     * Registra un nuevo lote en la base de datos
     */
    public boolean registrarLote(String codigoLote, String skuProducto, int cantidadStock, 
                                String fechaCaducidad, String distrito) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("ERROR: No se pudo cargar el driver MySQL: " + e.getMessage());
            return false;
        }

        // Primero obtenemos el ID del producto por SKU
        int productoId = obtenerIdProductoPorSKU(skuProducto);
        if (productoId == 0) {
            System.out.println("ERROR: No se encontró el producto con SKU: " + skuProducto);
            return false;
        }

        // Obtenemos o creamos la ubicación
        int ubicacionId = obtenerOCrearUbicacion(distrito);
        if (ubicacionId == 0) {
            System.out.println("ERROR: No se pudo obtener/crear la ubicación: " + distrito);
            return false;
        }

        String sql = "INSERT INTO lotes (codigo_lote, producto_id, ubicacion_id, stock_actual, fecha_vencimiento) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, codigoLote);
            pstmt.setInt(2, productoId);
            pstmt.setInt(3, ubicacionId);
            pstmt.setInt(4, cantidadStock);
            
            if (fechaCaducidad != null && !fechaCaducidad.isEmpty()) {
                pstmt.setDate(5, java.sql.Date.valueOf(fechaCaducidad));
            } else {
                pstmt.setNull(5, java.sql.Types.DATE);
            }

            int filasAfectadas = pstmt.executeUpdate();
            System.out.println("DEBUG: Lote registrado exitosamente. Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.out.println("ERROR: Error al registrar el lote: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Obtiene el ID del producto por su SKU
     */
    private int obtenerIdProductoPorSKU(String sku) {
        int productoId = 0;
        
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement("SELECT id_producto FROM productos WHERE codigo_sku = ?")) {

            pstmt.setString(1, sku);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    productoId = rs.getInt("id_producto");
                    System.out.println("DEBUG: Producto encontrado - ID: " + productoId + ", SKU: " + sku);
                } else {
                    System.out.println("DEBUG: No se encontró producto con SKU: " + sku);
                }
            }



        } catch (SQLException e) {
            System.out.println("ERROR: Error al buscar producto por SKU: " + e.getMessage());
            e.printStackTrace();
        }
        
        return productoId;
    }

    /**
     * Obtiene o crea una ubicación y retorna su ID
     */
    private int obtenerOCrearUbicacion(String nombreUbicacion) {
        int ubicacionId = 0;
        
        // Primero intentamos obtener la ubicación existente
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement("SELECT id_ubicacion FROM ubicaciones WHERE nombre = ?")) {

            pstmt.setString(1, nombreUbicacion);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ubicacionId = rs.getInt("id_ubicacion");
                    System.out.println("DEBUG: Ubicación encontrada - ID: " + ubicacionId + ", Nombre: " + nombreUbicacion);
                }
            }
        } catch (SQLException e) {
            System.out.println("ERROR: Error al buscar ubicación: " + e.getMessage());
            e.printStackTrace();
        }

        // Si no existe, la creamos
        if (ubicacionId == 0) {
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 PreparedStatement pstmt = conn.prepareStatement("INSERT INTO ubicaciones (nombre) VALUES (?)", PreparedStatement.RETURN_GENERATED_KEYS)) {

                pstmt.setString(1, nombreUbicacion);
                int filasAfectadas = pstmt.executeUpdate();
                
                if (filasAfectadas > 0) {
                    try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            ubicacionId = generatedKeys.getInt(1);
                            System.out.println("DEBUG: Nueva ubicación creada - ID: " + ubicacionId + ", Nombre: " + nombreUbicacion);
                        }
                    }
                }
            } catch (SQLException e) {
                System.out.println("ERROR: Error al crear ubicación: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        return ubicacionId;
    }

    /**
     * Obtiene el nombre del producto por SKU
     */
    public String obtenerNombreProductoPorSKU(String sku) {
        String nombreProducto = null;
        
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement("SELECT nombre FROM productos WHERE UPPER(codigo_sku) = UPPER(?)")) {

            // Sanitizamos el parámetro: trim y evitamos nulls
            String sanitizedSku = (sku == null) ? null : sku.trim();
            pstmt.setString(1, sanitizedSku);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    nombreProducto = rs.getString("nombre");
                    System.out.println("DEBUG: Nombre del producto encontrado: " + nombreProducto);
                }
            }
        } catch (SQLException e) {
            System.out.println("ERROR: Error al buscar nombre del producto: " + e.getMessage());
            e.printStackTrace();
        }
        
        return nombreProducto;
    }

    /**
     * Lista todos los lotes de un productor específico
     */
    public List<Object[]> listarLotesPorProductor(int productorId) {
        List<Object[]> lotes = new ArrayList<>();
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("ERROR: No se pudo cargar el driver MySQL: " + e.getMessage());
            return lotes;
        }

        String sql = "SELECT l.codigo_lote, p.nombre as producto_nombre, p.codigo_sku, " +
                    "u.nombre as ubicacion, l.stock_actual, l.fecha_vencimiento " +
                    "FROM lotes l " +
                    "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                    "INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                    "WHERE p.productor_id = ? " +
                    "ORDER BY l.codigo_lote DESC";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productorId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Object[] lote = new Object[6];
                    lote[0] = rs.getString("codigo_lote");
                    lote[1] = rs.getString("producto_nombre");
                    lote[2] = rs.getString("codigo_sku");
                    lote[3] = rs.getString("ubicacion");
                    lote[4] = rs.getInt("stock_actual");
                    lote[5] = rs.getDate("fecha_vencimiento");
                    lotes.add(lote);
                }
                System.out.println("DEBUG: Lotes encontrados: " + lotes.size());
            }
        } catch (SQLException e) {
            System.out.println("ERROR: Error al listar lotes: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lotes;
    }

    /**
     * Obtiene el stock total de un producto específico
     */
    public int obtenerStockTotalProducto(int productoId) {
        int stockTotal = 0;
        
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement("SELECT SUM(stock_actual) as stock_total FROM lotes WHERE producto_id = ?")) {

            pstmt.setInt(1, productoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stockTotal = rs.getInt("stock_total");
                    if (rs.wasNull()) {
                        stockTotal = 0;
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("ERROR: Error al obtener stock total: " + e.getMessage());
            e.printStackTrace();
        }
        
        return stockTotal;
    }
}
