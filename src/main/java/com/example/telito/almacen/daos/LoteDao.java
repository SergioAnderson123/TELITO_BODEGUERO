package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de lotes desde perspectiva del almacén
public class LoteDao extends DAOBase {

    // Lista lotes registrados (sin filtros)
    public ArrayList<Lote> listarLotesRegistrados(int pagina) {
        return listarLotesRegistrados(pagina, null, null);
    }
    
    // Lista lotes registrados con filtros de búsqueda y estado de stock
    public ArrayList<Lote> listarLotesRegistrados(int pagina, String busqueda, String estadoStock) {
        ArrayList<Lote> lista = new ArrayList<>();
        int registrosPorPagina = 5;
        int offset = (pagina - 1) * registrosPorPagina;

        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, l.estado, " +
                "l.producto_id, " +
                "p.nombre AS nombre_producto, p.codigo_sku AS codigo_sku, p.unidades_por_paquete, " +
                "FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes_disponibles, " +
                "u.nombre AS nombre_ubicacion, " +
                "CASE " +
                "    WHEN smc.id_stock_minimo IS NULL THEN 'No configurado' " +
                "    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) = 0 THEN 'Sin Stock' " +
                "    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_critico_lote THEN 'Sin Stock' " +
                "    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_minimo_lote THEN 'Poco Stock' " +
                "    ELSE 'En Stock' " +
                "END AS estado_stock, " +
                "CASE " +
                "    WHEN EXISTS (SELECT 1 FROM incidencias_almacen ia WHERE ia.lote_id = l.id_lote AND ia.estado = 'Pendiente') THEN 1 " +
                "    ELSE 0 " +
                "END AS tiene_incidencia_pendiente " +
                "FROM lotes l " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                "WHERE l.estado = 'Registrado' " +
                "AND l.ubicacion_id IS NOT NULL ";

        java.util.List<Object> params = new java.util.ArrayList<>();
        int paramIndex = 1;

        // Filtro por búsqueda (SKU, nombre de producto o código de lote)
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += "AND (p.codigo_sku LIKE ? OR p.nombre LIKE ? OR l.codigo_lote LIKE ?) ";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            params.add(busquedaParam);
        }

        sql += "ORDER BY p.codigo_sku DESC, l.codigo_lote DESC";

