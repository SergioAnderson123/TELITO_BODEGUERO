package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.MovimientoInventarioBean;
import java.sql.*;
import java.util.ArrayList;

public class MovimientoInventarioDao {

    /**
     * Query específico para obtener los 7 campos de product-movement:
     * Fecha, Producto, Tipo, Destino, Lote, Personal Responsable, Observaciones
     */
    public ArrayList<MovimientoInventarioBean> obtenerMovimientos() {

        // Aplicar patrón exitoso de JobDao - cargar driver explícitamente
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        // Usar misma configuración que JobDao exitoso
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";  // Cambio crítico: usar "root" como en JobDao exitoso

        ArrayList<MovimientoInventarioBean> listaMovimientos = new ArrayList<>();

        String sql = """
            SELECT 
                DATE_FORMAT(mi.fecha, '%d/%m/%Y') as fechaFormateada,
                p.nombre AS nombreProducto,
                mi.tipo,
                COALESCE(ubi.nombre, 'N/A') AS destino, -- Changed to ubi.nombre
                l.codigo_lote AS codigoLote,
                CONCAT(u.nombres, ' ', u.apellidos) AS responsable,
                COALESCE(mi.motivo, 'Sin observaciones') AS observaciones
            FROM movimientos_inventario mi
            INNER JOIN lotes l ON mi.lote_id = l.id_lote
            INNER JOIN productos p ON l.producto_id = p.id_producto  
            INNER JOIN usuarios u ON mi.usuario_id = u.id_usuario
            LEFT JOIN ubicaciones ubi ON l.ubicacion_id = ubi.id_ubicacion -- Changed join to ubicaciones
            ORDER BY mi.fecha DESC
            """;

        try {
            Connection conn = DriverManager.getConnection(url, username, password);
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

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

        } catch (SQLException e) {
            // Usar mismo patrón de manejo de errores que JobDao
            throw new RuntimeException(e);
        }

        return listaMovimientos;
    }
}