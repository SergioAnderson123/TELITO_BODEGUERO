package com.example.telito.administrador.daos;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.beans.Usuario;
import com.example.telito.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;

public class UsuarioDAO {
    // Las credenciales ahora están centralizadas en DatabaseConnection

    // Este método es para la tabla principal de usuarios, con todos los filtros.
    public ArrayList<Usuario> listarUsuarios(String busqueda, String rolId, String estado, String sortBy, String sortOrder, int page, int size) {

        ArrayList<Usuario> listaUsuarios = new ArrayList<>();
        // La consulta base une usuarios con roles para mostrar el nombre del rol.
        String sql = "SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.activo, u.rol_id, u.foto_perfil, r.nombre AS nombre_rol FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE 1=1";

        // Voy añadiendo a la consulta los filtros que el usuario haya usado.
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (u.nombres LIKE ? OR u.apellidos LIKE ? OR u.email LIKE ?)";
        }
        if (rolId != null && !rolId.trim().isEmpty()) {
            sql += " AND u.rol_id = ?";
        }
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND u.activo = ?";
        } else if (estado == null) {
            sql += " AND u.activo = 1"; // Por defecto, solo muestro los activos.
        }

        // Lógica para ordenar la tabla según la columna que se elija.
        String columnaOrden = "u.id_usuario";
        String direccionOrden = "ASC";

        if (sortBy != null && !sortBy.trim().isEmpty()) {
            switch (sortBy) {
                case "usuario": columnaOrden = "u.nombres"; break;
                case "correo": columnaOrden = "u.email"; break;
                case "rol": columnaOrden = "r.nombre"; break;
                case "estado": columnaOrden = "u.activo"; break;
            }
        }
        if (sortOrder != null && (sortOrder.equalsIgnoreCase("asc") || sortOrder.equalsIgnoreCase("desc"))) {
            direccionOrden = sortOrder.toUpperCase();
        }
        sql += " ORDER BY " + columnaOrden + " " + direccionOrden + " LIMIT ? OFFSET ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int parameterIndex = 1;
            // Asigno los valores a los '?' de la consulta que armé arriba.
            if (busqueda != null && !busqueda.trim().isEmpty()) {
                String busquedaConWildcards = "%" + busqueda + "%";
                pstmt.setString(parameterIndex++, busquedaConWildcards);
                pstmt.setString(parameterIndex++, busquedaConWildcards);
                pstmt.setString(parameterIndex++, busquedaConWildcards);
            }
            if (rolId != null && !rolId.trim().isEmpty()) {
                pstmt.setInt(parameterIndex++, Integer.parseInt(rolId));
            }
            if (estado != null && !estado.trim().isEmpty()) {
                pstmt.setInt(parameterIndex++, Integer.parseInt(estado));
            }

            // Pagination parameters
            int limit = Math.max(1, size);
            int offset = Math.max(0, (Math.max(1, page) - 1) * size);
            pstmt.setInt(parameterIndex++, limit);
            pstmt.setInt(parameterIndex, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("id_usuario"));
                    usuario.setNombres(rs.getString("nombres"));
                    usuario.setApellidos(rs.getString("apellidos"));
                    usuario.setEmail(rs.getString("email"));
                    usuario.setActivo(rs.getBoolean("activo"));

                    // Intentar obtener foto_perfil si existe la columna
                    try {
                        usuario.setFotoPerfil(rs.getString("foto_perfil"));
                    } catch (SQLException e) {
                        // Columna foto_perfil no existe, usar valor por defecto
                        usuario.setFotoPerfil(null);
                    }

                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("rol_id"));
                    rol.setNombre(rs.getString("nombre_rol"));
                    usuario.setRol(rol);

                    listaUsuarios.add(usuario);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return listaUsuarios;
    }

    // Count total users matching filters for pagination
    public int contarUsuarios(String busqueda, String rolId, String estado) {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM usuarios u WHERE 1=1";
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (u.nombres LIKE ? OR u.apellidos LIKE ? OR u.email LIKE ?)";
        }
        if (rolId != null && !rolId.trim().isEmpty()) {
            sql += " AND u.rol_id = ?";
        }
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND u.activo = ?";
        } else if (estado == null) {
            sql += " AND u.activo = 1";
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            int parameterIndex = 1;
            if (busqueda != null && !busqueda.trim().isEmpty()) {
                String busquedaConWildcards = "%" + busqueda + "%";
                pstmt.setString(parameterIndex++, busquedaConWildcards);
                pstmt.setString(parameterIndex++, busquedaConWildcards);
                pstmt.setString(parameterIndex++, busquedaConWildcards);
            }
            if (rolId != null && !rolId.trim().isEmpty()) {
                pstmt.setInt(parameterIndex++, Integer.parseInt(rolId));
            }
            if (estado != null && !estado.trim().isEmpty()) {
                pstmt.setInt(parameterIndex++, Integer.parseInt(estado));
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return total;
    }

    // Para el formulario de crear un usuario nuevo.
    public boolean crearUsuario(Usuario usuario) {
        // Encripto el password con SHA2 para no guardarlo en texto plano.
        String sql = "INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES (?, ?, ?, SHA2(?, 256), 1, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, usuario.getNombres());
            pstmt.setString(2, usuario.getApellidos());
            pstmt.setString(3, usuario.getEmail());
            pstmt.setString(4, usuario.getPassword());
            pstmt.setInt(5, usuario.getRol().getIdRol());
            int rows = pstmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Para cargar los datos de un usuario en el formulario de edición.
    public Usuario obtenerUsuarioPorId(int id) {
        Usuario usuario = null;
        String sql = "SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.activo, u.rol_id, r.nombre AS nombre_rol FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE u.id_usuario = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("id_usuario"));
                    usuario.setNombres(rs.getString("nombres"));
                    usuario.setApellidos(rs.getString("apellidos"));
                    usuario.setEmail(rs.getString("email"));
                    usuario.setActivo(rs.getBoolean("activo"));
                    
                    // Intentar obtener foto_perfil si existe la columna
                    try {
                        usuario.setFotoPerfil(rs.getString("foto_perfil"));
                    } catch (SQLException e) {
                        // Columna foto_perfil no existe, usar valor por defecto
                        usuario.setFotoPerfil(null);
                    }

                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("rol_id"));
                    rol.setNombre(rs.getString("nombre_rol"));
                    usuario.setRol(rol);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener usuario por ID: " + e.getMessage());
            e.printStackTrace();
        }
        return usuario;
    }
    
    // Actualiza solo el perfil del usuario (nombres, apellidos, foto)
    public void actualizarPerfil(int idUsuario, String nombres, String apellidos, String fotoPerfil) {
        String sql = "UPDATE usuarios SET nombres = ?, apellidos = ?, foto_perfil = ? WHERE id_usuario = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, nombres);
            pstmt.setString(2, apellidos);
            pstmt.setString(3, fotoPerfil);
            pstmt.setInt(4, idUsuario);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    // Actualiza solo la foto de perfil
    public void actualizarFotoPerfil(int idUsuario, String fotoPerfil) {
        String sql = "UPDATE usuarios SET foto_perfil = ? WHERE id_usuario = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, fotoPerfil);
            pstmt.setInt(2, idUsuario);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Actualiza los datos del usuario desde el formulario de edición.
    public void actualizarUsuario(Usuario usuario) {
        String sql = "UPDATE usuarios SET nombres = ?, apellidos = ?, email = ?, rol_id = ?, activo = ? WHERE id_usuario = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, usuario.getNombres());
            pstmt.setString(2, usuario.getApellidos());
            pstmt.setString(3, usuario.getEmail());
            pstmt.setInt(4, usuario.getRol().getIdRol());
            pstmt.setBoolean(5, usuario.isActivo());
            pstmt.setInt(6, usuario.getIdUsuario());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Borrado lógico, para 'banear' al usuario sin borrarlo de la BD.
    public void deshabilitarUsuario(int id) {
        String sql = "UPDATE usuarios SET activo = 0 WHERE id_usuario = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Método para autenticar usuarios en el login
    public Usuario autenticarUsuario(String email, String password) {
        Usuario usuario = null;
        String sql = "SELECT u.*, r.nombre AS nombre_rol FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                "WHERE u.email = ? AND u.password = SHA2(?, 256) AND u.activo = 1";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            pstmt.setString(2, password);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("id_usuario"));
                    usuario.setNombres(rs.getString("nombres"));
                    usuario.setApellidos(rs.getString("apellidos"));
                    usuario.setEmail(rs.getString("email"));
                    usuario.setActivo(rs.getBoolean("activo"));
                    
                    // Intentar obtener foto_perfil si existe la columna
                    try {
                        usuario.setFotoPerfil(rs.getString("foto_perfil"));
                    } catch (SQLException e) {
                        // Columna foto_perfil no existe, usar valor por defecto
                        usuario.setFotoPerfil(null);
                    }

                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("rol_id"));
                    rol.setNombre(rs.getString("nombre_rol"));
                    usuario.setRol(rol);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al autenticar usuario: " + e.getMessage());
            e.printStackTrace();
        }
        return usuario;
    }

    // Para la tarjeta de estadísticas del menú principal.
    public int contarTotalUsuarios() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM usuarios";
        try (Connection conn = DatabaseConnection.getConnection();
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

    // También para las estadísticas del menú.
    public int contarUsuariosBaneados() {
        int totalBaneados = 0;
        String sql = "SELECT COUNT(*) FROM usuarios WHERE activo = 0";
        try (Connection conn = DatabaseConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                totalBaneados = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return totalBaneados;
    }
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si ya existe un usuario registrado con el email especificado
     */
    public boolean existeEmail(String email) {
        String sql = "SELECT COUNT(*) as total FROM usuarios WHERE email = ?";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al verificar existencia de email: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}