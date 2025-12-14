package com.example.telito.almacen.daos;

import com.example.telito.almacen.beans.PlanTransporte;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de planes de transporte desde perspectiva del almacén
public class PlanTransporteDao extends DAOBase {

    // Lista planes pendientes y en salida para el almacén
    public ArrayList<PlanTransporte> listarPlanesPendientes() {
        ArrayList<PlanTransporte> lista = new ArrayList<>();
        String sql = """
            SELECT 
                pt.id_plan,
                pt.numero_plan,
                p.nombre AS nombre_producto,
                l.codigo_lote,
                l.id_lote,
                l.stock_actual,
                CASE 
                    WHEN pt.estado = 'Salida' THEN (
                        SELECT FLOOR(mi.cantidad / p.unidades_por_paquete)
                        FROM movimientos_inventario mi
                        WHERE mi.lote_id = l.id_lote
                        AND mi.tipo = 'Salida'
                        AND mi.motivo LIKE CONCAT('Plan de transporte: ', pt.numero_plan)
                        ORDER BY mi.fecha DESC
                        LIMIT 1
                    )
                    ELSE FLOOR(l.stock_actual / p.unidades_por_paquete)
                END AS paquetes_disponibles,
                pt.estado,
                c.nombre_completo AS nombre_conductor,
                v.placa AS placa_vehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
                d.nombre AS nombre_destino
            FROM planes_transporte pt
            LEFT JOIN lotes l ON pt.lote_id = l.id_lote
            LEFT JOIN productos p ON l.producto_id = p.id_producto
            LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
            LEFT JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            LEFT JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE pt.estado IN ('Pendiente', 'Salida')
            ORDER BY pt.id_plan DESC
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                PlanTransporte plan = new PlanTransporte();
                plan.setIdPlan(rs.getInt("id_plan"));
                plan.setNumeroPlan(rs.getString("numero_plan"));
                plan.setNombreProducto(rs.getString("nombre_producto") != null ? rs.getString("nombre_producto") : "N/A");
                plan.setCodigoLote(rs.getString("codigo_lote") != null ? rs.getString("codigo_lote") : "N/A");
                plan.setIdLote(rs.getInt("id_lote"));
                plan.setStockDisponible(rs.getInt("stock_actual"));
                plan.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                plan.setEstado(rs.getString("estado"));
                plan.setNombreConductor(rs.getString("nombre_conductor") != null ? rs.getString("nombre_conductor") : "N/A");
                plan.setPlacaVehiculo(rs.getString("placa_vehiculo") != null ? rs.getString("placa_vehiculo") : "N/A");
                plan.setFechaEntrega(rs.getString("fecha_entrega") != null ? rs.getString("fecha_entrega") : "N/A");
                plan.setNombreDestino(rs.getString("nombre_destino") != null ? rs.getString("nombre_destino") : "N/A");
                lista.add(plan);
            }
        } catch (SQLException e) {
            logger.error("Error al listar planes pendientes", e);
            throw new RuntimeException("Error al listar planes pendientes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    // Buscar plan de transporte por ID
    public PlanTransporte buscarPlanPorId(int id) {
        PlanTransporte plan = null;
        String sql = """
            SELECT 
                pt.id_plan,
                pt.numero_plan,
                p.nombre AS nombre_producto,
                l.codigo_lote,
                l.id_lote,
                l.stock_actual,
                CASE 
                    WHEN pt.estado = 'Salida' THEN (
                        SELECT FLOOR(mi.cantidad / p.unidades_por_paquete)
                        FROM movimientos_inventario mi
                        WHERE mi.lote_id = l.id_lote
                        AND mi.tipo = 'Salida'
                        AND mi.motivo LIKE CONCAT('Plan de transporte: ', pt.numero_plan)
                        ORDER BY mi.fecha DESC
                        LIMIT 1
                    )
                    ELSE FLOOR(l.stock_actual / p.unidades_por_paquete)
                END AS paquetes_disponibles,
                pt.estado,
                c.nombre_completo AS nombre_conductor,
                v.placa AS placa_vehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
                d.nombre AS nombre_destino
            FROM planes_transporte pt
            INNER JOIN lotes l ON pt.lote_id = l.id_lote
            INNER JOIN productos p ON l.producto_id = p.id_producto
            INNER JOIN conductores c ON pt.conductor_id = c.id_conductor
            INNER JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            INNER JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE pt.id_plan = ?
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                plan = new PlanTransporte();
                plan.setIdPlan(rs.getInt("id_plan"));
                plan.setNumeroPlan(rs.getString("numero_plan"));
                plan.setNombreProducto(rs.getString("nombre_producto"));
                plan.setCodigoLote(rs.getString("codigo_lote"));
                plan.setIdLote(rs.getInt("id_lote"));
                plan.setStockDisponible(rs.getInt("stock_actual"));
                plan.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                plan.setEstado(rs.getString("estado"));
                plan.setNombreConductor(rs.getString("nombre_conductor"));
                plan.setPlacaVehiculo(rs.getString("placa_vehiculo"));
                plan.setFechaEntrega(rs.getString("fecha_entrega"));
                plan.setNombreDestino(rs.getString("nombre_destino"));
            }
        } catch (SQLException e) {
            logger.error("Error al buscar plan por ID: " + id, e);
            throw new RuntimeException("Error al buscar plan por ID", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return plan;
    }

    // Actualizar el estado del plan de transporte
    public boolean actualizarEstado(int idPlan, String nuevoEstado) {
        String sql = "UPDATE planes_transporte SET estado = ? WHERE id_plan = ?";
        int filasAfectadas = executeUpdate(sql, nuevoEstado, idPlan);
        return filasAfectadas > 0;
    }

    // Contar planes pendientes
    public int contarPlanesPendientes() {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE estado = 'Pendiente'";
        return count(sql);
    }

    // Listar planes de transporte paginados
    public ArrayList<PlanTransporte> listarPlanesPaginados(int offset, int limit) {
        ArrayList<PlanTransporte> lista = new ArrayList<>();
        String sql = """
            SELECT 
                pt.id_plan,
                pt.numero_plan,
                p.nombre AS nombre_producto,
                l.codigo_lote,
                l.id_lote,
                l.stock_actual,
                CASE 
                    WHEN pt.estado = 'Salida' THEN (
                        SELECT FLOOR(mi.cantidad / p.unidades_por_paquete)
                        FROM movimientos_inventario mi
                        WHERE mi.lote_id = l.id_lote
                        AND mi.tipo = 'Salida'
                        AND mi.motivo LIKE CONCAT('Plan de transporte: ', pt.numero_plan)
                        ORDER BY mi.fecha DESC
                        LIMIT 1
                    )
                    ELSE FLOOR(l.stock_actual / p.unidades_por_paquete)
                END AS paquetes_disponibles,
                pt.estado,
                c.nombre_completo AS nombre_conductor,
                v.placa AS placa_vehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
                d.nombre AS nombre_destino
            FROM planes_transporte pt
            LEFT JOIN lotes l ON pt.lote_id = l.id_lote
            LEFT JOIN productos p ON l.producto_id = p.id_producto
            LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
            LEFT JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            LEFT JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE pt.estado IN ('Pendiente', 'Salida')
            ORDER BY pt.id_plan DESC
            LIMIT ? OFFSET ?
            """;

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
                PlanTransporte plan = new PlanTransporte();
                plan.setIdPlan(rs.getInt("id_plan"));
                plan.setNumeroPlan(rs.getString("numero_plan"));
                plan.setNombreProducto(rs.getString("nombre_producto") != null ? rs.getString("nombre_producto") : "N/A");
                plan.setCodigoLote(rs.getString("codigo_lote") != null ? rs.getString("codigo_lote") : "N/A");
                plan.setIdLote(rs.getInt("id_lote"));
                plan.setStockDisponible(rs.getInt("stock_actual"));
                plan.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                plan.setEstado(rs.getString("estado"));
                plan.setNombreConductor(rs.getString("nombre_conductor") != null ? rs.getString("nombre_conductor") : "N/A");
                plan.setPlacaVehiculo(rs.getString("placa_vehiculo") != null ? rs.getString("placa_vehiculo") : "N/A");
                plan.setFechaEntrega(rs.getString("fecha_entrega") != null ? rs.getString("fecha_entrega") : "N/A");
                plan.setNombreDestino(rs.getString("nombre_destino") != null ? rs.getString("nombre_destino") : "N/A");
                lista.add(plan);
            }
        } catch (SQLException e) {
            logger.error("Error al listar planes paginados", e);
            throw new RuntimeException("Error al listar planes paginados", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    // Contar total de planes
    public int contarTotalPlanes() {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE estado IN ('Pendiente', 'Salida')";
        return count(sql);
    }

    // Contar planes despachados (estado "Salida")
    public int contarPlanesDespachados() {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE estado = 'Salida'";
        return count(sql);
    }

    // Listar todos los planes despachados (estado "Salida") sin paginación para reportes
    public ArrayList<PlanTransporte> listarTodosPlanesDespachados() {
        ArrayList<PlanTransporte> lista = new ArrayList<>();
        String sql = """
            SELECT 
                pt.id_plan,
                pt.numero_plan,
                p.nombre AS nombre_producto,
                l.codigo_lote,
                l.id_lote,
                l.stock_actual,
                CASE 
                    WHEN pt.estado = 'Salida' THEN (
                        SELECT FLOOR(mi.cantidad / p.unidades_por_paquete)
                        FROM movimientos_inventario mi
                        WHERE mi.lote_id = l.id_lote
                        AND mi.tipo = 'Salida'
                        AND mi.motivo LIKE CONCAT('Plan de transporte: ', pt.numero_plan)
                        ORDER BY mi.fecha DESC
                        LIMIT 1
                    )
                    ELSE FLOOR(l.stock_actual / p.unidades_por_paquete)
                END AS paquetes_disponibles,
                pt.estado,
                c.nombre_completo AS nombre_conductor,
                v.placa AS placa_vehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
                d.nombre AS nombre_destino
            FROM planes_transporte pt
            LEFT JOIN lotes l ON pt.lote_id = l.id_lote
            LEFT JOIN productos p ON l.producto_id = p.id_producto
            LEFT JOIN conductores c ON pt.conductor_id = c.id_conductor
            LEFT JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            LEFT JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE pt.estado = 'Salida'
            ORDER BY pt.id_plan DESC
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                PlanTransporte plan = new PlanTransporte();
                plan.setIdPlan(rs.getInt("id_plan"));
                plan.setNumeroPlan(rs.getString("numero_plan"));
                plan.setNombreProducto(rs.getString("nombre_producto") != null ? rs.getString("nombre_producto") : "N/A");
                plan.setCodigoLote(rs.getString("codigo_lote") != null ? rs.getString("codigo_lote") : "N/A");
                plan.setIdLote(rs.getInt("id_lote"));
                plan.setStockDisponible(rs.getInt("stock_actual"));
                plan.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                plan.setEstado(rs.getString("estado"));
                plan.setNombreConductor(rs.getString("nombre_conductor") != null ? rs.getString("nombre_conductor") : "N/A");
                plan.setPlacaVehiculo(rs.getString("placa_vehiculo") != null ? rs.getString("placa_vehiculo") : "N/A");
                plan.setFechaEntrega(rs.getString("fecha_entrega") != null ? rs.getString("fecha_entrega") : "N/A");
                plan.setNombreDestino(rs.getString("nombre_destino") != null ? rs.getString("nombre_destino") : "N/A");
                // La tabla planes_transporte no tiene fecha_creacion, se deja null
                plan.setFechaCreacion(null);
                lista.add(plan);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todos los planes despachados", e);
            throw new RuntimeException("Error al listar todos los planes despachados", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}

