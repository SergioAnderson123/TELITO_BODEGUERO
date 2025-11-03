package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.InventarioBean;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventarioDao {

    // === MÉTODO MODIFICADO PARA MOSTRAR LOTES INDIVIDUALES (como Almacenero) ===
    public ArrayList<InventarioBean> obtenerInventario(String busqueda, String estado, String lotes) {
        ArrayList<InventarioBean> listaInventario = new ArrayList<>();

        // Consulta SQL igual que el Almacenero (por lote individual) + cálculo de paquetes
        String sql = "SELECT l.id_lote, l.codigo_lote, l.stock_actual, l.fecha_vencimiento, l.estado, " +
                     "p.nombre AS nombre_producto, p.codigo_sku AS codigo_sku, p.unidades_por_paquete, " +
                     "FLOOR(l.stock_actual / p.unidades_por_paquete) AS paquetes_disponibles, " +
                     "u.nombre AS nombre_ubicacion " +
                     "FROM lotes l " +
                     "INNER JOIN productos p ON l.producto_id = p.id_producto " +
                     "INNER JOIN ubicaciones u ON l.ubicacion_id = u.id_ubicacion " +
                     "WHERE l.estado = 'Registrado' ";

        List<Object> params = new ArrayList<>();

        // Filtro por búsqueda (SKU o Producto)
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += "AND (p.codigo_sku LIKE ? OR p.nombre LIKE ?) ";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }

        // Filtro por estado de stock (adaptado a stock_actual)
        if (estado != null && !estado.trim().isEmpty()) {
            if (estado.equals("En stock")) {
                sql += "AND l.stock_actual > 0 ";
            } else if (estado.equals("Sin stock")) {
                sql += "AND l.stock_actual = 0 ";
            }
        }

        sql += "ORDER BY p.codigo_sku ASC, l.codigo_lote ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Establecer parámetros dinámicos
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    InventarioBean inventario = new InventarioBean();
                    inventario.setIdLote(rs.getInt("id_lote"));
                    inventario.setCodigoLote(rs.getString("codigo_lote"));
                    inventario.setCodigoSKU(rs.getString("codigo_sku"));
                    inventario.setNombreProducto(rs.getString("nombre_producto"));
                    inventario.setStockActual(rs.getInt("stock_actual"));
                    inventario.setPaquetesDisponibles(rs.getInt("paquetes_disponibles"));
                    inventario.setNombreUbicacion(rs.getString("nombre_ubicacion"));
                    inventario.setFechaVencimiento(rs.getDate("fecha_vencimiento"));
                    inventario.setEstado(rs.getString("estado"));
                    
                    listaInventario.add(inventario);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        return listaInventario;
    }

    // === MÉTODO PARA OBTENER TODO SIN FILTROS (para mantener compatibilidad) ===
    public ArrayList<InventarioBean> obtenerInventario() {
        return obtenerInventario(null, null, null);
    }

    // === MÉTODO PARA OBTENER INVENTARIO AGRUPADO POR PRODUCTO (para Logística) ===
    public ArrayList<InventarioBean> obtenerInventarioAgrupado(String busqueda, String estadoFiltro) {
        return obtenerInventarioAgrupado(busqueda, estadoFiltro, 1, Integer.MAX_VALUE);
    }

    // === MÉTODO CON PAGINACIÓN PARA OBTENER INVENTARIO AGRUPADO ===
    public ArrayList<InventarioBean> obtenerInventarioAgrupado(String busqueda, String estadoFiltro, int page, int size) {
        ArrayList<InventarioBean> listaInventario = new ArrayList<>();

        String sql = """
            SELECT 
                p.id_producto,
                p.codigo_sku,
                p.nombre AS nombre_producto,
                p.precio_actual AS precio_por_paquete,
                p.unidades_por_paquete,
                ROUND(p.precio_actual / p.unidades_por_paquete, 2) AS costo_por_unidad,
                SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) AS total_paquetes,
                smc.stock_minimo_producto,
                smc.stock_critico_producto,
                CASE
                    WHEN smc.id_stock_minimo IS NULL THEN 'No configurado'
                    WHEN SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) = 0 THEN 'Sin Stock'
                    WHEN SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) <= smc.stock_critico_producto THEN 'Sin Stock'
                    WHEN SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) <= smc.stock_minimo_producto THEN 'Poco Stock'
                    ELSE 'En Stock'
                END AS estado_stock
            FROM productos p
            INNER JOIN lotes l ON p.id_producto = l.producto_id AND l.estado = 'Registrado'
            LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1
            WHERE 1=1
            """;

        List<Object> params = new ArrayList<>();

        // Filtro por búsqueda (SKU o Producto)
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += "AND (p.codigo_sku LIKE ? OR p.nombre LIKE ?) ";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }

        sql += "GROUP BY p.id_producto, p.codigo_sku, p.nombre, p.precio_actual, p.unidades_por_paquete, smc.stock_minimo_producto, smc.stock_critico_producto, smc.id_stock_minimo ";

        // Filtro por estado de stock (después del GROUP BY, usar HAVING)
        if (estadoFiltro != null && !estadoFiltro.trim().isEmpty()) {
            if (estadoFiltro.equals("En stock")) {
                sql += "HAVING estado_stock = 'En Stock' ";
            } else if (estadoFiltro.equals("Poco stock")) {
                sql += "HAVING estado_stock = 'Poco Stock' ";
            } else if (estadoFiltro.equals("Sin stock")) {
                sql += "HAVING estado_stock = 'Sin Stock' ";
            }
        }

        sql += "ORDER BY p.codigo_sku ASC LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Establecer parámetros dinámicos
            int paramIndex = 1;
            for (Object param : params) {
                pstmt.setObject(paramIndex++, param);
            }

            // Parámetros de paginación
            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    InventarioBean inventario = new InventarioBean();
                    inventario.setIdProducto(rs.getInt("id_producto"));
                    inventario.setCodigoSKU(rs.getString("codigo_sku"));
                    inventario.setNombreProducto(rs.getString("nombre_producto"));
                    inventario.setPaquetesDisponibles(rs.getInt("total_paquetes"));
                    inventario.setPrecioPorPaquete(rs.getDouble("precio_por_paquete"));
                    inventario.setCostoPorUnidad(rs.getDouble("costo_por_unidad"));
                    inventario.setEstadoStock(rs.getString("estado_stock"));
                    
                    listaInventario.add(inventario);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        return listaInventario;
    }

    // === MÉTODO PARA OBTENER TODO EL INVENTARIO AGRUPADO SIN PAGINACIÓN (para reportes) ===
    public ArrayList<InventarioBean> listarTodoInventarioAgrupado(String busqueda, String estadoFiltro) {
        return obtenerInventarioAgrupado(busqueda, estadoFiltro, 1, Integer.MAX_VALUE);
    }

    // === MÉTODO PARA CONTAR TOTAL DE REGISTROS CON FILTROS ===
    public int contarInventarioAgrupado(String busqueda, String estadoFiltro) {
        String sql = """
            SELECT COUNT(*) as total
            FROM (
                SELECT 
                    p.id_producto,
                    SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) AS total_paquetes,
                    smc.stock_minimo_producto,
                    smc.stock_critico_producto,
                    CASE
                        WHEN smc.id_stock_minimo IS NULL THEN 'No configurado'
                        WHEN SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) = 0 THEN 'Sin Stock'
                        WHEN SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) <= smc.stock_critico_producto THEN 'Sin Stock'
                        WHEN SUM(FLOOR(l.stock_actual / p.unidades_por_paquete)) <= smc.stock_minimo_producto THEN 'Poco Stock'
                        ELSE 'En Stock'
                    END AS estado_stock
                FROM productos p
                INNER JOIN lotes l ON p.id_producto = l.producto_id AND l.estado = 'Registrado'
                LEFT JOIN stock_minimo_config smc ON p.id_producto = smc.producto_id AND smc.activo = 1
                WHERE 1=1
            """;

        List<Object> params = new ArrayList<>();

        // Filtro por búsqueda (SKU o Producto)
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += "AND (p.codigo_sku LIKE ? OR p.nombre LIKE ?) ";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }

        sql += "GROUP BY p.id_producto, p.codigo_sku, p.nombre, p.precio_actual, p.unidades_por_paquete, smc.stock_minimo_producto, smc.stock_critico_producto, smc.id_stock_minimo ";

        // Filtro por estado de stock
        if (estadoFiltro != null && !estadoFiltro.trim().isEmpty()) {
            if (estadoFiltro.equals("En stock")) {
                sql += "HAVING estado_stock = 'En Stock' ";
            } else if (estadoFiltro.equals("Poco stock")) {
                sql += "HAVING estado_stock = 'Poco Stock' ";
            } else if (estadoFiltro.equals("Sin stock")) {
                sql += "HAVING estado_stock = 'Sin Stock' ";
            }
        }

        sql += ") as subquery";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Establecer parámetros dinámicos
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}