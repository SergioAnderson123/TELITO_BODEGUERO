package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.InventarioBean;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventarioDao {

    // === MÉTODO MODIFICADO PARA ACEPTAR FILTROS ===
    public ArrayList<InventarioBean> obtenerInventario(String busqueda, String estado, String lotes) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        ArrayList<InventarioBean> listaInventario = new ArrayList<>();

        // Consulta base con subconsulta para poder filtrar
        String sql = """
              SELECT
                  sku,
                  nombreProducto,
                  cantidadLotes,
                  codigosDeLote,
                  proximoVencimiento,
                  estadoStock,
                  stockTotal
              FROM (
                  SELECT
                      p.codigo_sku AS sku,
                      p.nombre AS nombreProducto,
                      COUNT(l.id_lote) AS cantidadLotes,
                      GROUP_CONCAT(l.codigo_lote SEPARATOR ', ') AS codigosDeLote,
                      DATE_FORMAT(MIN(l.fecha_vencimiento), '%d/%m/%Y') AS proximoVencimiento,
                      CASE
                          WHEN SUM(l.stock_actual) > 0 THEN 'En stock'
                          ELSE 'Sin stock'
                      END AS estadoStock,
                      SUM(l.stock_actual) AS stockTotal
                  FROM
                      productos p
                  LEFT JOIN
                      lotes l ON p.id_producto = l.producto_id
                  WHERE
                      l.id_lote IS NOT NULL
                  GROUP BY
                      p.id_producto, p.codigo_sku, p.nombre
              ) AS inventario
              WHERE 1=1
            """;

        List<Object> params = new ArrayList<>();

        // Filtro por búsqueda (SKU o Producto)
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (sku LIKE ? OR nombreProducto LIKE ?)";
            String busquedaParam = "%" + busqueda.trim() + "%";
            params.add(busquedaParam);
            params.add(busquedaParam);
        }

        // Filtro por estado de stock
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND estadoStock = ?";
            params.add(estado.trim());
        }

        // Filtro por cantidad de lotes
        if (lotes != null && !lotes.trim().isEmpty()) {
            if (lotes.equals("1")) {
                sql += " AND cantidadLotes = 1";
            } else if (lotes.equals("2-5")) {
                sql += " AND cantidadLotes BETWEEN 2 AND 5";
            } else if (lotes.equals("6+")) {
                sql += " AND cantidadLotes >= 6";
            }
        }

        sql += " ORDER BY sku ASC";

        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Establecer parámetros dinámicos
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String sku = rs.getString("sku");
                    String nombreProducto = rs.getString("nombreProducto");
                    int cantidadLotes = rs.getInt("cantidadLotes");
                    String codigosDeLote = rs.getString("codigosDeLote");
                    String proximoVencimiento = rs.getString("proximoVencimiento");
                    String estadoStock = rs.getString("estadoStock");
                    int stockTotal = rs.getInt("stockTotal");

                    InventarioBean inventario = new InventarioBean(
                            sku,
                            nombreProducto,
                            cantidadLotes,
                            codigosDeLote,
                            proximoVencimiento,
                            estadoStock,
                            stockTotal
                    );
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
}