package com.example.telito.administrador.daos;

import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.utils.AdminCache;
import com.example.telito.dao.BaseDao;

import java.sql.*;
import java.util.ArrayList;

/**
 * DAO para manejar operaciones relacionadas con roles de usuario.
 * Extiende de BaseDao para heredar la funcionalidad de conexión.
 */
public class RolDAO extends BaseDao {

    /**
     * Obtiene la lista completa de roles disponibles.
     * Utiliza cache para mejorar el rendimiento en consultas frecuentes.
     * Útil para llenar ComboBoxes en formularios.
     * 
     * @return ArrayList<Rol> lista de todos los roles
     */
    public ArrayList<Rol> listarRoles() {
        // Intentar obtener desde cache primero
        ArrayList<Rol> roles = AdminCache.get("roles_list", () -> {
            ArrayList<Rol> listaRoles = new ArrayList<>();
            String sql = "SELECT id_rol, nombre FROM roles ORDER BY nombre ASC";

            try (Connection conn = this.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {

                while (rs.next()) {
                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("id_rol"));
                    rol.setNombre(rs.getString("nombre"));
                    rol.setDescripcion(""); // Valor por defecto
                    rol.setActivo(true); // Valor por defecto
                    listaRoles.add(rol);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return listaRoles;
        });
        
        return roles != null ? roles : new ArrayList<>();
    }

    /**
     * Obtiene un rol específico por su ID.
     * 
     * @param idRol ID del rol a buscar
     * @return Rol objeto rol encontrado o null si no existe
     */
    public Rol obtenerRolPorId(int idRol) {
        Rol rol = null;
        String sql = "SELECT id_rol, nombre FROM roles WHERE id_rol = ?";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, idRol);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    rol = new Rol();
                    rol.setIdRol(rs.getInt("id_rol"));
                    rol.setNombre(rs.getString("nombre"));
                    rol.setDescripcion(""); // Valor por defecto
                    rol.setActivo(true); // Valor por defecto
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rol;
    }

    /**
     * Cuenta el total de roles activos.
     * Útil para estadísticas.
     * 
     * @return int número total de roles activos
     */
    public int contarRolesActivos() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM roles";
        
        try (Connection conn = this.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }
}
