package com.example.telito.administrador.daos;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Este DAO es solo para las consultas de los reportes. No hay inserts ni updates aquí.
public class ReporteDAO {

    private String user = "root";
    private String pass = "root";
    private String url = "jdbc:mysql://localhost:3306/telito_bodeguero";

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        return DriverManager.getConnection(url, user, pass);
    }

    // --- Indicadores agregados para tarjetas dinámicas de Reportes Globales ---
    public int contarRutasActivas() {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE estado IS NOT NULL AND estado <> 'Entregado'";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int calcularEficienciaLogistica() {
        String sql = "SELECT SUM(CASE WHEN estado = 'Entregado' THEN 1 ELSE 0 END) AS entregados, COUNT(*) AS total FROM planes_transporte";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                int total = rs.getInt("total");
                int entregados = rs.getInt("entregados");
                if (total == 0) return 0;
                return (int) Math.round((entregados * 100.0) / total);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int contarProductores() {
        String sql = "SELECT COUNT(DISTINCT productor_id) FROM productos WHERE productor_id IS NOT NULL";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int contarLotes() {
        String sql = "SELECT COUNT(*) FROM lotes";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int contarProductos() {
        String sql = "SELECT COUNT(*) FROM productos";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int contarUbicaciones() {
        String sql = "SELECT COUNT(*) FROM ubicaciones";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // --- Reportes para la gente de Logística ---
    public Map<String, Integer> obtenerConteoPlanesPorEstado() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT estado, COUNT(*) AS cantidad FROM planes_transporte GROUP BY estado";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                conteo.put(rs.getString("estado"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    public Map<String, Integer> obtenerProductosMasTransportados() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, SUM(mi.cantidad) AS total_salidas FROM movimientos_inventario mi " +
                     "JOIN lotes l ON mi.lote_id = l.id_lote " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE mi.tipo = 'Salida' GROUP BY p.nombre ORDER BY total_salidas DESC LIMIT 5";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("total_salidas"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    public Map<String, Integer> obtenerRendimientoConductores() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT c.nombre_completo, COUNT(pt.id_plan) AS entregas FROM planes_transporte pt " +
                     "JOIN conductores c ON pt.conductor_id = c.id_conductor " +
                     "WHERE pt.estado = 'Entregado' GROUP BY c.nombre_completo ORDER BY entregas DESC LIMIT 5";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                conteo.put(rs.getString("nombre_completo"), rs.getInt("entregas"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    public Map<String, Integer> obtenerHistorialPedidosDespachados() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(fecha_creacion, '%Y-%m') AS mes, COUNT(*) AS cantidad FROM pedidos " +
                     "WHERE estado_preparacion = 'Despachado' AND fecha_creacion >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                     "GROUP BY mes ORDER BY mes ASC";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                conteo.put(rs.getString("mes"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    // --- Reportes para la gente de Almacén ---
    public Map<String, Integer> obtenerMovimientosHoy() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT tipo, COUNT(*) AS cantidad FROM movimientos_inventario WHERE DATE(fecha) = CURDATE() GROUP BY tipo";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                conteo.put(rs.getString("tipo"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    public Map<String, Integer> getTop5ProductosConStock() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT p.nombre, SUM(l.stock_actual) AS stock_total " +
                     "FROM productos p " +
                     "JOIN lotes l ON l.producto_id = p.id_producto " +
                     "GROUP BY p.id_producto, p.nombre " +
                     "ORDER BY stock_total DESC LIMIT 5";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                conteo.put(rs.getString("nombre"), rs.getInt("stock_total"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    public Map<String, Integer> getMotivosDeAjuste() {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT motivo, COUNT(*) as cantidad FROM movimientos_inventario WHERE tipo = 'Ajuste' AND motivo IS NOT NULL GROUP BY motivo ORDER BY cantidad DESC";
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                conteo.put(rs.getString("motivo"), rs.getInt("cantidad"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
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
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> dia = new LinkedHashMap<>();
                dia.put("dia", rs.getString("dia"));
                dia.put("entradas", rs.getInt("entradas"));
                dia.put("salidas", rs.getInt("salidas"));
                actividad.add(dia);
            }
        } catch (SQLException e) { e.printStackTrace(); }
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
        try (Connection conn = getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> dia = new LinkedHashMap<>();
                dia.put("dia", rs.getString("dia"));
                dia.put("entradas", rs.getInt("entradas"));
                dia.put("salidas", rs.getInt("salidas"));
                dia.put("ajustes", rs.getInt("ajustes"));
                actividad.add(dia);
            }
        } catch (SQLException e) { e.printStackTrace(); }
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
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    conteo.put(rs.getString("nombre"), rs.getInt("stock_total"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
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
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    conteo.put(rs.getString("nombre"), rs.getDouble("valor_total"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    public Map<String, Integer> getLotesProximosAVencer(int productorId) {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT l.codigo_lote, DATEDIFF(l.fecha_vencimiento, CURDATE()) AS dias_restantes FROM lotes l " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "WHERE p.productor_id = ? AND l.fecha_vencimiento BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 60 DAY) " +
                     "ORDER BY dias_restantes ASC";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    conteo.put(rs.getString("codigo_lote"), rs.getInt("dias_restantes"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }

    public Map<String, Integer> getDistribucionLotesPorUbicacion(int productorId) {
        Map<String, Integer> conteo = new LinkedHashMap<>();
        String sql = "SELECT u.nombre, COUNT(l.id_lote) AS cantidad_lotes FROM lotes l " +
                     "JOIN productos p ON l.producto_id = p.id_producto " +
                     "JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                     "WHERE p.productor_id = ? GROUP BY u.nombre";
        try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    conteo.put(rs.getString("nombre"), rs.getInt("cantidad_lotes"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return conteo;
    }
}
