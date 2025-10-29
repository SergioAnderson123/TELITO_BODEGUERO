package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Vehiculo;
import com.example.telito.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;

public class VehiculoDAO {

    // Listar todos los vehículos (compat) -> por defecto página 1, tamaño 10
    public ArrayList<Vehiculo> listarVehiculos() {
        return listarVehiculos(1, 10);
    }

    // Listar vehículos con paginación
    public ArrayList<Vehiculo> listarVehiculos(int page, int size) {
        ArrayList<Vehiculo> lista = new ArrayList<>();
        String sql = "SELECT id_vehiculo, placa, marca, modelo, capacidad_kg FROM vehiculos ORDER BY placa ASC LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Vehiculo vehiculo = new Vehiculo();
                    vehiculo.setIdVehiculo(rs.getInt("id_vehiculo"));
                    vehiculo.setPlaca(rs.getString("placa"));
                    vehiculo.setMarca(rs.getString("marca"));
                    vehiculo.setModelo(rs.getString("modelo"));
                    vehiculo.setCapacidadKg(rs.getInt("capacidad_kg"));
                    lista.add(vehiculo);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    // Contar vehículos para paginación
    public int contarVehiculos() {
        String sql = "SELECT COUNT(*) FROM vehiculos";
        int total = 0;
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) total = rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Buscar vehículo por ID
    public Vehiculo buscarVehiculoPorId(int id) {
        Vehiculo vehiculo = null;
        String sql = "SELECT id_vehiculo, placa, marca, modelo, capacidad_kg FROM vehiculos WHERE id_vehiculo = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    vehiculo = new Vehiculo();
                    vehiculo.setIdVehiculo(rs.getInt("id_vehiculo"));
                    vehiculo.setPlaca(rs.getString("placa"));
                    vehiculo.setMarca(rs.getString("marca"));
                    vehiculo.setModelo(rs.getString("modelo"));
                    vehiculo.setCapacidadKg(rs.getInt("capacidad_kg"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return vehiculo;
    }

    // Crear nuevo vehículo
    public boolean crearVehiculo(Vehiculo vehiculo) {
        String sql = "INSERT INTO vehiculos (placa, marca, modelo, capacidad_kg) VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, vehiculo.getPlaca());
            pstmt.setString(2, vehiculo.getMarca());
            pstmt.setString(3, vehiculo.getModelo());
            pstmt.setInt(4, vehiculo.getCapacidadKg());

            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Actualizar vehículo
    public boolean actualizarVehiculo(Vehiculo vehiculo) {
        String sql = "UPDATE vehiculos SET placa = ?, marca = ?, modelo = ?, capacidad_kg = ? WHERE id_vehiculo = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, vehiculo.getPlaca());
            pstmt.setString(2, vehiculo.getMarca());
            pstmt.setString(3, vehiculo.getModelo());
            pstmt.setInt(4, vehiculo.getCapacidadKg());
            pstmt.setInt(5, vehiculo.getIdVehiculo());

            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Eliminar vehículo
    public boolean eliminarVehiculo(int id) {
        String sql = "DELETE FROM vehiculos WHERE id_vehiculo = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Verificar si la placa ya existe (para validaciones)
    public boolean existePlaca(String placa, int idExcluir) {
        String sql = "SELECT COUNT(*) FROM vehiculos WHERE placa = ? AND id_vehiculo != ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, placa);
            pstmt.setInt(2, idExcluir);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

