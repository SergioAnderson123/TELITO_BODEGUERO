package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.OrdenCompra;
import java.sql.*;
import java.util.ArrayList;

public class OrdenCompraDao {

    private final String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
    private final String user = "root";
    private final String pass = "root";

    // Carga del driver una sola vez para mayor eficiencia
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Error al cargar el driver de MySQL", e);
        }
    }

    public int contarOrdenesPendientes() {
        String sql = "SELECT COUNT(*) FROM ordenes_compra WHERE estado = 'Aprobado'";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
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
        // Se añade oc.numero_orden a la consulta
        String sql = "SELECT oc.id_orden_compra, oc.numero_orden, prod.nombre, prov.nombre, oc.cantidad, oc.estado " +
                "FROM ordenes_compra oc " +
                "INNER JOIN productos prod ON (oc.producto_id = prod.id_producto) " +
                "INNER JOIN proveedores prov ON (oc.proveedor_id = prov.id_proveedor) " +
                "WHERE oc.estado = 'Aprobado' LIMIT ? OFFSET ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    OrdenCompra oc = new OrdenCompra();
                    oc.setIdOrdenCompra(rs.getInt("id_orden_compra"));
                    oc.setNumeroOrden(rs.getString("numero_orden"));
                    oc.setNombreProducto(rs.getString("prod.nombre"));
                    oc.setNombreProveedor(rs.getString("prov.nombre"));
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

    public OrdenCompra buscarOrdenPorId(int idOrden) {
        OrdenCompra oc = null;
        // Se añade oc.numero_orden a la consulta
        String sql = "SELECT oc.id_orden_compra, oc.numero_orden, oc.producto_id, oc.proveedor_id, oc.cantidad, oc.estado, prod.nombre, prov.nombre " +
                "FROM ordenes_compra oc " +
                "INNER JOIN productos prod ON (oc.producto_id = prod.id_producto) " +
                "INNER JOIN proveedores prov ON (oc.proveedor_id = prov.id_proveedor) " +
                "WHERE oc.id_orden_compra = ?";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idOrden);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    oc = new OrdenCompra();
                    oc.setIdOrdenCompra(rs.getInt("id_orden_compra"));
                    oc.setNumeroOrden(rs.getString("numero_orden"));
                    oc.setProductoId(rs.getInt("producto_id"));
                    oc.setProveedorId(rs.getInt("proveedor_id"));
                    oc.setCantidad(rs.getInt("cantidad"));
                    oc.setEstado(rs.getString("estado"));
                    oc.setNombreProducto(rs.getString("prod.nombre"));
                    oc.setNombreProveedor(rs.getString("prov.nombre"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error al buscar orden por ID", e);
        }
        return oc;
    }

    public void actualizarEstado(int idOrden, String nuevoEstado) {
        String sql = "UPDATE ordenes_compra SET estado = ? WHERE id_orden_compra = ?";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, idOrden);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Error al actualizar estado de la orden", e);
        }
    }
}