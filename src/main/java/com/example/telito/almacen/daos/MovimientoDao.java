package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class MovimientoDao extends DAOBase {

    public int contarTotalMovimientos() {
        String sql = "SELECT COUNT(*) FROM movimientos_inventario";
        return count(sql);
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
    public int contarMovimientosPorUsuario(int usuarioId) {
        String sql = "SELECT COUNT(*) FROM movimientos_inventario WHERE usuario_id = ?";
        return count(sql, usuarioId);
    }

    public ArrayList<Movimiento> listarMovimientosPorUsuarioPaginado(int usuarioId, int limit, int offset) {
        ArrayList<Movimiento> listaMovimientos = new ArrayList<>();

        // La consulta es casi idéntica a la anterior, solo se añade un WHERE
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
                "WHERE m.usuario_id = ? " + // <-- El filtro principal
                "ORDER BY m.fecha DESC " +
                "LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);
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
                "ORDER BY m.fecha DESC " + // Ordenamos por fecha, del más reciente al más antiguo
                "LIMIT ? OFFSET ?";       // <-- Añadimos límite y offset para paginación

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
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
}