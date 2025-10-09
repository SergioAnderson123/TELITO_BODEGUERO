package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.PlanTransporteBean;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PlanTransporteDao {

    // (El método listarPlanesDeTransporte se queda igual)
    public ArrayList<PlanTransporteBean> listarPlanesDeTransporte(String busqueda, String conductorId, String estado, String fechaDesde, String fechaHasta) {
        // ... (código sin cambios)
        ArrayList<PlanTransporteBean> listaPlanes = new ArrayList<>();
        String sql = """
            SELECT
                pt.numero_plan AS numeroViaje, p.nombre AS nombreProducto, l.codigo_lote AS codigoLote,
                pt.estado, c.nombre_completo AS nombreConductor, v.placa AS placaVehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fechaEntrega, d.nombre AS nombreDestino
            FROM planes_transporte pt
            INNER JOIN lotes l ON pt.lote_id = l.id_lote
            INNER JOIN productos p ON l.producto_id = p.id_producto
            INNER JOIN conductores c ON pt.conductor_id = c.id_conductor
            INNER JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            INNER JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE 1=1
            """;
        List<Object> params = new ArrayList<>();
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (pt.numero_plan LIKE ? OR v.placa LIKE ? OR l.codigo_lote LIKE ? OR p.nombre LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
            params.add(busquedaParam);
            params.add(busquedaParam);
        }
        if (conductorId != null && !conductorId.trim().isEmpty()) {
            sql += " AND pt.conductor_id = ?";
            params.add(Integer.parseInt(conductorId));
        }
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND pt.estado = ?";
            params.add(estado.trim());
        }
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql += " AND pt.fecha_entrega >= ?";
            params.add(fechaDesde.trim());
        }
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql += " AND pt.fecha_entrega <= ?";
            params.add(fechaHasta.trim());
        }
        sql += " ORDER BY pt.id_plan DESC";
        try { Class.forName("com.mysql.cj.jdbc.Driver"); } catch (ClassNotFoundException e) { throw new RuntimeException(e); }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";
        try (Connection conn = DriverManager.getConnection(url, username, password); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    PlanTransporteBean plan = new PlanTransporteBean(rs.getString("numeroViaje"), rs.getString("nombreProducto"), rs.getString("codigoLote"), rs.getString("estado"), rs.getString("nombreConductor"), rs.getString("placaVehiculo"), rs.getString("fechaEntrega"), rs.getString("nombreDestino"));
                    listaPlanes.add(plan);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaPlanes;
    }

    // === NUEVO MÉTODO PARA GUARDAR UN PLAN ===
    public void crearPlan(String numeroPlan, int loteId, int conductorId, int vehiculoId, String fechaEntrega, int distritoId) {
        // Obtenemos el producto_id a partir del lote_id para insertarlo
        String sqlProducto = "SELECT producto_id FROM lotes WHERE id_lote = ?";
        String sqlInsert = "INSERT INTO planes_transporte (numero_plan, producto_id, lote_id, estado, conductor_id, vehiculo_id, fecha_entrega, distrito_id) VALUES (?, ?, ?, 'Pendiente', ?, ?, ?, ?)";

        try { Class.forName("com.mysql.cj.jdbc.Driver"); } catch (ClassNotFoundException e) { throw new RuntimeException(e); }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        try (Connection conn = DriverManager.getConnection(url, username, password)) {
            // 1. Obtener el producto_id
            int productoId = 0;
            try (PreparedStatement pstmtProducto = conn.prepareStatement(sqlProducto)) {
                pstmtProducto.setInt(1, loteId);
                try (ResultSet rs = pstmtProducto.executeQuery()) {
                    if (rs.next()) {
                        productoId = rs.getInt("producto_id");
                    }
                }
            }

            // 2. Insertar el nuevo plan de transporte
            if (productoId > 0) {
                try (PreparedStatement pstmtInsert = conn.prepareStatement(sqlInsert)) {
                    pstmtInsert.setString(1, numeroPlan);
                    pstmtInsert.setInt(2, productoId);
                    pstmtInsert.setInt(3, loteId);
                    pstmtInsert.setInt(4, conductorId);
                    pstmtInsert.setInt(5, vehiculoId);
                    pstmtInsert.setString(6, fechaEntrega);
                    pstmtInsert.setInt(7, distritoId);
                    pstmtInsert.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // === NUEVO MÉTODO PARA OBTENER EL ÚLTIMO ID ===
    public int obtenerUltimoId() {
        String sql = "SELECT MAX(id_plan) FROM planes_transporte";
        int ultimoId = 0;

        try { Class.forName("com.mysql.cj.jdbc.Driver"); } catch (ClassNotFoundException e) { throw new RuntimeException(e); }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

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