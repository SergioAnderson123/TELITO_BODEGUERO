package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.OrdenCompra;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;

public class OrdenCompraDao {
    // Las credenciales ahora están centralizadas en DatabaseConnection

    public int contarOrdenesPendientes() {
        String sql = "SELECT COUNT(*) FROM ordenes_compra WHERE estado = 'Aprobado'";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al contar órdenes pendientes", e);
        }
        return 0;
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

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
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
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al listar órdenes paginadas", e);
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

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idOrden);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    oc = new OrdenCompra();
                    oc.setIdOrdenCompra(rs.getInt("id_orden_compra"));
                    oc.setNumeroOrden(rs.getString("numero_orden"));
                    oc.setProductoId(rs.getInt("producto_id"));
                    oc.setProveedorId(rs.getInt("productor_id"));
                    oc.setLoteId(rs.getInt("lote_id"));
                    oc.setCantidad(rs.getInt("cantidad"));
                    oc.setEstado(rs.getString("estado"));
                    oc.setNombreProducto(rs.getString("prod.nombre"));
                    oc.setNombreProveedor(rs.getString("nombre_productor"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar orden por ID", e);
        }
        return oc;
    }

    public void actualizarEstado(int idOrden, String nuevoEstado) {
        String sql = "UPDATE ordenes_compra SET estado = ? WHERE id_orden_compra = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, idOrden);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error al actualizar estado de la orden", e);
        }
    }
}