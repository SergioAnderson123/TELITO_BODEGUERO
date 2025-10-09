package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.LoteBean;

import java.sql.*;
import java.util.ArrayList;

public class LoteDao {

    public ArrayList<LoteBean> listarLotesDisponibles() {
        ArrayList<LoteBean> lista = new ArrayList<>();
        String sql = """
            SELECT l.id_lote, l.codigo_lote, p.nombre AS nombre_producto
            FROM lotes l
            INNER JOIN productos p ON l.producto_id = p.id_producto
            WHERE l.stock_actual > 0
            ORDER BY p.nombre, l.codigo_lote;
            """;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        String url = "jdbc:mysql://localhost:3306/telito_bodeguero";
        String username = "root";
        String password = "root";

        try (Connection conn = DriverManager.getConnection(url, username, password);
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                LoteBean lote = new LoteBean();
                lote.setId(rs.getInt("id_lote"));
                lote.setCodigoLote(rs.getString("codigo_lote"));
                lote.setNombreProducto(rs.getString("nombre_producto"));
                lista.add(lote);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}