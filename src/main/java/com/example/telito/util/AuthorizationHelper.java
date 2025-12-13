package com.example.telito.util;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.beans.Rol;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Helper para verificar permisos y autorización de usuarios.
 * Centraliza la lógica de autorización del sistema.
 */
public class AuthorizationHelper {

    private static final Logger logger = LoggerFactory.getLogger(AuthorizationHelper.class);

    // IDs de roles según la base de datos
    public static final int ROL_ADMINISTRADOR = 1;
    public static final int ROL_LOGISTICA = 2;
    public static final int ROL_PRODUCTOR = 3;
    public static final int ROL_ALMACEN = 4;
    public static final int ROL_GERENTE_TIENDA = 7;

    /**
     * Obtiene el usuario actual de la sesión.
     * 
     * @param session Sesión HTTP
     * @return Usuario de la sesión o null si no existe
     */
    public static Usuario obtenerUsuarioActual(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (Usuario) session.getAttribute("usuario");
    }

    /**
     * Verifica si el usuario actual tiene permisos de administrador.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario es administrador, false en caso contrario
     */
    public static boolean esAdministrador(HttpSession session) {
        Usuario usuario = obtenerUsuarioActual(session);
        if (usuario == null || usuario.getRol() == null) {
            return false;
        }
        return usuario.getRol().getIdRol() == ROL_ADMINISTRADOR;
    }

    /**
     * Verifica si el usuario actual puede gestionar usuarios.
     * Solo los administradores pueden gestionar usuarios.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario puede gestionar usuarios, false en caso contrario
     */
    public static boolean puedeGestionarUsuarios(HttpSession session) {
        return esAdministrador(session);
    }

    /**
     * Verifica si el usuario puede editar un usuario específico.
     * Un administrador puede editar cualquier usuario.
     * Un usuario normal solo puede editar su propio perfil.
     * 
     * @param session Sesión HTTP
     * @param idUsuarioAEditar ID del usuario que se desea editar
     * @return true si el usuario puede editar, false en caso contrario
     */
    public static boolean puedeEditarUsuario(HttpSession session, int idUsuarioAEditar) {
        Usuario usuarioActual = obtenerUsuarioActual(session);
        
        if (usuarioActual == null) {
            logger.warn("Intento de editar usuario sin sesión activa. ID a editar: {}", idUsuarioAEditar);
            return false;
        }

        // Si es administrador, puede editar cualquier usuario
        if (esAdministrador(session)) {
            return true;
        }

        // Si no es administrador, solo puede editar su propio perfil
        boolean puedeEditar = usuarioActual.getIdUsuario() == idUsuarioAEditar;
        
        if (!puedeEditar) {
            logger.warn("Usuario ID {} intentó editar usuario ID {} sin permisos", 
                       usuarioActual.getIdUsuario(), idUsuarioAEditar);
        }
        
        return puedeEditar;
    }

    /**
     * Verifica si el usuario puede eliminar/deshabilitar un usuario.
     * Solo los administradores pueden deshabilitar usuarios.
     * Un usuario no puede deshabilitarse a sí mismo.
     * 
     * @param session Sesión HTTP
     * @param idUsuarioAEliminar ID del usuario que se desea eliminar
     * @return true si el usuario puede eliminar, false en caso contrario
     */
    public static boolean puedeEliminarUsuario(HttpSession session, int idUsuarioAEliminar) {
        Usuario usuarioActual = obtenerUsuarioActual(session);
        
        if (usuarioActual == null) {
            logger.warn("Intento de eliminar usuario sin sesión activa. ID a eliminar: {}", idUsuarioAEliminar);
            return false;
        }

        // Solo administradores pueden eliminar usuarios
        if (!esAdministrador(session)) {
            logger.warn("Usuario ID {} intentó eliminar usuario ID {} sin permisos de administrador", 
                       usuarioActual.getIdUsuario(), idUsuarioAEliminar);
            return false;
        }

        // Un administrador no puede eliminarse a sí mismo
        if (usuarioActual.getIdUsuario() == idUsuarioAEliminar) {
            logger.warn("Administrador ID {} intentó eliminarse a sí mismo", usuarioActual.getIdUsuario());
            return false;
        }

        return true;
    }

