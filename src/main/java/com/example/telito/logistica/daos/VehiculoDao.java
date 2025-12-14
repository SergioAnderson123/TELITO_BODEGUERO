package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.VehiculoBean;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de vehículos desde perspectiva de logística
public class VehiculoDao extends DAOBase {

    // Lista todos los vehículos ordenados por placa
    public ArrayList<VehiculoBean> listarVehiculos() {
        ArrayList<VehiculoBean> lista = new ArrayList<>();
        String sql = "SELECT id_vehiculo, placa FROM vehiculos ORDER BY placa ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                VehiculoBean vehiculo = new VehiculoBean();
                vehiculo.setId(rs.getInt("id_vehiculo"));
                vehiculo.setPlaca(rs.getString("placa"));
                lista.add(vehiculo);
            }
        } catch (SQLException e) {
            logger.error("Error al listar vehículos", e);
            throw new RuntimeException("Error al listar vehículos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}