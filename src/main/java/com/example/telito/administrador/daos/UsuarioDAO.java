package com.example.telito.administrador.daos;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.beans.Usuario;
import com.example.telito.dao.BaseDao;

import java.sql.*;
import java.util.ArrayList;

public class UsuarioDAO extends BaseDao {

    /**
     * Lista usuarios con todos los filtros (método original mantenido para compatibilidad).
     * Para mejor rendimiento con grandes volúmenes, usar listarUsuariosPaginado().
     * 
     * @param busqueda término de búsqueda
     * @param rolId ID del rol para filtrar
     * @param estado estado del usuario (activo/inactivo)
     * @param sortBy columna para ordenar
     * @param sortOrder dirección del ordenamiento (ASC/DESC)
     * @return ArrayList<Usuario> lista completa de usuarios
     */
    public ArrayList<Usuario> listarUsuarios(String busqueda, String rolId, String estado, String sortBy, String sortOrder) {

        ArrayList<Usuario> listaUsuarios = new ArrayList<>();
        // La consulta base une usuarios con roles para mostrar el nombre del rol.
        String sql = "SELECT u.*, r.nombre AS nombre_rol FROM usuarios u " +
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
        sql += " ORDER BY " + columnaOrden + " " + direccionOrden;

        try (Connection conn = this.getConnection();
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

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("id_usuario"));
                    usuario.setNombres(rs.getString("nombres"));
                    usuario.setApellidos(rs.getString("apellidos"));
                    usuario.setEmail(rs.getString("email"));
                    usuario.setActivo(rs.getBoolean("activo"));

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

    /**
     * Lista usuarios con paginación para mejor rendimiento con grandes volúmenes de datos.
     * 
     * @param busqueda término de búsqueda
     * @param rolId ID del rol para filtrar
     * @param estado estado del usuario (activo/inactivo)
     * @param sortBy columna para ordenar
     * @param sortOrder dirección del ordenamiento (ASC/DESC)
     * @param pagina número de página (empezando en 1)
     * @param tamañoPagina cantidad de registros por página
     * @return ArrayList<Usuario> lista paginada de usuarios
     */
    public ArrayList<Usuario> listarUsuariosPaginado(String busqueda, String rolId, String estado, 
                                                   String sortBy, String sortOrder, int pagina, int tamañoPagina) {
        
        ArrayList<Usuario> listaUsuarios = new ArrayList<>();
        
        // Construir la consulta base (igual que el método original)
        String sql = "SELECT u.*, r.nombre AS nombre_rol FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE 1=1";

        // Agregar filtros
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

        // Agregar ordenamiento
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
        sql += " ORDER BY " + columnaOrden + " " + direccionOrden;
        
        // Agregar paginación
        sql += " LIMIT ? OFFSET ?";

        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            int parameterIndex = 1;
            
            // Asignar valores de filtros
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
            
            // Calcular offset para paginación
            int offset = (pagina - 1) * tamañoPagina;
            pstmt.setInt(parameterIndex++, tamañoPagina);
            pstmt.setInt(parameterIndex++, offset);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Usuario usuario = new Usuario();
                    usuario.setIdUsuario(rs.getInt("id_usuario"));
                    usuario.setNombres(rs.getString("nombres"));
                    usuario.setApellidos(rs.getString("apellidos"));
                    usuario.setEmail(rs.getString("email"));
                    usuario.setActivo(rs.getBoolean("activo"));

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

    /**
     * Cuenta el total de usuarios que coinciden con los filtros dados.
     * Útil para calcular el total de páginas en la paginación.
     * 
     * @param busqueda término de búsqueda
     * @param rolId ID del rol para filtrar
     * @param estado estado del usuario (activo/inactivo)
     * @return int total de usuarios que coinciden con los filtros
     */
    public int contarUsuariosConFiltros(String busqueda, String rolId, String estado) {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE 1=1";

        // Agregar los mismos filtros que en listarUsuarios
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

        try (Connection conn = this.getConnection();
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
    public void crearUsuario(Usuario usuario) {
        // Encripto el password con SHA2 para no guardarlo en texto plano.
        String sql = "INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id) VALUES (?, ?, ?, SHA2(?, 256), 1, ?)";
        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, usuario.getNombres());
            pstmt.setString(2, usuario.getApellidos());
            pstmt.setString(3, usuario.getEmail());
            pstmt.setString(4, usuario.getPassword());
            pstmt.setInt(5, usuario.getRol().getIdRol());
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Para cargar los datos de un usuario en el formulario de edición.
    public Usuario obtenerUsuarioPorId(int id) {
        Usuario usuario = null;
        String sql = "SELECT u.*, r.nombre AS nombre_rol FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE u.id_usuario = ?";

        try (Connection conn = this.getConnection();
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

                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("rol_id"));
                    rol.setNombre(rs.getString("nombre_rol"));
                    usuario.setRol(rol);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

    // Actualiza los datos del usuario desde el formulario de edición.
    public void actualizarUsuario(Usuario usuario) {
        String sql = "UPDATE usuarios SET nombres = ?, apellidos = ?, email = ?, rol_id = ?, activo = ? WHERE id_usuario = ?";
        try (Connection conn = this.getConnection();
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
        try (Connection conn = this.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Para la tarjeta de estadísticas del menú principal.
    public int contarTotalUsuarios() {
        int total = 0;
        String sql = "SELECT COUNT(*) FROM usuarios";
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

    // Método para validar credenciales de login usando hash SHA-256
    public Usuario validarCredenciales(String email, String password) {
        Usuario usuario = null;
        String sql = "SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.activo, " +
                    "r.id_rol, r.nombre AS nombre_rol " +
                    "FROM usuarios u " +
                    "INNER JOIN roles r ON u.rol_id = r.id_rol " +
                    "WHERE u.email = ? AND u.password = SHA2(?, 256) AND u.activo = 1";

        try (Connection conn = this.getConnection();
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
                    
                    Rol rol = new Rol();
                    rol.setIdRol(rs.getInt("id_rol"));
                    rol.setNombre(rs.getString("nombre_rol"));
                    usuario.setRol(rol);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return usuario;
    }

    // También para las estadísticas del menú.
    public int contarUsuariosBaneados() {
        int totalBaneados = 0;
        String sql = "SELECT COUNT(*) FROM usuarios WHERE activo = 0";
        try (Connection conn = this.getConnection();
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
}