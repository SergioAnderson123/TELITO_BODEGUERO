package com.example.telito.gerente.daos;

import com.example.telito.almacen.beans.PlanTransporte;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO para gestionar recepciones de planes de transporte por el Gerente de Tienda.
 */
public class RecepcionDAO extends DAOBase {

    /**
     * Lista los planes de transporte destinados a un distrito específico con paginación y filtros.
     * Solo muestra planes con estado "En Ruta" o "Salida" (listos para recibir).
     * 
     * @param distritoId ID del distrito asignado al gerente
     * @param page Número de página
     * @param size Tamaño de página
     * @param busqueda Texto de búsqueda (opcional)
     * @param fechaDesde Fecha desde (opcional, formato YYYY-MM-DD)
     * @param fechaHasta Fecha hasta (opcional, formato YYYY-MM-DD)
     * @param estado Estado del plan (opcional, null para todos los estados disponibles)
     * @return Lista de planes de transporte
     */
    public ArrayList<PlanTransporte> listarPlanesPorDistrito(int distritoId, int page, int size, String busqueda, String fechaDesde, String fechaHasta, String estado) {
        ArrayList<PlanTransporte> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT 
                pt.id_plan,
                pt.numero_plan,
                p.nombre AS nombre_producto,
                l.codigo_lote,
                l.id_lote,
                pt.estado,
                c.nombre_completo AS nombre_conductor,
                v.placa AS placa_vehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
                d.nombre AS nombre_destino,
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
                END AS paquetes_disponibles
            FROM planes_transporte pt
            INNER JOIN lotes l ON pt.lote_id = l.id_lote
            INNER JOIN productos p ON l.producto_id = p.id_producto
            INNER JOIN conductores c ON pt.conductor_id = c.id_conductor
            INNER JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            INNER JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE pt.distrito_id = ?
            """);
        
        List<Object> params = new ArrayList<>();
        params.add(distritoId);
        
        // Filtrar por estado si se especifica
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND pt.estado = ?");
            params.add(estado);
        } else {
            // Por defecto, solo mostrar planes "En Ruta" o "Salida" (listos para recibir)
            sql.append(" AND pt.estado IN ('En Ruta', 'Salida')");
        }
        
        // Agregar filtros dinámicamente
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql.append(" AND (pt.numero_plan LIKE ? OR p.nombre LIKE ? OR l.codigo_lote LIKE ?)");
            String busquedaLike = "%" + busqueda.trim() + "%";
            params.add(busquedaLike);
            params.add(busquedaLike);
            params.add(busquedaLike);
        }
        
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) >= ?");
            params.add(fechaDesde.trim());
        }
        
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) <= ?");
            params.add(fechaHasta.trim());
        }
        
        sql.append(" ORDER BY pt.fecha_entrega ASC, pt.id_plan DESC LIMIT ? OFFSET ?");
        int offset = (page - 1) * size;
        params.add(size);
        params.add(offset);

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();

            while (rs.next()) {
                PlanTransporte plan = new PlanTransporte();
                plan.setIdPlan(rs.getInt("id_plan"));
                plan.setNumeroPlan(rs.getString("numero_plan"));
                plan.setNombreProducto(rs.getString("nombre_producto"));
                plan.setCodigoLote(rs.getString("codigo_lote"));
                plan.setIdLote(rs.getInt("id_lote"));
                plan.setEstado(rs.getString("estado"));
                plan.setNombreConductor(rs.getString("nombre_conductor"));
                plan.setPlacaVehiculo(rs.getString("placa_vehiculo"));
                plan.setFechaEntrega(rs.getString("fecha_entrega"));
                plan.setNombreDestino(rs.getString("nombre_destino"));
                plan.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                lista.add(plan);
            }
        } catch (SQLException e) {
            logger.error("Error al listar planes por distrito: " + distritoId, e);
            throw new RuntimeException("Error al listar planes por distrito", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    /**
     * Obtiene un plan de transporte por su ID.
     * 
     * @param idPlan ID del plan de transporte
     * @param distritoId ID del distrito (para validar que pertenece al gerente)
     * @return Plan de transporte o null si no existe o no pertenece al distrito
     */
    public PlanTransporte obtenerPlanPorId(int idPlan, int distritoId) {
        PlanTransporte plan = null;
        String sql = """
            SELECT 
                pt.id_plan,
                pt.numero_plan,
                p.nombre AS nombre_producto,
                l.codigo_lote,
                l.id_lote,
                pt.estado,
                c.nombre_completo AS nombre_conductor,
                v.placa AS placa_vehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
                d.nombre AS nombre_destino,
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
                END AS paquetes_disponibles
            FROM planes_transporte pt
            INNER JOIN lotes l ON pt.lote_id = l.id_lote
            INNER JOIN productos p ON l.producto_id = p.id_producto
            INNER JOIN conductores c ON pt.conductor_id = c.id_conductor
            INNER JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            INNER JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE pt.id_plan = ? AND pt.distrito_id = ?
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, idPlan);
            pstmt.setInt(2, distritoId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                plan = new PlanTransporte();
                plan.setIdPlan(rs.getInt("id_plan"));
                plan.setNumeroPlan(rs.getString("numero_plan"));
                plan.setNombreProducto(rs.getString("nombre_producto"));
                plan.setCodigoLote(rs.getString("codigo_lote"));
                plan.setIdLote(rs.getInt("id_lote"));
                plan.setEstado(rs.getString("estado"));
                plan.setNombreConductor(rs.getString("nombre_conductor"));
                plan.setPlacaVehiculo(rs.getString("placa_vehiculo"));
                plan.setFechaEntrega(rs.getString("fecha_entrega"));
                plan.setNombreDestino(rs.getString("nombre_destino"));
                plan.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener plan por ID: " + idPlan, e);
            throw new RuntimeException("Error al obtener plan por ID", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return plan;
    }

    /**
     * Confirma la recepción de un plan de transporte.
     * Cambia el estado del plan a "Entregado".
     * 
     * @param idPlan ID del plan de transporte
     * @param distritoId ID del distrito (para validar que pertenece al gerente)
     * @return true si se confirmó exitosamente, false en caso contrario
     */
    public boolean confirmarRecepcion(int idPlan, int distritoId) {
        // Primero verificar que el plan pertenece al distrito
        PlanTransporte plan = obtenerPlanPorId(idPlan, distritoId);
        if (plan == null) {
            logger.warn("Intento de confirmar recepción de plan que no pertenece al distrito. Plan ID: {}, Distrito ID: {}", idPlan, distritoId);
            return false;
        }
        
        // Solo se puede confirmar recepción si el estado es "En Ruta" o "Salida"
        if (!"En Ruta".equals(plan.getEstado()) && !"Salida".equals(plan.getEstado())) {
            logger.warn("Intento de confirmar recepción de plan con estado inválido. Plan ID: {}, Estado: {}", idPlan, plan.getEstado());
            return false;
        }
        
        String sql = "UPDATE planes_transporte SET estado = 'Entregado' WHERE id_plan = ? AND distrito_id = ?";
        int filasAfectadas = executeUpdate(sql, idPlan, distritoId);
        return filasAfectadas > 0;
    }

    /**
     * Cuenta los planes pendientes de recepción para un distrito.
     * 
     * @param distritoId ID del distrito
     * @return Número de planes pendientes
     */
    /**
     * Cuenta el total de planes pendientes para un distrito con filtros opcionales.
     * 
     * @param distritoId ID del distrito
     * @param busqueda Texto de búsqueda (opcional)
     * @param fechaDesde Fecha desde (opcional, formato YYYY-MM-DD)
     * @param fechaHasta Fecha hasta (opcional, formato YYYY-MM-DD)
     * @param estado Estado del plan (opcional)
     * @return Total de planes pendientes
     */
    public int contarPlanesPendientes(int distritoId, String busqueda, String fechaDesde, String fechaHasta, String estado) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM planes_transporte pt " +
                "INNER JOIN lotes l ON pt.lote_id = l.id_lote " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "WHERE pt.distrito_id = ?");
        
