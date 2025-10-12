package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.PlantillaConfig;
import com.example.telito.administrador.beans.PlantillaMapeo;
import com.example.telito.administrador.daos.PlantillaDAO;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PlantillaServlet", value = "/PlantillaServlet")
public class PlantillaServlet extends HttpServlet {

    // doGet para mostrar las páginas o para acciones que no sean de formularios (como deshabilitar).
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        PlantillaDAO plantillaDAO = new PlantillaDAO();
        HttpSession session = request.getSession();
        RequestDispatcher view;

        switch (action) {
            case "listar":
                // Carga la lista de plantillas para la tabla de gestión.
                ArrayList<PlantillaConfig> listaPlantillas = plantillaDAO.listarPlantillas();
                request.setAttribute("listaPlantillas", listaPlantillas);
                view = request.getRequestDispatcher("/administrador/gestion-plantillas.jsp");
                view.forward(request, response);
                break;

            case "formCrear":
                // Muestra el formulario para crear una plantilla nueva.
                view = request.getRequestDispatcher("/administrador/form-plantilla.jsp");
                view.forward(request, response);
                break;

            case "editar":
                // Carga los datos de una plantilla para rellenar el formulario de edición.
                try {
                    int idPlantilla = Integer.parseInt(request.getParameter("id"));
                    PlantillaConfig plantilla = plantillaDAO.obtenerPlantillaPorId(idPlantilla);
                    if (plantilla != null) {
                        request.setAttribute("plantilla", plantilla);
                        view = request.getRequestDispatcher("/administrador/form-plantilla.jsp");
                        view.forward(request, response);
                    } else {
                        session.setAttribute("errorMsg", "La plantilla que se intenta editar no existe.");
                        response.sendRedirect(request.getContextPath() + "/PlantillaServlet");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID de la plantilla no es válido.");
                    response.sendRedirect(request.getContextPath() + "/PlantillaServlet");
                }
                break;

            case "deshabilitar":
                // Es un borrado lógico, solo cambia el estado a inactivo.
                try {
                    int idPlantilla = Integer.parseInt(request.getParameter("id"));
                    plantillaDAO.deshabilitarPlantilla(idPlantilla);
                    session.setAttribute("successMsg", "Plantilla deshabilitada con éxito.");
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMsg", "El ID para deshabilitar la plantilla no es válido.");
                }
                response.sendRedirect(request.getContextPath() + "/PlantillaServlet");
                break;
        }
    }

    // doPost para procesar los formularios de "guardar" y "actualizar".
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        PlantillaDAO plantillaDAO = new PlantillaDAO();
        HttpSession session = request.getSession();

        try {
            switch (action) {
                case "guardar":
                    PlantillaConfig plantillaNueva = mapearPlantillaDesdeRequest(request);
                    plantillaDAO.crearPlantilla(plantillaNueva);
                    session.setAttribute("successMsg", "Nueva plantilla creada con éxito.");
                    response.sendRedirect(request.getContextPath() + "/PlantillaServlet");
                    break;

                case "actualizar":
                    PlantillaConfig plantillaActualizada = mapearPlantillaDesdeRequest(request);
                    plantillaDAO.actualizarPlantilla(plantillaActualizada);
                    session.setAttribute("successMsg", "Plantilla actualizada con éxito.");
                    response.sendRedirect(request.getContextPath() + "/PlantillaServlet");
                    break;
            }
        } catch (SQLException e) {
            session.setAttribute("errorMsg", "Error en la base de datos. La transacción se revirtió.");
            response.sendRedirect(request.getContextPath() + "/PlantillaServlet");
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Ocurrió un error al procesar la plantilla.");
            response.sendRedirect(request.getContextPath() + "/PlantillaServlet");
        }
    }

    // Método para leer todos los datos del formulario y meterlos en un objeto PlantillaConfig.
    private PlantillaConfig mapearPlantillaDesdeRequest(HttpServletRequest request) {
        PlantillaConfig plantilla = new PlantillaConfig();

        String idStr = request.getParameter("id_plantilla");
        if (idStr != null && !idStr.isEmpty()) {
            plantilla.setIdPlantilla(Integer.parseInt(idStr));
        }

        plantilla.setNombre(request.getParameter("nombre"));
        plantilla.setTipoCarga(request.getParameter("tipo_carga"));
        // El checkbox si no está marcado, no envía nada. Por eso compruebo si es nulo.
        plantilla.setActivo(request.getParameter("activo") != null && request.getParameter("activo").equals("true"));

        // El mapeo de columnas es dinámico, así que recibo dos arrays.
        List<PlantillaMapeo> mapeos = new ArrayList<>();
        String[] columnasExcel = request.getParameterValues("columna_excel");
        String[] camposDestino = request.getParameterValues("campo_destino");

        if (columnasExcel != null && camposDestino != null) {
            for (int i = 0; i < columnasExcel.length; i++) {
                // Solo proceso las filas que no estén vacías.
                if (!columnasExcel[i].isEmpty() && !camposDestino[i].isEmpty()) {
                    PlantillaMapeo mapeo = new PlantillaMapeo();
                    mapeo.setColumnaExcel(columnasExcel[i]);
                    mapeo.setCampoDestino(camposDestino[i]);
                    mapeos.add(mapeo);
                }
            }
        }
        plantilla.setMapeos(mapeos);

        return plantilla;
    }
}
