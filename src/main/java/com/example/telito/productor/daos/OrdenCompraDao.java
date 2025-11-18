package com.example.telito.productor.daos;

import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrdenCompraDao extends DAOBase {

    /**
     * Obtener todas las órdenes de compra dirigidas a un productor específico con paginación
     * @param productorId ID del usuario productor
     * @param offset Número de registros a saltar
     * @param limit Número máximo de registros a retornar
     * @return Lista de objetos con datos de la orden
     */
    public List<Object[]> listarOrdenesPorProductor(int productorId, int offset, int limit) {
        List<Object[]> ordenes = new ArrayList<>();
        
        // Primero actualizamos solo las órdenes Pendientes SIN lote asignado a Recibido
        String updateSql = "UPDATE ordenes_compra oc " +
                          "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                          "SET oc.estado = 'Recibido' " +
                          "WHERE p.productor_id = ? AND oc.estado = 'Pendiente' AND oc.lote_id IS NULL";
        
        String selectSql = "SELECT oc.id_orden_compra, " +
                          "IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden, " +
                          "p.nombre AS producto_nombre, " +
                          "oc.cantidad, " +
                          "oc.monto_total, " +
                          "CONCAT(u.nombres, ' ', u.apellidos) AS usuario_logistica, " +
                          "oc.estado, " +
                          "oc.lote_id " +
                          "FROM ordenes_compra oc " +
                          "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                          "INNER JOIN usuarios u ON oc.usuario_id = u.id_usuario " +
                          "WHERE p.productor_id = ? " +
                          "ORDER BY oc.id_orden_compra DESC " +
                          "LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement updateStmt = null;
        PreparedStatement selectStmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            // Actualizar órdenes pendientes a recibido
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setInt(1, productorId);
            int updated = updateStmt.executeUpdate();
            if (updated > 0) {
                logger.info("Órdenes actualizadas de Pendiente a Recibido: {}", updated);
            }
            
            // Luego obtener todas las órdenes
            selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setInt(1, productorId);
            selectStmt.setInt(2, limit);
            selectStmt.setInt(3, offset);
            rs = selectStmt.executeQuery();

            while (rs.next()) {
                Object[] orden = new Object[8];
                orden[0] = rs.getInt("id_orden_compra");
                orden[1] = rs.getString("numero_orden");
                orden[2] = rs.getString("producto_nombre");
                orden[3] = rs.getInt("cantidad");
                orden[4] = rs.getDouble("monto_total");
                orden[5] = rs.getString("usuario_logistica"); // Usuario que creó la orden
                orden[6] = rs.getString("estado");
                orden[7] = rs.getObject("lote_id"); // puede ser null
                ordenes.add(orden);
            }
        } catch (SQLException e) {
            logger.error("Error al listar órdenes de compra por productor: " + productorId, e);
            throw new RuntimeException("Error al listar órdenes de compra por productor", e);
        } finally {
            closeResultSet(rs);
            closePreparedStatement(selectStmt);
            closePreparedStatement(updateStmt);
            closeConnection(conn);
        }
        return ordenes;
    }

    /**
     * Contar el total de órdenes de compra de un productor
     * @param productorId ID del usuario productor
     * @return Total de órdenes
     */
    public int contarOrdenesPorProductor(int productorId) {
        String sql = "SELECT COUNT(*) " +
                     "FROM ordenes_compra oc " +
                     "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                     "WHERE p.productor_id = ?";
        return count(sql, productorId);
    }

    /**
     * Obtener todas las órdenes de compra dirigidas a un productor específico
     * @param productorId ID del usuario productor
     * @return Lista de objetos con datos de la orden
     */
    public List<Object[]> listarOrdenesPorProductor(int productorId) {
        List<Object[]> ordenes = new ArrayList<>();
        
        // Primero actualizamos solo las órdenes Pendientes SIN lote asignado a Recibido
        String updateSql = "UPDATE ordenes_compra oc " +
                          "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                          "SET oc.estado = 'Recibido' " +
                          "WHERE p.productor_id = ? AND oc.estado = 'Pendiente' AND oc.lote_id IS NULL";
        
        String selectSql = "SELECT oc.id_orden_compra, " +
                          "IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden, " +
                          "p.nombre AS producto_nombre, " +
                          "oc.cantidad, " +
                          "oc.monto_total, " +
                          "CONCAT(u.nombres, ' ', u.apellidos) AS usuario_logistica, " +
                          "oc.estado, " +
                          "oc.lote_id " +
                          "FROM ordenes_compra oc " +
                          "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                          "INNER JOIN usuarios u ON oc.usuario_id = u.id_usuario " +
                          "WHERE p.productor_id = ? " +
                          "ORDER BY oc.id_orden_compra DESC";

        Connection conn = null;
        PreparedStatement updateStmt = null;
        PreparedStatement selectStmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            // Actualizar órdenes pendientes a recibido
            updateStmt = conn.prepareStatement(updateSql);
            updateStmt.setInt(1, productorId);
            int updated = updateStmt.executeUpdate();
            if (updated > 0) {
                logger.info("Órdenes actualizadas de Pendiente a Recibido: {}", updated);
            }
            
            // Luego obtener todas las órdenes
            selectStmt = conn.prepareStatement(selectSql);
            selectStmt.setInt(1, productorId);
            rs = selectStmt.executeQuery();

            while (rs.next()) {
                Object[] orden = new Object[8];
                orden[0] = rs.getInt("id_orden_compra");
                orden[1] = rs.getString("numero_orden");
                orden[2] = rs.getString("producto_nombre");
                orden[3] = rs.getInt("cantidad");
                orden[4] = rs.getDouble("monto_total");
                orden[5] = rs.getString("usuario_logistica"); // Usuario que creó la orden
                orden[6] = rs.getString("estado");
                orden[7] = rs.getObject("lote_id"); // puede ser null
                ordenes.add(orden);
            }
        } catch (SQLException e) {
            logger.error("Error al listar órdenes de compra por productor: " + productorId, e);
            throw new RuntimeException("Error al listar órdenes de compra por productor", e);
        } finally {
            closeResultSet(rs);
            closePreparedStatement(selectStmt);
            closePreparedStatement(updateStmt);
            closeConnection(conn);
        }
        return ordenes;
    }

    /**
     * Obtener detalles completos de una orden de compra, pero SOLO si el producto pertenece al productor especificado.
     * Esto previene que un productor vea órdenes de compra de productos de otros productores.
     * @param idOrden ID de la orden de compra
     * @param productorId ID del productor (debe ser el dueño del producto de la orden)
     * @return Array con todos los datos de la orden, o null si no existe o no pertenece al productor
     */
    public Object[] obtenerDetalleOrden(int idOrden, int productorId) {
        String sql = "SELECT oc.id_orden_compra, " +
                     "oc.numero_Orden, " +
                     "p.nombre AS producto_nombre, " +
                     "p.codigo_sku, " +
                     "p.precio_actual, " +
                     "oc.cantidad, " +
                     "oc.monto_total, " +
                     "d.nombre AS distrito_destino, " +
                     "z.nombre AS zona_destino, " +
                     "oc.estado, " +
                     "CONCAT(u.nombres, ' ', u.apellidos) AS usuario_logistica, " +
                     "oc.lote_id " +
                     "FROM ordenes_compra oc " +
                     "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                     "INNER JOIN distritos d ON oc.distrito_id = d.idDistrito " +
                     "INNER JOIN zonas z ON d.zona_id = z.idZona " +
                     "INNER JOIN usuarios u ON oc.usuario_id = u.id_usuario " +
                     "WHERE oc.id_orden_compra = ? AND p.productor_id = ? AND p.activo = 1";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idOrden);
            pstmt.setInt(2, productorId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Object[] detalle = new Object[12];
                detalle[0] = rs.getInt("id_orden_compra");
                detalle[1] = rs.getString("numero_Orden");
                detalle[2] = rs.getString("producto_nombre");
                detalle[3] = rs.getString("codigo_sku");
                detalle[4] = rs.getDouble("precio_actual");
                detalle[5] = rs.getInt("cantidad");
                detalle[6] = rs.getDouble("monto_total");
                detalle[7] = rs.getString("zona_destino");
                detalle[8] = rs.getString("distrito_destino");
                detalle[9] = rs.getString("estado");
                detalle[10] = rs.getString("usuario_logistica");
                detalle[11] = rs.getObject("lote_id");
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
     * Actualizar el estado de una orden de compra a "Pendiente" y asociar un lote.
     * SOLO si el producto de la orden pertenece al productor especificado.
     * Esto previene que un productor modifique órdenes de compra de productos de otros productores.
     * @param idOrden ID de la orden de compra
     * @param idLote ID del lote generado
     * @param productorId ID del productor (debe ser el dueño del producto de la orden)
     * @return true si se actualizó correctamente, false si la orden no pertenece al productor
     */
    public boolean completarOrden(int idOrden, int idLote, int productorId) {
        String sql = "UPDATE ordenes_compra oc " +
                     "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                     "SET oc.estado = 'Pendiente', oc.lote_id = ? " +
                     "WHERE oc.id_orden_compra = ? AND p.productor_id = ? AND p.activo = 1";

        int filasAfectadas = executeUpdate(sql, idLote, idOrden, productorId);
        logger.info("Orden {} completada con lote {} (productor: {})", idOrden, idLote, productorId);
        return filasAfectadas > 0;
    }

    /**
     * Actualizar el estado de una orden de compra.
     * SOLO si el producto de la orden pertenece al productor especificado.
     * Esto previene que un productor modifique órdenes de compra de productos de otros productores.
     * @param idOrden ID de la orden de compra
     * @param nuevoEstado Nuevo estado de la orden
     * @param productorId ID del productor (debe ser el dueño del producto de la orden)
     * @return true si se actualizó correctamente, false si la orden no pertenece al productor
     */
    public boolean actualizarEstadoOrden(int idOrden, String nuevoEstado, int productorId) {
        String sql = "UPDATE ordenes_compra oc " +
                     "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                     "SET oc.estado = ? " +
                     "WHERE oc.id_orden_compra = ? AND p.productor_id = ? AND p.activo = 1";

        int filasAfectadas = executeUpdate(sql, nuevoEstado, idOrden, productorId);
        if (filasAfectadas == 0) {
            logger.warn("No se encontró la orden con ID {} o no pertenece al productor {} o ya tiene el estado {}", idOrden, productorId, nuevoEstado);
        } else {
            logger.info("Estado de orden {} actualizado a {} (productor: {})", idOrden, nuevoEstado, productorId);
        }
        return filasAfectadas > 0;
    }

    /**
     * Obtiene los datos básicos de una orden para notificaciones.
     * Incluye el usuario_id de logística que creó la orden.
     * SOLO si el producto de la orden pertenece al productor especificado.
     * 
     * @param idOrden ID de la orden de compra
     * @param productorId ID del productor (debe ser el dueño del producto de la orden)
     * @return Array con [numeroOrden, nombreProducto, cantidad, montoTotal, usuarioIdLogistica] o null
     */
    public Object[] obtenerDatosBasicosOrden(int idOrden, int productorId) {
        String sql = """
            SELECT 
                IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden,
                pr.nombre AS nombre_producto,
                oc.cantidad,
                oc.monto_total,
                oc.usuario_id
            FROM ordenes_compra oc
            INNER JOIN productos pr ON oc.producto_id = pr.id_producto
            WHERE oc.id_orden_compra = ? AND pr.productor_id = ? AND pr.activo = 1
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idOrden);
            pstmt.setInt(2, productorId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Object[] datos = new Object[5];
                datos[0] = rs.getString("numero_orden");
                datos[1] = rs.getString("nombre_producto");
                datos[2] = rs.getInt("cantidad");
                datos[3] = rs.getDouble("monto_total");
                datos[4] = rs.getInt("usuario_id");
                return datos;
            } else {
                logger.warn("No se encontró la orden con ID: {}", idOrden);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener datos básicos de orden: " + idOrden, e);
            throw new RuntimeException("Error al obtener datos básicos de orden", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }
}

