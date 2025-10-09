package com.example.inventario.daos;

import com.example.inventario.beans.Movimiento;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

public class MovimientoDao {

    private String url = "jdbc:mysql://localhost:3306/telito4";
    private String user = "root";
    private String pass = "chupamela2005";

    public void registrarMovimiento(Movimiento movimiento) {
        String sql = "INSERT INTO movimientos_inventario (lote_id, tipo, cantidad, motivo, pedido_id, usuario_id) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        try{Class.forName("com.mysql.cj.jdbc.Driver");
        }catch(ClassNotFoundException e){
            throw new RuntimeException(e);
        }

        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, movimiento.getLoteId());
            pstmt.setString(2, movimiento.getTipoMovimiento());
            pstmt.setInt(3, movimiento.getCantidad());
            pstmt.setString(4, movimiento.getMotivo());

            // Para los IDs que pueden ser nulos, usamos setObject
            if (movimiento.getPedidoId() != null) {
                pstmt.setInt(5, movimiento.getPedidoId());
            } else {
                pstmt.setNull(5, Types.INTEGER);
            }
            System.out.println("--- El usuario es: " + movimiento.getUsuarioId() + " ---");
            if (movimiento.getUsuarioId() != null) {
                pstmt.setInt(6, movimiento.getUsuarioId());
            } else {
                pstmt.setInt(6, 1);
            }

            pstmt.executeUpdate();

        } catch (SQLException e) {
            throw new RuntimeException("Error al registrar movimiento", e);
        }
    }
}
