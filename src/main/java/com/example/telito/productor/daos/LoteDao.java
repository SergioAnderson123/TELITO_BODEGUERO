package com.example.telito.productor.daos;

import com.example.telito.util.DAOBase;

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
public class LoteDao extends DAOBase {

    /**
     * Genera un nuevo código de lote automático en formato L--0001, L--0002, etc.
     * @return String con el nuevo código generado (ej: "L--0016")
     */
    public String generarNuevoCodigoLote() {
        String sql = "SELECT codigo_lote FROM lotes WHERE codigo_lote LIKE 'L--%' ORDER BY id_lote DESC LIMIT 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
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
            logger.error("Error al generar nuevo código de lote", e);
            // En caso de error, generar código con timestamp
            return "L--" + System.currentTimeMillis();
        } finally {
            closeResources(conn, pstmt, rs);
        }
    }

    /**
     * MÉTODO CORREGIDO
     * Registra un nuevo lote creado por un productor.
     * Asigna el estado 'No Registrado' por defecto.
     * Ahora requiere los IDs de ubicación y distrito.
     */
    public boolean registrarLote(String codigoLote, int productoId, int cantidadStock,
                                 String fechaCaducidad, int ubicacionId, int distritoId, Double costoProduccion) {

        // Se añaden las columnas 'distrito_id', 'estado' y 'costo_produccion' al INSERT
        String sql = "INSERT INTO lotes (codigo_lote, producto_id, stock_actual, fecha_vencimiento, ubicacion_id, distrito_id, estado, costo_produccion) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'No Registrado', ?)";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
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
            
            if (costoProduccion != null) {
                pstmt.setDouble(7, costoProduccion);
            } else {
                pstmt.setNull(7, java.sql.Types.DECIMAL);
            }

            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            logger.error("Error al registrar el lote", e);
            throw new RuntimeException("Error al registrar el lote", e);
        } finally {
            closePreparedStatement(pstmt);
            closeConnection(conn);
        }
    }

    /**
     * Sobrecarga compatible con el otro proyecto: recibe SKU y nombre de distrito,
     * resuelve los IDs internamente y registra el lote.
     */
    public boolean registrarLote(String codigoLote, String skuProducto, int cantidadStock,
                                 String fechaCaducidad, String distritoNombre, Double costoProduccion) {
        
        int productoId = obtenerIdProductoPorSKU(skuProducto);
        if (productoId == 0) {
            logger.error("No se encontró producto con SKU: {}", skuProducto);
            return false;
        }
        
        // Obtener unidades por paquete del producto
        int unidadesPorPaquete = obtenerUnidadesPorPaquete(productoId);
        
        // Calcular stock real: paquetes × unidades por paquete
        int stockReal = cantidadStock * unidadesPorPaquete;
        logger.debug("Cálculo: {} paquetes × {} unidades = {} unidades totales", cantidadStock, unidadesPorPaquete, stockReal);
        
        int ubicacionId = obtenerOCrearUbicacion(distritoNombre);
        if (ubicacionId == 0) {
            logger.error("No se pudo obtener/crear ubicación: {}", distritoNombre);
            return false;
        }
        
        int distritoId = obtenerOCrearDistrito(distritoNombre);
        if (distritoId == 0) {
            logger.error("No se pudo obtener/crear distrito: {}", distritoNombre);
            return false;
        }

        String sql = "INSERT INTO lotes (codigo_lote, producto_id, ubicacion_id, stock_actual, fecha_vencimiento, estado, distrito_id, costo_produccion) VALUES (?, ?, ?, ?, ?, 'No Registrado', ?, ?)";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, codigoLote);
            pstmt.setInt(2, productoId);
            pstmt.setInt(3, ubicacionId);
            pstmt.setInt(4, stockReal); // Guardamos el stock calculado (no los paquetes)

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
            
            if (costoProduccion != null) {
                pstmt.setDouble(7, costoProduccion);
            } else {
                pstmt.setNull(7, java.sql.Types.DECIMAL);
            }

            int rowsAffected = pstmt.executeUpdate();
            logger.info("Lote registrado: {} filas insertadas", rowsAffected);
            return rowsAffected > 0;

        } catch (SQLException e) {
            logger.error("Error SQL al registrar el lote", e);
            throw new RuntimeException("Error al registrar el lote", e);
        } finally {
            closePreparedStatement(pstmt);
            closeConnection(conn);
        }
    }

    // Obtiene o crea un distrito y retorna su ID
    private int obtenerOCrearDistrito(String nombreDistrito) {
        int distritoId = 0;
        String sqlSelect = "SELECT idDistrito FROM distritos WHERE nombre = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sqlSelect);
            pstmt.setString(1, nombreDistrito);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                distritoId = rs.getInt("idDistrito");
                logger.debug("Distrito encontrado: {} (ID: {})", nombreDistrito, distritoId);
            }
        } catch (SQLException e) {
            logger.error("Error al buscar distrito: " + nombreDistrito, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        if (distritoId == 0) {
            // Si no existe, intentar usar "Cercado de Lima" como fallback (zona Oeste = 4)
            // Si el nombre solicitado es "Cercado", buscar "Cercado de Lima" en su lugar
            String distritoFallback = "Cercado".equalsIgnoreCase(nombreDistrito) ? "Cercado de Lima" : nombreDistrito;
            
            String sqlSelectFallback = "SELECT idDistrito FROM distritos WHERE nombre = ?";
            try {
                conn = getConnection();
                pstmt = conn.prepareStatement(sqlSelectFallback);
                pstmt.setString(1, distritoFallback);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    distritoId = rs.getInt("idDistrito");
                    logger.info("Distrito fallback encontrado: {} (ID: {}) en lugar de {}", distritoFallback, distritoId, nombreDistrito);
                } else {
                    // Si tampoco existe el fallback, usar "Cercado de Lima" como último recurso (zona Oeste = 4)
                    String sqlSelectDefault = "SELECT idDistrito FROM distritos WHERE nombre = 'Cercado de Lima'";
                    pstmt = conn.prepareStatement(sqlSelectDefault);
                    rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        distritoId = rs.getInt("idDistrito");
                        logger.warn("Distrito '{}' no encontrado. Usando 'Cercado de Lima' (ID: {}) como distrito por defecto", nombreDistrito, distritoId);
                    } else {
                        logger.error("No se pudo encontrar ningún distrito válido. '{}' no existe y 'Cercado de Lima' tampoco está disponible.", nombreDistrito);
                    }
                }
            } catch (SQLException e) {
                logger.error("Error al buscar distrito fallback: " + nombreDistrito, e);
            } finally {
                closeResultSet(rs);
                closePreparedStatement(pstmt);
                closeConnection(conn);
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
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, skuTrimmed);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                productoId = rs.getInt("id_producto");
                logger.debug("Producto encontrado con SKU '{}' (ID: {})", skuTrimmed, productoId);
            } else {
                logger.warn("No se encontró producto con SKU '{}'", skuTrimmed);
            }
        } catch (SQLException e) {
            logger.error("Error SQL al buscar producto por SKU: " + skuTrimmed, e);
        } finally {
            closeResources(conn, pstmt, rs);
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
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                unidadesPorPaquete = rs.getInt("unidades_por_paquete");
                logger.debug("Unidades por paquete del producto ID {}: {}", productoId, unidadesPorPaquete);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener unidades por paquete del producto: " + productoId, e);
        } finally {
            closeResources(conn, pstmt, rs);
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

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sqlSelect);
            pstmt.setString(1, nombreUbicacion);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                ubicacionId = rs.getInt("id_ubicacion");
            }
        } catch (SQLException e) {
            logger.error("Error al buscar ubicación: " + nombreUbicacion, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }

        if (ubicacionId == 0) {
            String sqlInsert = "INSERT INTO ubicaciones (nombre) VALUES (?)";
            conn = null;
            pstmt = null;
            rs = null;

            try {
                conn = getConnection();
                pstmt = conn.prepareStatement(sqlInsert, PreparedStatement.RETURN_GENERATED_KEYS);
                pstmt.setString(1, nombreUbicacion);
                if (pstmt.executeUpdate() > 0) {
                    rs = pstmt.getGeneratedKeys();
                    if (rs.next()) {
                        ubicacionId = rs.getInt(1);
                    }
                }
            } catch (SQLException e) {
                logger.error("Error al crear ubicación: " + nombreUbicacion, e);
            } finally {
                closeResultSet(rs);
                closePreparedStatement(pstmt);
                closeConnection(conn);
            }
        }
        return ubicacionId;
    }

    // --- EL RESTO DE MÉTODOS NO NECESITAN CAMBIOS ---

    /**
     * Obtiene el nombre de un producto por SKU, pero SOLO si pertenece al productor especificado.
     * Esto previene que un productor vea productos de otros productores.
     * @param sku Código SKU del producto
     * @param productorId ID del productor (debe ser el dueño del producto)
     * @return Nombre del producto si existe y pertenece al productor, null en caso contrario
     */
    public String obtenerNombreProductoPorSKU(String sku, int productorId) {
        String nombreProducto = null;
        String sql = "SELECT nombre FROM productos WHERE UPPER(codigo_sku) = UPPER(?) AND productor_id = ? AND activo = 1";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, (sku == null) ? null : sku.trim());
            pstmt.setInt(2, productorId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                nombreProducto = rs.getString("nombre");
            }
        } catch (SQLException e) {
            logger.error("Error al buscar nombre del producto: " + sku, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return nombreProducto;
    }

    public List<Object[]> listarLotesPorProductor(int productorId) {
        List<Object[]> lotes = new ArrayList<>();
        String sql = "SELECT l.codigo_lote, p.nombre as producto_nombre, p.codigo_sku, " +
                "u.nombre as ubicacion, l.stock_actual, l.fecha_vencimiento, " +
                "COALESCE(d.nombre, 'Sin asignar') as distrito, l.estado " +
                "FROM lotes l " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                "LEFT JOIN distritos d ON l.distrito_id = d.id_distrito " +
                "WHERE p.productor_id = ? " +
                "ORDER BY l.codigo_lote DESC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Object[] lote = new Object[8];
                lote[0] = rs.getString("codigo_lote");
                lote[1] = rs.getString("producto_nombre");
                lote[2] = rs.getString("codigo_sku");
                lote[3] = rs.getString("ubicacion");
                lote[4] = rs.getInt("stock_actual");
                lote[5] = rs.getDate("fecha_vencimiento");
                lote[6] = rs.getString("distrito");
                lote[7] = rs.getString("estado");
                lotes.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al listar lotes del productor: " + productorId, e);
            throw new RuntimeException("Error al listar lotes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lotes;
    }

    public int obtenerStockTotalProducto(int productoId) {
        int stockTotal = 0;
        String sql = "SELECT SUM(stock_actual) as stock_total FROM lotes WHERE producto_id = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                stockTotal = rs.getInt("stock_total");
            }
        } catch (SQLException e) {
            logger.error("Error al obtener stock total del producto: " + productoId, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return stockTotal;
    }

    /**
     * Obtener los lotes disponibles de un productor para un producto específico
     * @param productoId ID del producto
     * @return Lista de arrays con los datos de cada lote
     */
    /**
     * Obtiene los lotes disponibles para un producto, pero SOLO si el producto pertenece al productor especificado.
     * Esto previene que un productor vea o modifique lotes de productos de otros productores.
     * @param productoId ID del producto
     * @param productorId ID del productor (debe ser el dueño del producto)
     * @return Lista de lotes disponibles si el producto pertenece al productor, lista vacía en caso contrario
     */
    public List<Object[]> obtenerLotesDisponiblesParaProducto(int productoId, int productorId) {
        List<Object[]> lotes = new ArrayList<>();
        String sql = "SELECT l.id_lote, l.codigo_lote, p.codigo_sku, p.nombre AS producto_nombre, " +
                     "l.stock_actual, p.unidades_por_paquete, l.fecha_vencimiento " +
                     "FROM lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE l.producto_id = ? AND p.productor_id = ? AND p.activo = 1 AND l.stock_actual > 0 " +
                     "ORDER BY l.fecha_vencimiento ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            pstmt.setInt(2, productorId);
            rs = pstmt.executeQuery();

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
            logger.debug("Lotes encontrados para producto {}: {}", productoId, lotes.size());
        } catch (SQLException e) {
            logger.error("Error al obtener lotes para producto: " + productoId, e);
            throw new RuntimeException("Error al obtener lotes para producto", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lotes;
    }
    
    /**
     * Busca un lote por su ID y retorna su información, pero SOLO si el lote pertenece a un producto del productor especificado.
     * Esto previene que un productor vea o modifique lotes de productos de otros productores.
     * @param idLote ID del lote
     * @param productorId ID del productor (debe ser el dueño del producto al que pertenece el lote)
     * @return Array con [id_lote, codigo_lote, producto_id, stock_actual, unidades_por_paquete] o null si no existe o no pertenece al productor
     */
    public Object[] buscarLotePorId(int idLote, int productorId) {
        String sql = "SELECT l.id_lote, l.codigo_lote, l.producto_id, l.stock_actual, p.unidades_por_paquete " +
                     "FROM lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE l.id_lote = ? AND p.productor_id = ? AND p.activo = 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idLote);
            pstmt.setInt(2, productorId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Object[] lote = new Object[5];
                lote[0] = rs.getInt("id_lote");
                lote[1] = rs.getString("codigo_lote");
                lote[2] = rs.getInt("producto_id");
                lote[3] = rs.getInt("stock_actual");
                lote[4] = rs.getInt("unidades_por_paquete");
                return lote;
            }
        } catch (SQLException e) {
            logger.error("Error al buscar lote por ID: " + idLote, e);
            throw new RuntimeException("Error al buscar lote por ID", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }
    
    /**
     * Actualiza el stock de un lote, pero SOLO si el lote pertenece a un producto del productor especificado.
     * Esto previene que un productor modifique lotes de productos de otros productores.
     * @param idLote ID del lote
     * @param nuevoStock Nuevo stock (en unidades)
     * @param productorId ID del productor (debe ser el dueño del producto al que pertenece el lote)
     * @return true si se actualizó correctamente, false si el lote no pertenece al productor
     */
    public boolean actualizarStock(int idLote, int nuevoStock, int productorId) {
        String sql = "UPDATE lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "SET l.stock_actual = ? " +
                     "WHERE l.id_lote = ? AND p.productor_id = ? AND p.activo = 1";
        
        int filasAfectadas = executeUpdate(sql, nuevoStock, idLote, productorId);
        logger.info("Stock del lote {} actualizado a {} unidades (productor: {})", idLote, nuevoStock, productorId);
        return filasAfectadas > 0;
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
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Object[] lote = new Object[4];
                lote[0] = rs.getInt("id_lote");
                lote[1] = rs.getString("codigo_lote");
                lote[2] = rs.getInt("stock_actual");
                lote[3] = rs.getDate("fecha_vencimiento");
                lotes.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener resumen de lotes del producto: " + productoId, e);
            throw new RuntimeException("Error al obtener resumen de lotes", e);
        } finally {
            closeResources(conn, pstmt, rs);
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
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sqlStockActual);
            pstmt.setInt(1, idLote);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                stockActual = rs.getInt("stock_actual");
            }
        } catch (SQLException e) {
            logger.error("Error al obtener stock actual del lote: " + idLote, e);
            return 0;
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        // Sumar todas las salidas registradas
        String sqlSalidas = "SELECT COALESCE(SUM(cantidad), 0) as total_salidas " +
                            "FROM movimientos_inventario " +
                            "WHERE lote_id = ? AND tipo = 'Salida'";
        
        conn = null;
        pstmt = null;
        rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sqlSalidas);
            pstmt.setInt(1, idLote);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                int totalSalidas = rs.getInt("total_salidas");
                // Stock inicial = stock actual + salidas registradas
                int stockInicial = stockActual + totalSalidas;
                return stockInicial > 0 ? stockInicial : stockActual; // Si es 0 o negativo, usar stock actual
            }
        } catch (SQLException e) {
            logger.error("Error al calcular stock inicial del lote: " + idLote, e);
        } finally {
            closeResources(conn, pstmt, rs);
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
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idLote);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("total_salidas");
            }
        } catch (SQLException e) {
            logger.error("Error al obtener salidas del lote: " + idLote, e);
        } finally {
            closeResources(conn, pstmt, rs);
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
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productoId);
            rs = pstmt.executeQuery();

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
        } catch (SQLException e) {
            logger.error("Error al obtener resumen completo de lotes del producto: " + productoId, e);
            throw new RuntimeException("Error al obtener resumen completo de lotes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lotes;
    }
}

