package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Vehiculo;
import com.example.telito.administrador.daos.VehiculoDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "VehiculoServlet", value = "/administrador/VehiculoServlet")
public class VehiculoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        VehiculoDAO vehiculoDAO = new VehiculoDAO();

        if (action == null) {
            action = "listar";
        }

        switch (action) {
            case "listar":
                ArrayList<Vehiculo> listaVehiculos = vehiculoDAO.listarVehiculos();
                request.setAttribute("listaVehiculos", listaVehiculos);
                RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/gestion-vehiculos.jsp");
                dispatcher.forward(request, response);
                break;

            case "crear":
                RequestDispatcher dispatcherCrear = request.getRequestDispatcher("/administrador/crear-vehiculo.jsp");
                dispatcherCrear.forward(request, response);
                break;

            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Vehiculo vehiculoEditar = vehiculoDAO.buscarVehiculoPorId(idEditar);
                request.setAttribute("vehiculo", vehiculoEditar);
                RequestDispatcher dispatcherEditar = request.getRequestDispatcher("/administrador/editar-vehiculo.jsp");
                dispatcherEditar.forward(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                boolean eliminado = vehiculoDAO.eliminarVehiculo(idEliminar);
                if (eliminado) {
                    request.getSession().setAttribute("mensaje", "Vehículo eliminado exitosamente.");
                    request.getSession().setAttribute("tipoMensaje", "success");
                } else {
                    request.getSession().setAttribute("mensaje", "Error al eliminar el vehículo.");
                    request.getSession().setAttribute("tipoMensaje", "danger");
                }
                response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        VehiculoDAO vehiculoDAO = new VehiculoDAO();

        if ("guardar".equals(action)) {
            String placa = request.getParameter("placa");
            String marca = request.getParameter("marca");
            String modelo = request.getParameter("modelo");
            int capacidadKg = Integer.parseInt(request.getParameter("capacidadKg"));

            Vehiculo vehiculo = new Vehiculo();
            vehiculo.setPlaca(placa);
            vehiculo.setMarca(marca);
            vehiculo.setModelo(modelo);
            vehiculo.setCapacidadKg(capacidadKg);

            boolean creado = vehiculoDAO.crearVehiculo(vehiculo);
            if (creado) {
                request.getSession().setAttribute("mensaje", "Vehículo creado exitosamente.");
                request.getSession().setAttribute("tipoMensaje", "success");
            } else {
                request.getSession().setAttribute("mensaje", "Error al crear el vehículo.");
                request.getSession().setAttribute("tipoMensaje", "danger");
            }
            response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");

        } else if ("actualizar".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String placa = request.getParameter("placa");
            String marca = request.getParameter("marca");
            String modelo = request.getParameter("modelo");
            int capacidadKg = Integer.parseInt(request.getParameter("capacidadKg"));

            Vehiculo vehiculo = new Vehiculo();
            vehiculo.setIdVehiculo(id);
            vehiculo.setPlaca(placa);
            vehiculo.setMarca(marca);
            vehiculo.setModelo(modelo);
            vehiculo.setCapacidadKg(capacidadKg);

            boolean actualizado = vehiculoDAO.actualizarVehiculo(vehiculo);
            if (actualizado) {
                request.getSession().setAttribute("mensaje", "Vehículo actualizado exitosamente.");
                request.getSession().setAttribute("tipoMensaje", "success");
            } else {
                request.getSession().setAttribute("mensaje", "Error al actualizar el vehículo.");
                request.getSession().setAttribute("tipoMensaje", "danger");
            }
            response.sendRedirect(request.getContextPath() + "/administrador/VehiculoServlet");
        }
    }
}

