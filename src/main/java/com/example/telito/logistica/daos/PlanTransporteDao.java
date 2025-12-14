package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.PlanTransporteBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// DAO para gestión de planes de transporte
public class PlanTransporteDao extends DAOBase {

    // Listar todas (compatibilidad - sin paginación)
    public ArrayList<PlanTransporteBean> listarPlanesDeTransporte(String busqueda, String conductorId, String estado, String fechaDesde, String fechaHasta) {
        return listarPlanesDeTransporte(busqueda, conductorId, estado, fechaDesde, fechaHasta, 1, Integer.MAX_VALUE);
    }

    // Listar con filtros y paginación
    public ArrayList<PlanTransporteBean> listarPlanesDeTransporte(String busqueda, String conductorId, String estado, String fechaDesde, String fechaHasta, int page, int size) {
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
        sql += " ORDER BY pt.id_plan DESC LIMIT ? OFFSET ?";
        
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
            
            // Aplicar paginación
            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PlanTransporteBean plan = new PlanTransporteBean(rs.getString("numeroViaje"), rs.getString("nombreProducto"), rs.getString("codigoLote"), rs.getString("estado"), rs.getString("nombreConductor"), rs.getString("placaVehiculo"), rs.getString("fechaEntrega"), rs.getString("nombreDestino"));
                listaPlanes.add(plan);
            }
        } catch (SQLException e) {
            logger.error("Error al listar planes de transporte", e);
            throw new RuntimeException("Error al listar planes de transporte", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaPlanes;
    }

    // Método para contar total de planes
    public int contarPlanes(String busqueda, String conductorId, String estado, String fechaDesde, String fechaHasta) {
        String sql = """
            SELECT COUNT(*) as total
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
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            logger.error("Error al contar planes de transporte", e);
            throw new RuntimeException("Error al contar planes de transporte", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    // === NUEVO MÉTODO PARA GUARDAR UN PLAN ===
    public void crearPlan(String numeroPlan, int loteId, int conductorId, int vehiculoId, String fechaEntrega, int distritoId) {
        // Obtenemos el producto_id a partir del lote_id para insertarlo
        String sqlProducto = "SELECT producto_id FROM lotes WHERE id_lote = ?";
        String sqlInsert = "INSERT INTO planes_transporte (numero_plan, producto_id, lote_id, estado, conductor_id, vehiculo_id, fecha_entrega, distrito_id) VALUES (?, ?, ?, 'Pendiente', ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement pstmtProducto = null;
        ResultSet rs = null;
        PreparedStatement pstmtInsert = null;

        try {
            conn = getConnection();
            // 1. Obtener el producto_id
            int productoId = 0;
            pstmtProducto = conn.prepareStatement(sqlProducto);
            pstmtProducto.setInt(1, loteId);
            rs = pstmtProducto.executeQuery();

            if (rs.next()) {
                productoId = rs.getInt("producto_id");
            }
            closeResultSet(rs);
            closePreparedStatement(pstmtProducto);

            // 2. Insertar el nuevo plan de transporte
            if (productoId > 0) {
                pstmtInsert = conn.prepareStatement(sqlInsert);
                pstmtInsert.setString(1, numeroPlan);
                pstmtInsert.setInt(2, productoId);
                pstmtInsert.setInt(3, loteId);
                pstmtInsert.setInt(4, conductorId);
                pstmtInsert.setInt(5, vehiculoId);
                pstmtInsert.setString(6, fechaEntrega);
                pstmtInsert.setInt(7, distritoId);
                pstmtInsert.executeUpdate();
                logger.info("Plan de transporte creado: {}", numeroPlan);
            }
        } catch (SQLException e) {
            logger.error("Error al crear plan de transporte", e);
            throw new RuntimeException("Error al crear plan de transporte", e);
        } finally {
            closePreparedStatement(pstmtInsert);
            closePreparedStatement(pstmtProducto);
            closeResultSet(rs);
            closeConnection(conn);
        }
    }

    // === NUEVO MÉTODO PARA OBTENER EL ÚLTIMO ID ===
    public int obtenerUltimoId() {
        String sql = "SELECT MAX(id_plan) FROM planes_transporte";
        int ultimoId = 0;

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
            logger.error("Error al obtener último ID de plan de transporte", e);
            throw new RuntimeException("Error al obtener último ID de plan de transporte", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }

    // === MÉTODO PARA OBTENER TODOS LOS PLANES AGRUPADOS POR VIAJE SIN PAGINACIÓN (para reportes) ===
    public ArrayList<PlanTransporteBean> listarTodosPlanesAgrupadosPorViaje(String busqueda, String conductorId, String estado, String fechaDesde, String fechaHasta) {
        ArrayList<PlanTransporteBean> listaPlanes = new ArrayList<>();
        
        // Consulta agrupada por numero_plan para obtener un registro por viaje
        // Calculamos fecha_salida como fecha_entrega - 1 día (estimación)
        String sql = """
            SELECT
                pt.numero_plan AS numeroViaje,
                c.nombre_completo AS nombreConductor,
                v.placa AS placaVehiculo,
                DATE_FORMAT(DATE_SUB(MIN(pt.fecha_entrega), INTERVAL 1 DAY), '%d/%m/%Y') AS fechaSalida,
                DATE_FORMAT(MIN(pt.fecha_entrega), '%d/%m/%Y') AS fechaEntrega,
                MAX(pt.estado) AS estado,
                d.nombre AS nombreDestino,
                COUNT(DISTINCT pt.lote_id) AS cantidadLotes
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
            sql += " AND (pt.numero_plan LIKE ? OR v.placa LIKE ? OR c.nombre_completo LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
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
        
        sql += " GROUP BY pt.numero_plan, c.nombre_completo, v.placa, d.nombre ORDER BY pt.numero_plan DESC";
        
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
            while (rs.next()) {
                PlanTransporteBean plan = new PlanTransporteBean(
                    rs.getString("numeroViaje"),
                    null, // nombreProducto - no necesario en reporte agrupado
                    null, // codigoLote - no necesario en reporte agrupado
                    rs.getString("estado"),
                    rs.getString("nombreConductor"),
                    rs.getString("placaVehiculo"),
                    rs.getString("fechaEntrega"),
                    rs.getString("nombreDestino")
                );
                plan.setFechaSalida(rs.getString("fechaSalida"));
                plan.setCantidadLotes(rs.getInt("cantidadLotes"));
                listaPlanes.add(plan);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todos los planes agrupados por viaje", e);
            throw new RuntimeException("Error al listar todos los planes agrupados por viaje", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return listaPlanes;
    }
}