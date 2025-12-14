package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Conductor;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de conductores
public class ConductorDAO extends DAOBase {

    // Listar todos (compatibilidad - página 1, tamaño 10)
    public ArrayList<Conductor> listarConductores() {
        return listarConductores(1, 10);
    }

    // Listar con paginación
    public ArrayList<Conductor> listarConductores(int page, int size) {
        return listarConductores(null, page, size);
    }
    
    // Listar con filtros y paginación
    public ArrayList<Conductor> listarConductores(String busqueda, int page, int size) {
        ArrayList<Conductor> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, nombre_completo, licencia FROM conductores WHERE 1=1";
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (nombre_completo LIKE ? OR licencia LIKE ?)";
        }
        
        sql += " ORDER BY nombre_completo ASC LIMIT ? OFFSET ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            int paramIndex = 1;
            if (busqueda != null && !busqueda.trim().isEmpty()) {
                String busquedaConWildcards = "%" + busqueda + "%";
                pstmt.setString(paramIndex++, busquedaConWildcards);
                pstmt.setString(paramIndex++, busquedaConWildcards);
            }

            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);
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

    // Contar total (sin filtros)
    public int contarConductores() {
        return contarConductores(null);
    }
    
    // Contar con filtros
    public int contarConductores(String busqueda) {
        String sql = "SELECT COUNT(*) FROM conductores WHERE 1=1";
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (nombre_completo LIKE ? OR licencia LIKE ?)";
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            if (busqueda != null && !busqueda.trim().isEmpty()) {
                String busquedaConWildcards = "%" + busqueda + "%";
                pstmt.setString(1, busquedaConWildcards);
                pstmt.setString(2, busquedaConWildcards);
            }
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar conductores", e);
            throw new RuntimeException("Error al contar conductores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
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

    // Verificar si el conductor tiene planes de transporte asociados
    public boolean tienePlanesTransporteAsociados(int id) {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE conductor_id = ?";
        int count = count(sql, id);
        return count > 0;
    }
    
    // Eliminar conductor (verifica si tiene planes asociados primero)
    public boolean eliminarConductor(int id) throws RuntimeException {
        // Verificar si tiene planes de transporte asociados
        if (tienePlanesTransporteAsociados(id)) {
            throw new RuntimeException("No se puede eliminar el conductor porque tiene planes de transporte asociados. " +
                                     "Por favor, elimine o reasigne los planes de transporte primero.");
        }
        
        String sql = "DELETE FROM conductores WHERE id_conductor = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;
        } catch (SQLIntegrityConstraintViolationException e) {
            // Por si acaso todavía ocurre la excepción, la manejamos específicamente
            logger.error("Error de integridad referencial al eliminar conductor: " + id, e);
            throw new RuntimeException("No se puede eliminar el conductor porque está siendo utilizado en planes de transporte. " +
                                     "Por favor, elimine o reasigne los planes de transporte primero.", e);
        } catch (SQLException e) {
            logger.error("Error al eliminar conductor: " + id, e);
            throw new RuntimeException("Error al eliminar el conductor", e);
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Verificar si la licencia ya existe (para validaciones)
    public boolean existeLicencia(String licencia, int idExcluir) {
        String sql = "SELECT COUNT(*) FROM conductores WHERE licencia = ? AND id_conductor != ?";
        return count(sql, licencia, idExcluir) > 0;
    }

    /**
     * Cuenta el total de conductores
     */
    public int contarTotalConductores() {
        String sql = "SELECT COUNT(*) FROM conductores";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar total conductores", e);
            throw new RuntimeException("Error al contar total conductores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }

    /**
     * Cuenta conductores con planes de transporte asignados
     */
    public int contarConductoresConPlanes() {
        String sql = "SELECT COUNT(DISTINCT c.id_conductor) FROM conductores c " +
                     "INNER JOIN planes_transporte pt ON c.id_conductor = pt.conductor_id";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar conductores con planes", e);
            throw new RuntimeException("Error al contar conductores con planes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }

    /**
     * Cuenta conductores sin planes de transporte asignados
     */
    public int contarConductoresSinPlanes() {
        String sql = "SELECT COUNT(*) FROM conductores c " +
                     "LEFT JOIN planes_transporte pt ON c.id_conductor = pt.conductor_id " +
                     "WHERE pt.conductor_id IS NULL";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar conductores sin planes", e);
            throw new RuntimeException("Error al contar conductores sin planes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
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

