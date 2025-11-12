package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.administrador.beans.Categoria;
import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.administrador.daos.CategoriaDAO;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "AlertaServlet", value = "/AlertaServlet")
public class AlertaServlet extends HttpServlet {

    private AlertaDAO alertaDAO = new AlertaDAO();
    private CategoriaDAO categoriaDAO = new CategoriaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a AlertaServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        String action = request.getParameter("action");

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "listar":
                listarAlertas(request, response);
                break;
            case "formCrear": {
                try {
                    ArrayList<Categoria> listaCategorias = categoriaDAO.listarCategorias();
                    request.setAttribute("listaCategorias", listaCategorias);
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("error", "Error al cargar categorías: " + e.getMessage());
                }
                RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/form-alerta.jsp");
                dispatcher.forward(request, response);
                break;
            }
            case "editar":
                mostrarFormularioEdicion(request, response);
                break;
            case "borrar": {
                // Soporta borrado lógico vía GET para el enlace de la tabla
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    alertaDAO.deshabilitarAlerta(id);
                    request.getSession().setAttribute("successMsg", "Alerta deshabilitada exitosamente");
                } catch (NumberFormatException e) {
                    request.getSession().setAttribute("errorMsg", "ID de alerta inválido");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.getSession().setAttribute("errorMsg", "Error al deshabilitar la alerta: " + e.getMessage());
                }
                response.sendRedirect(request.getContextPath() + "/AlertaServlet?action=listar");
                break;
            }
            default:
                listarAlertas(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a AlertaServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        String action = request.getParameter("action");

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "crear":
                crearAlerta(request, response);
                break;
            case "actualizar":
                actualizarAlerta(request, response);
                break;
            case "eliminar":
                eliminarAlerta(request, response);
                break;
            default:
                listarAlertas(request, response);
                break;
        }
    }

    private void listarAlertas(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int page = 1;
            int size = 10;
            try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
            try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
            if (page < 1) page = 1;
            if (size < 1) size = 10;

            int totalRows = alertaDAO.contarAlertas();
            int totalPages = (int) Math.ceil(totalRows / (double) size);
            if (totalPages == 0) totalPages = 1;
            if (page > totalPages) page = totalPages;

            // Obtener lista de alertas
            ArrayList<AlertaConfig> listaAlertas = alertaDAO.listarAlertas(page, size);
            request.setAttribute("listaAlertas", listaAlertas);
            request.setAttribute("currentPage", page);
            request.setAttribute("size", size);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalRows", totalRows);

            // Obtener lista de categorías para el formulario
            ArrayList<Categoria> listaCategorias = categoriaDAO.listarCategorias();
            request.setAttribute("listaCategorias", listaCategorias);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-alertas.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar las alertas: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-alertas.jsp");
            dispatcher.forward(request, response);
        }
    }

    private void mostrarFormularioEdicion(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int idAlerta = Integer.parseInt(request.getParameter("id"));

            // Obtener la alerta específica
            AlertaConfig alerta = alertaDAO.obtenerAlertaPorId(idAlerta);
            request.setAttribute("alerta", alerta);

            // Obtener lista de categorías para el formulario
            ArrayList<Categoria> listaCategorias = categoriaDAO.listarCategorias();
            request.setAttribute("listaCategorias", listaCategorias);

            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/editar-alerta.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("error", "ID de alerta inválido");
            listarAlertas(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar la alerta: " + e.getMessage());
            listarAlertas(request, response);
        }
    }

    private void crearAlerta(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String nombre = request.getParameter("nombre");
            String tipoAlerta = request.getParameter("tipoAlerta");
            String umbralDiasStr = request.getParameter("umbralDias");
            String categoriaIdStr = request.getParameter("categoriaId");
            String rolANotificar = request.getParameter("rolANotificar");
            String mensajePersonalizado = request.getParameter("mensajePersonalizado");
            boolean activo = request.getParameter("activo") != null;

            // Crear objeto de alerta
            AlertaConfig alerta = new AlertaConfig();
            alerta.setNombre(nombre);
            alerta.setTipoAlerta(tipoAlerta);
            alerta.setActivo(activo);
            alerta.setMensajePersonalizado(mensajePersonalizado);

            // Configurar umbral de días si se proporciona
            if (umbralDiasStr != null && !umbralDiasStr.trim().isEmpty()) {
                try {
                    alerta.setUmbralDias(Integer.parseInt(umbralDiasStr));
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "El umbral de días debe ser un número válido");
                    listarAlertas(request, response);
                    return;
                }
            }

            // Configurar categoría si se selecciona
            if (categoriaIdStr != null && !categoriaIdStr.trim().isEmpty()) {
                try {
                    Categoria categoria = new Categoria();
                    categoria.setIdCategoria(Integer.parseInt(categoriaIdStr));
                    alerta.setCategoria(categoria);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "ID de categoría inválido");
                    listarAlertas(request, response);
                    return;
                }
            }

            // Configurar rol a notificar
            com.example.telito.administrador.beans.Rol rol = new com.example.telito.administrador.beans.Rol();
            rol.setNombre(rolANotificar);
            alerta.setRolANotificar(rol);

            alertaDAO.crearAlerta(alerta);
            request.getSession().setAttribute("successMsg", "Alerta creada exitosamente");

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Error al crear la alerta: " + e.getMessage());
        }

        listarAlertas(request, response);
    }

    private void actualizarAlerta(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int idAlertaConfig = Integer.parseInt(request.getParameter("idAlertaConfig"));
            String nombre = request.getParameter("nombre");
            String tipoAlerta = request.getParameter("tipoAlerta");
            String umbralDiasStr = request.getParameter("umbralDias");
            String categoriaIdStr = request.getParameter("categoriaId");
            String rolANotificar = request.getParameter("rolANotificar");
            String mensajePersonalizado = request.getParameter("mensajePersonalizado");
            boolean activo = request.getParameter("activo") != null;

            // Obtener alerta existente
            AlertaConfig alerta = alertaDAO.obtenerAlertaPorId(idAlertaConfig);

            if (alerta == null) {
                request.setAttribute("error", "Alerta no encontrada");
                listarAlertas(request, response);
                return;
            }

            // Actualizar campos
            alerta.setNombre(nombre);
            alerta.setTipoAlerta(tipoAlerta);
            alerta.setActivo(activo);
            alerta.setMensajePersonalizado(mensajePersonalizado);

            // Configurar umbral de días si se proporciona
            if (umbralDiasStr != null && !umbralDiasStr.trim().isEmpty()) {
                try {
                    alerta.setUmbralDias(Integer.parseInt(umbralDiasStr));
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "El umbral de días debe ser un número válido");
                    listarAlertas(request, response);
                    return;
                }
            } else {
                alerta.setUmbralDias(null);
            }

            // Configurar categoría si se selecciona
            if (categoriaIdStr != null && !categoriaIdStr.trim().isEmpty()) {
                try {
                    Categoria categoria = new Categoria();
                    categoria.setIdCategoria(Integer.parseInt(categoriaIdStr));
                    alerta.setCategoria(categoria);
                } catch (NumberFormatException e) {
                    request.setAttribute("error", "ID de categoría inválido");
                    listarAlertas(request, response);
                    return;
                }
            } else {
                alerta.setCategoria(null);
            }

            // Configurar rol a notificar
            com.example.telito.administrador.beans.Rol rol = new com.example.telito.administrador.beans.Rol();
            rol.setNombre(rolANotificar);
            alerta.setRolANotificar(rol);

            alertaDAO.actualizarAlerta(alerta);
            request.getSession().setAttribute("successMsg", "Alerta actualizada exitosamente");

        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "ID de alerta inválido");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Error al actualizar la alerta: " + e.getMessage());
        }
        listarAlertas(request, response);
    }

    private void eliminarAlerta(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int idAlertaConfig = Integer.parseInt(request.getParameter("idAlertaConfig"));
            alertaDAO.deshabilitarAlerta(idAlertaConfig);
            request.getSession().setAttribute("successMsg", "Alerta deshabilitada exitosamente");
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "ID de alerta inválido");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Error al deshabilitar la alerta: " + e.getMessage());
        }

        listarAlertas(request, response);
    }
}