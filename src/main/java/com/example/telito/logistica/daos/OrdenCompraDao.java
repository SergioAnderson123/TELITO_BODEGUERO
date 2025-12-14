package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.OrdenCompraBean;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrdenCompraDao extends DAOBase {

    // === MÉTODO MODIFICADO PARA ACEPTAR FILTROS (sin paginación, para compatibilidad) ===
    public ArrayList<OrdenCompraBean> obtenerOrdenes(String busqueda, String proveedorId, String estado) {
        return obtenerOrdenes(busqueda, proveedorId, estado, 1, Integer.MAX_VALUE);
    }

    // === MÉTODO CON PAGINACIÓN PARA OBTENER ÓRDENES DE COMPRA ===
    public ArrayList<OrdenCompraBean> obtenerOrdenes(String busqueda, String proveedorId, String estado, int page, int size) {

        ArrayList<OrdenCompraBean> listaOrdenes = new ArrayList<>();

        String sql = """
            SELECT * FROM (
                SELECT
                    oc.id_orden_compra AS id_orden,
                    CONCAT(productor.nombres, ' ', productor.apellidos) AS nombre_proveedor,
                    pr.nombre AS nombre_producto,
                    oc.cantidad AS cantidad_paquetes,
                    CONCAT(u.nombres, ' ', u.apellidos) AS personal_responsable,
                    CASE 
                        WHEN oc.estado = 'Pendiente' AND oc.lote_id IS NOT NULL THEN 'Recibido'
                        WHEN oc.estado IN ('Recibido', 'En Proceso') THEN 'Pendiente'
                        ELSE oc.estado
                    END AS estado,
                    oc.monto_total
                FROM ordenes_compra oc
                INNER JOIN usuarios productor ON oc.productor_id = productor.id_usuario
                INNER JOIN productos pr ON oc.producto_id = pr.id_producto
                INNER JOIN usuarios u ON oc.usuario_id = u.id_usuario
                WHERE 1=1
            """;

        List<Object> params = new ArrayList<>();

        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (pr.nombre LIKE ?";
            params.add("%" + busqueda.trim() + "%");

            // Si el usuario ingresa algo como OC001 o 001, intentamos filtrar por id
            String digits = busqueda.replaceAll("\\D", "");
            if (!digits.isEmpty()) {
                sql += " OR oc.id_orden_compra = ?";
                params.add(Integer.parseInt(digits));
            }
            sql += ")";
        }
        if (proveedorId != null && !proveedorId.trim().isEmpty()) {
            sql += " AND productor.id_usuario = ?";
            params.add(Integer.parseInt(proveedorId));
        }

        sql += ") AS ordenes_filtradas WHERE 1=1";
        
        // Filtrar por el estado calculado (no el original)
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND estado = ?";
            params.add(estado.trim());
        }

        sql += " ORDER BY id_orden DESC LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            int paramIndex = 1;
            for (Object param : params) {
                pstmt.setObject(paramIndex++, param);
            }

            // Parámetros de paginación
            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                int idOrden = rs.getInt("id_orden");
                String numeroOrden = String.format("OC%03d", idOrden);
                String nombreProveedor = rs.getString("nombre_proveedor");
                String nombreProducto = rs.getString("nombre_producto");
                int cantidadPaquetes = rs.getInt("cantidad_paquetes");
                String personalResponsable = rs.getString("personal_responsable");
                String estadoRs = rs.getString("estado");
                double monto = rs.getDouble("monto_total");
                String montoTotal = String.format("S/. %.2f", monto);

                OrdenCompraBean orden = new OrdenCompraBean(
                        numeroOrden, nombreProveedor, nombreProducto, cantidadPaquetes,
                        personalResponsable, estadoRs, montoTotal
                );
                listaOrdenes.add(orden);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener órdenes de compra", e);
            throw new RuntimeException("Error al obtener órdenes de compra", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaOrdenes;
    }

    // === MÉTODO PARA OBTENER TODAS LAS ÓRDENES SIN PAGINACIÓN (para reportes) ===
    public ArrayList<OrdenCompraBean> listarTodasOrdenes(String busqueda, String proveedorId, String estado) {
        return obtenerOrdenes(busqueda, proveedorId, estado, 1, Integer.MAX_VALUE);
    }

    // === MÉTODO PARA CONTAR TOTAL DE ÓRDENES CON FILTROS ===
    public int contarOrdenes(String busqueda, String proveedorId, String estado) {
        String sql = """
            SELECT COUNT(*) as total FROM (
                SELECT
                    oc.id_orden_compra AS id_orden,
                    CASE 
                        WHEN oc.estado = 'Pendiente' AND oc.lote_id IS NOT NULL THEN 'Recibido'
                        WHEN oc.estado IN ('Recibido', 'En Proceso') THEN 'Pendiente'
                        ELSE oc.estado
                    END AS estado
                FROM ordenes_compra oc
                INNER JOIN usuarios productor ON oc.productor_id = productor.id_usuario
                INNER JOIN productos pr ON oc.producto_id = pr.id_producto
                INNER JOIN usuarios u ON oc.usuario_id = u.id_usuario
                WHERE 1=1
            """;

        List<Object> params = new ArrayList<>();

        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (pr.nombre LIKE ?";
            params.add("%" + busqueda.trim() + "%");

            String digits = busqueda.replaceAll("\\D", "");
            if (!digits.isEmpty()) {
                sql += " OR oc.id_orden_compra = ?";
                params.add(Integer.parseInt(digits));
            }
            sql += ")";
        }
        if (proveedorId != null && !proveedorId.trim().isEmpty()) {
            sql += " AND productor.id_usuario = ?";
            params.add(Integer.parseInt(proveedorId));
        }
        
        sql += ") AS ordenes_filtradas WHERE 1=1";
        
        // Filtrar por el estado calculado (no el original)
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND estado = ?";
            params.add(estado.trim());
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
            logger.error("Error al contar órdenes de compra", e);
            throw new RuntimeException("Error al contar órdenes de compra", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    public boolean crearOrdenCompra(String numeroOrden, int productorId, int productoId, int cantidad, int usuarioId, double montoTotal, int distritoId) {
        String sql;
        boolean includeNumero = numeroOrden != null && !numeroOrden.isEmpty();
        if (includeNumero) {
            sql = "INSERT INTO ordenes_compra (numero_Orden, productor_id, producto_id, cantidad, usuario_id, estado, monto_total, distrito_id) VALUES (?, ?, ?, ?, ?, 'Pendiente', ?, ?)";
        } else {
            sql = "INSERT INTO ordenes_compra (productor_id, producto_id, cantidad, usuario_id, estado, monto_total, distrito_id) VALUES (?, ?, ?, ?, 'Pendiente', ?, ?)";
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            int idx = 1;
            if (includeNumero) {
                pstmt.setString(idx++, numeroOrden);
            }
            pstmt.setInt(idx++, productorId);
            pstmt.setInt(idx++, productoId);
            pstmt.setInt(idx++, cantidad);
            pstmt.setInt(idx++, usuarioId);
            pstmt.setDouble(idx++, montoTotal);
            pstmt.setInt(idx, distritoId);
            
            int rowsAffected = pstmt.executeUpdate();
            logger.info("Orden de compra creada: {} filas insertadas", rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            logger.error("Error SQL al crear orden de compra", e);
            throw new RuntimeException("Error al crear orden de compra", e);
        } finally {
            closePreparedStatement(pstmt);
            closeConnection(conn);
        }
    }
    
    /**
     * Crea una orden de compra y retorna el ID de la orden creada.
     * Útil cuando se necesita el ID para notificaciones por correo.
     * 
     * @param numeroOrden Número de orden (puede ser null)
     * @param productorId ID del productor
     * @param productoId ID del producto
     * @param cantidad Cantidad de paquetes
     * @param usuarioId ID del usuario que crea la orden (logística)
     * @param montoTotal Monto total de la orden
     * @param distritoId ID del distrito
     * @return ID de la orden creada, o 0 si falla
     */
    public int crearOrdenCompraYRetornarId(String numeroOrden, int productorId, int productoId, int cantidad, int usuarioId, double montoTotal, int distritoId) {
        String sql;
        boolean includeNumero = numeroOrden != null && !numeroOrden.isEmpty();
        if (includeNumero) {
            sql = "INSERT INTO ordenes_compra (numero_Orden, productor_id, producto_id, cantidad, usuario_id, estado, monto_total, distrito_id) VALUES (?, ?, ?, ?, ?, 'Pendiente', ?, ?)";
        } else {
            sql = "INSERT INTO ordenes_compra (productor_id, producto_id, cantidad, usuario_id, estado, monto_total, distrito_id) VALUES (?, ?, ?, ?, 'Pendiente', ?, ?)";
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet generatedKeys = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            int idx = 1;
            if (includeNumero) {
                pstmt.setString(idx++, numeroOrden);
            }
            pstmt.setInt(idx++, productorId);
            pstmt.setInt(idx++, productoId);
            pstmt.setInt(idx++, cantidad);
            pstmt.setInt(idx++, usuarioId);
            pstmt.setDouble(idx++, montoTotal);
            pstmt.setInt(idx, distritoId);
            
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int idOrden = generatedKeys.getInt(1);
                    logger.info("Orden de compra creada con ID: {}", idOrden);
                    return idOrden;
                }
            }
            return 0;
        } catch (SQLException e) {
            logger.error("Error SQL al crear orden de compra y retornar ID", e);
            throw new RuntimeException("Error al crear orden de compra", e);
        } finally {
            closeResultSet(generatedKeys);
            closePreparedStatement(pstmt);
            closeConnection(conn);
        }
    }

    public int obtenerUltimoId() {
        String sql = "SELECT MAX(id_orden_compra) FROM ordenes_compra";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener último ID de orden de compra", e);
            throw new RuntimeException("Error al obtener último ID de orden de compra", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    /**
     * Obtener detalles completos de una orden incluyendo el lote asignado
     * @param idOrden ID de la orden de compra
     * @return Array con todos los detalles de la orden y el lote
     */
    public Object[] obtenerDetalleConLote(int idOrden) {
        String sql = "SELECT " +
                     "CONCAT(productor.nombres, ' ', productor.apellidos) AS productor, " +
                     "CONCAT(u.nombres, ' ', u.apellidos) AS personal_responsable, " +
                     "pr.nombre AS producto, " +
                     "pr.codigo_sku AS sku, " +
                     "oc.cantidad AS cantidad_paquetes, " +
                     "oc.monto_total, " +
                     "oc.estado, " +
                     "l.codigo_lote, " +
                     "l.fecha_vencimiento, " +
                     "l.stock_actual, " +
                     "ub.nombre AS ubicacion " +
                     "FROM ordenes_compra oc " +
                     "INNER JOIN usuarios productor ON oc.productor_id = productor.id_usuario " +
                     "INNER JOIN productos pr ON oc.producto_id = pr.id_producto " +
                     "INNER JOIN usuarios u ON oc.usuario_id = u.id_usuario " +
                     "LEFT JOIN lotes l ON oc.lote_id = l.id_lote " +
                     "LEFT JOIN ubicaciones ub ON l.ubicacion_id = ub.id_ubicacion " +
                     "WHERE oc.id_orden_compra = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idOrden);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Object[] detalle = new Object[11];
                detalle[0] = rs.getString("productor");
                detalle[1] = rs.getString("personal_responsable");
                detalle[2] = rs.getString("producto");
                detalle[3] = rs.getString("sku");
                detalle[4] = rs.getInt("cantidad_paquetes");
                detalle[5] = String.format("S/. %.2f", rs.getDouble("monto_total"));
                detalle[6] = rs.getString("estado");
                detalle[7] = rs.getString("codigo_lote");
                detalle[8] = rs.getDate("fecha_vencimiento");
                detalle[9] = rs.getInt("stock_actual");
                detalle[10] = rs.getString("ubicacion");
                return detalle;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener detalle de orden: " + idOrden, e);
            throw new RuntimeException("Error al obtener detalle de orden", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }

    /**
     * Actualizar el estado de una orden de compra
     * @param idOrden ID de la orden de compra
     * @param nuevoEstado Nuevo estado ('Aprobado' o 'Rechazado')
     * @return true si se actualizó correctamente
     */
    public boolean actualizarEstadoOrden(int idOrden, String nuevoEstado) {
        String sql = "UPDATE ordenes_compra SET estado = ? WHERE id_orden_compra = ?";
        
        int filasAfectadas = executeUpdate(sql, nuevoEstado, idOrden);
        logger.info("Estado de orden {} actualizado a {}", idOrden, nuevoEstado);
        return filasAfectadas > 0;
    }
    
    /**
     * Obtiene el ID del productor (usuario) asociado a una orden de compra.
     * Útil para enviar notificaciones por correo.
     * 
     * @param idOrden ID de la orden de compra
     * @return ID del productor, o 0 si no se encuentra
     */
    public int obtenerProductorIdPorOrden(int idOrden) {
        String sql = "SELECT productor_id FROM ordenes_compra WHERE id_orden_compra = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idOrden);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("productor_id");
            }
        } catch (SQLException e) {
            logger.error("Error al obtener productor_id de la orden: " + idOrden, e);
            throw new RuntimeException("Error al obtener productor_id de la orden", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }
    
    /**
     * Obtiene los datos básicos de una orden para notificaciones.
     * 
     * @param idOrden ID de la orden de compra
     * @return Array con [numeroOrden, nombreProducto, cantidad, montoTotal] o null
     */
    public Object[] obtenerDatosBasicosOrden(int idOrden) {
        String sql = """
            SELECT 
                IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden,
                pr.nombre AS nombre_producto,
                oc.cantidad,
                oc.monto_total,
                oc.productor_id
            FROM ordenes_compra oc
            INNER JOIN productos pr ON oc.producto_id = pr.id_producto
            WHERE oc.id_orden_compra = ?
            """;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idOrden);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Object[] datos = new Object[5];
                datos[0] = rs.getString("numero_orden");
                datos[1] = rs.getString("nombre_producto");
                datos[2] = rs.getInt("cantidad");
                datos[3] = rs.getDouble("monto_total");
                datos[4] = rs.getInt("productor_id");
                return datos;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener datos básicos de la orden: " + idOrden, e);
            throw new RuntimeException("Error al obtener datos básicos de la orden", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }
    
    /**
     * Obtiene los datos necesarios para revertir el stock cuando se rechaza una orden.
     * @param idOrden ID de la orden de compra
     * @return Array con [lote_id, cantidad_paquetes, producto_id, productor_id] o null si no tiene lote asignado
     */
    public Object[] obtenerDatosParaRevertirStock(int idOrden) {
        String sql = """
            SELECT 
                oc.lote_id,
                oc.cantidad,
                oc.producto_id,
                oc.productor_id
            FROM ordenes_compra oc
            WHERE oc.id_orden_compra = ? AND oc.lote_id IS NOT NULL AND oc.lote_id > 0
            """;
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idOrden);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Object[] datos = new Object[4];
                datos[0] = rs.getInt("lote_id");
                datos[1] = rs.getInt("cantidad"); // cantidad en paquetes
                datos[2] = rs.getInt("producto_id");
                datos[3] = rs.getInt("productor_id");
                return datos;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener datos para revertir stock de la orden: " + idOrden, e);
            throw new RuntimeException("Error al obtener datos para revertir stock", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }
}