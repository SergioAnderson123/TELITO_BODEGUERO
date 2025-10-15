package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.OrdenCompraBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrdenCompraDao {

    // === MÉTODO MODIFICADO PARA ACEPTAR FILTROS ===
    public ArrayList<OrdenCompraBean> obtenerOrdenes(String busqueda, String proveedorId, String estado) {

        ArrayList<OrdenCompraBean> listaOrdenes = new ArrayList<>();

        String sql = """
            SELECT
                oc.id_orden_compra AS id_orden,
                p.nombre AS nombre_proveedor,
                pr.nombre AS nombre_producto,
                oc.cantidad AS cantidad_paquetes,
                CASE
                    WHEN oc.estado = 'Pendiente' THEN 'Por Confirmar'
                    ELSE CONCAT(u.nombres, ' ', u.apellidos)
                END AS personal_responsable,
                oc.estado,
                oc.monto_total
            FROM ordenes_compra oc
            INNER JOIN proveedores p ON oc.proveedor_id = p.id_proveedor
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
            sql += " AND p.id_proveedor = ?";
            params.add(Integer.parseInt(proveedorId));
        }
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND oc.estado = ?";
            params.add(estado.trim());
        }

        sql += " ORDER BY oc.id_orden_compra DESC";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

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

    // === CÓDIGO RESTAURADO ===
    public void crearOrdenCompra(String numeroOrden, int proveedorId, int productoId, int cantidad, int usuarioId, double montoTotal) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";
        String sql;
        boolean includeNumero = numeroOrden != null && !numeroOrden.isEmpty();
        if (includeNumero) {
            sql = "INSERT INTO ordenes_compra (numero, proveedor_id, producto_id, cantidad, usuario_id, estado, monto_total) VALUES (?, ?, ?, ?, ?, 'Pendiente', ?)";
        } else {
            sql = "INSERT INTO ordenes_compra (proveedor_id, producto_id, cantidad, usuario_id, estado, monto_total) VALUES (?, ?, ?, ?, 'Pendiente', ?)";
        }
        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            int idx = 1;
            if (includeNumero) {
                pstmt.setString(idx++, numeroOrden);
            }
            pstmt.setInt(idx++, proveedorId);
            pstmt.setInt(idx++, productoId);
            pstmt.setInt(idx++, cantidad);
            pstmt.setInt(idx++, usuarioId);
            pstmt.setDouble(idx, montoTotal);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
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
}