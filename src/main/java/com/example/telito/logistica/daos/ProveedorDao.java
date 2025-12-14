package com.example.telito.logistica.daos;

import com.example.telito.logistica.beans.ProveedorBean;
import com.example.telito.util.DAOBase;
import java.sql.*;
import java.util.ArrayList;

public class ProveedorDao extends DAOBase {

    public ArrayList<ProveedorBean> listarProveedores() {
        ArrayList<ProveedorBean> listaProveedores = new ArrayList<>();
        String sql = "SELECT id_proveedor, nombre FROM proveedores ORDER BY nombre ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProveedorBean proveedor = new ProveedorBean();
                proveedor.setId(rs.getInt("id_proveedor"));
                proveedor.setNombre(rs.getString("nombre"));
                listaProveedores.add(proveedor);
            }
        } catch (SQLException e) {
            logger.error("Error al listar proveedores", e);
            throw new RuntimeException("Error al listar proveedores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaProveedores;
    }
    
    // Listar solo productores (usuarios con rol_id = 3) como proveedores
    public ArrayList<ProveedorBean> listarProductores() {
        ArrayList<ProveedorBean> listaProductores = new ArrayList<>();
        String sql = "SELECT u.id_usuario, CONCAT(u.nombres, ' ', u.apellidos) as nombre_completo " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "ORDER BY u.nombres ASC";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProveedorBean productor = new ProveedorBean();
                productor.setId(rs.getInt("id_usuario"));
                productor.setNombre(rs.getString("nombre_completo"));
                listaProductores.add(productor);
                logger.debug("Productor encontrado: ID={}, Nombre={}", productor.getId(), productor.getNombre());
            }
            logger.info("Total de productores encontrados: {}", listaProductores.size());
        } catch (SQLException e) {
            logger.error("Error al listar productores", e);
            throw new RuntimeException("Error al listar productores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaProductores;
    }
    
    /**
     * Busca productores por texto (para autocompletado)
     * @param busqueda Texto de búsqueda (nombre o apellido)
     * @param limit Límite de resultados (máximo 20)
     * @return Lista de productores que coinciden con la búsqueda
     */
    public ArrayList<ProveedorBean> buscarProductores(String busqueda, int limit) {
        ArrayList<ProveedorBean> listaProductores = new ArrayList<>();
        String sql = "SELECT u.id_usuario, CONCAT(u.nombres, ' ', u.apellidos) as nombre_completo " +
                     "FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "WHERE r.nombre = 'Productor' AND u.activo = 1 " +
                     "AND (u.nombres LIKE ? OR u.apellidos LIKE ? OR CONCAT(u.nombres, ' ', u.apellidos) LIKE ?) " +
                     "ORDER BY u.nombres ASC " +
                     "LIMIT ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            String searchPattern = "%" + (busqueda != null ? busqueda.trim() : "") + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            pstmt.setString(3, searchPattern);
            pstmt.setInt(4, limit > 0 && limit <= 20 ? limit : 20);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProveedorBean productor = new ProveedorBean();
                productor.setId(rs.getInt("id_usuario"));
                productor.setNombre(rs.getString("nombre_completo"));
                listaProductores.add(productor);
            }
        } catch (SQLException e) {
            logger.error("Error al buscar productores: " + busqueda, e);
            throw new RuntimeException("Error al buscar productores", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaProductores;
    }
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si existe un productor (usuario con rol Productor) con el ID especificado
     */
    public boolean existeProductor(int productorId) {
        String sql = "SELECT COUNT(*) as total FROM usuarios u " +
                     "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                     "WHERE u.id_usuario = ? AND r.nombre = 'Productor' AND u.activo = 1";
        
        return count(sql, productorId) > 0;
    }
}