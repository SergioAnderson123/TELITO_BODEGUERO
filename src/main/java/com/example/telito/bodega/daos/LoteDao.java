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

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error al cargar el driver de MySQL", e);
        }
    }

    /**
     * MÉTODO CORREGIDO
     * Registra un nuevo lote creado por un productor.
     * Asigna el estado 'No Registrado' por defecto.
     * Ahora requiere los IDs de ubicación y distrito.
     */
    public boolean registrarLote(String codigoLote, int productoId, int cantidadStock,
                                 String fechaCaducidad, int ubicacionId, int distritoId) {

        // Se añaden las columnas 'distrito_id' y 'estado' al INSERT
        String sql = "INSERT INTO lotes (codigo_lote, producto_id, stock_actual, fecha_vencimiento, ubicacion_id, distrito_id, estado) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'No Registrado')";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, codigoLote);
            pstmt.setInt(2, productoId);
            pstmt.setInt(3, cantidadStock);

            if (fechaCaducidad != null && !fechaCaducidad.isEmpty()) {
                pstmt.setDate(4, java.sql.Date.valueOf(fechaCaducidad));
            } else {
                pstmt.setNull(4, java.sql.Types.DATE);
            }

            pstmt.setInt(5, ubicacionId);
            pstmt.setInt(6, distritoId);

            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("ERROR: Error al registrar el lote: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Sobrecarga compatible con el otro proyecto: recibe SKU y nombre de distrito,
     * resuelve los IDs internamente y registra el lote.
     */
    public boolean registrarLote(String codigoLote, String skuProducto, int cantidadStock,
                                 String fechaCaducidad, String distritoNombre) {
        int productoId = obtenerIdProductoPorSKU(skuProducto);
        if (productoId == 0) {
            return false;
        }
        int ubicacionId = obtenerOCrearUbicacion(distritoNombre);
        if (ubicacionId == 0) {
            return false;
        }
        int distritoId = obtenerOCrearDistrito(distritoNombre);
        if (distritoId == 0) {
            return false;
        }

        String sql = "INSERT INTO lotes (codigo_lote, producto_id, ubicacion_id, stock_actual, fecha_vencimiento, estado, distrito_id) VALUES (?, ?, ?, ?, ?, 'No Registrado', ?)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, codigoLote);
            pstmt.setInt(2, productoId);
            pstmt.setInt(3, ubicacionId);
            pstmt.setInt(4, cantidadStock);

            if (fechaCaducidad != null && !fechaCaducidad.isEmpty()) {
                try {
                    // Intento formato ISO (yyyy-MM-dd) que envía <input type="date">
                    pstmt.setDate(5, java.sql.Date.valueOf(fechaCaducidad));
                } catch (IllegalArgumentException ex) {
                    // Intento dd/MM/yyyy por si el navegador envía ese formato
                    try {
                        String[] p = fechaCaducidad.split("/");
                        if (p.length == 3) {
                            String iso = p[2] + "-" + (p[1].length()==1? ("0"+p[1]) : p[1]) + "-" + (p[0].length()==1? ("0"+p[0]) : p[0]);
                            pstmt.setDate(5, java.sql.Date.valueOf(iso));
                        } else {
                            pstmt.setNull(5, java.sql.Types.DATE);
                        }
                    } catch (Exception e2) {
                        pstmt.setNull(5, java.sql.Types.DATE);
                    }
                }
            } else {
                pstmt.setNull(5, java.sql.Types.DATE);
            }
            pstmt.setInt(6, distritoId);

            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("ERROR: Error al registrar el lote (simple): " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Obtiene o crea un distrito y retorna su ID
    private int obtenerOCrearDistrito(String nombreDistrito) {
        int distritoId = 0;
        String sqlSelect = "SELECT idDistrito FROM distritos WHERE nombre = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sqlSelect)) {
            pstmt.setString(1, nombreDistrito);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    distritoId = rs.getInt("idDistrito");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al buscar distrito: " + e.getMessage());
        }

        if (distritoId == 0) {
            String sqlInsert = "INSERT INTO distritos (nombre) VALUES (?)";
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 PreparedStatement pstmt = conn.prepareStatement(sqlInsert, PreparedStatement.RETURN_GENERATED_KEYS)) {
                pstmt.setString(1, nombreDistrito);
                if (pstmt.executeUpdate() > 0) {
                    try (ResultSet keys = pstmt.getGeneratedKeys()) {
                        if (keys.next()) {
                            distritoId = keys.getInt(1);
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("ERROR: Error al crear distrito: " + e.getMessage());
            }
        }
        return distritoId;
    }

    /**
     * Obtiene el ID del producto por su SKU.
     * (Este método es auxiliar y está correcto)
     */
    public int obtenerIdProductoPorSKU(String sku) {
        int productoId = 0;
        String sql = "SELECT id_producto FROM productos WHERE UPPER(codigo_sku) = UPPER(?) AND activo = 1";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, (sku == null) ? "" : sku.trim());

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    productoId = rs.getInt("id_producto");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al buscar producto por SKU: " + e.getMessage());
            e.printStackTrace();
        }
        return productoId;
    }

    /**
     * Obtiene o crea una ubicación y retorna su ID.
     * (Este método es auxiliar y está correcto)
     */
    public int obtenerOCrearUbicacion(String nombreUbicacion) {
        int ubicacionId = 0;
        String sqlSelect = "SELECT id_ubicacion FROM ubicaciones WHERE nombre = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sqlSelect)) {
            pstmt.setString(1, nombreUbicacion);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ubicacionId = rs.getInt("id_ubicacion");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al buscar ubicación: " + e.getMessage());
        }

        if (ubicacionId == 0) {
            String sqlInsert = "INSERT INTO ubicaciones (nombre) VALUES (?)";
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 PreparedStatement pstmt = conn.prepareStatement(sqlInsert, PreparedStatement.RETURN_GENERATED_KEYS)) {
                pstmt.setString(1, nombreUbicacion);
                if (pstmt.executeUpdate() > 0) {
                    try (ResultSet keys = pstmt.getGeneratedKeys()) {
                        if (keys.next()) {
                            ubicacionId = keys.getInt(1);
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("ERROR: Error al crear ubicación: " + e.getMessage());
            }
        }
        return ubicacionId;
    }

    // --- EL RESTO DE MÉTODOS NO NECESITAN CAMBIOS ---

    public String obtenerNombreProductoPorSKU(String sku) {
        String nombreProducto = null;
        String sql = "SELECT nombre FROM productos WHERE UPPER(codigo_sku) = UPPER(?)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, (sku == null) ? null : sku.trim());
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    nombreProducto = rs.getString("nombre");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al buscar nombre del producto: " + e.getMessage());
        }
        return nombreProducto;
    }

    public List<Object[]> listarLotesPorProductor(int productorId) {
        List<Object[]> lotes = new ArrayList<>();
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
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al listar lotes: " + e.getMessage());
        }
        return lotes;
    }

    public int obtenerStockTotalProducto(int productoId) {
        int stockTotal = 0;
        String sql = "SELECT SUM(stock_actual) as stock_total FROM lotes WHERE producto_id = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productoId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stockTotal = rs.getInt("stock_total");
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al obtener stock total: " + e.getMessage());
        }
        return stockTotal;
    }
}