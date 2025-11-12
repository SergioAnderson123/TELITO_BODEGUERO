package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Conductor;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class ConductorDAO extends DAOBase {

    // Listar todos los conductores (compat) -> por defecto página 1, tamaño 10
    public ArrayList<Conductor> listarConductores() {
        return listarConductores(1, 10);
    }

    // Listar conductores con paginación
    public ArrayList<Conductor> listarConductores(int page, int size) {
        ArrayList<Conductor> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, nombre_completo, licencia FROM conductores ORDER BY nombre_completo ASC LIMIT ? OFFSET ?";

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
                Conductor conductor = new Conductor();
                conductor.setIdConductor(rs.getInt("id_conductor"));
                conductor.setNombreCompleto(rs.getString("nombre_completo"));
                conductor.setLicencia(rs.getString("licencia"));
                lista.add(conductor);
            }
        } catch (SQLException e) {
            logger.error("Error al listar conductores", e);
            throw new RuntimeException("Error al listar conductores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }

    // Contar conductores para paginación
    public int contarConductores() {
        String sql = "SELECT COUNT(*) FROM conductores";
        return count(sql);
    }

    // Buscar conductor por ID
    public Conductor buscarConductorPorId(int id) {
        Conductor conductor = null;
        String sql = "SELECT id_conductor, nombre_completo, licencia FROM conductores WHERE id_conductor = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                conductor = new Conductor();
                conductor.setIdConductor(rs.getInt("id_conductor"));
                conductor.setNombreCompleto(rs.getString("nombre_completo"));
                conductor.setLicencia(rs.getString("licencia"));
            }
        } catch (SQLException e) {
            logger.error("Error al buscar conductor por ID: " + id, e);
            throw new RuntimeException("Error al buscar conductor", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return conductor;
    }

    // Crear nuevo conductor
    public boolean crearConductor(Conductor conductor) {
        String sql = "INSERT INTO conductores (nombre_completo, licencia) VALUES (?, ?)";
        int filasAfectadas = executeUpdate(sql, conductor.getNombreCompleto(), conductor.getLicencia());
        return filasAfectadas > 0;
    }

    // Actualizar conductor
    public boolean actualizarConductor(Conductor conductor) {
        String sql = "UPDATE conductores SET nombre_completo = ?, licencia = ? WHERE id_conductor = ?";
        int filasAfectadas = executeUpdate(sql, conductor.getNombreCompleto(), conductor.getLicencia(), conductor.getIdConductor());
        return filasAfectadas > 0;
    }

    // Eliminar conductor
    public boolean eliminarConductor(int id) {
        String sql = "DELETE FROM conductores WHERE id_conductor = ?";
        int filasAfectadas = executeUpdate(sql, id);
        return filasAfectadas > 0;
    }

    // Verificar si la licencia ya existe (para validaciones)
    public boolean existeLicencia(String licencia, int idExcluir) {
        String sql = "SELECT COUNT(*) FROM conductores WHERE licencia = ? AND id_conductor != ?";
        return count(sql, licencia, idExcluir) > 0;
    }

    /**
     * Obtiene todos los conductores sin paginación.
     * Útil para exportar a Excel.
     * 
     * @return Lista completa de conductores
     */
    public ArrayList<Conductor> listarTodosConductores() {
        ArrayList<Conductor> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, nombre_completo, licencia FROM conductores ORDER BY nombre_completo ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Conductor conductor = new Conductor();
                conductor.setIdConductor(rs.getInt("id_conductor"));
                conductor.setNombreCompleto(rs.getString("nombre_completo"));
                conductor.setLicencia(rs.getString("licencia"));
                lista.add(conductor);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todos los conductores", e);
            throw new RuntimeException("Error al listar todos los conductores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return lista;
    }
}