    /**
     * Verifica si el usuario está autenticado.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario está autenticado, false en caso contrario
     */
    public static boolean estaAutenticado(HttpSession session) {
        return obtenerUsuarioActual(session) != null;
    }

    /**
     * Verifica si el usuario tiene un rol específico.
     * 
     * @param session Sesión HTTP
     * @param rolId ID del rol a verificar
     * @return true si el usuario tiene el rol, false en caso contrario
     */
    public static boolean tieneRol(HttpSession session, int rolId) {
        Usuario usuario = obtenerUsuarioActual(session);
        if (usuario == null || usuario.getRol() == null) {
            return false;
        }
        return usuario.getRol().getIdRol() == rolId;
    }

    /**
     * Verifica si el usuario actual tiene permisos de almacenero.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario es almacenero, false en caso contrario
     */
    public static boolean esAlmacenero(HttpSession session) {
        return tieneRol(session, ROL_ALMACEN);
    }

    /**
     * Verifica si el usuario actual tiene permisos de logística.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario es de logística, false en caso contrario
     */
    public static boolean esLogistica(HttpSession session) {
        return tieneRol(session, ROL_LOGISTICA);
    }

    /**
     * Verifica si el usuario actual tiene permisos de productor.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario es productor, false en caso contrario
     */
    public static boolean esProductor(HttpSession session) {
        return tieneRol(session, ROL_PRODUCTOR);
    }
    
    /**
     * Verifica si el usuario actual tiene permisos de gerente de tienda.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario es gerente de tienda, false en caso contrario
     */
    public static boolean esGerenteTienda(HttpSession session) {
        return tieneRol(session, ROL_GERENTE_TIENDA);
    }

    /**
     * Verifica si el usuario puede acceder al módulo de almacén.
     * Solo los usuarios con rol de almacenero pueden acceder.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario puede acceder al módulo de almacén, false en caso contrario
     */
    public static boolean puedeAccederAlmacen(HttpSession session) {
        return esAlmacenero(session);
    }

    /**
     * Verifica si el usuario puede acceder al módulo de logística.
     * Solo los usuarios con rol de logística pueden acceder.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario puede acceder al módulo de logística, false en caso contrario
     */
    public static boolean puedeAccederLogistica(HttpSession session) {
        return esLogistica(session);
    }

    /**
     * Verifica si el usuario puede acceder al módulo de productor.
     * Solo los usuarios con rol de productor pueden acceder.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario puede acceder al módulo de productor, false en caso contrario
     */
    public static boolean puedeAccederProductor(HttpSession session) {
        return esProductor(session);
    }

    /**
     * Verifica si el usuario puede acceder al módulo de administrador.
     * Solo los usuarios con rol de administrador pueden acceder.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario puede acceder al módulo de administrador, false en caso contrario
     */
    public static boolean puedeAccederAdministrador(HttpSession session) {
        return esAdministrador(session);
    }
    
    /**
     * Verifica si el usuario puede acceder al módulo de gerente de tienda.
     * Solo los usuarios con rol de gerente de tienda pueden acceder.
     * 
     * @param session Sesión HTTP
     * @return true si el usuario puede acceder al módulo de gerente de tienda, false en caso contrario
     */
    public static boolean puedeAccederGerenteTienda(HttpSession session) {
        return esGerenteTienda(session);
    }

    /**
     * Obtiene la URL de redirección según el rol del usuario.
     * 
     * @param session Sesión HTTP
     * @param contextPath Context path de la aplicación
     * @return URL de redirección según el rol, o null si no hay sesión válida
     */
    public static String obtenerUrlRedireccionPorRol(HttpSession session, String contextPath) {
        if (session == null || session.getAttribute("usuario") == null) {
            return contextPath + "/acceso/login";
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getRol() == null) {
            return contextPath + "/acceso/login";
        }
        
        String rolNombre = usuario.getRol().getNombre().toLowerCase();
        
        switch (rolNombre) {
            case "administrador":
                return contextPath + "/inicio";
            case "logística":
            case "logistica":
                return contextPath + "/InventarioServlet";
            case "productor":
                return contextPath + "/productor/index.jsp";
            case "almacenero":
            case "almacén":
                return contextPath + "/almacen/index.jsp";
            case "gerente de tienda":
                return contextPath + "/gerente-tienda/index.jsp";
            default:
                return contextPath + "/acceso/login";
        }
    }
}

