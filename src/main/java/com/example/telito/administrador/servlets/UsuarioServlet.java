package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.services.UsuarioService;
import com.example.telito.administrador.validators.UsuarioValidator;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;

/**
 * Servlet para gestionar usuarios.
 * Refactorizado para mejorar la separación de responsabilidades:
 * - Usa UsuarioService para la lógica de negocio
 * - Usa UsuarioValidator para las validaciones
 * - Usa AuthorizationHelper para permisos
 * - Usa logging profesional (SLF4J)
 */
@WebServlet(name = "UsuarioServlet", value = "/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioServlet.class);
    private final UsuarioDAO usuarioDAO;
    private final UsuarioService usuarioService;

    public UsuarioServlet() {
        this.usuarioDAO = new UsuarioDAO();
        this.usuarioService = new UsuarioService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ServletException {

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        HttpSession session = request.getSession();
        RequestDispatcher view;

        logger.debug("Procesando acción GET: {}", action);

        switch (action) {
            case "listar":
                listarUsuarios(request, response);
                break;

            case "formCrear":
                if (!AuthorizationHelper.puedeGestionarUsuarios(session)) {
                    logger.warn("Intento de acceder a formulario de creación sin permisos");
                    session.setAttribute("errorMsg", "No tienes permisos para crear usuarios.");
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    return;
                }
                view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                view.forward(request, response);
                break;

            case "editar":
                editarUsuario(request, response, session);
                break;

            case "borrar":
                borrarUsuario(request, response, session);
                break;

            default:
                logger.warn("Acción no reconocida: {}", action);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        HttpSession session = request.getSession();

        logger.debug("Procesando POST con acción: {}", action);

        switch (action) {
            case "guardar":
                guardarUsuario(request, response, session);
                break;

            case "actualizar":
                actualizarUsuario(request, response, session);
                break;

            default:
                logger.warn("Acción POST no reconocida: {}", action);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
                break;
        }
    }

    /**
     * Lista usuarios con paginación, filtros y ordenamiento.
     */
    private void listarUsuarios(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Recoger parámetros de filtros
                String busqueda = request.getParameter("busqueda");
                String rolId = request.getParameter("rol");
                String estado = request.getParameter("estado");
                String sortBy = request.getParameter("sortBy");
                String sortOrder = request.getParameter("sortOrder");
            
                // Paginación
            int page = parseInteger(request.getParameter("page"), 1);
            int size = parseInteger(request.getParameter("size"), 10);
                if (page < 1) page = 1;
                if (size < 1) size = 10;

            // Obtener datos
                int totalRows = usuarioDAO.contarUsuarios(busqueda, rolId, estado);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;
            
            ArrayList<Usuario> listaUsuarios = usuarioDAO.listarUsuarios(
                busqueda, rolId, estado, sortBy, sortOrder, page, size);

            // Establecer atributos en el request
                request.setAttribute("lista", listaUsuarios);
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("rolFiltro", rolId);
                request.setAttribute("estadoFiltro", estado);
                request.setAttribute("sortBy", sortBy);
                request.setAttribute("sortOrder", sortOrder);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);

            logger.debug("Listando usuarios: página {}, total: {}", page, totalRows);

            RequestDispatcher view = request.getRequestDispatcher("/administrador/gestion_de_usuarios.jsp");
                view.forward(request, response);
            
        } catch (Exception e) {
            logger.error("Error al listar usuarios: {}", e.getMessage(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Error al cargar la lista de usuarios");
        }
    }

    /**
     * Muestra el formulario de edición de un usuario.
     */
    private void editarUsuario(HttpServletRequest request, HttpServletResponse response, 
                               HttpSession session) throws ServletException, IOException {
        
                try {
                    int idUsuario = Integer.parseInt(request.getParameter("id"));
            
            // Verificar permisos
            if (!AuthorizationHelper.puedeEditarUsuario(session, idUsuario)) {
                logger.warn("Intento de editar usuario ID {} sin permisos", idUsuario);
                session.setAttribute("errorMsg", "No tienes permisos para editar este usuario.");
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                return;
            }
            
                    Usuario usuario = usuarioDAO.obtenerUsuarioPorId(idUsuario);
                    if (usuario != null) {
                        request.setAttribute("usuario", usuario);
                RequestDispatcher view = request.getRequestDispatcher("/administrador/editar-usuario.jsp");
                        view.forward(request, response);
                    } else {
                logger.warn("Usuario ID {} no encontrado para editar", idUsuario);
                        session.setAttribute("errorMsg", "El usuario que se intenta editar no existe.");
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    }
            
                } catch (NumberFormatException e) {
            logger.error("ID de usuario inválido: {}", request.getParameter("id"));
                    session.setAttribute("errorMsg", "El ID del usuario no es válido.");
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                }
    }

    /**
     * Deshabilita un usuario (borrado lógico).
     */
    private void borrarUsuario(HttpServletRequest request, HttpServletResponse response, 
                              HttpSession session) throws IOException {
        
                try {
                    int idADeshabilitar = Integer.parseInt(request.getParameter("id"));
            
            // Verificar permisos
            if (!AuthorizationHelper.puedeEliminarUsuario(session, idADeshabilitar)) {
                logger.warn("Intento de eliminar usuario ID {} sin permisos", idADeshabilitar);
                session.setAttribute("errorMsg", "No tienes permisos para eliminar este usuario.");
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                return;
            }
            
                    usuarioDAO.deshabilitarUsuario(idADeshabilitar);
            logger.info("Usuario ID {} deshabilitado exitosamente", idADeshabilitar);
                    session.setAttribute("successMsg", "Usuario deshabilitado con éxito.");
            
                } catch (NumberFormatException e) {
            logger.error("ID de usuario inválido para eliminar: {}", request.getParameter("id"));
                    session.setAttribute("errorMsg", "El ID para deshabilitar no es válido.");
        } catch (Exception e) {
            logger.error("Error al deshabilitar usuario: {}", e.getMessage(), e);
            session.setAttribute("errorMsg", "Error al deshabilitar el usuario.");
                }
        
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
    }

    /**
     * Guarda un nuevo usuario.
     */
    private void guardarUsuario(HttpServletRequest request, HttpServletResponse response, 
                               HttpSession session) throws ServletException, IOException {
        
        // Verificar permisos
        if (!AuthorizationHelper.puedeGestionarUsuarios(session)) {
            logger.warn("Intento de crear usuario sin permisos");
            session.setAttribute("errorMsg", "No tienes permisos para crear usuarios.");
            response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
            return;
        }
        
        // Obtener parámetros
                String nombres = request.getParameter("nombres");
                String apellidos = request.getParameter("apellidos");
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String rolIdStr = request.getParameter("rol_id");
                
        // Validar datos
        ArrayList<String> errores = UsuarioValidator.validarUsuario(
            nombres, apellidos, email, password, rolIdStr, usuarioDAO, true);
        
                if (!errores.isEmpty()) {
            logger.warn("Errores de validación al crear usuario: {}", errores);
                    request.setAttribute("errores", errores);
                    request.setAttribute("nombres", nombres);
                    request.setAttribute("apellidos", apellidos);
                    request.setAttribute("email", email);
                    request.setAttribute("rol_id", rolIdStr);
                    
                    RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                    view.forward(request, response);
                    return;
                }
                
        // Mapear usuario desde request
                    Usuario usuarioNuevo = mapearUsuarioDesdeRequest(request);
        String passwordOriginal = password;
        
        // Crear usuario usando el servicio
        UsuarioService.ResultadoCreacionUsuario resultado = usuarioService.crearOReactivarUsuario(
            usuarioNuevo, passwordOriginal, request.getContextPath());
        
        if (resultado.isExito()) {
            logger.info("Usuario creado exitosamente. ID: {}, Email: {}", 
                       resultado.getUsuario().getIdUsuario(), resultado.getUsuario().getEmail());
                        session.setAttribute("successMsg", "Usuario creado con éxito.");
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    } else {
            logger.error("Error al crear usuario: {}", resultado.getError());
            errores.add(resultado.getError());
                        request.setAttribute("errores", errores);
                        request.setAttribute("nombres", nombres);
                        request.setAttribute("apellidos", apellidos);
                        request.setAttribute("email", email);
                        request.setAttribute("rol_id", rolIdStr);
                        
                        RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                        view.forward(request, response);
                    }
    }

    /**
     * Actualiza un usuario existente.
     */
    private void actualizarUsuario(HttpServletRequest request, HttpServletResponse response, 
                                  HttpSession session) throws IOException {
        
                try {
                    Usuario usuarioActualizado = mapearUsuarioDesdeRequest(request);
                    
            // Verificar permisos
            if (!AuthorizationHelper.puedeEditarUsuario(session, usuarioActualizado.getIdUsuario())) {
                logger.warn("Intento de actualizar usuario ID {} sin permisos", usuarioActualizado.getIdUsuario());
                session.setAttribute("errorMsg", "No tienes permisos para actualizar este usuario.");
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                return;
            }
            
            // Validar datos básicos (sin validar email duplicado ni contraseña obligatoria)
            String nombres = request.getParameter("nombres");
            String apellidos = request.getParameter("apellidos");
            String email = request.getParameter("email");
            String rolIdStr = request.getParameter("rol_id");
            
            ArrayList<String> errores = UsuarioValidator.validarUsuarioActualizacion(
                nombres, apellidos, email, rolIdStr);
            
            if (!errores.isEmpty()) {
                logger.warn("Errores de validación al actualizar usuario: {}", errores);
                session.setAttribute("errorMsg", String.join(", ", errores));
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet?action=editar&id=" + 
                                    usuarioActualizado.getIdUsuario());
                return;
            }
            
            String passwordNueva = request.getParameter("password");
            
            // Actualizar usuario usando el servicio
            boolean actualizado = usuarioService.actualizarUsuario(
                usuarioActualizado, passwordNueva, request.getContextPath());
            
            if (actualizado) {
                logger.info("Usuario actualizado exitosamente. ID: {}", usuarioActualizado.getIdUsuario());
                session.setAttribute("successMsg", "Usuario actualizado con éxito.");
                                } else {
                logger.error("Error al actualizar usuario ID {}", usuarioActualizado.getIdUsuario());
                session.setAttribute("errorMsg", "Error al actualizar el usuario.");
            }
            
                } catch (NumberFormatException e) {
            logger.error("Error al procesar datos para actualizar: {}", e.getMessage(), e);
                    session.setAttribute("errorMsg", "Error al procesar los datos para actualizar.");
        } catch (Exception e) {
            logger.error("Error inesperado al actualizar usuario: {}", e.getMessage(), e);
            session.setAttribute("errorMsg", "Error inesperado al actualizar el usuario.");
                }
        
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
    }

    /**
     * Helper para mapear un objeto Usuario desde los parámetros del request.
     */
    private Usuario mapearUsuarioDesdeRequest(HttpServletRequest request) throws NumberFormatException {
        Usuario usuario = new Usuario();
        
        String idUsuarioStr = request.getParameter("id_usuario");
        if (idUsuarioStr != null && !idUsuarioStr.isEmpty()) {
            usuario.setIdUsuario(Integer.parseInt(idUsuarioStr));
        }

        usuario.setNombres(request.getParameter("nombres"));
        usuario.setApellidos(request.getParameter("apellidos"));
        usuario.setEmail(request.getParameter("email"));

        String password = request.getParameter("password");
        if (password != null && !password.trim().isEmpty()) {
            usuario.setPassword(password);
        }

        String activoParam = request.getParameter("activo");
        usuario.setActivo(activoParam != null && activoParam.equals("true"));

        Rol rol = new Rol();
        rol.setIdRol(Integer.parseInt(request.getParameter("rol_id")));
        usuario.setRol(rol);

        return usuario;
    }

    /**
     * Helper para parsear enteros de forma segura.
     */
    private int parseInteger(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
