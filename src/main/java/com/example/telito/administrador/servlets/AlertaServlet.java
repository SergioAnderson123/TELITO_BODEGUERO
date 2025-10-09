package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.AlertaConfig;
import com.example.telito.administrador.beans.Categoria;
import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.daos.AlertaDAO;

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

    // El método doGet se encarga de las acciones que NO modifican datos (o que solo leen).
    // Por ejemplo, mostrar listas o formularios.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        AlertaDAO alertaDAO = new AlertaDAO();
        HttpSession session = request.getSession();
        RequestDispatcher view;

        // El filtro AlertCountFilter ya se encarga de actualizar el contador de alertas en la sesión,
        // así que no necesito hacerlo aquí de nuevo.

        switch (action) {
            case "listar":
                // Carga la lista de reglas para mostrarla en la tabla de gestion-alertas.jsp
                ArrayList<AlertaConfig> listaAlertas = alertaDAO.listarAlertas();
                request.setAttribute("listaAlertas", listaAlertas);
                view = request.getRequestDispatcher("gestion-alertas.jsp");
                view.forward(request, response);
                break;

            case "formCrear":
                // Solo muestra el formulario para crear una nueva regla.
                view = request.getRequestDispatcher("crear-alerta.jsp");
                view.forward(request, response);
                break;

            case "editar":
                // Carga los datos de una regla existente para ponerlos en el formulario de edición.
                try {
                    int idAlerta = Integer.parseInt(request.getParameter("id"));
                    AlertaConfig alerta = alertaDAO.obtenerAlertaPorId(idAlerta);
                    if (alerta != null) {
                        request.setAttribute("alerta", alerta);
                        view = request.getRequestDispatcher("editar-alerta.jsp");
                        view.forward(request, response);
                    } else {
                        session.setAttribute("errorMsg", "La regla de alerta que se intenta editar no existe.");
                        response.sendRedirect(request.getContextPath() + "/AlertaServlet");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID de la regla no es válido.");
                    response.sendRedirect(request.getContextPath() + "/AlertaServlet");
                }
                break;

            case "borrar":
                // Deshabilita la regla (borrado lógico).
                try {
                    int idAlerta = Integer.parseInt(request.getParameter("id"));
                    alertaDAO.deshabilitarAlerta(idAlerta);
                    session.setAttribute("successMsg", "Regla de alerta deshabilitada con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID para deshabilitar la regla no es válido.");
                }
                response.sendRedirect(request.getContextPath() + "/AlertaServlet");
                break;
        }
    }

    // El doPost se usa para las acciones que SÍ modifican datos (crear, actualizar).
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        AlertaDAO alertaDAO = new AlertaDAO();
        HttpSession session = request.getSession();

        switch (action) {
            case "guardar":
                // Procesa los datos del formulario de creación.
                try {
                    AlertaConfig alerta = mapearAlertaDesdeRequest(request);
                    alertaDAO.crearAlerta(alerta);
                    session.setAttribute("successMsg", "Nueva regla de alerta creada con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "Error al procesar los datos de la regla.");
                }
                response.sendRedirect(request.getContextPath() + "/AlertaServlet");
                break;

            case "actualizar":
                // Procesa los datos del formulario de edición.
                try {
                    AlertaConfig alerta = mapearAlertaDesdeRequest(request);
                    alertaDAO.actualizarAlerta(alerta);
                    session.setAttribute("successMsg", "Regla de alerta actualizada con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "Error al procesar los datos para actualizar la regla.");
                }
                response.sendRedirect(request.getContextPath() + "/AlertaServlet");
                break;
        }
    }

    // Este método ayuda a no repetir código. Lee los datos del formulario
    // y los convierte en un objeto AlertaConfig.
    private AlertaConfig mapearAlertaDesdeRequest(HttpServletRequest request) throws NumberFormatException {
        AlertaConfig alerta = new AlertaConfig();

        String idStr = request.getParameter("id_alerta_config");
        if (idStr != null && !idStr.isEmpty()) {
            alerta.setIdAlertaConfig(Integer.parseInt(idStr));
        }

        alerta.setNombre(request.getParameter("nombre"));
        alerta.setTipoAlerta(request.getParameter("tipo_alerta"));

        String umbralStr = request.getParameter("umbral_dias");
        if (umbralStr != null && !umbralStr.isEmpty()) {
            alerta.setUmbralDias(Integer.parseInt(umbralStr));
        } else {
            alerta.setUmbralDias(null);
        }

        String categoriaIdStr = request.getParameter("categoria_id");
        if (categoriaIdStr != null && !categoriaIdStr.isEmpty()) {
            Categoria categoria = new Categoria();
            categoria.setIdCategoria(Integer.parseInt(categoriaIdStr));
            alerta.setCategoria(categoria);
        }

        Rol rol = new Rol();
        rol.setIdRol(Integer.parseInt(request.getParameter("rol_a_notificar_id")));
        alerta.setRolANotificar(rol);

        String activoParam = request.getParameter("activo");
        alerta.setActivo(activoParam != null && activoParam.equals("true"));

        return alerta;
    }
}
