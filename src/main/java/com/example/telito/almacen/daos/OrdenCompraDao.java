package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.OrdenCompra;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class OrdenCompraDao extends DAOBase {

    public int contarOrdenesPendientes() {
        String sql = "SELECT COUNT(*) FROM ordenes_compra WHERE estado = 'Aprobado'";
        return count(sql);
    }

    public ArrayList<OrdenCompra> listarOrdenesPaginadas(int offset, int limit) {
        ArrayList<OrdenCompra> lista = new ArrayList<>();
        String sql = "SELECT oc.id_orden_compra, " +
                "IFNULL(oc.numero_Orden, CONCAT('OC', LPAD(oc.id_orden_compra, 3, '0'))) AS numero_orden, " +
                "prod.nombre, " +
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
                "WHERE oc.estado = 'Aprobado' LIMIT ? OFFSET ?";

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
                OrdenCompra oc = new OrdenCompra();
                oc.setIdOrdenCompra(rs.getInt("id_orden_compra"));
                oc.setNumeroOrden(rs.getString("numero_orden"));
                oc.setNombreProducto(rs.getString("prod.nombre"));
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
                "prod.nombre, " +
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
                // Manejar correctamente valores NULL en lote_id
                Object loteIdObj = rs.getObject("lote_id");
                if (loteIdObj != null) {
                    oc.setLoteId(rs.getInt("lote_id"));
                } else {
                    oc.setLoteId(0); // 0 indica que no hay lote asignado
                }
                oc.setCantidad(rs.getInt("cantidad"));
                oc.setEstado(rs.getString("estado"));
                oc.setNombreProducto(rs.getString("prod.nombre"));
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
}