package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class MovimientoDao extends DAOBase {

    public int contarTotalMovimientos() {
        return contarTotalMovimientos(null, null, null);
    }
    
    public int contarTotalMovimientos(String busqueda, String tipoMovimiento, String filtroUsuario) {
        String sql = "SELECT COUNT(*) FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "INNER JOIN usuarios u ON (m.usuario_id = u.id_usuario) " +
                "WHERE 1=1";
        
        java.util.List<Object> params = new java.util.ArrayList<>();
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.nombre LIKE ? OR l.codigo_lote LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        if (tipoMovimiento != null && !tipoMovimiento.trim().isEmpty()) {
            if ("Ajuste".equals(tipoMovimiento)) {
                sql += " AND m.motivo LIKE 'Ajuste de inventario%'";
            } else {
                sql += " AND m.tipo = ?";
                params.add(tipoMovimiento.trim());
            }
        }
        
        if ("mios".equals(filtroUsuario)) {
            // Este filtro se maneja en el servlet pasando el usuarioId
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
            logger.error("Error al contar movimientos", e);
            throw new RuntimeException("Error al contar movimientos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    /**
     * Cuenta movimientos de tipo 'Entrada'
     */
    public int contarMovimientosEntrada(String busqueda) {
        return contarTotalMovimientos(busqueda, "Entrada", null);
    }

    /**
     * Cuenta movimientos de tipo 'Salida'
     */
    public int contarMovimientosSalida(String busqueda) {
        return contarTotalMovimientos(busqueda, "Salida", null);
    }

    /**
     * Cuenta movimientos de tipo 'Ajuste'
     */
    public int contarMovimientosAjuste(String busqueda) {
        String sql = "SELECT COUNT(*) FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "WHERE m.motivo LIKE 'Ajuste de inventario%'";
        
        java.util.List<Object> params = new java.util.ArrayList<>();
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.nombre LIKE ? OR l.codigo_lote LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
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
            logger.error("Error al contar movimientos de ajuste", e);
            throw new RuntimeException("Error al contar movimientos de ajuste", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }
    
    public int contarMovimientosPorUsuario(int usuarioId) {
        return contarMovimientosPorUsuario(usuarioId, null, null);
    }
    
    public int contarMovimientosPorUsuario(int usuarioId, String busqueda, String tipoMovimiento) {
        String sql = "SELECT COUNT(*) FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "INNER JOIN usuarios u ON (m.usuario_id = u.id_usuario) " +
                "WHERE m.usuario_id = ?";
        
        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(usuarioId);
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.nombre LIKE ? OR l.codigo_lote LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        if (tipoMovimiento != null && !tipoMovimiento.trim().isEmpty()) {
            if ("Ajuste".equals(tipoMovimiento)) {
                sql += " AND m.motivo LIKE 'Ajuste de inventario%'";
            } else {
                sql += " AND m.tipo = ?";
                params.add(tipoMovimiento.trim());
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
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar movimientos por usuario", e);
            throw new RuntimeException("Error al contar movimientos por usuario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    public void registrarMovimiento(Movimiento movimiento) {
        // CORRECCIÓN: Se añade la columna 'orden_compra_id'
        String sql = "INSERT INTO movimientos_inventario (lote_id, usuario_id, pedido_id, orden_compra_id, tipo, cantidad, motivo) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        executeUpdate(sql,
            movimiento.getLoteId(),
            movimiento.getUsuarioId(),
            movimiento.getPedidoId(),
            movimiento.getOrdenCompraId(),
            movimiento.getTipoMovimiento(),
            movimiento.getCantidad(),
            movimiento.getMotivo());
    }

    public ArrayList<Movimiento> listarMovimientosPorUsuarioPaginado(int usuarioId, int limit, int offset) {
        return listarMovimientosPorUsuarioPaginado(usuarioId, limit, offset, null, null);
    }
    
    public ArrayList<Movimiento> listarMovimientosPorUsuarioPaginado(int usuarioId, int limit, int offset, String busqueda, String tipoMovimiento) {
        ArrayList<Movimiento> listaMovimientos = new ArrayList<>();

        String sql = "SELECT " +
                "m.id_movimiento, m.tipo, m.cantidad, m.motivo, m.fecha, " +
                "l.codigo_lote, " +
                "p.nombre AS nombre_producto, " +
                "CONCAT(u.nombres, ' ', u.apellidos) AS nombre_usuario, " +
                "ped.numero_pedido, " +
                "oc.numero_orden " +
                "FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "INNER JOIN usuarios u ON (m.usuario_id = u.id_usuario) " +
                "LEFT JOIN pedidos ped ON (m.pedido_id = ped.id_pedido) " +
                "LEFT JOIN ordenes_compra oc ON (m.orden_compra_id = oc.id_orden_compra) " +
                "WHERE m.usuario_id = ?";

        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(usuarioId);
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.nombre LIKE ? OR l.codigo_lote LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        if (tipoMovimiento != null && !tipoMovimiento.trim().isEmpty()) {
            if ("Ajuste".equals(tipoMovimiento)) {
                sql += " AND m.motivo LIKE 'Ajuste de inventario%'";
            } else {
                sql += " AND m.tipo = ?";
                params.add(tipoMovimiento.trim());
            }
        }
        
        sql += " ORDER BY m.fecha DESC LIMIT ? OFFSET ?";

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
                Movimiento mov = new Movimiento();
                mov.setIdMovimiento(rs.getInt("id_movimiento"));
                mov.setTipoMovimiento(rs.getString("tipo"));
                mov.setCantidad(rs.getInt("cantidad"));
                mov.setMotivo(rs.getString("motivo"));
                mov.setFecha(rs.getTimestamp("fecha"));
                mov.setCodigoLote(rs.getString("codigo_lote"));
                mov.setNombreProducto(rs.getString("nombre_producto"));
                mov.setNombreUsuario(rs.getString("nombre_usuario"));
                mov.setNumeroPedido(rs.getString("numero_pedido"));
                mov.setNumeroOrdenCompra(rs.getString("numero_orden"));
                listaMovimientos.add(mov);
            }
        } catch (SQLException e) {
            logger.error("Error al listar los movimientos del usuario", e);
            throw new RuntimeException("Error al listar los movimientos del usuario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaMovimientos;
    }

    /**
     * NUEVO MÉTODO
     * Obtiene una lista completa de todos los movimientos de inventario.
     * Une varias tablas para obtener datos legibles en lugar de solo IDs.
     * @return ArrayList de objetos Movimiento, cada uno con información detallada.
     */
    public ArrayList<Movimiento> listarMovimientosPaginado(int limit, int offset) {
        return listarMovimientosPaginado(limit, offset, null, null);
    }
    
    public ArrayList<Movimiento> listarMovimientosPaginado(int limit, int offset, String busqueda, String tipoMovimiento) {
        ArrayList<Movimiento> listaMovimientos = new ArrayList<>();

        String sql = "SELECT " +
                "m.id_movimiento, m.tipo, m.cantidad, m.motivo, m.fecha, " +
                "l.codigo_lote, " +
                "p.nombre AS nombre_producto, " +
                "CONCAT(u.nombres, ' ', u.apellidos) AS nombre_usuario, " +
                "ped.numero_pedido, " +
                "oc.numero_orden " +
                "FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "INNER JOIN usuarios u ON (m.usuario_id = u.id_usuario) " +
                "LEFT JOIN pedidos ped ON (m.pedido_id = ped.id_pedido) " +
                "LEFT JOIN ordenes_compra oc ON (m.orden_compra_id = oc.id_orden_compra) " +
                "WHERE 1=1";

        java.util.List<Object> params = new java.util.ArrayList<>();
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.nombre LIKE ? OR l.codigo_lote LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        
        if (tipoMovimiento != null && !tipoMovimiento.trim().isEmpty()) {
            if ("Ajuste".equals(tipoMovimiento)) {
                sql += " AND m.motivo LIKE 'Ajuste de inventario%'";
            } else {
                sql += " AND m.tipo = ?";
                params.add(tipoMovimiento.trim());
            }
        }
        
        sql += " ORDER BY m.fecha DESC LIMIT ? OFFSET ?";

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
                Movimiento mov = new Movimiento();
                mov.setIdMovimiento(rs.getInt("id_movimiento"));
                mov.setTipoMovimiento(rs.getString("tipo"));
                mov.setCantidad(rs.getInt("cantidad"));
                mov.setMotivo(rs.getString("motivo"));
                mov.setFecha(rs.getTimestamp("fecha"));
                mov.setCodigoLote(rs.getString("codigo_lote"));
                mov.setNombreProducto(rs.getString("nombre_producto"));
                mov.setNombreUsuario(rs.getString("nombre_usuario"));
                mov.setNumeroPedido(rs.getString("numero_pedido"));
                mov.setNumeroOrdenCompra(rs.getString("numero_orden"));
                listaMovimientos.add(mov);
            }
        } catch (SQLException e) {
            logger.error("Error al listar los movimientos de inventario", e);
            throw new RuntimeException("Error al listar los movimientos de inventario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaMovimientos;
    }

    /**
     * MÉTODO NUEVO
     * Obtiene una lista completa de todos los movimientos de inventario sin paginación.
     * Útil para reportes y exportaciones.
     * @return ArrayList de objetos Movimiento, cada uno con información detallada.
     */
    public ArrayList<Movimiento> listarTodosMovimientos() {
        ArrayList<Movimiento> listaMovimientos = new ArrayList<>();

        String sql = "SELECT " +
                "m.id_movimiento, m.tipo, m.cantidad, m.motivo, m.fecha, " +
                "l.codigo_lote, " +
                "p.nombre AS nombre_producto, " +
                "CONCAT(u.nombres, ' ', u.apellidos) AS nombre_usuario, " +
                "ped.numero_pedido, " +
                "oc.numero_orden " +
                "FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "INNER JOIN usuarios u ON (m.usuario_id = u.id_usuario) " +
                "LEFT JOIN pedidos ped ON (m.pedido_id = ped.id_pedido) " +
                "LEFT JOIN ordenes_compra oc ON (m.orden_compra_id = oc.id_orden_compra) " +
                "ORDER BY m.fecha DESC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Movimiento mov = new Movimiento();
                mov.setIdMovimiento(rs.getInt("id_movimiento"));
                mov.setTipoMovimiento(rs.getString("tipo"));
                mov.setCantidad(rs.getInt("cantidad"));
                mov.setMotivo(rs.getString("motivo"));
                mov.setFecha(rs.getTimestamp("fecha"));
                mov.setCodigoLote(rs.getString("codigo_lote"));
                mov.setNombreProducto(rs.getString("nombre_producto"));
                mov.setNombreUsuario(rs.getString("nombre_usuario"));
                mov.setNumeroPedido(rs.getString("numero_pedido"));
                mov.setNumeroOrdenCompra(rs.getString("numero_orden"));
                listaMovimientos.add(mov);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todos los movimientos de inventario", e);
            throw new RuntimeException("Error al listar todos los movimientos de inventario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaMovimientos;
    }
    
    /**
     * Obtiene los movimientos de ajuste de un lote específico.
     */
    public ArrayList<Movimiento> listarAjustesPorLote(int loteId) {
        ArrayList<Movimiento> listaMovimientos = new ArrayList<>();
        
        String sql = "SELECT " +
                "m.id_movimiento, m.tipo, m.cantidad, m.motivo, m.fecha, " +
                "l.codigo_lote, " +
                "p.nombre AS nombre_producto, " +
                "CONCAT(u.nombres, ' ', u.apellidos) AS nombre_usuario " +
                "FROM movimientos_inventario m " +
                "INNER JOIN lotes l ON (m.lote_id = l.id_lote) " +
                "INNER JOIN productos p ON (l.producto_id = p.id_producto) " +
                "INNER JOIN usuarios u ON (m.usuario_id = u.id_usuario) " +
                "WHERE m.lote_id = ? AND m.motivo LIKE 'Ajuste de inventario%' " +
                "ORDER BY m.fecha DESC " +
                "LIMIT 10";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, loteId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Movimiento mov = new Movimiento();
                mov.setIdMovimiento(rs.getInt("id_movimiento"));
                mov.setTipoMovimiento(rs.getString("tipo"));
                mov.setCantidad(rs.getInt("cantidad"));
                mov.setMotivo(rs.getString("motivo"));
                mov.setFecha(rs.getTimestamp("fecha"));
                mov.setCodigoLote(rs.getString("codigo_lote"));
                mov.setNombreProducto(rs.getString("nombre_producto"));
                mov.setNombreUsuario(rs.getString("nombre_usuario"));
                listaMovimientos.add(mov);
            }
        } catch (SQLException e) {
            logger.error("Error al listar ajustes por lote", e);
            throw new RuntimeException("Error al listar ajustes por lote", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return listaMovimientos;
    }
    
    /**
     * Elimina los movimientos de salida relacionados con una orden de compra.
     * Se usa cuando se rechaza una orden para revertir el descuento de stock.
     * @param ordenCompraId ID de la orden de compra
     * @return true si se eliminó al menos un movimiento, false si no se encontró ninguno
     */
    public boolean eliminarMovimientoPorOrdenCompra(int ordenCompraId) {
        String sql = "DELETE FROM movimientos_inventario WHERE orden_compra_id = ? AND tipo = 'Salida'";
        
        int filasAfectadas = executeUpdate(sql, ordenCompraId);
        logger.info("Movimientos de salida eliminados para orden de compra {}: {} filas", ordenCompraId, filasAfectadas);
        return filasAfectadas > 0;
    }
}