        // Si hay filtro de estado, envolver en subconsulta
        if (estadoStock != null && !estadoStock.trim().isEmpty()) {
            String estadoFiltro = "";
            if (estadoStock.equals("En stock")) {
                estadoFiltro = "En Stock";
            } else if (estadoStock.equals("Poco stock")) {
                estadoFiltro = "Poco Stock";
            } else if (estadoStock.equals("Sin stock")) {
                estadoFiltro = "Sin Stock";
            }
            
            if (!estadoFiltro.isEmpty()) {
                sql = "SELECT * FROM (" + sql + ") AS subquery WHERE estado_stock = ? LIMIT ? OFFSET ?";
            } else {
                sql += " LIMIT ? OFFSET ?";
            }
        } else {
            sql += " LIMIT ? OFFSET ?";
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            // Establecer parámetros dinámicos
            for (Object param : params) {
                pstmt.setObject(paramIndex++, param);
            }
            
            // Si hay filtro de estado, agregar el parámetro
            if (estadoStock != null && !estadoStock.trim().isEmpty()) {
                String estadoFiltro = "";
                if (estadoStock.equals("En stock")) {
                    estadoFiltro = "En Stock";
                } else if (estadoStock.equals("Poco stock")) {
                    estadoFiltro = "Poco Stock";
                } else if (estadoStock.equals("Sin stock")) {
                    estadoFiltro = "Sin Stock";
                }
                if (!estadoFiltro.isEmpty()) {
                    pstmt.setString(paramIndex++, estadoFiltro);
                }
            }
            
            pstmt.setInt(paramIndex++, registrosPorPagina);
            pstmt.setInt(paramIndex, offset);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Lote lote = new Lote();
                lote.setIdLote(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setStockActual(rs.getInt("stock_actual"));
                lote.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                lote.setEstado(rs.getString("estado"));
                lote.setProductoId(rs.getInt("producto_id"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lote.setCodigoSKU(rs.getString("codigo_sku"));
                lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                lote.setEstadoStock(rs.getString("estado_stock"));
                // Verificar si tiene incidencia pendiente
                try {
                    // MySQL devuelve 1 o 0 para el CASE WHEN
                    int tieneIncidenciaInt = rs.getInt("tiene_incidencia_pendiente");
                    boolean tieneIncidencia = tieneIncidenciaInt == 1;
                    lote.setTieneIncidenciaPendiente(tieneIncidencia);
                    if (tieneIncidencia) {
                        logger.info("Lote ID: " + lote.getIdLote() + " (Código: " + lote.getCodigoLote() + ") - TIENE incidencia pendiente");
                    }
                } catch (SQLException e) {
                    // Si la columna no existe en esta consulta, asumir false
                    logger.warn("No se pudo obtener tiene_incidencia_pendiente para lote ID: " + lote.getIdLote() + " - " + e.getMessage());
                    lote.setTieneIncidenciaPendiente(false);
                }
                lista.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al listar los lotes registrados", e);
            throw new RuntimeException("Error al listar los lotes registrados", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    /**
     * MÉTODO MODIFICADO: Renombrado y filtrado.
     * Cuenta el total de lotes que están marcados como "Registrado".
     */
    public int contarTotalLotesRegistrados() {
        return contarTotalLotesRegistrados(null, null);
    }
    
    /**
     * Cuenta lotes registrados con filtros opcionales.
     */
    public int contarTotalLotesRegistrados(String busqueda, String estadoStock) {
        String sql = """
            SELECT COUNT(*) as total
            FROM (
                SELECT l.id_lote,
                CASE 
                    WHEN smc.id_stock_minimo IS NULL THEN 'No configurado' 
                    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) = 0 THEN 'Sin Stock' 
                    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_critico_lote THEN 'Sin Stock' 
                    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_minimo_lote THEN 'Poco Stock' 
                    ELSE 'En Stock' 
                END AS estado_stock
                FROM lotes l 
                INNER JOIN productos p ON l.producto_id = p.id_producto 
                INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion 
                LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 
                WHERE l.estado = 'Registrado' 
                AND l.ubicacion_id IS NOT NULL
            """;
        
        java.util.List<Object> params = new java.util.ArrayList<>();
        
        // Filtro por búsqueda
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.codigo_sku LIKE ? OR p.nombre LIKE ? OR l.codigo_lote LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        sql += ") as subquery";
        
        // Filtro por estado de stock
        if (estadoStock != null && !estadoStock.trim().isEmpty()) {
            if (estadoStock.equals("En stock")) {
                sql += " WHERE estado_stock = 'En Stock'";
            } else if (estadoStock.equals("Poco stock")) {
                sql += " WHERE estado_stock = 'Poco Stock'";
            } else if (estadoStock.equals("Sin stock")) {
                sql += " WHERE estado_stock = 'Sin Stock'";
            }
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            logger.error("Error al contar lotes registrados", e);
            throw new RuntimeException("Error al contar lotes registrados", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    /**
     * NUEVO MÉTODO
     * Actualiza el estado de un lote, típicamente de 'No Registrado' a 'Registrado'.
     */
    public void actualizarEstado(int idLote, String nuevoEstado) {
        String sql = "UPDATE lotes SET estado = ? WHERE id_lote = ?";
        executeUpdate(sql, nuevoEstado, idLote);
    }

    /**
     * MÉTODO MODIFICADO
     * Busca los lotes disponibles para un producto, asegurándose de que estén registrados.
     */
    public ArrayList<Lote> buscarLotesPorProducto(int idProducto) {
        ArrayList<Lote> listaLotes = new ArrayList<>();
        // Solo buscar lotes del almacén (con ubicacion_id asignada, NO del productor)
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, u.nombre AS nombre_ubicacion " +
                "FROM lotes l " +
                "INNER JOIN ubicaciones u ON (l.ubicacion_id = u.id_ubicacion) " +
                "WHERE l.producto_id = ? AND l.stock_actual > 0 AND l.estado = 'Registrado' " +
                "AND l.ubicacion_id IS NOT NULL " + // Solo lotes del almacén
                "ORDER BY l.fecha_vencimiento ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idProducto);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Lote lote = new Lote();
                lote.setIdLote(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setStockActual(rs.getInt("stock_actual"));
                lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                listaLotes.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al buscar lotes por producto", e);
            throw new RuntimeException("Error al buscar lotes por producto", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaLotes;
    }

    // --- MÉTODOS SIN CAMBIOS ---
    // (Estos métodos siguen siendo necesarios y no requieren modificaciones)

    public void actualizarStock(int idLote, int nuevoStock) {
        String sql = "UPDATE lotes SET stock_actual = ? WHERE id_lote = ?";
        executeUpdate(sql, nuevoStock, idLote);
    }

    /**
     * Actualiza la ubicación, distrito y estado de un lote existente.
     * Se usa cuando el almacén recibe un lote del productor.
     */
    public void actualizarUbicacionYEstado(int idLote, int ubicacionId, int distritoId, String estado) {
        String sql = "UPDATE lotes SET ubicacion_id = ?, distrito_id = ?, estado = ? WHERE id_lote = ?";
        executeUpdate(sql, ubicacionId, distritoId, estado, idLote);
        logger.info("Lote {} actualizado - Nueva ubicación: {}, distrito: {}, estado: {}", 
                   idLote, ubicacionId, distritoId, estado);
    }

    public Lote buscarLotePorId(int idLote) {
        Lote lote = null;
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, l.estado, " +
                " l.producto_id, l.ubicacion_id, l.distrito_id, " +
                " p.nombre AS nombre_producto, p.unidades_por_paquete, " +
                " FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes_disponibles, " +
                " u.nombre AS nombre_ubicacion " +
                " FROM lotes l " +
                " INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                " INNER JOIN ubicaciones u ON (l.ubicacion_id = u.id_ubicacion) " +
                " WHERE l.id_lote = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idLote);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                lote = new Lote();
                lote.setIdLote(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setStockActual(rs.getInt("stock_actual"));
                lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                lote.setEstado(rs.getString("estado"));
                lote.setProductoId(rs.getInt("producto_id"));
                lote.setUbicacionId(rs.getInt("ubicacion_id"));
                lote.setDistritoId(rs.getInt("distrito_id"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                // Obtener unidades por paquete y calcular paquetes disponibles
                try {
                    int unidadesPorPaquete = rs.getInt("unidades_por_paquete");
                    lote.setUnidadesPorPaquete(unidadesPorPaquete);
                    int paquetesDisponibles = rs.getInt("paquetes_disponibles");
                    lote.setPaquetesDisponibles(paquetesDisponibles);
                } catch (SQLException e) {
                    // Si no se puede obtener, usar valores por defecto
                    lote.setUnidadesPorPaquete(1);
                    lote.setPaquetesDisponibles(0);
                }
            }
        } catch (SQLException e) {
            logger.error("Error al buscar el lote", e);
            throw new RuntimeException("Error al buscar el lote", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lote;
    }
    
    /**
     * Busca un lote por su código.
     */
    public Lote buscarLotePorCodigo(String codigoLote) {
        Lote lote = null;
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, l.estado, " +
                "l.producto_id, l.ubicacion_id, l.distrito_id, " +
                "p.nombre AS nombre_producto " +
                "FROM lotes l " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "WHERE l.codigo_lote = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, codigoLote);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                lote = new Lote();
                lote.setIdLote(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setStockActual(rs.getInt("stock_actual"));
                lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                lote.setEstado(rs.getString("estado"));
                lote.setProductoId(rs.getInt("producto_id"));
                lote.setUbicacionId(rs.getInt("ubicacion_id"));
                lote.setDistritoId(rs.getInt("distrito_id"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
            }
        } catch (SQLException e) {
            logger.error("Error al buscar lote por código: " + codigoLote, e);
            throw new RuntimeException("Error al buscar lote por código", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lote;
    }

    public int crearLote(Lote lote) {
        // CORRECCIÓN: Se añade la columna 'estado' a la consulta
        String sql = "INSERT INTO lotes (codigo_lote, stock_actual, fecha_vencimiento, producto_id, ubicacion_id, distrito_id, estado) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        int generatedId = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, lote.getCodigoLote());
            pstmt.setInt(2, lote.getStockActual());
            pstmt.setDate(3, new java.sql.Date(lote.getFechaVencimiento().getTime()));
            pstmt.setInt(4, lote.getProductoId());
            pstmt.setInt(5, lote.getUbicacionId());
            pstmt.setInt(6, lote.getDistritoId());
            pstmt.setString(7, lote.getEstado()); // <-- SE AÑADE EL ESTADO
            pstmt.executeUpdate();

            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                generatedId = rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al crear lote", e);
            throw new RuntimeException("Error al crear lote", e);
        } finally {
            closeResultSet(rs);
            closePreparedStatement(pstmt);
            closeConnection(conn);
        }
        return generatedId;
    }

    /**
     * Actualizar la ubicación de un lote existente
     */
    public void actualizarUbicacion(int idLote, int idUbicacion) {
        String sql = "UPDATE lotes SET ubicacion_id = ? WHERE id_lote = ?";
        executeUpdate(sql, idUbicacion, idLote);
        logger.info("Ubicación del lote {} actualizada a ubicación {}", idLote, idUbicacion);
    }

    /**
     * Actualizar el estado de un lote a "Registrado" cuando el almacenero lo recibe
     */
    public void registrarLote(int idLote) {
        String sql = "UPDATE lotes SET estado = 'Registrado' WHERE id_lote = ?";
        executeUpdate(sql, idLote);
        logger.info("Lote {} marcado como 'Registrado'", idLote);
    }
    
    /**
     * Obtiene el resumen de lotes por producto (todos los lotes con stock > 0)
     * @param productoId ID del producto
     * @return Lista de arrays con [id_lote, codigo_lote, stock_actual, fecha_vencimiento, unidades_por_paquete, paquetes]
     */
    public ArrayList<Object[]> obtenerResumenLotesPorProducto(int productoId) {
        ArrayList<Object[]> lotes = new ArrayList<>();
        // Solo mostrar lotes del almacén (con ubicacion_id asignada), no del productor
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, " +
                     "p.unidades_por_paquete, FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes " +
                     "FROM lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE l.producto_id = ? AND l.stock_actual > 0 " +
                     "AND l.ubicacion_id IS NOT NULL " + // Solo lotes del almacén
                     "AND l.estado = 'Registrado' " + // Solo lotes registrados
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
                Object[] lote = new Object[6];
                lote[0] = rs.getInt("id_lote");
                lote[1] = rs.getString("codigo_lote");
                lote[2] = rs.getInt("stock_actual");
                lote[3] = rs.getDate("fecha_vencimiento");
                lote[4] = rs.getInt("unidades_por_paquete");
                lote[5] = rs.getInt("paquetes");
                lotes.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener resumen de lotes", e);
            throw new RuntimeException("Error al obtener resumen de lotes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lotes;
    }
    
    /**
     * Obtiene todos los lotes registrados sin paginación.
     * Útil para exportar a Excel.
     * 
     * @return Lista completa de lotes registrados
     */
    public ArrayList<Lote> listarTodosLotesRegistrados() {
        ArrayList<Lote> lista = new ArrayList<>();

        // Solo mostrar lotes del almacén (con ubicacion_id asignada), no del productor
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, l.estado, " +
                "l.producto_id, " +
                "p.nombre AS nombre_producto, p.codigo_sku AS codigo_sku, p.unidades_por_paquete, " +
                "FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes_disponibles, " +
                "u.nombre AS nombre_ubicacion, " +
                "CASE " +
                "    WHEN smc.id_stock_minimo IS NULL THEN 'No configurado' " +
                "    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) = 0 THEN 'Sin Stock' " +
                "    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_critico_lote THEN 'Sin Stock' " +
                "    WHEN FLOOR(l.stock_actual / p.unidades_por_paquete) <= smc.stock_minimo_lote THEN 'Poco Stock' " +
                "    ELSE 'En Stock' " +
                "END AS estado_stock " +
                "FROM lotes l " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                "LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1 " +
                "WHERE l.estado = 'Registrado' " +
                "AND l.ubicacion_id IS NOT NULL " + // Solo lotes del almacén
                "ORDER BY l.codigo_lote ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Lote lote = new Lote();
                lote.setIdLote(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setStockActual(rs.getInt("stock_actual"));
                lote.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                lote.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                lote.setEstado(rs.getString("estado"));
                lote.setProductoId(rs.getInt("producto_id"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lote.setCodigoSKU(rs.getString("codigo_sku"));
                lote.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                lote.setEstadoStock(rs.getString("estado_stock"));
                // Verificar si tiene incidencia pendiente (puede no estar en todas las consultas)
                try {
                    int tieneIncidencia = rs.getInt("tiene_incidencia_pendiente");
                    lote.setTieneIncidenciaPendiente(tieneIncidencia == 1);
                } catch (SQLException e) {
                    // Si la columna no existe en esta consulta, asumir false
                    lote.setTieneIncidenciaPendiente(false);
                }
                lista.add(lote);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todos los lotes registrados", e);
            throw new RuntimeException("Error al listar todos los lotes registrados", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}