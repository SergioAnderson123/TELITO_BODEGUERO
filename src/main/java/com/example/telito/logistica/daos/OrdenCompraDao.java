package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.OrdenCompraBean;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrdenCompraDao {

    // === MÉTODO MODIFICADO PARA ACEPTAR FILTROS (sin paginación, para compatibilidad) ===
    public ArrayList<OrdenCompraBean> obtenerOrdenes(String busqueda, String proveedorId, String estado) {
        return obtenerOrdenes(busqueda, proveedorId, estado, 1, Integer.MAX_VALUE);
    }

    // === MÉTODO CON PAGINACIÓN PARA OBTENER ÓRDENES DE COMPRA ===
    public ArrayList<OrdenCompraBean> obtenerOrdenes(String busqueda, String proveedorId, String estado, int page, int size) {

        ArrayList<OrdenCompraBean> listaOrdenes = new ArrayList<>();

        String sql = """
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
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND oc.estado = ?";
            params.add(estado.trim());
        }

        sql += " ORDER BY oc.id_orden_compra DESC LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int paramIndex = 1;
            for (Object param : params) {
                pstmt.setObject(paramIndex++, param);
            }

            // Parámetros de paginación
            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
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
            SELECT COUNT(*) as total
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
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND oc.estado = ?";
            params.add(estado.trim());
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
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
        
        System.out.println("=== DEBUG DAO - CREAR ORDEN DE COMPRA ===");
        System.out.println("SQL: " + sql);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            int idx = 1;
            if (includeNumero) {
                pstmt.setString(idx++, numeroOrden);
                System.out.println("Param " + (idx-1) + ": " + numeroOrden);
            }
            pstmt.setInt(idx++, productorId);
            System.out.println("Param " + (idx-1) + " (productor_id): " + productorId);
            pstmt.setInt(idx++, productoId);
            System.out.println("Param " + (idx-1) + " (producto_id): " + productoId);
            pstmt.setInt(idx++, cantidad);
            System.out.println("Param " + (idx-1) + " (cantidad): " + cantidad);
            pstmt.setInt(idx++, usuarioId);
            System.out.println("Param " + (idx-1) + " (usuario_id): " + usuarioId);
            pstmt.setDouble(idx++, montoTotal);
            System.out.println("Param " + (idx-1) + " (monto_total): " + montoTotal);
            pstmt.setInt(idx, distritoId);
            System.out.println("Param " + idx + " (distrito_id): " + distritoId);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("✓ DAO: Filas insertadas = " + rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ ERROR SQL al crear orden de compra:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            return false;
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
        
        System.out.println("=== DEBUG DAO - CREAR ORDEN DE COMPRA Y RETORNAR ID ===");
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
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
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int idOrden = generatedKeys.getInt(1);
                        System.out.println("✓ DAO: Orden creada con ID: " + idOrden);
                        return idOrden;
                    }
                }
            }
            return 0;
        } catch (SQLException e) {
            System.err.println("❌ ERROR SQL al crear orden de compra:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }

    // === CÓDIGO RESTAURADO (Y CAUSA DEL ERROR) ===
    public int obtenerUltimoId() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        String sql = "SELECT MAX(id_orden_compra) FROM ordenes_compra";
        int ultimoId = 0;

        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                ultimoId = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return ultimoId;
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

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idOrden);
            
            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            System.err.println("ERROR: Error al obtener detalle de orden: " + e.getMessage());
            e.printStackTrace();
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
        
        System.out.println("=== DEBUG DAO - ACTUALIZAR ESTADO ===");
        System.out.println("ID Orden: " + idOrden);
        System.out.println("Nuevo Estado: " + nuevoEstado);
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, idOrden);
            
            int rowsAffected = pstmt.executeUpdate();
            System.out.println("✓ Filas actualizadas: " + rowsAffected);
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ ERROR: Error al actualizar estado:");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
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
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idOrden);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("productor_id");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener productor_id de la orden: " + e.getMessage());
            e.printStackTrace();
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
                    datos[4] = rs.getInt("productor_id");
                    return datos;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener datos básicos de la orden: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}