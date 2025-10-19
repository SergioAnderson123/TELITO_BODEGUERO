package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.daos.RolDAO;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.utils.UsuarioValidator;
import com.example.telito.administrador.utils.AdminLogger;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "UsuarioServlet", value = "/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    /**
     * Maneja las solicitudes GET para mostrar vistas y operaciones de lectura.
     * Incluye validación de parámetros y logging de operaciones.
     */
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        HttpSession session = request.getSession();
        RequestDispatcher view;
        
        // Obtener información del usuario logueado para logging
        Usuario usuarioSesion = (Usuario) session.getAttribute("usuarioSesion");
        String userEmail = usuarioSesion != null ? usuarioSesion.getEmail() : "unknown";

        try {
            switch (action) {

                case "listar":
                    // Validar parámetros de búsqueda
                    String busqueda = request.getParameter("busqueda");
                    String rolId = request.getParameter("rol");
                    String estado = request.getParameter("estado");
                    String sortBy = request.getParameter("sortBy");
                    String sortOrder = request.getParameter("sortOrder");

                    // Validar parámetros de búsqueda
                    UsuarioValidator.ValidationResult validationResult = UsuarioValidator.validateSearchParams(busqueda, rolId, estado);
                    if (!validationResult.isValid()) {
                        AdminLogger.warn(String.format("Invalid search parameters from user %s: %s", userEmail, validationResult.getErrorsAsString()));
                        session.setAttribute("errorMsg", "Parámetros de búsqueda inválidos: " + validationResult.getErrorsAsString());
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                        return;
                    }

                    AdminLogger.logUserOperation("LIST_USERS", userEmail, String.format("Search: %s, Role: %s, State: %s", busqueda, rolId, estado));

                    // Le paso todo al DAO para que arme la consulta SQL.
                    ArrayList<Usuario> listaUsuarios = usuarioDAO.listarUsuarios(busqueda, rolId, estado, sortBy, sortOrder);

                    // Devuelvo los datos a la página para que se muestre la tabla.
                    request.setAttribute("lista", listaUsuarios);
                    // También devuelvo los filtros para que se queden seleccionados.
                    request.setAttribute("busqueda", busqueda);
                    request.setAttribute("rolFiltro", rolId);
                    request.setAttribute("estadoFiltro", estado);
                    request.setAttribute("sortBy", sortBy);
                    request.setAttribute("sortOrder", sortOrder);

                    AdminLogger.info(String.format("Successfully listed %d users for user %s", listaUsuarios.size(), userEmail));
                    view = request.getRequestDispatcher("/administrador/gestion_de_usuarios.jsp");
                    view.forward(request, response);
                    break;

                case "formCrear":
                    AdminLogger.logUserOperation("SHOW_CREATE_FORM", userEmail, "Displaying user creation form");
                    
                    // Cargo la lista de roles para el ComboBox
                    RolDAO rolDAO = new RolDAO();
                    ArrayList<Rol> listaRoles = rolDAO.listarRoles();
                    request.setAttribute("listaRoles", listaRoles);
                    
                    // Solo me lleva al JSP para crear un usuario.
                    view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                    view.forward(request, response);
                    break;

                case "editar":
                    // Busco el usuario en la BD y lo mando al JSP para que rellene el formulario.
                    try {
                        int idUsuario = Integer.parseInt(request.getParameter("id"));
                        AdminLogger.logUserOperation("SHOW_EDIT_FORM", userEmail, String.format("Editing user ID: %d", idUsuario));
                        
                        Usuario usuario = usuarioDAO.obtenerUsuarioPorId(idUsuario);
                        if (usuario != null) {
                            // También cargo la lista de roles para el ComboBox
                            RolDAO rolDAOEditar = new RolDAO();
                            ArrayList<Rol> listaRolesEditar = rolDAOEditar.listarRoles();
                            request.setAttribute("listaRoles", listaRolesEditar);
                            
                            request.setAttribute("usuario", usuario);
                            AdminLogger.info(String.format("Successfully loaded user %s for editing by %s", usuario.getEmail(), userEmail));
                            view = request.getRequestDispatcher("/administrador/editar-usuario.jsp");
                            view.forward(request, response);
                        } else {
                            AdminLogger.warn(String.format("Attempted to edit non-existent user ID %d by %s", idUsuario, userEmail));
                            session.setAttribute("errorMsg", "El usuario que se intenta editar no existe.");
                            response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                        }
                    } catch (NumberFormatException e) {
                        AdminLogger.error(String.format("Invalid user ID parameter from user %s", userEmail), e);
                        session.setAttribute("errorMsg", "El ID del usuario no es válido.");
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    }
                    break;

                case "borrar":
                    // Deshabilita al usuario (borrado lógico).
                    try {
                        int idADeshabilitar = Integer.parseInt(request.getParameter("id"));
                        AdminLogger.logUserOperation("DISABLE_USER", userEmail, String.format("Disabling user ID: %d", idADeshabilitar));
                        
                        usuarioDAO.deshabilitarUsuario(idADeshabilitar);
                        AdminLogger.info(String.format("Successfully disabled user ID %d by %s", idADeshabilitar, userEmail));
                        session.setAttribute("successMsg", "Usuario deshabilitado con éxito.");
                    } catch (NumberFormatException e) {
                        AdminLogger.error(String.format("Invalid user ID for deletion from user %s", userEmail), e);
                        session.setAttribute("errorMsg", "El ID para deshabilitar no es válido.");
                    }
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    break;
                    
                default:
                    AdminLogger.warn(String.format("Unknown action '%s' requested by user %s", action, userEmail));
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    break;
            }
        } catch (Exception e) {
            AdminLogger.error(String.format("Unexpected error in UsuarioServlet.doGet for user %s", userEmail), e);
            session.setAttribute("errorMsg", "Error interno del servidor. Por favor, intente nuevamente.");
            response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
        }
    }

    /**
     * Maneja las solicitudes POST para crear y actualizar usuarios.
     * Incluye validación robusta y logging detallado.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        HttpSession session = request.getSession();
        
        // Obtener información del usuario logueado para logging
        Usuario usuarioSesion = (Usuario) session.getAttribute("usuarioSesion");
        String userEmail = usuarioSesion != null ? usuarioSesion.getEmail() : "unknown";

        try {
            switch (action) {
                case "guardar":
                    // Crear nuevo usuario con validación robusta
                    Usuario usuarioNuevo = mapearUsuarioDesdeRequest(request);
                    
                    // Validar usuario antes de guardar
                    UsuarioValidator.ValidationResult validationResult = UsuarioValidator.validateUsuario(usuarioNuevo, false);
                    if (!validationResult.isValid()) {
                        AdminLogger.warn(String.format("Validation failed for new user by %s: %s", userEmail, validationResult.getErrorsAsString()));
                        session.setAttribute("errorMsg", "Error de validación: " + validationResult.getErrorsAsString());
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet?action=formCrear");
                        return;
                    }
                    
                    AdminLogger.logUserOperation("CREATE_USER", userEmail, String.format("Creating user: %s", usuarioNuevo.getEmail()));
                    
                    usuarioDAO.crearUsuario(usuarioNuevo);
                    AdminLogger.info(String.format("Successfully created user %s by %s", usuarioNuevo.getEmail(), userEmail));
                    session.setAttribute("successMsg", "Usuario creado con éxito.");
                    break;

                case "actualizar":
                    // Actualizar usuario existente con validación robusta
                    Usuario usuarioActualizado = mapearUsuarioDesdeRequest(request);
                    
                    // Validar usuario antes de actualizar
                    UsuarioValidator.ValidationResult updateValidationResult = UsuarioValidator.validateUsuario(usuarioActualizado, true);
                    if (!updateValidationResult.isValid()) {
                        AdminLogger.warn(String.format("Validation failed for user update by %s: %s", userEmail, updateValidationResult.getErrorsAsString()));
                        session.setAttribute("errorMsg", "Error de validación: " + updateValidationResult.getErrorsAsString());
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet?action=editar&id=" + usuarioActualizado.getIdUsuario());
                        return;
                    }
                    
                    AdminLogger.logUserOperation("UPDATE_USER", userEmail, String.format("Updating user ID: %d", usuarioActualizado.getIdUsuario()));
                    
                    usuarioDAO.actualizarUsuario(usuarioActualizado);
                    AdminLogger.info(String.format("Successfully updated user ID %d by %s", usuarioActualizado.getIdUsuario(), userEmail));
                    session.setAttribute("successMsg", "Usuario actualizado con éxito.");
                    break;
                    
                default:
                    AdminLogger.warn(String.format("Unknown POST action '%s' from user %s", action, userEmail));
                    session.setAttribute("errorMsg", "Acción no válida.");
                    break;
            }
        } catch (NumberFormatException e) {
            AdminLogger.error(String.format("Number format error in UsuarioServlet.doPost for user %s", userEmail), e);
            session.setAttribute("errorMsg", "Error al procesar los datos numéricos.");
        } catch (Exception e) {
            AdminLogger.error(String.format("Unexpected error in UsuarioServlet.doPost for user %s", userEmail), e);
            session.setAttribute("errorMsg", "Error interno del servidor. Por favor, intente nuevamente.");
        }
        
        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
    }

    /**
     * Helper para mapear datos del formulario a un objeto Usuario.
     * Incluye validación básica de parámetros.
     * 
     * @param request la solicitud HTTP con los parámetros del formulario
     * @return Usuario objeto mapeado desde el formulario
     * @throws NumberFormatException si hay errores en la conversión de números
     */
    private Usuario mapearUsuarioDesdeRequest(HttpServletRequest request) throws NumberFormatException {
        Usuario usuario = new Usuario();
        
        // Mapear ID (solo para actualizaciones)
        String idUsuarioStr = request.getParameter("id_usuario");
        if (idUsuarioStr != null && !idUsuarioStr.trim().isEmpty()) {
            usuario.setIdUsuario(Integer.parseInt(idUsuarioStr.trim()));
        }

        // Mapear nombres con trim para eliminar espacios
        String nombres = request.getParameter("nombres");
        usuario.setNombres(nombres != null ? nombres.trim() : null);
        
        // Mapear apellidos con trim
        String apellidos = request.getParameter("apellidos");
        usuario.setApellidos(apellidos != null ? apellidos.trim() : null);
        
        // Mapear email con trim y conversión a minúsculas
        String email = request.getParameter("email");
        usuario.setEmail(email != null ? email.trim().toLowerCase() : null);

        // Mapear contraseña (solo si se proporciona)
        String password = request.getParameter("password");
        if (password != null && !password.trim().isEmpty()) {
            usuario.setPassword(password);
        }

        // Mapear estado activo
        String activoParam = request.getParameter("activo");
        usuario.setActivo(activoParam != null && activoParam.equals("true"));

        // Mapear rol con validación
        String rolIdStr = request.getParameter("rol_id");
        if (rolIdStr == null || rolIdStr.trim().isEmpty()) {
            throw new NumberFormatException("El rol es obligatorio");
        }
        
        Rol rol = new Rol();
        rol.setIdRol(Integer.parseInt(rolIdStr.trim()));
        usuario.setRol(rol);

        return usuario;
    }
}
