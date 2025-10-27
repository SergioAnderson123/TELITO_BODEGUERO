package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Conductor;
import com.example.telito.administrador.daos.ConductorDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "ConductorServlet", value = "/administrador/ConductorServlet")
public class ConductorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        ConductorDAO conductorDAO = new ConductorDAO();

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "listar":
                ArrayList<Conductor> listaConductores = conductorDAO.listarConductores();
                request.setAttribute("listaConductores", listaConductores);
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
                boolean eliminado = conductorDAO.eliminarConductor(idEliminar);
                if (eliminado) {
                    request.getSession().setAttribute("mensaje", "Conductor eliminado exitosamente.");
                    request.getSession().setAttribute("tipoMensaje", "success");
                } else {
                    request.getSession().setAttribute("mensaje", "Error al eliminar el conductor.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                }
                response.sendRedirect(request.getContextPath() + "/administrador/ConductorServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

