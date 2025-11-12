package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Vehiculo;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class VehiculoDAO extends DAOBase {

    // Listar todos los vehículos (compat) -> por defecto página 1, tamaño 10
    public ArrayList<Vehiculo> listarVehiculos() {
        return listarVehiculos(1, 10);
    }

    // Listar vehículos con paginación
    public ArrayList<Vehiculo> listarVehiculos(int page, int size) {
        ArrayList<Vehiculo> lista = new ArrayList<>();
        String sql = "SELECT id_vehiculo, placa, marca, modelo, capacidad_kg FROM vehiculos ORDER BY placa ASC LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Vehiculo vehiculo = new Vehiculo();
                vehiculo.setIdVehiculo(rs.getInt("id_vehiculo"));
                vehiculo.setPlaca(rs.getString("placa"));
                vehiculo.setMarca(rs.getString("marca"));
                vehiculo.setModelo(rs.getString("modelo"));
                vehiculo.setCapacidadKg(rs.getInt("capacidad_kg"));
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

    // Contar vehículos para paginación
    public int contarVehiculos() {
        String sql = "SELECT COUNT(*) FROM vehiculos";
        return count(sql);
    }

    // Buscar vehículo por ID
    public Vehiculo buscarVehiculoPorId(int id) {
        Vehiculo vehiculo = null;
        String sql = "SELECT id_vehiculo, placa, marca, modelo, capacidad_kg FROM vehiculos WHERE id_vehiculo = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                vehiculo = new Vehiculo();
                vehiculo.setIdVehiculo(rs.getInt("id_vehiculo"));
                vehiculo.setPlaca(rs.getString("placa"));
                vehiculo.setMarca(rs.getString("marca"));
                vehiculo.setModelo(rs.getString("modelo"));
                vehiculo.setCapacidadKg(rs.getInt("capacidad_kg"));
            }
        } catch (SQLException e) {
            logger.error("Error al buscar vehículo por ID: " + id, e);
            throw new RuntimeException("Error al buscar vehículo", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return vehiculo;
    }

    // Crear nuevo vehículo
    public boolean crearVehiculo(Vehiculo vehiculo) {
        String sql = "INSERT INTO vehiculos (placa, marca, modelo, capacidad_kg) VALUES (?, ?, ?, ?)";
        int filasAfectadas = executeUpdate(sql, vehiculo.getPlaca(), vehiculo.getMarca(), vehiculo.getModelo(), vehiculo.getCapacidadKg());
        return filasAfectadas > 0;
    }

    // Actualizar vehículo
    public boolean actualizarVehiculo(Vehiculo vehiculo) {
        String sql = "UPDATE vehiculos SET placa = ?, marca = ?, modelo = ?, capacidad_kg = ? WHERE id_vehiculo = ?";
        int filasAfectadas = executeUpdate(sql, vehiculo.getPlaca(), vehiculo.getMarca(), vehiculo.getModelo(), vehiculo.getCapacidadKg(), vehiculo.getIdVehiculo());
        return filasAfectadas > 0;
    }

    // Eliminar vehículo
    public boolean eliminarVehiculo(int id) {
        String sql = "DELETE FROM vehiculos WHERE id_vehiculo = ?";
        int filasAfectadas = executeUpdate(sql, id);
        return filasAfectadas > 0;
    }

    // Verificar si la placa ya existe (para validaciones)
    public boolean existePlaca(String placa, int idExcluir) {
        String sql = "SELECT COUNT(*) FROM vehiculos WHERE placa = ? AND id_vehiculo != ?";
        return count(sql, placa, idExcluir) > 0;
    }
}

