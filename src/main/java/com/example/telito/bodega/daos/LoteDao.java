package com.example.telito.bodega.daos;

import com.example.telito.util.DatabaseConnection;

import java.sql.Connection;
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
    // Las credenciales ahora están centralizadas en DatabaseConnection

    /**
     * Genera un nuevo código de lote automático en formato L--0001, L--0002, etc.
     * @return String con el nuevo código generado (ej: "L--0016")
     */
    public String generarNuevoCodigoLote() {
        String sql = "SELECT codigo_lote FROM lotes WHERE codigo_lote LIKE 'L--%' ORDER BY id_lote DESC LIMIT 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                String ultimoCodigo = rs.getString("codigo_lote");
                // Extraer el número del código (ej: "L--0015" -> 15)
                String numeroStr = ultimoCodigo.replaceAll("[^0-9]", "");
                
                if (!numeroStr.isEmpty()) {
                    int ultimoNumero = Integer.parseInt(numeroStr);
                    int nuevoNumero = ultimoNumero + 1;
                    // Formatear con ceros a la izquierda (4 dígitos)
                    return String.format("L--%04d", nuevoNumero);
                }
            }
            
            // Si no hay códigos previos, empezar desde L--0001
            return "L--0001";
            
        } catch (SQLException e) {
            System.err.println("Error al generar nuevo código de lote: " + e.getMessage());
            e.printStackTrace();
            // En caso de error, generar código con timestamp
            return "L--" + System.currentTimeMillis();
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

        try (Connection conn = DatabaseConnection.getConnection();
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
        
        System.out.println("=== DEBUG DAO - REGISTRAR LOTE ===");
        System.out.println("Código Lote: " + codigoLote);
        System.out.println("SKU Producto: " + skuProducto);
        System.out.println("Cantidad Stock: " + cantidadStock);
        System.out.println("Fecha Caducidad: " + fechaCaducidad);
        System.out.println("Distrito Nombre: " + distritoNombre);
        
        int productoId = obtenerIdProductoPorSKU(skuProducto);
        System.out.println("Producto ID obtenido: " + productoId);
        if (productoId == 0) {
            System.err.println("❌ ERROR: No se encontró producto con SKU: " + skuProducto);
            return false;
        }
        
        // Obtener unidades por paquete del producto
        int unidadesPorPaquete = obtenerUnidadesPorPaquete(productoId);
        
        // Calcular stock real: paquetes × unidades por paquete
        int stockReal = cantidadStock * unidadesPorPaquete;
        System.out.println("📦 CÁLCULO: " + cantidadStock + " paquetes × " + unidadesPorPaquete + " unidades = " + stockReal + " unidades totales");
        
        int ubicacionId = obtenerOCrearUbicacion(distritoNombre);
        System.out.println("Ubicación ID obtenido/creado: " + ubicacionId);
        if (ubicacionId == 0) {
            System.err.println("❌ ERROR: No se pudo obtener/crear ubicación: " + distritoNombre);
            return false;
        }
        
        int distritoId = obtenerOCrearDistrito(distritoNombre);
        System.out.println("Distrito ID obtenido/creado: " + distritoId);
        if (distritoId == 0) {
            System.err.println("❌ ERROR: No se pudo obtener/crear distrito: " + distritoNombre);
            return false;
        }

        String sql = "INSERT INTO lotes (codigo_lote, producto_id, ubicacion_id, stock_actual, fecha_vencimiento, estado, distrito_id) VALUES (?, ?, ?, ?, ?, 'No Registrado', ?)";
        System.out.println("SQL: " + sql);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, codigoLote);
            pstmt.setInt(2, productoId);
            pstmt.setInt(3, ubicacionId);
            pstmt.setInt(4, stockReal); // Guardamos el stock calculado (no los paquetes)

            if (fechaCaducidad != null && !fechaCaducidad.isEmpty()) {
                try {
                    // Intento formato ISO (yyyy-MM-dd) que envía <input type="date">
                    pstmt.setDate(5, java.sql.Date.valueOf(fechaCaducidad));
                    System.out.println("Fecha parseada: " + fechaCaducidad);
                } catch (IllegalArgumentException ex) {
                    // Intento dd/MM/yyyy por si el navegador envía ese formato
                    try {
                        String[] p = fechaCaducidad.split("/");
                        if (p.length == 3) {
                            String iso = p[2] + "-" + (p[1].length()==1? ("0"+p[1]) : p[1]) + "-" + (p[0].length()==1? ("0"+p[0]) : p[0]);
                            pstmt.setDate(5, java.sql.Date.valueOf(iso));
                            System.out.println("Fecha parseada (dd/MM/yyyy): " + iso);
                        } else {
                            pstmt.setNull(5, java.sql.Types.DATE);
                            System.out.println("Fecha inválida, usando NULL");
                        }
                    } catch (Exception e2) {
                        pstmt.setNull(5, java.sql.Types.DATE);
                        System.out.println("Fecha inválida, usando NULL");
                    }
                }
            } else {
                pstmt.setNull(5, java.sql.Types.DATE);
                System.out.println("Sin fecha de caducidad");
            }
            pstmt.setInt(6, distritoId);

            int rowsAffected = pstmt.executeUpdate();
            System.out.println("✓ Filas insertadas: " + rowsAffected);
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("❌ ERROR SQL al registrar el lote:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // Obtiene o crea un distrito y retorna su ID
    private int obtenerOCrearDistrito(String nombreDistrito) {
        int distritoId = 0;
        String sqlSelect = "SELECT idDistrito FROM distritos WHERE nombre = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlSelect)) {
            pstmt.setString(1, nombreDistrito);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    distritoId = rs.getInt("idDistrito");
                    System.out.println("✓ Distrito encontrado: " + nombreDistrito + " (ID: " + distritoId + ")");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al buscar distrito: " + e.getMessage());
            e.printStackTrace();
        }

        if (distritoId == 0) {
            // Si no existe, usar zona_id = 5 (Centro) por defecto
            String sqlInsert = "INSERT INTO distritos (nombre, zona_id) VALUES (?, 5)";
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sqlInsert, PreparedStatement.RETURN_GENERATED_KEYS)) {
                pstmt.setString(1, nombreDistrito);
                if (pstmt.executeUpdate() > 0) {
                    try (ResultSet keys = pstmt.getGeneratedKeys()) {
                        if (keys.next()) {
                            distritoId = keys.getInt(1);
                            System.out.println("✓ Distrito creado: " + nombreDistrito + " (ID: " + distritoId + ", zona_id: 5)");
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("❌ ERROR: Error al crear distrito: " + e.getMessage());
                e.printStackTrace();
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
        
        String skuTrimmed = (sku == null) ? "" : sku.trim();
        System.out.println("Buscando producto con SKU: '" + skuTrimmed + "'");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, skuTrimmed);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    productoId = rs.getInt("id_producto");
                    System.out.println("✓ Producto encontrado con SKU '" + skuTrimmed + "' (ID: " + productoId + ")");
                } else {
                    System.err.println("❌ No se encontró producto con SKU '" + skuTrimmed + "'");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR SQL al buscar producto por SKU: " + e.getMessage());
            e.printStackTrace();
        }
        return productoId;
    }

    /**
     * Obtiene las unidades por paquete de un producto
     * @param productoId ID del producto
     * @return Número de unidades por paquete (por defecto 1 si no se encuentra)
     */
    public int obtenerUnidadesPorPaquete(int productoId) {
        int unidadesPorPaquete = 1; // valor por defecto
        String sql = "SELECT unidades_por_paquete FROM productos WHERE id_producto = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    unidadesPorPaquete = rs.getInt("unidades_por_paquete");
                    System.out.println("✓ Unidades por paquete del producto ID " + productoId + ": " + unidadesPorPaquete);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR al obtener unidades por paquete: " + e.getMessage());
            e.printStackTrace();
        }
        
        return unidadesPorPaquete;
    }

    /**
     * Obtiene o crea una ubicación y retorna su ID.
     * (Este método es auxiliar y está correcto)
     */
    public int obtenerOCrearUbicacion(String nombreUbicacion) {
        int ubicacionId = 0;
        String sqlSelect = "SELECT id_ubicacion FROM ubicaciones WHERE nombre = ?";

        try (Connection conn = DatabaseConnection.getConnection();
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
            try (Connection conn = DatabaseConnection.getConnection();
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

        try (Connection conn = DatabaseConnection.getConnection();
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

        try (Connection conn = DatabaseConnection.getConnection();
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

        try (Connection conn = DatabaseConnection.getConnection();
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

    /**
     * Obtener los lotes disponibles de un productor para un producto específico
     * @param productoId ID del producto
     * @return Lista de arrays con los datos de cada lote
     */
    public List<Object[]> obtenerLotesDisponiblesParaProducto(int productoId) {
        List<Object[]> lotes = new ArrayList<>();
        String sql = "SELECT l.id_lote, l.codigo_lote, p.codigo_sku, p.nombre AS producto_nombre, " +
                     "l.stock_actual, p.unidades_por_paquete, l.fecha_vencimiento " +
                     "FROM lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE l.producto_id = ? AND l.stock_actual > 0 " +
                     "ORDER BY l.fecha_vencimiento ASC";

        System.out.println("=== DEBUG DAO - OBTENER LOTES PARA PRODUCTO ===");
        System.out.println("Producto ID: " + productoId);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Object[] lote = new Object[7];
                    lote[0] = rs.getInt("id_lote");
                    lote[1] = rs.getString("codigo_lote");
                    lote[2] = rs.getString("codigo_sku");
                    lote[3] = rs.getString("producto_nombre");
                    
                    int stockActual = rs.getInt("stock_actual");
                    int unidadesPorPaquete = rs.getInt("unidades_por_paquete");
                    int paquetes = (unidadesPorPaquete > 0) ? (stockActual / unidadesPorPaquete) : stockActual;
                    
                    lote[4] = paquetes; // Cantidad de paquetes
                    lote[5] = stockActual; // Stock actual (unidades totales)
                    lote[6] = rs.getDate("fecha_vencimiento"); // Puede ser null
                    
                    lotes.add(lote);
                }
                System.out.println("✓ Lotes encontrados: " + lotes.size());
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al obtener lotes para producto:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        }
        return lotes;
    }
    
    /**
     * Busca un lote por su ID y retorna su información
     * @param idLote ID del lote
     * @return Array con [id_lote, codigo_lote, producto_id, stock_actual, unidades_por_paquete] o null si no existe
     */
    public Object[] buscarLotePorId(int idLote) {
        String sql = "SELECT l.id_lote, l.codigo_lote, l.producto_id, l.stock_actual, p.unidades_por_paquete " +
                     "FROM lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE l.id_lote = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idLote);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Object[] lote = new Object[5];
                    lote[0] = rs.getInt("id_lote");
                    lote[1] = rs.getString("codigo_lote");
                    lote[2] = rs.getInt("producto_id");
                    lote[3] = rs.getInt("stock_actual");
                    lote[4] = rs.getInt("unidades_por_paquete");
                    return lote;
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al buscar lote por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Actualiza el stock de un lote
     * @param idLote ID del lote
     * @param nuevoStock Nuevo stock (en unidades)
     * @return true si se actualizó correctamente
     */
    public boolean actualizarStock(int idLote, int nuevoStock) {
        String sql = "UPDATE lotes SET stock_actual = ? WHERE id_lote = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, nuevoStock);
            pstmt.setInt(2, idLote);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("✓ Stock del lote " + idLote + " actualizado a " + nuevoStock + " unidades");
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al actualizar stock del lote: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Obtiene el resumen de lotes por producto (todos los lotes con stock > 0)
     * @param productoId ID del producto
     * @return Lista de arrays con [id_lote, codigo_lote, stock_actual, fecha_vencimiento]
     */
    public List<Object[]> obtenerResumenLotesPorProducto(int productoId) {
        List<Object[]> lotes = new ArrayList<>();
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento " +
                     "FROM lotes l " +
                     "WHERE l.producto_id = ? AND l.stock_actual > 0 " +
                     "ORDER BY l.fecha_vencimiento ASC, l.codigo_lote ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Object[] lote = new Object[4];
                    lote[0] = rs.getInt("id_lote");
                    lote[1] = rs.getString("codigo_lote");
                    lote[2] = rs.getInt("stock_actual");
                    lote[3] = rs.getDate("fecha_vencimiento");
                    lotes.add(lote);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al obtener resumen de lotes: " + e.getMessage());
            e.printStackTrace();
        }
        return lotes;
    }
    
    /**
     * Obtiene el stock inicial de un lote calculando: stock_actual + todas las salidas registradas
     * Si no hay movimientos, retorna el stock_actual como stock inicial
     * @param idLote ID del lote
     * @return Stock inicial en unidades
     */
    public int obtenerStockInicialLote(int idLote) {
        // Primero obtener el stock actual
        int stockActual = 0;
        String sqlStockActual = "SELECT stock_actual FROM lotes WHERE id_lote = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlStockActual)) {
            pstmt.setInt(1, idLote);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stockActual = rs.getInt("stock_actual");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al obtener stock actual del lote: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
        
        // Sumar todas las salidas registradas
        String sqlSalidas = "SELECT COALESCE(SUM(cantidad), 0) as total_salidas " +
                            "FROM movimientos_inventario " +
                            "WHERE lote_id = ? AND tipo = 'Salida'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlSalidas)) {
            
            pstmt.setInt(1, idLote);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int totalSalidas = rs.getInt("total_salidas");
                    // Stock inicial = stock actual + salidas registradas
                    int stockInicial = stockActual + totalSalidas;
                    return stockInicial > 0 ? stockInicial : stockActual; // Si es 0 o negativo, usar stock actual
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al calcular stock inicial del lote: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Si no hay salidas registradas, el stock inicial es el stock actual
        return stockActual;
    }
    
    /**
     * Obtiene el total de salidas registradas de un lote
     * @param idLote ID del lote
     * @return Total de unidades que han salido del lote
     */
    private int obtenerSalidasLote(int idLote) {
        String sql = "SELECT COALESCE(SUM(cantidad), 0) as total_salidas " +
                     "FROM movimientos_inventario " +
                     "WHERE lote_id = ? AND tipo = 'Salida'";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idLote);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total_salidas");
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al obtener salidas del lote: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
    
    /**
     * Obtiene el resumen completo de todos los lotes de un producto con stock inicial y restante
     * @param productoId ID del producto
     * @return Lista de arrays con [id_lote, codigo_lote, stock_inicial, stock_actual, paquetes_inicial, paquetes_restante, fecha_vencimiento, unidades_por_paquete]
     */
    public List<Object[]> obtenerResumenCompletoLotesPorProducto(int productoId) {
        List<Object[]> lotes = new ArrayList<>();
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, p.unidades_por_paquete " +
                     "FROM lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE l.producto_id = ? " +
                     "ORDER BY l.fecha_vencimiento ASC, l.codigo_lote ASC";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productoId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    int idLote = rs.getInt("id_lote");
                    int stockActual = rs.getInt("stock_actual");
                    int unidadesPorPaquete = rs.getInt("unidades_por_paquete");
                    
                    // Obtener salidas registradas
                    int salidasRegistradas = obtenerSalidasLote(idLote);
                    
                    // Calcular stock inicial: stock actual + salidas registradas
                    // Si no hay salidas, el stock inicial es el stock actual (lote completo)
                    int stockInicial = stockActual + salidasRegistradas;
                    
                    // Si el stock inicial es 0 o menor al actual, usar el actual (para lotes nuevos sin movimientos)
                    if (stockInicial < stockActual) {
                        stockInicial = stockActual;
                    }
                    
                    int paquetesInicial = (unidadesPorPaquete > 0) ? (stockInicial / unidadesPorPaquete) : stockInicial;
                    int paquetesRestante = (unidadesPorPaquete > 0) ? (stockActual / unidadesPorPaquete) : stockActual;
                    
                    Object[] lote = new Object[8];
                    lote[0] = idLote;
                    lote[1] = rs.getString("codigo_lote");
                    lote[2] = stockInicial; // Stock inicial en unidades
                    lote[3] = stockActual; // Stock actual (restante) en unidades
                    lote[4] = paquetesInicial; // Paquetes iniciales
                    lote[5] = paquetesRestante; // Paquetes restantes
                    lote[6] = rs.getDate("fecha_vencimiento");
                    lote[7] = unidadesPorPaquete;
                    lotes.add(lote);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al obtener resumen completo de lotes: " + e.getMessage());
            e.printStackTrace();
        }
        return lotes;
    }
}