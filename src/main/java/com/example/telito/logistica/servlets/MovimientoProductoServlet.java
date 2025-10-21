package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.MovimientoInventarioBean;
import com.example.telito.logistica.daos.MovimientoInventarioDao;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet("/MovimientoProductoServlet")
public class MovimientoProductoServlet extends HttpServlet {

    public void doGet(HttpServletRequest request,
                      HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("text/html");

        // Obtener parámetros de búsqueda y filtros
        String busqueda = request.getParameter("busqueda");
        String tipo = request.getParameter("tipo");
        String periodo = request.getParameter("periodo");

        // Obtener datos filtrados directamente desde el DAO
        MovimientoInventarioDao movimientoDao = new MovimientoInventarioDao();
        ArrayList<MovimientoInventarioBean> listaMovimientos = movimientoDao.obtenerMovimientos(busqueda, tipo, periodo);

        // Enviar datos a la JSP
        request.setAttribute("listaMovimientos", listaMovimientos);

        // Forward a la JSP
        String vista = "/logistica/MovimientoProducto/product-movement.jsp";
        RequestDispatcher rd = request.getRequestDispatcher(vista);
        rd.forward(request, response);
    }

    public void doPost(HttpServletRequest request,
                       HttpServletResponse response) throws IOException, ServletException {
        // Por ahora solo manejamos GET para mostrar datos
        // POST se puede implementar después para agregar nuevos movimientos
        doGet(request, response);
    }
}