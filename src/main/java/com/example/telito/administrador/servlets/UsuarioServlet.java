package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.beans.Rol;
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

    // doGet para mostrar las vistas o para acciones simples que no vienen de un form.
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        HttpSession session = request.getSession();
        RequestDispatcher view;

        switch (action) {

            case "listar":
                // Recojo todos los parámetros de los filtros de la página.
                String busqueda = request.getParameter("busqueda");
                String rolId = request.getParameter("rol");
                String estado = request.getParameter("estado");
                String sortBy = request.getParameter("sortBy");
                String sortOrder = request.getParameter("sortOrder");
                // Paginación
                int page = 1;
                int size = 10;
                try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
                try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 10;

                // Le paso todo al DAO para que arme la consulta SQL.
                int totalRows = usuarioDAO.contarUsuarios(busqueda, rolId, estado);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;
                ArrayList<Usuario> listaUsuarios = usuarioDAO.listarUsuarios(busqueda, rolId, estado, sortBy, sortOrder, page, size);

                // Devuelvo los datos a la página para que se muestre la tabla.
                request.setAttribute("lista", listaUsuarios);
                // También devuelvo los filtros para que se queden seleccionados.
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("rolFiltro", rolId);
                request.setAttribute("estadoFiltro", estado);
                request.setAttribute("sortBy", sortBy);
                request.setAttribute("sortOrder", sortOrder);
                // Atributos de paginación
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);

                view = request.getRequestDispatcher("/administrador/gestion_de_usuarios.jsp");
                view.forward(request, response);
                break;

            case "formCrear":
                // Solo me lleva al JSP para crear un usuario.
                view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                view.forward(request, response);
                break;

            case "editar":
                // Busco el usuario en la BD y lo mando al JSP para que rellene el formulario.
                try {
                    int idUsuario = Integer.parseInt(request.getParameter("id"));
                    Usuario usuario = usuarioDAO.obtenerUsuarioPorId(idUsuario);
                    if (usuario != null) {
                        request.setAttribute("usuario", usuario);
                        view = request.getRequestDispatcher("/administrador/editar-usuario.jsp");
                        view.forward(request, response);
                    } else {
                        session.setAttribute("errorMsg", "El usuario que se intenta editar no existe.");
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID del usuario no es válido.");
                    response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                }
                break;

            case "borrar":
                // Deshabilita al usuario (borrado lógico).
                try {
                    int idADeshabilitar = Integer.parseInt(request.getParameter("id"));
                    usuarioDAO.deshabilitarUsuario(idADeshabilitar);
                    session.setAttribute("successMsg", "Usuario deshabilitado con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID para deshabilitar no es válido.");
                }
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                break;
        }
    }

    // doPost para cuando se envía un formulario (crear o actualizar).
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        HttpSession session = request.getSession();

        switch (action) {
            case "guardar":
                // ========== VALIDACIONES DE USUARIO ==========
                ArrayList<String> errores = new ArrayList<>();
                
                // 1. Validar que los parámetros obligatorios existan
                String nombres = request.getParameter("nombres");
                String apellidos = request.getParameter("apellidos");
                String email = request.getParameter("email");
                String password = request.getParameter("password");
                String rolIdStr = request.getParameter("rol_id");
                
                if (nombres == null || nombres.trim().isEmpty()) {
                    errores.add("El nombre es obligatorio");
                }
                if (apellidos == null || apellidos.trim().isEmpty()) {
                    errores.add("Los apellidos son obligatorios");
                }
                if (email == null || email.trim().isEmpty()) {
                    errores.add("El email es obligatorio");
                }
                if (password == null || password.trim().isEmpty()) {
                    errores.add("La contraseña es obligatoria");
                }
                if (rolIdStr == null || rolIdStr.trim().isEmpty()) {
                    errores.add("Debe seleccionar un rol");
                }
                
                // 2. Validar longitudes máximas
                if (nombres != null && nombres.length() > 100) {
                    errores.add("El nombre no puede exceder 100 caracteres");
                }
                if (apellidos != null && apellidos.length() > 100) {
                    errores.add("Los apellidos no pueden exceder 100 caracteres");
                }
                if (email != null && email.length() > 100) {
                    errores.add("El email no puede exceder 100 caracteres");
                }
                if (password != null && password.length() > 100) {
                    errores.add("La contraseña no puede exceder 100 caracteres");
                }
                
                // 3. Validar formato de email
                if (email != null && !email.trim().isEmpty()) {
                    String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$";
                    if (!email.matches(emailRegex)) {
                        errores.add("El formato del email no es válido");
                    }
                }
                
                // 4. Validar complejidad de contraseña
                if (password != null && !password.trim().isEmpty()) {
                    if (password.length() < 4) {
                        errores.add("La contraseña debe tener al menos 4 caracteres");
                    }
                }
                
                // 5. Validar que el rol_id sea un número válido
                int rolId = 0;
                try {
                    rolId = Integer.parseInt(rolIdStr);
                    if (rolId <= 0) {
                        errores.add("El ID del rol no es válido");
                    }
                } catch (NumberFormatException e) {
                    errores.add("El ID del rol debe ser un número válido");
                }
                
                // 6. Validar que el email no esté registrado
                if (email != null && !email.trim().isEmpty()) {
                    if (usuarioDAO.existeEmail(email)) {
                        errores.add("El email '" + email + "' ya está registrado");
                    }
                }
                
                // Si hay errores, volver al formulario
                if (!errores.isEmpty()) {
                    request.setAttribute("errores", errores);
                    request.setAttribute("nombres", nombres);
                    request.setAttribute("apellidos", apellidos);
                    request.setAttribute("email", email);
                    request.setAttribute("rol_id", rolIdStr);
                    
                    RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                    view.forward(request, response);
                    return;
                }
                
                // ========== TODO VÁLIDO - CREAR USUARIO ==========
                try {
                    Usuario usuarioNuevo = mapearUsuarioDesdeRequest(request);
                    boolean creado = usuarioDAO.crearUsuario(usuarioNuevo);
                    
                    if (creado) {
                        session.setAttribute("successMsg", "Usuario creado con éxito.");
                        response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                    } else {
                        errores.add("Error al guardar el usuario en la base de datos");
                        request.setAttribute("errores", errores);
                        request.setAttribute("nombres", nombres);
                        request.setAttribute("apellidos", apellidos);
                        request.setAttribute("email", email);
                        request.setAttribute("rol_id", rolIdStr);
                        
                        RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                        view.forward(request, response);
                    }
                } catch (Exception e) {
                    System.err.println("Error al crear usuario: " + e.getMessage());
                    e.printStackTrace();
                    
                    errores.add("Error inesperado al crear el usuario. Por favor, contacte al administrador.");
                    request.setAttribute("errores", errores);
                    request.setAttribute("nombres", nombres);
                    request.setAttribute("apellidos", apellidos);
                    request.setAttribute("email", email);
                    request.setAttribute("rol_id", rolIdStr);
                    
                    RequestDispatcher view = request.getRequestDispatcher("/administrador/crear-usuario.jsp");
                    view.forward(request, response);
                }
                break;

            case "actualizar":
                // Lee los datos del form, actualiza la BD y redirige.
                try {
                    Usuario usuarioActualizado = mapearUsuarioDesdeRequest(request);
                    usuarioDAO.actualizarUsuario(usuarioActualizado);
                    session.setAttribute("successMsg", "Usuario actualizado con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "Error al procesar los datos para actualizar.");
                }
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
                break;
        }
    }

    // Helper para no repetir código. Convierte los datos del form a un objeto Usuario.
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
        if (password != null) {
            usuario.setPassword(password);
        }

        // Si el checkbox de 'activo' está marcado, llega el parámetro. Si no, llega nulo.
        String activoParam = request.getParameter("activo");
        usuario.setActivo(activoParam != null && activoParam.equals("true"));

        Rol rol = new Rol();
        rol.setIdRol(Integer.parseInt(request.getParameter("rol_id")));
        usuario.setRol(rol);

        return usuario;
    }
}
