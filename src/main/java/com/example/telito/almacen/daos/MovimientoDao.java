package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.Movimiento;
import java.sql.*;
import java.util.ArrayList;

public class MovimientoDao {

    private String url = "jdbc:mysql://localhost:3306/telito_bodeguero"; // Asegúrate que sea el nombre correcto
    private String user = "root";
    private String pass = "root";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error al cargar el driver de MySQL", e);
        }
    }

    public int contarTotalMovimientos() {
        String sql = "SELECT COUNT(*) FROM movimientos_inventario";
        int total = 0;

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al contar los movimientos", e);
        }
        return total;
    }

    public void registrarMovimiento(Movimiento movimiento) {
        // CORRECCIÓN: Se añade la columna 'orden_compra_id'
        String sql = "INSERT INTO movimientos_inventario (lote_id, usuario_id, pedido_id, orden_compra_id, tipo, cantidad, motivo) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, movimiento.getLoteId());
            pstmt.setObject(2, movimiento.getUsuarioId());
            pstmt.setObject(3, movimiento.getPedidoId());
            pstmt.setObject(4, movimiento.getOrdenCompraId()); // Se añade el ID de orden de compra
            pstmt.setString(5, movimiento.getTipoMovimiento());
            pstmt.setInt(6, movimiento.getCantidad());
            pstmt.setString(7, movimiento.getMotivo());
            pstmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Error al registrar movimiento", e);
        }
    }
    public int contarMovimientosPorUsuario(int usuarioId) {
        String sql = "SELECT COUNT(*) FROM movimientos_inventario WHERE usuario_id = ?";
        int total = 0;

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al contar los movimientos del usuario", e);
        }
        return total;
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

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, usuarioId);
            pstmt.setInt(2, limit);
            pstmt.setInt(3, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar los movimientos del usuario", e);
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

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar los movimientos de inventario", e);
        }
        return listaMovimientos;
    }
}