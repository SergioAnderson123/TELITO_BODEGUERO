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
        return listarConductores(busqueda, null, null, page, size);
    }
    
    // Listar con todos los filtros
    public ArrayList<Conductor> listarConductores(String busqueda, String dni, String fechaVencimiento, int page, int size) {
        ArrayList<Conductor> lista = new ArrayList<>();
        String sql = "SELECT id_conductor, nombre_completo, licencia, telefono, email, dni, tipo_licencia, fecha_vencimiento_licencia FROM conductores WHERE 1=1";
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (nombre_completo LIKE ? OR licencia LIKE ? OR dni LIKE ? OR email LIKE ? OR telefono LIKE ?)";
        }
        
        if (dni != null && !dni.trim().isEmpty()) {
            sql += " AND dni LIKE ?";
        }
        
        if (fechaVencimiento != null && !fechaVencimiento.trim().isEmpty()) {
            sql += " AND fecha_vencimiento_licencia <= ?";
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
                pstmt.setString(paramIndex++, busquedaConWildcards);
                pstmt.setString(paramIndex++, busquedaConWildcards);
                pstmt.setString(paramIndex++, busquedaConWildcards);
            }
            
            if (dni != null && !dni.trim().isEmpty()) {
                pstmt.setString(paramIndex++, "%" + dni + "%");
            }
            
            if (fechaVencimiento != null && !fechaVencimiento.trim().isEmpty()) {
                pstmt.setString(paramIndex++, fechaVencimiento);
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
                conductor.setTelefono(rs.getString("telefono"));
                conductor.setEmail(rs.getString("email"));
                conductor.setDni(rs.getString("dni"));
                conductor.setTipoLicencia(rs.getString("tipo_licencia"));
                Date fechaVenc = rs.getDate("fecha_vencimiento_licencia");
                conductor.setFechaVencimientoLicencia(fechaVenc != null ? fechaVenc : null);
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
        return contarConductores(busqueda, null, null);
    }
    
    // Contar con todos los filtros
    public int contarConductores(String busqueda, String dni, String fechaVencimiento) {
        String sql = "SELECT COUNT(*) FROM conductores WHERE 1=1";
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (nombre_completo LIKE ? OR licencia LIKE ? OR dni LIKE ? OR email LIKE ? OR telefono LIKE ?)";
        }
        
        if (dni != null && !dni.trim().isEmpty()) {
            sql += " AND dni LIKE ?";
        }
        
        if (fechaVencimiento != null && !fechaVencimiento.trim().isEmpty()) {
            sql += " AND fecha_vencimiento_licencia <= ?";
        }
        
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
                pstmt.setString(paramIndex++, busquedaConWildcards);
                pstmt.setString(paramIndex++, busquedaConWildcards);
                pstmt.setString(paramIndex++, busquedaConWildcards);
            }
            
            if (dni != null && !dni.trim().isEmpty()) {
                pstmt.setString(paramIndex++, "%" + dni + "%");
            }
            
            if (fechaVencimiento != null && !fechaVencimiento.trim().isEmpty()) {
                pstmt.setString(paramIndex++, fechaVencimiento);
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
        String sql = "SELECT id_conductor, nombre_completo, licencia, telefono, email, dni, tipo_licencia, fecha_vencimiento_licencia FROM conductores WHERE id_conductor = ?";

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
                conductor.setTelefono(rs.getString("telefono"));
                conductor.setEmail(rs.getString("email"));
                conductor.setDni(rs.getString("dni"));
                conductor.setTipoLicencia(rs.getString("tipo_licencia"));
                Date fechaVenc = rs.getDate("fecha_vencimiento_licencia");
                conductor.setFechaVencimientoLicencia(fechaVenc != null ? fechaVenc : null);
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
        String sql = "INSERT INTO conductores (nombre_completo, licencia, telefono, email, dni, tipo_licencia, fecha_vencimiento_licencia) VALUES (?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, conductor.getNombreCompleto());
            pstmt.setString(2, conductor.getLicencia());
            pstmt.setString(3, conductor.getTelefono());
            pstmt.setString(4, conductor.getEmail());
            pstmt.setString(5, conductor.getDni());
            pstmt.setString(6, conductor.getTipoLicencia());
            if (conductor.getFechaVencimientoLicencia() != null) {
                pstmt.setDate(7, conductor.getFechaVencimientoLicencia());
            } else {
                pstmt.setDate(7, null);
            }
            
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;
        } catch (SQLException e) {
            logger.error("Error al crear conductor", e);
            throw new RuntimeException("Error al crear conductor", e);
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Actualizar conductor
    public boolean actualizarConductor(Conductor conductor) {
        String sql = "UPDATE conductores SET nombre_completo = ?, licencia = ?, telefono = ?, email = ?, dni = ?, tipo_licencia = ?, fecha_vencimiento_licencia = ? WHERE id_conductor = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, conductor.getNombreCompleto());
            pstmt.setString(2, conductor.getLicencia());
            pstmt.setString(3, conductor.getTelefono());
            pstmt.setString(4, conductor.getEmail());
            pstmt.setString(5, conductor.getDni());
            pstmt.setString(6, conductor.getTipoLicencia());
            if (conductor.getFechaVencimientoLicencia() != null) {
                pstmt.setDate(7, conductor.getFechaVencimientoLicencia());
            } else {
                pstmt.setDate(7, null);
            }
            pstmt.setInt(8, conductor.getIdConductor());
            
            int filasAfectadas = pstmt.executeUpdate();
            return filasAfectadas > 0;
        } catch (SQLException e) {
            logger.error("Error al actualizar conductor", e);
            throw new RuntimeException("Error al actualizar conductor", e);
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Verificar si el conductor tiene planes de transporte asociados (solo cuenta los que NO están entregados ni cancelados)
    public boolean tienePlanesTransporteAsociados(int id) {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE conductor_id = ? AND estado NOT IN ('Entregado', 'Cancelado')";
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
        String sql = "SELECT id_conductor, nombre_completo, licencia, telefono, email, dni, tipo_licencia, fecha_vencimiento_licencia FROM conductores ORDER BY nombre_completo ASC";

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
                conductor.setTelefono(rs.getString("telefono"));
                conductor.setEmail(rs.getString("email"));
                conductor.setDni(rs.getString("dni"));
                conductor.setTipoLicencia(rs.getString("tipo_licencia"));
                Date fechaVenc = rs.getDate("fecha_vencimiento_licencia");
                conductor.setFechaVencimientoLicencia(fechaVenc != null ? fechaVenc : null);
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

