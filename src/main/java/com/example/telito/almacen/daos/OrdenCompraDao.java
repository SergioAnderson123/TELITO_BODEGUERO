package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.OrdenCompra;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class OrdenCompraDao extends DAOBase {

    public int contarOrdenesPendientes() {
        return contarOrdenesPendientes(null, null, null);
    }
    
    public int contarOrdenesPendientes(String busqueda, String proveedorId) {
        return contarOrdenesPendientes(busqueda, proveedorId, null);
    }
    
    public int contarOrdenesPendientes(String busqueda, String proveedorId, String estado) {
        String sql = "SELECT COUNT(*) FROM (" +
                "SELECT oc.id_orden_compra, " +
                "CASE " +
                "    WHEN EXISTS (SELECT 1 FROM movimientos_inventario mi WHERE mi.orden_compra_id = oc.id_orden_compra AND mi.tipo = 'Entrada') " +
                "    THEN 'Registrado' " +
                "    ELSE oc.estado " +
                "END AS estado_calculado " +
                "FROM ordenes_compra oc " +
                "INNER JOIN productos prod ON (oc.producto_id = prod.id_producto) " +
                "INNER JOIN usuarios productor ON (oc.productor_id = productor.id_usuario) " +
                "WHERE oc.estado = 'Aprobado'";
        
        java.util.List<Object> params = new java.util.ArrayList<>();
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (prod.nombre LIKE ? OR oc.numero_Orden LIKE ?";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            
            // Si el usuario ingresa algo como OC001 o 001, intentamos filtrar por id
            String digits = busqueda.replaceAll("\\D", "");
            if (!digits.isEmpty()) {
                try {
                    sql += " OR oc.id_orden_compra = ?";
                    params.add(Integer.parseInt(digits));
                } catch (NumberFormatException e) {
                    // Ignorar si no es un número válido
                }
            }
            sql += ")";
        }
        
        if (proveedorId != null && !proveedorId.trim().isEmpty()) {
            sql += " AND productor.id_usuario = ?";
            params.add(Integer.parseInt(proveedorId));
        }
        
        sql += ") AS ordenes_filtradas";
        
        // Filtro por estado - aplicar sobre el estado calculado
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " WHERE estado_calculado = ?";
            params.add(estado);
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
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar órdenes pendientes", e);
            throw new RuntimeException("Error al contar órdenes pendientes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    /**
     * Cuenta todas las órdenes con estado 'Aprobado' (total de órdenes disponibles para recibir)
     */
    public int contarTotalOrdenes() {
        String sql = "SELECT COUNT(*) FROM ordenes_compra WHERE estado = 'Aprobado'";
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
            logger.error("Error al contar total de órdenes", e);
            throw new RuntimeException("Error al contar total de órdenes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    /**
     * Cuenta las órdenes que ya tienen movimientos de entrada registrados (ya fueron recibidas)
     */
    public int contarOrdenesRegistradas() {
        String sql = "SELECT COUNT(DISTINCT oc.id_orden_compra) FROM ordenes_compra oc " +
                "INNER JOIN movimientos_inventario mi ON mi.orden_compra_id = oc.id_orden_compra " +
                "WHERE oc.estado = 'Aprobado' AND mi.tipo = 'Entrada'";
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
            logger.error("Error al contar órdenes registradas", e);
            throw new RuntimeException("Error al contar órdenes registradas", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    public ArrayList<OrdenCompra> listarOrdenesPaginadas(int offset, int limit) {
        return listarOrdenesPaginadas(offset, limit, null, null, null);
    }
    
    public ArrayList<OrdenCompra> listarOrdenesPaginadas(int offset, int limit, String busqueda, String proveedorId) {
        return listarOrdenesPaginadas(offset, limit, busqueda, proveedorId, null);
    }
    
    public ArrayList<OrdenCompra> listarOrdenesPaginadas(int offset, int limit, String busqueda, String proveedorId, String estado) {
        ArrayList<OrdenCompra> lista = new ArrayList<>();
        String sql = "SELECT * FROM (" +
                "SELECT oc.id_orden_compra, " +
                "IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden, " +
                "prod.nombre AS producto_nombre, " +
                "CONCAT(productor.nombres, ' ', productor.apellidos) AS nombre_productor, " +
                "oc.cantidad, " +
                "CASE " +
                "    WHEN EXISTS (SELECT 1 FROM movimientos_inventario mi WHERE mi.orden_compra_id = oc.id_orden_compra AND mi.tipo = 'Entrada') " +
                "    THEN 'Registrado' " +
                "    ELSE oc.estado " +
                "END AS estado " +
                "FROM ordenes_compra oc " +
                "INNER JOIN productos prod ON (oc.producto_id = prod.id_producto) " +
                "INNER JOIN usuarios productor ON (oc.productor_id = productor.id_usuario) " +
                "WHERE oc.estado = 'Aprobado'";

        java.util.List<Object> params = new java.util.ArrayList<>();
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (prod.nombre LIKE ? OR oc.numero_Orden LIKE ?";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            
            // Si el usuario ingresa algo como OC001 o 001, intentamos filtrar por id
            String digits = busqueda.replaceAll("\\D", "");
            if (!digits.isEmpty()) {
                try {
                    sql += " OR oc.id_orden_compra = ?";
                    params.add(Integer.parseInt(digits));
                } catch (NumberFormatException e) {
                    // Ignorar si no es un número válido
                }
            }
            sql += ")";
        }
        
        if (proveedorId != null && !proveedorId.trim().isEmpty()) {
            sql += " AND productor.id_usuario = ?";
            params.add(Integer.parseInt(proveedorId));
        }
        
        sql += ") AS ordenes_filtradas";
        
        // Filtro por estado - aplicar sobre el estado calculado
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " WHERE estado = ?";
            params.add(estado);
        }
        
        sql += " ORDER BY id_orden_compra DESC LIMIT ? OFFSET ?";

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
            
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                OrdenCompra oc = new OrdenCompra();
                oc.setIdOrdenCompra(rs.getInt("id_orden_compra"));
                oc.setNumeroOrden(rs.getString("numero_orden"));
                oc.setNombreProducto(rs.getString("producto_nombre"));
                oc.setNombreProveedor(rs.getString("nombre_productor"));
                oc.setCantidad(rs.getInt("cantidad"));
                oc.setEstado(rs.getString("estado"));
                lista.add(oc);
            }
        } catch (SQLException e) {
            logger.error("Error al listar órdenes paginadas", e);
            throw new RuntimeException("Error al listar órdenes paginadas", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    /**
     * MÉTODO CORREGIDO
     * Busca una orden de compra por su ID y ahora también incluye el lote_id asociado.
     */
    public OrdenCompra buscarOrdenPorId(int idOrden) {
        OrdenCompra oc = null;
        String sql = "SELECT oc.id_orden_compra, " +
                "IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden, " +
                "oc.producto_id, " +
                "oc.productor_id, " +
                "oc.lote_id, " +
                "oc.cantidad, " +
                "oc.estado, " +
                "prod.nombre AS producto_nombre, " +
                "CONCAT(productor.nombres, ' ', productor.apellidos) AS nombre_productor " +
                "FROM ordenes_compra oc " +
                "INNER JOIN productos prod ON (oc.producto_id = prod.id_producto) " +
                "INNER JOIN usuarios productor ON (oc.productor_id = productor.id_usuario) " +
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
                oc = new OrdenCompra();
                oc.setIdOrdenCompra(rs.getInt("id_orden_compra"));
                oc.setNumeroOrden(rs.getString("numero_orden"));
                oc.setProductoId(rs.getInt("producto_id"));
                oc.setProveedorId(rs.getInt("productor_id"));
                oc.setLoteId(rs.getInt("lote_id"));
                oc.setCantidad(rs.getInt("cantidad"));
                oc.setEstado(rs.getString("estado"));
                oc.setNombreProducto(rs.getString("producto_nombre"));
                oc.setNombreProveedor(rs.getString("nombre_productor"));
            }
        } catch (SQLException e) {
            logger.error("Error al buscar orden por ID: " + idOrden, e);
            throw new RuntimeException("Error al buscar orden por ID", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return oc;
    }

    public void actualizarEstado(int idOrden, String nuevoEstado) {
        String sql = "UPDATE ordenes_compra SET estado = ? WHERE id_orden_compra = ?";
        executeUpdate(sql, nuevoEstado, idOrden);
    }

    /**
     * Lista los productores (usuarios con rol Productor) para usar en filtros.
     * Retorna lista vacía si hay error en lugar de lanzar excepción.
     */
    public ArrayList<java.util.Map<String, Object>> listarProductores() {
        ArrayList<java.util.Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT u.id_usuario, CONCAT(u.nombres, ' ', u.apellidos) as nombre_completo " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "ORDER BY u.nombres ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                java.util.Map<String, Object> productor = new java.util.HashMap<>();
                productor.put("id", rs.getInt("id_usuario"));
                productor.put("nombre", rs.getString("nombre_completo"));
                lista.add(productor);
            }
        } catch (SQLException e) {
            logger.error("Error al listar productores", e);
            // Retornar lista vacía en lugar de lanzar excepción para no romper la página
            return new ArrayList<>();
        } catch (Exception e) {
            logger.error("Error inesperado al listar productores", e);
            return new ArrayList<>();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
    
    /**
     * Obtiene el usuario_id de logística que creó la orden de compra.
     * Útil para enviar notificaciones por correo.
     * 
     * @param idOrden ID de la orden de compra
     * @return ID del usuario de logística, o 0 si no se encuentra
     */
    public int obtenerUsuarioIdLogistica(int idOrden) {
        String sql = "SELECT usuario_id FROM ordenes_compra WHERE id_orden_compra = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idOrden);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("usuario_id");
            }
        } catch (SQLException e) {
            logger.error("Error al obtener usuario_id de logística de la orden: " + idOrden, e);
            throw new RuntimeException("Error al obtener usuario_id de logística", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    /**
     * Método para obtener todas las órdenes sin paginación (para reportes)
     */
    public ArrayList<OrdenCompra> listarTodasLasOrdenes() {
        ArrayList<OrdenCompra> lista = new ArrayList<>();
        String sql = "SELECT oc.id_orden_compra, " +
                "IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden, " +
                "prod.nombre AS producto_nombre, " +
                "prod.sku AS producto_sku, " +
                "CONCAT(productor.nombres, ' ', productor.apellidos) AS nombre_productor, " +
                "oc.cantidad, " +
                "oc.fecha_pedido, " +
                "oc.fecha_entrega_esperada, " +
                "oc.costo_total, " +
                "CASE " +
                "    WHEN EXISTS (SELECT 1 FROM movimientos_inventario mi WHERE mi.orden_compra_id = oc.id_orden_compra AND mi.tipo = 'Entrada') " +
                "    THEN 'Registrado' " +
                "    ELSE oc.estado " +
                "END AS estado " +
                "FROM ordenes_compra oc " +
                "INNER JOIN productos prod ON (oc.producto_id = prod.id_producto) " +
                "INNER JOIN usuarios productor ON (oc.productor_id = productor.id_usuario) " +
                "WHERE oc.estado = 'Aprobado' " +
                "ORDER BY oc.id_orden_compra DESC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                OrdenCompra oc = new OrdenCompra();
                oc.setIdOrdenCompra(rs.getInt("id_orden_compra"));
                oc.setNumeroOrden(rs.getString("numero_orden"));
                oc.setNombreProducto(rs.getString("producto_nombre"));
                oc.setProductoSku(rs.getString("producto_sku"));
                oc.setNombreProveedor(rs.getString("nombre_productor"));
                oc.setCantidad(rs.getInt("cantidad"));
                
                // Manejo de fechas que pueden ser NULL
                Date fechaPedido = rs.getDate("fecha_pedido");
                if (fechaPedido != null) {
                    oc.setFechaPedido(fechaPedido);
                }
                
                Date fechaEntrega = rs.getDate("fecha_entrega_esperada");
                if (fechaEntrega != null) {
                    oc.setFechaEntregaEsperada(fechaEntrega);
                }
                
                // Manejo de BigDecimal que puede ser NULL
                java.math.BigDecimal costo = rs.getBigDecimal("costo_total");
                if (costo != null) {
                    oc.setCostoTotal(costo);
                }
                
                oc.setEstado(rs.getString("estado"));
                lista.add(oc);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todas las órdenes", e);
            throw new RuntimeException("Error al listar todas las órdenes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}