package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.InventarioBean;
import java.sql.*;
import java.util.ArrayList;

public class InventarioDao {

    public ArrayList<InventarioBean> obtenerInventario() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }

        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        ArrayList<InventarioBean> listaInventario = new ArrayList<>();

        // Esta consulta SQL ya es la correcta, no se toca.
        String sql = """
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
              ORDER BY
                  p.codigo_sku ASC;
            """;

        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            // === ESTA SECCIÓN ES LA QUE HA SIDO CORREGIDA ===
            while (rs.next()) {
                // Leer las columnas del ResultSet USANDO LOS ALIAS CORRECTOS
                String sku = rs.getString("sku");
                String nombreProducto = rs.getString("nombreProducto");
                int cantidadLotes = rs.getInt("cantidadLotes");
                String codigosDeLote = rs.getString("codigosDeLote");           // CORREGIDO
                String proximoVencimiento = rs.getString("proximoVencimiento");   // CORREGIDO
                String estadoStock = rs.getString("estadoStock");
                int stockTotal = rs.getInt("stockTotal");                       // AÑADIDO

                // Crear el Bean usando el constructor y los datos correctos
                InventarioBean inventario = new InventarioBean(
                        sku,
                        nombreProducto,
                        cantidadLotes,
                        codigosDeLote,       // CORREGIDO
                        proximoVencimiento,  // CORREGIDO
                        estadoStock,
                        stockTotal           // AÑADIDO
                );
                listaInventario.add(inventario);
            }
        } catch (SQLException e) {
            // Imprimir el error en la consola ayuda a depurar
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        return listaInventario;
    }
}