        List<Object> params = new ArrayList<>();
        params.add(distritoId);
        
        // Filtrar por estado si se especifica
        if (estado != null && !estado.trim().isEmpty()) {
            sql.append(" AND pt.estado = ?");
            params.add(estado);
        } else {
            // Por defecto, solo contar planes "En Ruta" o "Salida"
            sql.append(" AND pt.estado IN ('En Ruta', 'Salida')");
        }
        
        // Agregar filtros dinámicamente
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql.append(" AND (pt.numero_plan LIKE ? OR p.nombre LIKE ? OR l.codigo_lote LIKE ?)");
            String busquedaLike = "%" + busqueda.trim() + "%";
            params.add(busquedaLike);
            params.add(busquedaLike);
            params.add(busquedaLike);
        }
        
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) >= ?");
            params.add(fechaDesde.trim());
        }
        
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) <= ?");
            params.add(fechaHasta.trim());
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar planes pendientes", e);
            throw new RuntimeException("Error al contar planes pendientes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }
    
    /**
     * Cuenta los planes pendientes de hoy para un distrito.
     * 
     * @param distritoId ID del distrito
     * @return Total de planes pendientes de hoy
     */
    public int contarPlanesPendientesHoy(int distritoId) {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE distrito_id = ? AND estado IN ('En Ruta', 'Salida') AND DATE(fecha_entrega) = CURDATE()";
        return count(sql, distritoId);
    }
    
    /**
     * Cuenta los planes pendientes de los últimos 7 días para un distrito.
     * 
     * @param distritoId ID del distrito
     * @return Total de planes pendientes de los últimos 7 días
     */
    public int contarPlanesPendientesUltimos7Dias(int distritoId) {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE distrito_id = ? AND estado IN ('En Ruta', 'Salida') AND DATE(fecha_entrega) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
        return count(sql, distritoId);
    }

    /**
     * Lista el historial de recepciones completadas para un distrito.
     * 
     * @param distritoId ID del distrito
     * @param page Número de página
     * @param size Tamaño de página
     * @param busqueda Texto de búsqueda (opcional)
     * @param fechaDesde Fecha desde (opcional, formato YYYY-MM-DD)
     * @param fechaHasta Fecha hasta (opcional, formato YYYY-MM-DD)
     * @return Lista de planes entregados
     */
    public ArrayList<PlanTransporte> listarHistorialRecepciones(int distritoId, int page, int size, String busqueda, String fechaDesde, String fechaHasta) {
        ArrayList<PlanTransporte> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT 
                pt.id_plan,
                pt.numero_plan,
                p.nombre AS nombre_producto,
                l.codigo_lote,
                l.id_lote,
                pt.estado,
                c.nombre_completo AS nombre_conductor,
                v.placa AS placa_vehiculo,
                DATE_FORMAT(pt.fecha_entrega, '%d/%m/%Y') AS fecha_entrega,
                d.nombre AS nombre_destino,
                0 AS paquetes_disponibles
            FROM planes_transporte pt
            INNER JOIN lotes l ON pt.lote_id = l.id_lote
            INNER JOIN productos p ON l.producto_id = p.id_producto
            INNER JOIN conductores c ON pt.conductor_id = c.id_conductor
            INNER JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo
            INNER JOIN distritos d ON pt.distrito_id = d.idDistrito
            WHERE pt.distrito_id = ? AND pt.estado = 'Entregado'
            """);
        
        List<Object> params = new ArrayList<>();
        params.add(distritoId);
        
        // Agregar filtros dinámicamente
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql.append(" AND (pt.numero_plan LIKE ? OR p.nombre LIKE ? OR l.codigo_lote LIKE ?)");
            String busquedaLike = "%" + busqueda.trim() + "%";
            params.add(busquedaLike);
            params.add(busquedaLike);
            params.add(busquedaLike);
        }
        
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) >= ?");
            params.add(fechaDesde.trim());
        }
        
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) <= ?");
            params.add(fechaHasta.trim());
        }
        
        sql.append(" ORDER BY pt.fecha_entrega DESC, pt.id_plan DESC LIMIT ? OFFSET ?");
        int offset = (page - 1) * size;
        params.add(size);
        params.add(offset);

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();

            while (rs.next()) {
                PlanTransporte plan = new PlanTransporte();
                plan.setIdPlan(rs.getInt("id_plan"));
                plan.setNumeroPlan(rs.getString("numero_plan"));
                plan.setNombreProducto(rs.getString("nombre_producto"));
                plan.setCodigoLote(rs.getString("codigo_lote"));
                plan.setIdLote(rs.getInt("id_lote"));
                plan.setEstado(rs.getString("estado"));
                plan.setNombreConductor(rs.getString("nombre_conductor"));
                plan.setPlacaVehiculo(rs.getString("placa_vehiculo"));
                plan.setFechaEntrega(rs.getString("fecha_entrega"));
                plan.setNombreDestino(rs.getString("nombre_destino"));
                plan.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                lista.add(plan);
            }
        } catch (SQLException e) {
            logger.error("Error al listar historial de recepciones", e);
            throw new RuntimeException("Error al listar historial de recepciones", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    /**
     * Cuenta el total de recepciones completadas para un distrito con filtros opcionales.
     * 
     * @param distritoId ID del distrito
     * @param busqueda Texto de búsqueda (opcional)
     * @param fechaDesde Fecha desde (opcional, formato YYYY-MM-DD)
     * @param fechaHasta Fecha hasta (opcional, formato YYYY-MM-DD)
     * @return Total de recepciones completadas
     */
    public int contarHistorialRecepciones(int distritoId, String busqueda, String fechaDesde, String fechaHasta) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM planes_transporte pt " +
                "INNER JOIN lotes l ON pt.lote_id = l.id_lote " +
                "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                "WHERE pt.distrito_id = ? AND pt.estado = 'Entregado'");
        
        List<Object> params = new ArrayList<>();
        params.add(distritoId);
        
        // Agregar filtros dinámicamente
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql.append(" AND (pt.numero_plan LIKE ? OR p.nombre LIKE ? OR l.codigo_lote LIKE ?)");
            String busquedaLike = "%" + busqueda.trim() + "%";
            params.add(busquedaLike);
            params.add(busquedaLike);
            params.add(busquedaLike);
        }
        
        if (fechaDesde != null && !fechaDesde.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) >= ?");
            params.add(fechaDesde.trim());
        }
        
        if (fechaHasta != null && !fechaHasta.trim().isEmpty()) {
            sql.append(" AND DATE(pt.fecha_entrega) <= ?");
            params.add(fechaHasta.trim());
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar historial de recepciones", e);
            throw new RuntimeException("Error al contar historial de recepciones", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }
    
    /**
     * Cuenta las recepciones completadas hoy para un distrito.
     * 
     * @param distritoId ID del distrito
     * @return Total de recepciones completadas hoy
     */
    public int contarRecepcionesHoy(int distritoId) {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE distrito_id = ? AND estado = 'Entregado' AND DATE(fecha_entrega) = CURDATE()";
        return count(sql, distritoId);
    }
    
    /**
     * Cuenta las recepciones completadas en los últimos 7 días para un distrito.
     * 
     * @param distritoId ID del distrito
     * @return Total de recepciones completadas en los últimos 7 días
     */
    public int contarRecepcionesUltimos7Dias(int distritoId) {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE distrito_id = ? AND estado = 'Entregado' AND DATE(fecha_entrega) >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
        return count(sql, distritoId);
    }
}

