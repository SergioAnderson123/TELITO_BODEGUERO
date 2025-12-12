package com.example.telito.administrador.daos;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.beans.Usuario;
import com.example.telito.util.DAOBase;

import java.sql.*;
import java.util.ArrayList;

public class UsuarioDAO extends DAOBase {

    // Este método es para la tabla principal de usuarios, con todos los filtros.
    public ArrayList<Usuario> listarUsuarios(String busqueda, String rolId, String estado, String sortBy, String sortOrder, int page, int size) {

        ArrayList<Usuario> listaUsuarios = new ArrayList<>();
        // La consulta base une usuarios con roles para mostrar el nombre del rol.
        String sql = "SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.codigo_productor, u.activo, u.rol_id, u.foto_perfil, r.nombre AS nombre_rol FROM usuarios u " +
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
        // Por defecto, ordenar por ID descendente para que los usuarios más recientes aparezcan primero
        String columnaOrden = "u.id_usuario";
        String direccionOrden = "DESC";

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

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

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
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNombres(rs.getString("nombres"));
                usuario.setApellidos(rs.getString("apellidos"));
                usuario.setEmail(rs.getString("email"));
                usuario.setActivo(rs.getBoolean("activo"));

                // Intentar obtener codigo_productor si existe la columna
                try {
                    usuario.setCodigoProductor(rs.getString("codigo_productor"));
                } catch (SQLException e) {
                    usuario.setCodigoProductor(null);
                }

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
        } catch (SQLException e) {
            logger.error("Error al listar usuarios", e);
            throw new RuntimeException("Error al listar usuarios", e);
        } finally {
            closeResources(conn, pstmt, rs);
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

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
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
            rs = pstmt.executeQuery();

            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Error al contar usuarios", e);
            throw new RuntimeException("Error al contar usuarios", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return total;
    }

    // Para el formulario de crear un usuario nuevo.
    // NOTA: La cuenta NO se activa automáticamente. Se debe enviar email de activación.
    public boolean crearUsuario(Usuario usuario) {
        // Encripto el password con SHA2 para no guardarlo en texto plano.
        // Si es productor y tiene código, incluirlo; si no, el trigger lo generará automáticamente
        // cuenta_activada se establece en FALSE por defecto (requiere activación por email)
        String sql;
        if (usuario.getRol().getIdRol() == 3 && usuario.getCodigoProductor() != null && !usuario.getCodigoProductor().trim().isEmpty()) {
            // Productor con código específico
            sql = "INSERT INTO usuarios (nombres, apellidos, email, codigo_productor, password, activo, rol_id, cuenta_activada) VALUES (?, ?, ?, ?, SHA2(?, 256), 1, ?, 0)";
            int filasAfectadas = executeUpdate(sql,
                usuario.getNombres(),
                usuario.getApellidos(),
                usuario.getEmail(),
                usuario.getCodigoProductor(),
                usuario.getPassword(),
                usuario.getRol().getIdRol());
            return filasAfectadas > 0;
        } else {
            // Usuario normal o productor sin código (el trigger generará el código)
            sql = "INSERT INTO usuarios (nombres, apellidos, email, password, activo, rol_id, cuenta_activada) VALUES (?, ?, ?, SHA2(?, 256), 1, ?, 0)";
            int filasAfectadas = executeUpdate(sql,
                usuario.getNombres(),
                usuario.getApellidos(),
                usuario.getEmail(),
                usuario.getPassword(),
                usuario.getRol().getIdRol());
            return filasAfectadas > 0;
        }
    }

    // Para cargar los datos de un usuario en el formulario de edición.
    public Usuario obtenerUsuarioPorId(int id) {
        Usuario usuario = null;
        String sql = "SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.codigo_productor, u.activo, u.rol_id, u.foto_perfil, r.nombre AS nombre_rol FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE u.id_usuario = ?";

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNombres(rs.getString("nombres"));
                usuario.setApellidos(rs.getString("apellidos"));
                usuario.setEmail(rs.getString("email"));
                usuario.setActivo(rs.getBoolean("activo"));
                
                // Intentar obtener codigo_productor si existe la columna
                try {
                    usuario.setCodigoProductor(rs.getString("codigo_productor"));
                } catch (SQLException e) {
                    usuario.setCodigoProductor(null);
                }
                
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
        } catch (SQLException e) {
            logger.error("Error al obtener usuario por ID: " + id, e);
            throw new RuntimeException("Error al obtener usuario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return usuario;
    }
    
    // Actualiza solo el perfil del usuario (nombres, apellidos, foto)
    public void actualizarPerfil(int idUsuario, String nombres, String apellidos, String fotoPerfil) {
        String sql = "UPDATE usuarios SET nombres = ?, apellidos = ?, foto_perfil = ? WHERE id_usuario = ?";
        executeUpdate(sql, nombres, apellidos, fotoPerfil, idUsuario);
    }
    
    // Actualiza solo la foto de perfil
    public void actualizarFotoPerfil(int idUsuario, String fotoPerfil) {
        String sql = "UPDATE usuarios SET foto_perfil = ? WHERE id_usuario = ?";
        executeUpdate(sql, fotoPerfil, idUsuario);
    }

    // Actualiza los datos del usuario desde el formulario de edición.
    public void actualizarUsuario(Usuario usuario) {
        // Si es productor, actualizar también el código de productor
        if (usuario.getRol().getIdRol() == 3 && usuario.getCodigoProductor() != null) {
            String sql = "UPDATE usuarios SET nombres = ?, apellidos = ?, email = ?, codigo_productor = ?, rol_id = ?, activo = ? WHERE id_usuario = ?";
            executeUpdate(sql,
                usuario.getNombres(),
                usuario.getApellidos(),
                usuario.getEmail(),
                usuario.getCodigoProductor(),
                usuario.getRol().getIdRol(),
                usuario.isActivo(),
                usuario.getIdUsuario());
        } else {
            // Si cambia de productor a otro rol, limpiar el código de productor
            String sql = "UPDATE usuarios SET nombres = ?, apellidos = ?, email = ?, codigo_productor = NULL, rol_id = ?, activo = ? WHERE id_usuario = ?";
            executeUpdate(sql,
                usuario.getNombres(),
                usuario.getApellidos(),
                usuario.getEmail(),
                usuario.getRol().getIdRol(),
                usuario.isActivo(),
                usuario.getIdUsuario());
        }
    }
    
    /**
     * Actualiza un usuario incluyendo la contraseña (útil para reactivar usuarios).
     */
    public boolean actualizarUsuarioConPassword(Usuario usuario) {
        String sql = "UPDATE usuarios SET nombres = ?, apellidos = ?, email = ?, password = SHA2(?, 256), rol_id = ?, activo = ? WHERE id_usuario = ?";
        int filasAfectadas = executeUpdate(sql,
            usuario.getNombres(),
            usuario.getApellidos(),
            usuario.getEmail(),
            usuario.getPassword(),
            usuario.getRol().getIdRol(),
            usuario.isActivo(),
            usuario.getIdUsuario());
        return filasAfectadas > 0;
    }

    // Borrado lógico, para 'banear' al usuario sin borrarlo de la BD.
    public void deshabilitarUsuario(int id) {
        String sql = "UPDATE usuarios SET activo = 0 WHERE id_usuario = ?";
        executeUpdate(sql, id);
    }
    
    /**
     * Obtiene el nombre del rol por su ID.
     * Útil para notificaciones por correo.
     * 
     * @param rolId ID del rol
     * @return Nombre del rol o null si no existe
     */
    public String obtenerNombreRolPorId(int rolId) {
        String sql = "SELECT nombre FROM roles WHERE id_rol = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, rolId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getString("nombre");
            }
        } catch (SQLException e) {
            logger.error("Error al obtener nombre del rol: " + rolId, e);
            throw new RuntimeException("Error al obtener nombre del rol", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }

    // Método para autenticar usuarios en el login (por email, nombre de usuario o código de productor)
    public Usuario autenticarUsuario(String emailOUsuario, String password) {
        Usuario usuario = null;
        // Autenticar por email, nombre de usuario (combinando nombres y apellidos), solo nombres, O código de productor
        String sql = """
            SELECT u.*, r.nombre AS nombre_rol 
            FROM usuarios u 
            INNER JOIN roles r ON u.rol_id = r.id_rol 
            WHERE (u.email = ? OR CONCAT(u.nombres, ' ', u.apellidos) = ? OR u.nombres = ? OR u.codigo_productor = ?)
            AND u.password = SHA2(?, 256) 
            AND u.activo = 1
            """;

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, emailOUsuario);  // Email
            pstmt.setString(2, emailOUsuario);  // Nombre completo (nombres + apellidos)
            pstmt.setString(3, emailOUsuario);  // Solo nombres
            pstmt.setString(4, emailOUsuario);  // Código de productor
            pstmt.setString(5, password);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNombres(rs.getString("nombres"));
                usuario.setApellidos(rs.getString("apellidos"));
                usuario.setEmail(rs.getString("email"));
                usuario.setActivo(rs.getBoolean("activo"));
                
                // Intentar obtener codigo_productor si existe la columna
                try {
                    usuario.setCodigoProductor(rs.getString("codigo_productor"));
                } catch (SQLException e) {
                    usuario.setCodigoProductor(null);
                }
                
                // Intentar obtener foto_perfil si existe la columna
                try {
                    usuario.setFotoPerfil(rs.getString("foto_perfil"));
                } catch (SQLException e) {
                    // Columna foto_perfil no existe, usar valor por defecto
                    usuario.setFotoPerfil(null);
                }
                
                // Intentar obtener cuenta_activada y fecha_activacion si existen las columnas
                try {
                    // Si el valor es NULL, considerarlo como activado (usuarios antiguos)
                    boolean cuentaActivada = rs.getBoolean("cuenta_activada");
                    boolean wasNull = rs.wasNull();
                    if (wasNull) {
                        // Si era NULL, activar la cuenta automáticamente (compatibilidad con usuarios antiguos)
                        cuentaActivada = true;
                    }
                    usuario.setCuentaActivada(cuentaActivada);
                    
                    // Obtener fecha_activacion
                    try {
                        usuario.setFechaActivacion(rs.getTimestamp("fecha_activacion"));
                    } catch (SQLException e) {
                        usuario.setFechaActivacion(null);
                    }
                } catch (SQLException e) {
                    // Columna cuenta_activada no existe, asumir que está activada (compatibilidad)
                    usuario.setCuentaActivada(true);
                    usuario.setFechaActivacion(null);
                }

                Rol rol = new Rol();
                rol.setIdRol(rs.getInt("rol_id"));
                rol.setNombre(rs.getString("nombre_rol"));
                usuario.setRol(rol);
            }
        } catch (SQLException e) {
            logger.error("Error al autenticar usuario", e);
            throw new RuntimeException("Error al autenticar usuario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return usuario;
    }
    
    /**
     * Obtiene un usuario por su email.
     * 
     * @param email Email del usuario
     * @return Usuario o null si no existe
     */
    public Usuario obtenerUsuarioPorEmail(String email) {
        Usuario usuario = null;
        String sql = "SELECT u.*, r.nombre AS nombre_rol FROM usuarios u " +
                    "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE u.email = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNombres(rs.getString("nombres"));
                usuario.setApellidos(rs.getString("apellidos"));
                usuario.setEmail(rs.getString("email"));
                usuario.setActivo(rs.getBoolean("activo"));
                
                try {
                    // Si el valor es NULL, considerarlo como activado (usuarios antiguos)
                    boolean cuentaActivada = rs.getBoolean("cuenta_activada");
                    if (rs.wasNull()) {
                        // Si era NULL, activar la cuenta automáticamente (compatibilidad con usuarios antiguos)
                        cuentaActivada = true;
                    }
                    usuario.setCuentaActivada(cuentaActivada);
                } catch (SQLException e) {
                    // Columna cuenta_activada no existe, asumir que está activada (compatibilidad)
                    usuario.setCuentaActivada(true);
                }
                
                try {
                    usuario.setFechaActivacion(rs.getTimestamp("fecha_activacion"));
                } catch (SQLException e) {
                    // Columna fecha_activacion no existe o es NULL
                    usuario.setFechaActivacion(null);
                }
                
                try {
                    usuario.setCodigoProductor(rs.getString("codigo_productor"));
                } catch (SQLException e) {
                    usuario.setCodigoProductor(null);
                }
                
                try {
                    usuario.setFotoPerfil(rs.getString("foto_perfil"));
                } catch (SQLException e) {
                    usuario.setFotoPerfil(null);
                }
                
                Rol rol = new Rol();
                rol.setIdRol(rs.getInt("rol_id"));
                rol.setNombre(rs.getString("nombre_rol"));
                usuario.setRol(rol);
            }
        } catch (SQLException e) {
            logger.error("Error al obtener usuario por email: " + email, e);
            throw new RuntimeException("Error al obtener usuario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return usuario;
    }
    
    /**
     * Actualiza la contraseña de un usuario.
     * 
     * @param usuarioId ID del usuario
     * @param contrasenaHash Contraseña hasheada (SHA-256)
     * @return true si se actualizó correctamente
     */
    public boolean actualizarContrasena(int usuarioId, String contrasenaHash) {
        String sql = "UPDATE usuarios SET password = ? WHERE id_usuario = ?";
        int filasAfectadas = executeUpdate(sql, contrasenaHash, usuarioId);
        return filasAfectadas > 0;
    }
    
    /**
     * Actualiza el estado de activación de una cuenta.
     * 
     * @param usuarioId ID del usuario
     * @param activado true para activar, false para desactivar
     * @return true si se actualizó correctamente
     */
    public boolean actualizarEstadoActivacion(int usuarioId, boolean activado) {
        String sql = "UPDATE usuarios SET cuenta_activada = ?, fecha_activacion = NOW() WHERE id_usuario = ?";
        int filasAfectadas = executeUpdate(sql, activado ? 1 : 0, usuarioId);
        return filasAfectadas > 0;
    }
    
    /**
     * Incrementa el contador de intentos de activación fallidos.
     * 
     * @param usuarioId ID del usuario
     */
    public void incrementarIntentosActivacion(int usuarioId) {
        String sql = "UPDATE usuarios SET intentos_activacion = intentos_activacion + 1, ultimo_intento_activacion = NOW() WHERE id_usuario = ?";
        executeUpdate(sql, usuarioId);
    }
    
    /**
     * Resetea el contador de intentos de activación.
     * 
     * @param usuarioId ID del usuario
     */
    public void resetearIntentosActivacion(int usuarioId) {
        String sql = "UPDATE usuarios SET intentos_activacion = 0, ultimo_intento_activacion = NULL WHERE id_usuario = ?";
        executeUpdate(sql, usuarioId);
    }

    // Para la tarjeta de estadísticas del menú principal.
    public int contarTotalUsuarios() {
        String sql = "SELECT COUNT(*) FROM usuarios";
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
            logger.debug("contarTotalUsuarios() retornó: {}", count);
        } catch (SQLException e) {
            logger.error("Error al contar total usuarios", e);
            throw new RuntimeException("Error al contar total usuarios", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }

    // También para las estadísticas del menú.
    public int contarUsuariosBaneados() {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE activo = 0";
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
            logger.debug("contarUsuariosBaneados() retornó: {}", count);
        } catch (SQLException e) {
            logger.error("Error al contar usuarios baneados", e);
            throw new RuntimeException("Error al contar usuarios baneados", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }

    /**
     * Cuenta los usuarios activos
     */
    public int contarUsuariosActivos() {
        // Usar la misma lógica que contarUsuariosBaneados pero con activo = 1
        String sql = "SELECT COUNT(*) FROM usuarios WHERE activo = 1";
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
            logger.debug("contarUsuariosActivos() retornó: {}", count);
        } catch (SQLException e) {
            logger.error("Error al contar usuarios activos", e);
            throw new RuntimeException("Error al contar usuarios activos", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        
        return count;
    }
    
    // ========== MÉTODOS DE VALIDACIÓN ==========
    
    /**
     * Verifica si ya existe un usuario ACTIVO registrado con el email especificado.
     * Solo considera usuarios activos, permitiendo reutilizar emails de usuarios inactivos.
     */
    public boolean existeEmail(String email) {
        String sql = "SELECT COUNT(*) as total FROM usuarios WHERE email = ? AND activo = 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
        } catch (SQLException e) {
            logger.error("Error al verificar existencia de email: " + email, e);
            throw new RuntimeException("Error al verificar existencia de email", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return false;
    }
    
    /**
     * Verifica si existe un usuario (activo o inactivo) con el email especificado.
     * Útil para detectar si un usuario fue eliminado con borrado lógico.
     * 
     * @param email Email a verificar
     * @return ID del usuario si existe, 0 si no existe
     */
    public int obtenerIdUsuarioPorEmail(String email) {
        String sql = "SELECT id_usuario FROM usuarios WHERE email = ?";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("id_usuario");
            }
        } catch (SQLException e) {
            logger.error("Error al obtener ID de usuario por email: " + email, e);
            throw new RuntimeException("Error al obtener ID de usuario por email", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return 0;
    }
    
    /**
     * Obtiene todos los usuarios que coinciden con los filtros especificados.
     * Sin paginación, útil para exportar a Excel.
     * 
     * @param busqueda Búsqueda por nombre, apellido o email
     * @param rolId Filtro por rol
     * @param estado Filtro por estado (1=activo, 0=inactivo, null=todos)
     * @param sortBy Columna por la cual ordenar
     * @param sortOrder Dirección del ordenamiento (ASC/DESC)
     * @return Lista de usuarios que coinciden con los filtros
     */
    public ArrayList<Usuario> listarTodosUsuarios(String busqueda, String rolId, String estado, String sortBy, String sortOrder) {
        ArrayList<Usuario> listaUsuarios = new ArrayList<>();
        String sql = "SELECT u.id_usuario, u.nombres, u.apellidos, u.email, u.codigo_productor, u.activo, u.rol_id, u.foto_perfil, r.nombre AS nombre_rol FROM usuarios u " +
                "INNER JOIN roles r ON u.rol_id = r.id_rol WHERE 1=1";

        // Aplicar filtros
        if (busqueda != null && !busqueda.trim().isEmpty()) {
            sql += " AND (u.nombres LIKE ? OR u.apellidos LIKE ? OR u.email LIKE ?)";
        }
        if (rolId != null && !rolId.trim().isEmpty()) {
            sql += " AND u.rol_id = ?";
        }
        if (estado != null && !estado.trim().isEmpty()) {
            sql += " AND u.activo = ?";
        } else if (estado == null) {
            sql += " AND u.activo = 1"; // Por defecto, solo activos
        }

        // Ordenamiento - por defecto DESC para que los más recientes aparezcan primero
        String columnaOrden = "u.id_usuario";
        String direccionOrden = "DESC";

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

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);

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
            rs = pstmt.executeQuery();

            while (rs.next()) {
                Usuario usuario = new Usuario();
                usuario.setIdUsuario(rs.getInt("id_usuario"));
                usuario.setNombres(rs.getString("nombres"));
                usuario.setApellidos(rs.getString("apellidos"));
                usuario.setEmail(rs.getString("email"));
                usuario.setActivo(rs.getBoolean("activo"));

                try {
                    usuario.setCodigoProductor(rs.getString("codigo_productor"));
                } catch (SQLException e) {
                    usuario.setCodigoProductor(null);
                }

                try {
                    usuario.setFotoPerfil(rs.getString("foto_perfil"));
                } catch (SQLException e) {
                    usuario.setFotoPerfil(null);
                }

                Rol rol = new Rol();
                rol.setIdRol(rs.getInt("rol_id"));
                rol.setNombre(rs.getString("nombre_rol"));
                usuario.setRol(rol);

                listaUsuarios.add(usuario);
            }
        } catch (SQLException e) {
            logger.error("Error al listar todos los usuarios", e);
            throw new RuntimeException("Error al listar todos los usuarios", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return listaUsuarios;
    }

    // ========== MÉTODOS AUXILIARES PARA CORREOS ==========
    
    /**
     * Obtiene el email de un usuario por su ID.
     * Útil para enviar notificaciones por correo.
     * 
     * @param usuarioId ID del usuario
     * @return Email del usuario, o null si no existe o no tiene email
     */
    public String obtenerEmailPorId(int usuarioId) {
        String sql = "SELECT email FROM usuarios WHERE id_usuario = ? AND activo = 1";
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, usuarioId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String email = rs.getString("email");
                return (email != null && !email.trim().isEmpty()) ? email : null;
            }
        } catch (SQLException e) {
            logger.error("Error al obtener email del usuario: " + usuarioId, e);
            throw new RuntimeException("Error al obtener email del usuario", e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return null;
    }
}