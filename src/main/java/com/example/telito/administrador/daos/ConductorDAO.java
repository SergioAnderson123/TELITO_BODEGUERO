package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Conductor;
import com.example.telito.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;

public class ConductorDAO {

    // Listar todos los conductores
    public ArrayList<Conductor> listarConductores() {
        ArrayList<Conductor> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, nombre_completo, licencia FROM conductores ORDER BY nombre_completo ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Conductor conductor = new Conductor();
                conductor.setIdConductor(rs.getInt("id_conductor"));
                conductor.setNombreCompleto(rs.getString("nombre_completo"));
                conductor.setLicencia(rs.getString("licencia"));
                lista.add(conductor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    // Buscar conductor por ID
    public Conductor buscarConductorPorId(int id) {
        Conductor conductor = null;
        String sql = "SELECT id_conductor, nombre_completo, licencia FROM conductores WHERE id_conductor = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    conductor = new Conductor();
                    conductor.setIdConductor(rs.getInt("id_conductor"));
                    conductor.setNombreCompleto(rs.getString("nombre_completo"));
                    conductor.setLicencia(rs.getString("licencia"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conductor;
    }

    // Crear nuevo conductor
    public boolean crearConductor(Conductor conductor) {
        String sql = "INSERT INTO conductores (nombre_completo, licencia) VALUES (?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, conductor.getNombreCompleto());
            pstmt.setString(2, conductor.getLicencia());

            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Actualizar conductor
    public boolean actualizarConductor(Conductor conductor) {
        String sql = "UPDATE conductores SET nombre_completo = ?, licencia = ? WHERE id_conductor = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, conductor.getNombreCompleto());
            pstmt.setString(2, conductor.getLicencia());
            pstmt.setInt(3, conductor.getIdConductor());

            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Eliminar conductor
    public boolean eliminarConductor(int id) {
        String sql = "DELETE FROM conductores WHERE id_conductor = ?";

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

    // Verificar si la licencia ya existe (para validaciones)
    public boolean existeLicencia(String licencia, int idExcluir) {
        String sql = "SELECT COUNT(*) FROM conductores WHERE licencia = ? AND id_conductor != ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, licencia);
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

