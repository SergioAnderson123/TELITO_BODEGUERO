package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Conductor;
import com.example.telito.administrador.daos.ConductorDAO;
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

@WebServlet(name = "ConductorServlet", value = "/administrador/ConductorServlet")
public class ConductorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a ConductorServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        String action = request.getParameter("action");
        ConductorDAO conductorDAO = new ConductorDAO();

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "listar":
                int page = 1;
                int size = 10;
                String busqueda = request.getParameter("busqueda");
                try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
                try { size = Integer.parseInt(request.getParameter("size")); } catch (Exception ignored) {}
                if (page < 1) page = 1;
                if (size < 1) size = 10;

                int totalRows = conductorDAO.contarConductores(busqueda);
                int totalPages = (int) Math.ceil(totalRows / (double) size);
                if (totalPages == 0) totalPages = 1;
                if (page > totalPages) page = totalPages;

                ArrayList<Conductor> listaConductores = conductorDAO.listarConductores(busqueda, page, size);
                request.setAttribute("listaConductores", listaConductores);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", size);
                request.setAttribute("totalPages", totalPages);
                request.setAttribute("totalRows", totalRows);
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("baseUrl", request.getContextPath() + "/administrador/ConductorServlet");
                request.setAttribute("param1Name", "action");
                request.setAttribute("param1Value", "listar");
                request.setAttribute("itemName", "conductores");

                RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-conductores.jsp");
                dispatcher.forward(request, response);
                break;

            case "crear":
                RequestDispatcher dispatcherCrear = request.getRequestDispatcher("/administrador/crear-conductor.jsp");
                dispatcherCrear.forward(request, response);
                break;

            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Conductor conductorEditar = conductorDAO.buscarConductorPorId(idEditar);
                request.setAttribute("conductor", conductorEditar);
                RequestDispatcher dispatcherEditar = request.getRequestDispatcher("/administrador/editar-conductor.jsp");
                dispatcherEditar.forward(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                try {
                    boolean eliminado = conductorDAO.eliminarConductor(idEliminar);
                    if (eliminado) {
                        request.getSession().setAttribute("mensaje", "Conductor eliminado exitosamente.");
                        request.getSession().setAttribute("tipoMensaje", "success");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al eliminar el conductor. El conductor no existe.");
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                } catch (RuntimeException e) {
                    // Capturar el mensaje específico sobre planes de transporte asociados
                    String mensajeError = e.getMessage();
                    if (mensajeError != null && mensajeError.contains("planes de transporte")) {
                        request.getSession().setAttribute("mensaje", mensajeError);
                        request.getSession().setAttribute("tipoMensaje", "warning");
                    } else {
                        request.getSession().setAttribute("mensaje", "Error al eliminar el conductor: " + (mensajeError != null ? mensajeError : "Error desconocido"));
                        request.getSession().setAttribute("tipoMensaje", "danger");
                    }
                    System.err.println("Error al eliminar conductor: " + e.getMessage());
                    e.printStackTrace();
                } catch (Exception e) {
                    request.getSession().setAttribute("mensaje", "Error inesperado al eliminar el conductor.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                    System.err.println("Error inesperado al eliminar conductor: " + e.getMessage());
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a ConductorServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        ConductorDAO conductorDAO = new ConductorDAO();

        if ("guardar".equals(action)) {
            String nombreCompleto = request.getParameter("nombreCompleto");
            String licencia = request.getParameter("licencia");

            Conductor conductor = new Conductor();
            conductor.setNombreCompleto(nombreCompleto);
            conductor.setLicencia(licencia);

            boolean creado = conductorDAO.crearConductor(conductor);
            if (creado) {
                request.getSession().setAttribute("mensaje", "Conductor creado exitosamente.");
                request.getSession().setAttribute("tipoMensaje", "success");
            } else {
                request.getSession().setAttribute("mensaje", "Error al crear el conductor.");
                request.getSession().setAttribute("tipoMensaje", "danger");
            }
            response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");

        } else if ("actualizar".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String nombreCompleto = request.getParameter("nombreCompleto");
            String licencia = request.getParameter("licencia");

            Conductor conductor = new Conductor();
            conductor.setIdConductor(id);
            conductor.setNombreCompleto(nombreCompleto);
            conductor.setLicencia(licencia);

            boolean actualizado = conductorDAO.actualizarConductor(conductor);
            if (actualizado) {
                request.getSession().setAttribute("mensaje", "Conductor actualizado exitosamente.");
                request.getSession().setAttribute("tipoMensaje", "success");
            } else {
                request.getSession().setAttribute("mensaje", "Error al actualizar el conductor.");
                request.getSession().setAttribute("tipoMensaje", "danger");
            }
            response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
        }
    }
}

