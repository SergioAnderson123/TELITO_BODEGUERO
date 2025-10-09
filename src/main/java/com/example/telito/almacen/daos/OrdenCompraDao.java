package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.OrdenCompra;
import com.example.telito.almacen.beans.Producto;
import com.example.telito.almacen.beans.Proveedor;

import java.sql.*;
import java.util.ArrayList;

public class OrdenCompraDao {

    private String url = "jdbc:mysql://localhost:3306/telito4";
    private String user = "root";
    private String pass = "root";


    public ArrayList<OrdenCompra> listarOrdenesPendientes() {
        ArrayList<OrdenCompra> lista = new ArrayList<>();
        String sql = "SELECT oc.id_orden_compra, prod.nombre, prov.nombre, oc.cantidad, oc.estado " +
                "FROM ordenes_compra oc " +
                "INNER JOIN productos prod ON (oc.producto_id = prod.id_producto) " +
                "INNER JOIN proveedores prov ON (oc.proveedor_id = prov.id_proveedor) " +
                "WHERE oc.estado = 'Aprobado'";

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                OrdenCompra oc = new OrdenCompra();
                oc.setIdOrdenCompra(rs.getInt(1));
                oc.setNombreProducto(rs.getString(2));
                oc.setNombreProveedor(rs.getString(3));
                oc.setCantidad(rs.getInt(4));
                oc.setEstado(rs.getString(5));
                lista.add(oc);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
        return lista;
    }


    public OrdenCompra buscarOrdenPorId(int idOrden) {
        OrdenCompra oc = null;
        String sql = "SELECT oc.id_orden_compra, oc.producto_id, oc.proveedor_id, oc.cantidad, oc.estado, prod.nombre, prov.nombre " +
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
                    oc.setProductoId(rs.getInt("producto_id"));
                    oc.setProveedorId(rs.getInt("proveedor_id"));
                    oc.setCantidad(rs.getInt("cantidad"));
                    oc.setEstado(rs.getString("estado"));
                    oc.setNombreProducto(rs.getString("prod.nombre"));
                    oc.setNombreProveedor(rs.getString("prov.nombre"));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
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
            throw new RuntimeException(e);
        }
    }
}