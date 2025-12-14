package com.example.telito.administrador.daos;

import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// DAO solo para consultas de reportes - sin inserts ni updates
public class ReporteDAO extends DAOBase {

    // Contar rutas activas (planes no entregados)
    public int contarRutasActivas() {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE estado IS NOT NULL AND estado <> 'Entregado'";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.error("Error en método de conteo", e);
            throw new RuntimeException("Error en consulta de conteo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }

    // Calcula porcentaje de planes entregados vs total
    public int calcularEficienciaLogistica() {
        String sql = "SELECT SUM(CASE WHEN estado = 'Entregado' THEN 1 ELSE 0 END) AS entregados, COUNT(*) AS total FROM planes_transporte";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) {
                int total = rs.getInt("total");
                int entregados = rs.getInt("entregados");
                if (total == 0) return 0;
                return (int) Math.round((entregados * 100.0) / total);
            }
        } catch (SQLException e) {
            logger.error("Error al calcular eficiencia logística", e);
            throw new RuntimeException("Error al calcular eficiencia logística", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }

    public int contarProductores() {
        String sql = "SELECT COUNT(DISTINCT productor_id) FROM productos WHERE productor_id IS NOT NULL";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.error("Error en método de conteo", e);
            throw new RuntimeException("Error en consulta de conteo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }

    public int contarLotes() {
        String sql = "SELECT COUNT(*) FROM lotes";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.error("Error en método de conteo", e);
            throw new RuntimeException("Error en consulta de conteo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }

    public int contarProductos() {
        String sql = "SELECT COUNT(*) FROM productos";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.error("Error en método de conteo", e);
            throw new RuntimeException("Error en consulta de conteo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }

    public int contarUbicaciones() {
        String sql = "SELECT COUNT(*) FROM ubicaciones";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            logger.error("Error en método de conteo", e);
            throw new RuntimeException("Error en consulta de conteo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return 0;
    }

    // --- Reportes para la gente de Logística ---
    public Map<String, Integer> obtenerConteoPlanesPorEstado() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT estado, COUNT(*) AS cantidad FROM planes_transporte GROUP BY estado";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("estado"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener conteo", e);
            throw new RuntimeException("Error al obtener conteo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    public Map<String, Integer> obtenerProductosMasTransportados() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, SUM(mi.cantidad) AS total_salidas FROM movimientos_inventario mi " +
                     "JOIN lotes l ON mi.lote_id = l.id_lote " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE mi.tipo = 'Salida' GROUP BY p.nombre ORDER BY total_salidas DESC LIMIT 5";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("total_salidas"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener productos más transportados", e);
            throw new RuntimeException("Error al obtener productos más transportados", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }


    // --- Reportes adicionales para Logística ---
    
    /**
     * Obtiene la distribución de planes de transporte por distrito
     * Muestra qué distritos reciben más entregas
     */
    public Map<String, Integer> obtenerDistribucionPlanesPorDistrito() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT d.nombre AS nombre_distrito, COUNT(pt.id_plan) AS cantidad " +
                     "FROM planes_transporte pt " +
                     "JOIN distritos d ON pt.distrito_id = d.idDistrito " +
                     "WHERE pt.estado IN ('Salida', 'Entregado', 'En Ruta') " +
                     "GROUP BY d.nombre " +
                     "ORDER BY cantidad DESC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_distrito"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener distribución de planes por distrito", e);
            throw new RuntimeException("Error al obtener distribución de planes por distrito", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene la distribución de órdenes de compra por estado
     * Muestra el estado general del flujo de órdenes
     */
    public Map<String, Integer> obtenerOrdenesCompraPorEstado() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT estado, COUNT(*) AS cantidad " +
                     "FROM ordenes_compra " +
                     "GROUP BY estado " +
                     "ORDER BY cantidad DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("estado"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener órdenes de compra por estado", e);
            throw new RuntimeException("Error al obtener órdenes de compra por estado", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene las tendencias de planes de transporte por mes (últimos 6 meses)
     * Muestra la evolución temporal de los planes
     */
    public Map<String, Integer> obtenerTendenciasPlanesPorMes() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(fecha_entrega, '%Y-%m') AS mes, COUNT(*) AS cantidad " +
                     "FROM planes_transporte " +
                     "WHERE fecha_entrega >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                     "GROUP BY mes " +
                     "ORDER BY mes ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                String mes = rs.getString("mes");
                // Formatear mes para mejor visualización (ej: "2025-11" -> "Nov 2025")
                if (mes != null && mes.length() >= 7) {
                    String[] partes = mes.split("-");
                    if (partes.length >= 2) {
                        try {
                            int mesNum = Integer.parseInt(partes[1]);
                            String[] mesesNombres = {"Ene", "Feb", "Mar", "Abr", "May", "Jun", 
                                                     "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"};
                            if (mesNum >= 1 && mesNum <= 12) {
                                mes = mesesNombres[mesNum - 1] + " " + partes[0];
                            }
                        } catch (NumberFormatException e) {
                            // Si falla el parseo, usar el mes original
                        }
                    }
                }
                conteo.put(mes, rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener tendencias de planes por mes", e);
            throw new RuntimeException("Error al obtener tendencias de planes por mes", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene la distribución de planes de transporte por zona geográfica
     * Muestra planes agrupados por Norte, Sur, Este, Oeste
     */
    public Map<String, Integer> obtenerDistribucionPlanesPorZona() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT z.nombre AS nombre_zona, COUNT(pt.id_plan) AS cantidad " +
                     "FROM planes_transporte pt " +
                     "JOIN distritos d ON pt.distrito_id = d.idDistrito " +
                     "JOIN zonas z ON d.zona_id = z.idZona " +
                     "WHERE pt.estado IN ('Salida', 'Entregado', 'En Ruta', 'Pendiente') " +
                     "GROUP BY z.nombre " +
                     "ORDER BY cantidad DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_zona"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener distribución de planes por zona", e);
            throw new RuntimeException("Error al obtener distribución de planes por zona", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene los vehículos más utilizados en planes de transporte
     * Muestra qué vehículos se usan más frecuentemente
     */
    public Map<String, Integer> obtenerVehiculosMasUtilizados() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT v.placa, COUNT(pt.id_plan) AS cantidad_planes " +
                     "FROM planes_transporte pt " +
                     "JOIN vehiculos v ON pt.vehiculo_id = v.id_vehiculo " +
                     "WHERE pt.estado IN ('Salida', 'Entregado', 'En Ruta', 'Pendiente') " +
                     "GROUP BY v.placa " +
                     "ORDER BY cantidad_planes DESC " +
                     "LIMIT 8";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("placa"), rs.getInt("cantidad_planes"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener vehículos más utilizados", e);
            throw new RuntimeException("Error al obtener vehículos más utilizados", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene los productos más solicitados en órdenes de compra
     * Muestra qué productos tienen más órdenes de compra
     */
    public Map<String, Integer> obtenerProductosMasSolicitadosOrdenes() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, COUNT(oc.id_orden_compra) AS cantidad_ordenes " +
                     "FROM ordenes_compra oc " +
                     "JOIN productos p ON oc.producto_id = p.id_producto " +
                     "GROUP BY p.nombre " +
                     "ORDER BY cantidad_ordenes DESC " +
                     "LIMIT 8";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("cantidad_ordenes"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener productos más solicitados en órdenes", e);
            throw new RuntimeException("Error al obtener productos más solicitados en órdenes", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene comparativa de planes: Pendientes vs Completados
     * Muestra la distribución entre planes pendientes y completados
     */
    public Map<String, Integer> obtenerComparativaPlanesPendientesVsCompletados() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT " +
                     "  CASE " +
                     "    WHEN estado IN ('Pendiente') THEN 'Pendientes' " +
                     "    WHEN estado IN ('Salida', 'Entregado') THEN 'Completados' " +
                     "    WHEN estado IN ('En Ruta') THEN 'En Ruta' " +
                     "    ELSE 'Otros' " +
                     "  END AS categoria, " +
                     "  COUNT(*) AS cantidad " +
                     "FROM planes_transporte " +
                     "GROUP BY categoria " +
                     "ORDER BY cantidad DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("categoria"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener comparativa de planes", e);
            throw new RuntimeException("Error al obtener comparativa de planes", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    // --- Reportes para la gente de Almacén ---
    public Map<String, Integer> obtenerMovimientosHoy() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT tipo, COUNT(*) AS cantidad FROM movimientos_inventario WHERE DATE(fecha) = CURDATE() GROUP BY tipo";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("tipo"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener movimientos de hoy", e);
            throw new RuntimeException("Error al obtener movimientos de hoy", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    public Map<String, Integer> getTop5ProductosConStock() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, SUM(l.stock_actual) AS stock_total " +
                     "FROM productos p " +
                     "JOIN lotes l ON l.producto_id = p.id_producto " +
                     "GROUP BY p.id_producto, p.nombre " +
                     "ORDER BY stock_total DESC LIMIT 5";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("stock_total"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener top 5 productos con stock", e);
            throw new RuntimeException("Error al obtener top 5 productos con stock", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    public Map<String, Integer> getMotivosDeAjuste() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT motivo, COUNT(*) as cantidad FROM movimientos_inventario WHERE tipo = 'Ajuste' AND motivo IS NOT NULL GROUP BY motivo ORDER BY cantidad DESC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("motivo"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener motivos de ajuste", e);
            throw new RuntimeException("Error al obtener motivos de ajuste", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    public List<Map<String, Object>> getActividadDiaria30Dias() {
        List<Map<String, Object>> actividad = new ArrayList<>();
        String sql = "SELECT DATE(fecha) as dia, " +
                     "SUM(CASE WHEN tipo = 'Entrada' THEN 1 ELSE 0 END) as entradas, " +
                     "SUM(CASE WHEN tipo = 'Salida' THEN 1 ELSE 0 END) as salidas " +
                     "FROM movimientos_inventario " +
                     "WHERE fecha >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                     "GROUP BY dia ORDER BY dia ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Map<String, Object> dia = new LinkedHashMap<>();
                dia.put("dia", rs.getString("dia"));
                dia.put("entradas", rs.getInt("entradas"));
                dia.put("salidas", rs.getInt("salidas"));
                actividad.add(dia);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener actividad diaria", e);
            throw new RuntimeException("Error al obtener actividad diaria", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return actividad;
    }

    public List<Map<String, Object>> getMovimientosUltimos7Dias() {
        List<Map<String, Object>> actividad = new ArrayList<>();
        String sql = "SELECT DATE(fecha) as dia, " +
                     "SUM(CASE WHEN tipo = 'Entrada' THEN 1 ELSE 0 END) as entradas, " +
                     "SUM(CASE WHEN tipo = 'Salida' THEN 1 ELSE 0 END) as salidas, " +
                     "SUM(CASE WHEN tipo = 'Ajuste' THEN 1 ELSE 0 END) as ajustes " +
                     "FROM movimientos_inventario " +
                     "WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                     "GROUP BY dia ORDER BY dia ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Map<String, Object> dia = new LinkedHashMap<>();
                dia.put("dia", rs.getString("dia"));
                dia.put("entradas", rs.getInt("entradas"));
                dia.put("salidas", rs.getInt("salidas"));
                dia.put("ajustes", rs.getInt("ajustes"));
                actividad.add(dia);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener movimientos", e);
            throw new RuntimeException("Error al obtener movimientos", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return actividad;
    }

    // --- Nuevos reportes para Almacén ---
    
    /**
     * Obtiene la distribución de stock por ubicación
     * Muestra qué ubicaciones tienen más stock
     */
    public Map<String, Integer> obtenerDistribucionStockPorUbicacion() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT u.nombre AS ubicacion, COALESCE(SUM(l.stock_actual), 0) AS stock_total " +
                     "FROM ubicaciones u " +
                     "LEFT JOIN lotes l ON l.ubicacion_id = u.id_ubicacion AND l.estado = 'Registrado' " +
                     "GROUP BY u.id_ubicacion, u.nombre " +
                     "ORDER BY stock_total DESC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("ubicacion"), rs.getInt("stock_total"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener distribución de stock por ubicación", e);
            throw new RuntimeException("Error al obtener distribución de stock por ubicación", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene productos con stock mínimo o crítico
     * Muestra productos que necesitan atención
     */
    public Map<String, Integer> obtenerProductosStockMinimo() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, " +
                     "COALESCE(SUM(l.stock_actual), 0) AS stock_actual, " +
                     "COALESCE(smc.stock_minimo_lote, 0) AS stock_minimo " +
                     "FROM productos p " +
                     "LEFT JOIN lotes l ON l.producto_id = p.id_producto AND l.estado = 'Registrado' " +
                     "LEFT JOIN stock_minimo_config smc ON smc.producto_id = p.id_producto " +
                     "WHERE p.activo = 1 " +
                     "GROUP BY p.id_producto, p.nombre, smc.stock_minimo_lote " +
                     "HAVING stock_actual <= stock_minimo AND stock_minimo > 0 " +
                     "ORDER BY stock_actual ASC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("stock_actual"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener productos con stock mínimo", e);
            throw new RuntimeException("Error al obtener productos con stock mínimo", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene los almaceneros más activos
     * Muestra qué usuarios han realizado más movimientos
     */
    public Map<String, Integer> obtenerAlmacenerosMasActivos() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT CONCAT(u.nombres, ' ', u.apellidos) AS nombre_completo, " +
                     "COUNT(m.id_movimiento) AS total_movimientos " +
                     "FROM movimientos_inventario m " +
                     "JOIN usuarios u ON m.usuario_id = u.id_usuario " +
                     "JOIN roles r ON u.rol_id = r.id_rol " +
                     "WHERE r.nombre = 'Almacenero' " +
                     "AND m.fecha >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                     "GROUP BY u.id_usuario, u.nombres, u.apellidos " +
                     "ORDER BY total_movimientos DESC " +
                     "LIMIT 8";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_completo"), rs.getInt("total_movimientos"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener almaceneros más activos", e);
            throw new RuntimeException("Error al obtener almaceneros más activos", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene lotes próximos a vencer (próximos 60 días)
     */
    public Map<String, Integer> obtenerLotesProximosAVencer() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre AS producto, " +
                     "COUNT(l.id_lote) AS cantidad_lotes " +
                     "FROM lotes l " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE l.fecha_vencimiento IS NOT NULL " +
                     "AND l.fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 60 DAY) " +
                     "AND l.estado = 'Registrado' " +
                     "GROUP BY p.id_producto, p.nombre " +
                     "ORDER BY cantidad_lotes DESC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("producto"), rs.getInt("cantidad_lotes"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener lotes próximos a vencer", e);
            throw new RuntimeException("Error al obtener lotes próximos a vencer", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene tendencias de entradas vs salidas por mes (últimos 6 meses)
     */
    public Map<String, Map<String, Integer>> obtenerTendenciasEntradasSalidasPorMes() {
        Map<String, Map<String, Integer>> resultado = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, " +
                     "SUM(CASE WHEN tipo = 'Entrada' THEN 1 ELSE 0 END) AS entradas, " +
                     "SUM(CASE WHEN tipo = 'Salida' THEN 1 ELSE 0 END) AS salidas " +
                     "FROM movimientos_inventario " +
                     "WHERE fecha >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                     "GROUP BY mes " +
                     "ORDER BY mes ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                Map<String, Integer> datosMes = new LinkedHashMap<>();
                datosMes.put("entradas", rs.getInt("entradas"));
                datosMes.put("salidas", rs.getInt("salidas"));
                resultado.put(rs.getString("mes"), datosMes);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener tendencias de entradas y salidas", e);
            throw new RuntimeException("Error al obtener tendencias de entradas y salidas", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return resultado;
    }

    /**
     * Obtiene productos con mayor rotación (más movimientos)
     */
    public Map<String, Integer> obtenerProductosMayorRotacion() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre AS producto, " +
                     "COUNT(m.id_movimiento) AS total_movimientos " +
                     "FROM movimientos_inventario m " +
                     "JOIN lotes l ON m.lote_id = l.id_lote " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE m.fecha >= DATE_SUB(NOW(), INTERVAL 30 DAY) " +
                     "GROUP BY p.id_producto, p.nombre " +
                     "ORDER BY total_movimientos DESC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("producto"), rs.getInt("total_movimientos"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener productos con mayor rotación", e);
            throw new RuntimeException("Error al obtener productos con mayor rotación", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    // --- Reportes para el Productor ---
    public Map<String, Integer> getTop5ProductosPorProductor(int productorId) {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, SUM(l.stock_actual) AS stock_total " +
                     "FROM productos p " +
                     "JOIN lotes l ON l.producto_id = p.id_producto " +
                     "WHERE p.productor_id = ? " +
                     "GROUP BY p.id_producto, p.nombre " +
                     "ORDER BY stock_total DESC LIMIT 5";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("stock_total"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener datos del productor", e);
            throw new RuntimeException("Error al obtener datos del productor", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return conteo;
    }

    public Map<String, Double> getValorInventarioPorCategoria(int productorId) {
        Map<String, Double> conteo = new LinkedHashMap<>();
        String sql = "SELECT c.nombre, SUM(l.stock_actual * p.precio_actual) AS valor_total " +
                     "FROM productos p " +
                     "JOIN categorias c ON p.categoria_id = c.id_categoria " +
                     "JOIN lotes l ON l.producto_id = p.id_producto " +
                     "WHERE p.productor_id = ? " +
                     "GROUP BY c.id_categoria, c.nombre";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getDouble("valor_total"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener valor de inventario", e);
            throw new RuntimeException("Error al obtener valor de inventario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return conteo;
    }

    public Map<String, Integer> getLotesProximosAVencer(int productorId) {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT l.codigo_lote, DATEDIFF(l.fecha_vencimiento, CURDATE()) AS dias_restantes FROM lotes l " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE p.productor_id = ? AND l.fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 60 DAY) " +
                     "ORDER BY dias_restantes ASC";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                conteo.put(rs.getString("codigo_lote"), rs.getInt("dias_restantes"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener lotes próximos a vencer", e);
            throw new RuntimeException("Error al obtener lotes próximos a vencer", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return conteo;
    }

    public Map<String, Integer> getDistribucionLotesPorUbicacion(int productorId) {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT u.nombre, COUNT(l.id_lote) AS cantidad_lotes FROM lotes l " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                     "WHERE p.productor_id = ? GROUP BY u.nombre";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productorId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("cantidad_lotes"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener distribución de lotes por ubicación", e);
            throw new RuntimeException("Error al obtener distribución de lotes por ubicación", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return conteo;
    }

    // --- Reportes agregados de TODOS los productores ---
    
    /**
     * Obtiene la distribución de productores por cantidad de productos
     * Muestra cuántos productos tiene cada productor
     */
    public Map<String, Integer> obtenerDistribucionProductoresPorCantidadProductos() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT CONCAT(u.nombres, ' ', u.apellidos) AS nombre_productor, " +
                     "COUNT(DISTINCT p.id_producto) AS cantidad_productos " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "LEFT JOIN productos p ON p.productor_id = u.id_usuario AND p.activo = 1 " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "GROUP BY u.id_usuario, u.nombres, u.apellidos " +
                     "ORDER BY cantidad_productos DESC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_productor"), rs.getInt("cantidad_productos"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener distribución de productores por cantidad de productos", e);
            throw new RuntimeException("Error al obtener distribución de productores por cantidad de productos", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene los top productores por stock total
     * Muestra qué productores tienen más stock acumulado
     */
    public Map<String, Integer> obtenerTopProductoresPorStockTotal() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT CONCAT(u.nombres, ' ', u.apellidos) AS nombre_productor, " +
                     "COALESCE(SUM(l.stock_actual), 0) AS stock_total " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "LEFT JOIN productos p ON p.productor_id = u.id_usuario AND p.activo = 1 " +
                     "LEFT JOIN lotes l ON l.producto_id = p.id_producto " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "GROUP BY u.id_usuario, u.nombres, u.apellidos " +
                     "ORDER BY stock_total DESC " +
                     "LIMIT 8";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_productor"), rs.getInt("stock_total"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener top productores por stock total", e);
            throw new RuntimeException("Error al obtener top productores por stock total", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene los productos más comunes entre todos los productores
     * Muestra qué productos son producidos por más productores
     */
    public Map<String, Integer> obtenerProductosMasComunesEntreProductores() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, COUNT(DISTINCT p.productor_id) AS cantidad_productores " +
                     "FROM productos p " +
                     "WHERE p.activo = 1 " +
                     "GROUP BY p.nombre " +
                     "HAVING cantidad_productores > 0 " +
                     "ORDER BY cantidad_productores DESC, p.nombre ASC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("cantidad_productores"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener productos más comunes entre productores", e);
            throw new RuntimeException("Error al obtener productos más comunes entre productores", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene la distribución de órdenes de compra por productor
     * Muestra cuántas órdenes de compra tiene cada productor
     */
    public Map<String, Integer> obtenerDistribucionOrdenesCompraPorProductor() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT CONCAT(u.nombres, ' ', u.apellidos) AS nombre_productor, " +
                     "COUNT(oc.id_orden_compra) AS cantidad_ordenes " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "LEFT JOIN productos p ON p.productor_id = u.id_usuario " +
                     "LEFT JOIN ordenes_compra oc ON oc.producto_id = p.id_producto " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "GROUP BY u.id_usuario, u.nombres, u.apellidos " +
                     "HAVING cantidad_ordenes > 0 " +
                     "ORDER BY cantidad_ordenes DESC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_productor"), rs.getInt("cantidad_ordenes"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener distribución de órdenes de compra por productor", e);
            throw new RuntimeException("Error al obtener distribución de órdenes de compra por productor", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    /**
     * Obtiene la comparativa de valor de inventario por productor
     * Muestra el valor total del inventario de cada productor
     */
    public Map<String, Double> obtenerComparativaValorInventarioPorProductor() {
        Map<String, Double> conteo = new LinkedHashMap<>();
        String sql = "SELECT CONCAT(u.nombres, ' ', u.apellidos) AS nombre_productor, " +
                     "COALESCE(SUM(l.stock_actual * p.precio_actual), 0) AS valor_inventario " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "LEFT JOIN productos p ON p.productor_id = u.id_usuario AND p.activo = 1 " +
                     "LEFT JOIN lotes l ON l.producto_id = p.id_producto " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "GROUP BY u.id_usuario, u.nombres, u.apellidos " +
                     "ORDER BY valor_inventario DESC " +
                     "LIMIT 10";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_productor"), rs.getDouble("valor_inventario"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener comparativa de valor de inventario por productor", e);
            throw new RuntimeException("Error al obtener comparativa de valor de inventario por productor", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }
}
