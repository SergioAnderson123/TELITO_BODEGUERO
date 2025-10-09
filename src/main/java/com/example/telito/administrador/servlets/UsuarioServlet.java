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
                // Lee los datos del form, los guarda en la BD y redirige.
                try {
                    Usuario usuarioNuevo = mapearUsuarioDesdeRequest(request);
                    usuarioDAO.crearUsuario(usuarioNuevo);
                    session.setAttribute("successMsg", "Usuario creado con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "Error al procesar el rol del usuario.");
                }
                response.sendRedirect(request.getContextPath() + "/UsuarioServlet");
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
