package com.example.telito.administrador.daos;

import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Este DAO es solo para las consultas de los reportes. No hay inserts ni updates aquí.
public class ReporteDAO extends DAOBase {

    // --- Indicadores agregados para tarjetas dinámicas de Reportes Globales ---
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

    public Map<String, Integer> obtenerRendimientoConductores() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT c.nombre_completo, COUNT(pt.id_plan) AS entregas FROM planes_transporte pt " +
                     "JOIN conductores c ON pt.conductor_id = c.id_conductor " +
                     "WHERE pt.estado = 'Entregado' GROUP BY c.nombre_completo ORDER BY entregas DESC LIMIT 5";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("nombre_completo"), rs.getInt("entregas"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener rendimiento de conductores", e);
            throw new RuntimeException("Error al obtener rendimiento de conductores", e);
        } finally {
            closeResources(conn, stmt, rs);
        }
        return conteo;
    }

    public Map<String, Integer> obtenerHistorialPedidosDespachados() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes, COUNT(*) AS cantidad FROM pedidos " +
                     "WHERE estado_preparacion = 'Despachado' AND fecha_creacion >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                     "GROUP BY mes ORDER BY mes ASC";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                conteo.put(rs.getString("mes"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) {
            logger.error("Error al obtener historial de pedidos despachados", e);
            throw new RuntimeException("Error al obtener historial de pedidos despachados", e);
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
}
