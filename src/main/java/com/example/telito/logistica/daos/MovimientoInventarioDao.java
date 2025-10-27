package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.MovimientoInventarioBean;
import com.example.telito.util.DatabaseConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MovimientoInventarioDao {

    // === MÉTODO MODIFICADO PARA ACEPTAR FILTROS ===
    public ArrayList<MovimientoInventarioBean> obtenerMovimientos(String busqueda, String tipo, String periodo) {
        // Conexión centralizada

        ArrayList<MovimientoInventarioBean> listaMovimientos = new ArrayList<>();

        String sql = """
            SELECT 
                DATE_FORMAT(mi.fecha, '%d/%m/%Y') as fechaFormateada,
                p.nombre AS nombreProducto,
                mi.tipo,
                COALESCE(ubi.nombre, 'N/A') AS destino,
                l.codigo_lote AS codigoLote,
                CONCAT(u.nombres, ' ', u.apellidos) AS responsable,
                COALESCE(mi.motivo, 'Sin observaciones') AS observaciones
            FROM movimientos_inventario mi
            INNER JOIN lotes l ON mi.lote_id = l.id_lote
            INNER JOIN productos p ON l.producto_id = p.id_producto  
            INNER JOIN usuarios u ON mi.usuario_id = u.id_usuario
            LEFT JOIN ubicaciones ubi ON l.ubicacion_id = ubi.id_ubicacion
            WHERE 1=1
            AND (mi.motivo IS NULL OR mi.motivo NOT LIKE 'Ajuste de inventario%')
            """;

        List<Object> params = new ArrayList<>();

        // Filtro por búsqueda (Producto o Lote)
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (p.nombre LIKE ? OR l.codigo_lote LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }

        // Filtro por tipo de movimiento
        if (tipo != null && !tipo.trim().isEmpty()) {
            sql += " AND mi.tipo = ?";
            params.add(tipo.trim());
        }

        // Filtro por periodo (últimos X días)
        if (periodo != null && !periodo.trim().isEmpty()) {
            try {
                int dias = Integer.parseInt(periodo);
                sql += " AND mi.fecha >= DATE_SUB(CURDATE(), INTERVAL ? DAY)";
                params.add(dias);
            } catch (NumberFormatException e) {
                // Si no es un número válido, ignorar el filtro
            }
        }

        sql += " ORDER BY mi.fecha DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Establecer parámetros dinámicos
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MovimientoInventarioBean movimiento = new MovimientoInventarioBean(
                            rs.getString("fechaFormateada"),
                            rs.getString("nombreProducto"),
                            rs.getString("tipo"),
                            rs.getString("destino"),
                            rs.getString("codigoLote"),
                            rs.getString("responsable"),
                            rs.getString("observaciones")
                    );
                    listaMovimientos.add(movimiento);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }

        return listaMovimientos;
    }

    // === MÉTODO PARA OBTENER TODO SIN FILTROS (para mantener compatibilidad) ===
    public ArrayList<MovimientoInventarioBean> obtenerMovimientos() {
        return obtenerMovimientos(null, null, null);
    }
}