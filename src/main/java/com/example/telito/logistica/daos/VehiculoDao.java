package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.VehiculoBean;
import com.example.telito.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;

public class VehiculoDao {

    public ArrayList<VehiculoBean> listarVehiculos() {
        ArrayList<VehiculoBean> lista = new ArrayList<>();
        String sql = "SELECT id_vehiculo, placa FROM vehiculos ORDER BY placa ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                VehiculoBean vehiculo = new VehiculoBean();
                vehiculo.setId(rs.getInt("id_vehiculo"));
                vehiculo.setPlaca(rs.getString("placa"));
                lista.add(vehiculo);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }
}