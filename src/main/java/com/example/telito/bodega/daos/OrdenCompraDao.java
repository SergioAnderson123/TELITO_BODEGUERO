package com.example.telito.bodega.daos;

import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrdenCompraDao {

    /**
     * Obtener todas las órdenes de compra dirigidas a un productor específico
     * @param productorId ID del usuario productor
     * @return Lista de objetos con datos de la orden
     */
    public List<Object[]> listarOrdenesPorProductor(int productorId) {
        List<Object[]> ordenes = new ArrayList<>();
        String sql = "SELECT oc.id_orden_compra, " +
                     "oc.numero_Orden, " +
                     "p.nombre AS producto_nombre, " +
                     "oc.cantidad, " +
                     "oc.monto_total, " +
                     "d.nombre AS distrito_destino, " +
                     "z.nombre AS zona_destino, " +
                     "oc.estado, " +
                     "oc.lote_id " +
                     "FROM ordenes_compra oc " +
                     "INNER JOIN productos p ON oc.producto_id = p.id_producto " +
                     "INNER JOIN distritos d ON oc.distrito_id = d.idDistrito " +
                     "INNER JOIN zonas z ON d.zona_id = z.idZona " +
                     "WHERE p.productor_id = ? " +
                     "ORDER BY oc.id_orden_compra DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, productorId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Object[] orden = new Object[9];
                    orden[0] = rs.getInt("id_orden_compra");
                    orden[1] = rs.getString("numero_Orden");
                    orden[2] = rs.getString("producto_nombre");
                    orden[3] = rs.getInt("cantidad");
                    orden[4] = rs.getDouble("monto_total");
                    orden[5] = rs.getString("zona_destino") + " - " + rs.getString("distrito_destino");
                    orden[6] = rs.getString("estado");
                    orden[7] = rs.getObject("lote_id"); // puede ser null
                    orden[8] = rs.getString("distrito_destino"); // distrito solo
                    ordenes.add(orden);
                }
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al listar órdenes de compra por productor: " + e.getMessage());
            e.printStackTrace();
        }
        return ordenes;
    }

    /**
     * Obtener detalles completos de una orden de compra
     * @param idOrden ID de la orden de compra
     * @return Array con todos los datos de la orden
     */
    public Object[] obtenerDetalleOrden(int idOrden) {
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
                     "WHERE oc.id_orden_compra = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idOrden);
            
            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al obtener detalle de orden: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Actualizar el estado de una orden de compra a "Completada" y asociar un lote
     * @param idOrden ID de la orden de compra
     * @param idLote ID del lote generado
     * @return true si se actualizó correctamente
     */
    public boolean completarOrden(int idOrden, int idLote) {
        String sql = "UPDATE ordenes_compra SET estado = 'Recibido', lote_id = ? WHERE id_orden_compra = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idLote);
            pstmt.setInt(2, idOrden);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: Error al completar orden: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}



