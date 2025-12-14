package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Vehiculo;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

// DAO para gestión de vehículos
public class VehiculoDAO extends DAOBase {

    // Listar todos (compatibilidad - página 1, tamaño 10)
    public ArrayList<Vehiculo> listarVehiculos() {
        return listarVehiculos(1, 10);
    }

    // Listar con paginación
    public ArrayList<Vehiculo> listarVehiculos(int page, int size) {
        return listarVehiculos(null, page, size);
    }
    
    // Listar con filtros y paginación
    public ArrayList<Vehiculo> listarVehiculos(String busqueda, int page, int size) {
        ArrayList<Vehiculo> lista = new ArrayList<>();
        String sql = "SELECT id_vehiculo, placa, marca, modelo, capacidad_kg FROM vehiculos WHERE 1=1";
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (placa LIKE ? OR marca LIKE ? OR modelo LIKE ?)";
        }
        
        sql += " ORDER BY placa ASC LIMIT ? OFFSET ?";

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
            }

            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(paramIndex++, limit);
            pstmt.setInt(paramIndex, offset);
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

    // Contar total (sin filtros)
    public int contarVehiculos() {
        return contarVehiculos(null);
    }
    
    // Contar con filtros
    public int contarVehiculos(String busqueda) {
        String sql = "SELECT COUNT(*) FROM vehiculos WHERE 1=1";
        
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (placa LIKE ? OR marca LIKE ? OR modelo LIKE ?)";
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
                pstmt.setString(3, busquedaConWildcards);
            }
            
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar vehículos", e);
            throw new RuntimeException("Error al contar vehículos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
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

    // Verificar si el vehículo tiene planes de transporte asociados
    public boolean tienePlanesTransporteAsociados(int id) {
        String sql = "SELECT COUNT(*) FROM planes_transporte WHERE vehiculo_id = ?";
        int count = count(sql, id);
        return count > 0;
    }
    
    // Eliminar vehículo (verifica si tiene planes asociados primero)
    public boolean eliminarVehiculo(int id) throws RuntimeException {
        // Verificar si tiene planes de transporte asociados
        if (tienePlanesTransporteAsociados(id)) {
            throw new RuntimeException("No se puede eliminar el vehículo porque tiene planes de transporte asociados. " +
                                     "Por favor, elimine o reasigne los planes de transporte primero.");
        }
        
        String sql = "DELETE FROM vehiculos WHERE id_vehiculo = ?";
        
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
            logger.error("Error de integridad referencial al eliminar vehículo: " + id, e);
            throw new RuntimeException("No se puede eliminar el vehículo porque está siendo utilizado en planes de transporte. " +
                                     "Por favor, elimine o reasigne los planes de transporte primero.", e);
        } catch (SQLException e) {
            logger.error("Error al eliminar vehículo: " + id, e);
            throw new RuntimeException("Error al eliminar el vehículo", e);
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // Verificar si la placa ya existe (para validaciones)
    public boolean existePlaca(String placa, int idExcluir) {
        String sql = "SELECT COUNT(*) FROM vehiculos WHERE placa = ? AND id_vehiculo != ?";
        return count(sql, placa, idExcluir) > 0;
    }

    /**
     * Cuenta el total de vehículos
     */
    public int contarTotalVehiculos() {
        String sql = "SELECT COUNT(*) FROM vehiculos";
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
            logger.error("Error al contar total vehículos", e);
            throw new RuntimeException("Error al contar total vehículos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }

    /**
     * Cuenta vehículos con planes de transporte asignados
     */
    public int contarVehiculosConPlanes() {
        String sql = "SELECT COUNT(DISTINCT v.id_vehiculo) FROM vehiculos v " +
                     "INNER JOIN planes_transporte pt ON v.id_vehiculo = pt.vehiculo_id";
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
            logger.error("Error al contar vehículos con planes", e);
            throw new RuntimeException("Error al contar vehículos con planes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }

    /**
     * Cuenta vehículos sin planes de transporte asignados
     */
    public int contarVehiculosSinPlanes() {
        String sql = "SELECT COUNT(*) FROM vehiculos v " +
                     "LEFT JOIN planes_transporte pt ON v.id_vehiculo = pt.vehiculo_id " +
                     "WHERE pt.vehiculo_id IS NULL";
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
            logger.error("Error al contar vehículos sin planes", e);
            throw new RuntimeException("Error al contar vehículos sin planes", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }
}

