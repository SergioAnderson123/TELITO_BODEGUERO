package com.example.telito.productor.daos;

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

        System.out.println("=== DEBUG DAO PRODUCTOR - Listar Órdenes ===");
        System.out.println("Productor ID: " + productorId);

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Actualizar órdenes pendientes a recibido
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setInt(1, productorId);
                int updated = updateStmt.executeUpdate();
                if (updated > 0) {
                    System.out.println("✓ Órdenes actualizadas de Pendiente a Recibido: " + updated);
                }
            }
            
            // Luego obtener todas las órdenes
            try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
                selectStmt.setInt(1, productorId);
                
                try (ResultSet rs = selectStmt.executeQuery()) {
                    int count = 0;
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
                        count++;
                    }
                    System.out.println("✓ Órdenes encontradas: " + count);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al listar órdenes de compra por productor:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
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
     * Actualizar el estado de una orden de compra a "Pendiente" y asociar un lote
     * @param idOrden ID de la orden de compra
     * @param idLote ID del lote generado
     * @return true si se actualizó correctamente
     */
    public boolean completarOrden(int idOrden, int idLote) {
        String sql = "UPDATE ordenes_compra SET estado = 'Pendiente', lote_id = ? WHERE id_orden_compra = ?";

        System.out.println("=== DEBUG DAO - COMPLETAR ORDEN ===");
        System.out.println("ID Orden: " + idOrden);
        System.out.println("ID Lote: " + idLote);
        System.out.println("Nuevo Estado: Pendiente");

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idLote);
            pstmt.setInt(2, idOrden);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("✓ Filas actualizadas: " + rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al completar orden: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Actualizar el estado de una orden de compra
     * @param idOrden ID de la orden de compra
     * @param nuevoEstado Nuevo estado de la orden
     * @return true si se actualizó correctamente
     */
    public boolean actualizarEstadoOrden(int idOrden, String nuevoEstado) {
        String sql = "UPDATE ordenes_compra SET estado = ? WHERE id_orden_compra = ?";

        System.out.println("=== DEBUG DAO - ACTUALIZAR ESTADO ===");
        System.out.println("ID Orden: " + idOrden);
        System.out.println("Nuevo Estado: " + nuevoEstado);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, idOrden);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("✓ Filas actualizadas: " + rowsAffected);
            
            if (rowsAffected == 0) {
                System.err.println("⚠️ ADVERTENCIA: No se encontró la orden con ID " + idOrden + " o ya tiene el estado " + nuevoEstado);
            }
            
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al actualizar estado de orden:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.err.println("❌ ERROR INESPERADO: Error al actualizar estado de orden:");
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Obtiene los datos básicos de una orden para notificaciones.
     * Incluye el usuario_id de logística que creó la orden.
     * 
     * @param idOrden ID de la orden de compra
     * @return Array con [numeroOrden, nombreProducto, cantidad, montoTotal, usuarioIdLogistica] o null
     */
    public Object[] obtenerDatosBasicosOrden(int idOrden) {
        String sql = """
            SELECT 
                IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden,
                pr.nombre AS nombre_producto,
                oc.cantidad,
                oc.monto_total,
                oc.usuario_id
            FROM ordenes_compra oc
            INNER JOIN productos pr ON oc.producto_id = pr.id_producto
            WHERE oc.id_orden_compra = ?
            """;

        System.out.println("=== DEBUG DAO - OBTENER DATOS BÁSICOS ORDEN ===");
        System.out.println("ID Orden: " + idOrden);

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idOrden);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Object[] datos = new Object[5];
                    datos[0] = rs.getString("numero_orden");
                    datos[1] = rs.getString("nombre_producto");
                    datos[2] = rs.getInt("cantidad");
                    datos[3] = rs.getDouble("monto_total");
                    datos[4] = rs.getInt("usuario_id");
                    
                    System.out.println("✓ Datos obtenidos:");
                    System.out.println("  - Número orden: " + datos[0]);
                    System.out.println("  - Producto: " + datos[1]);
                    System.out.println("  - Cantidad: " + datos[2]);
                    System.out.println("  - Monto total: " + datos[3]);
                    System.out.println("  - Usuario ID logística: " + datos[4]);
                    
                    return datos;
                } else {
                    System.err.println("❌ No se encontró la orden con ID: " + idOrden);
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al obtener datos básicos de orden:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("❌ ERROR INESPERADO: Error al obtener datos básicos de orden:");
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}

