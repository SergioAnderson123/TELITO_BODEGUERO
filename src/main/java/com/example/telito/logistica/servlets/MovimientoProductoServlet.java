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

@WebServlet(name = "MovimientoProductoServlet", value = "/MovimientoProductoServlet")
public class MovimientoProductoServlet extends HttpServlet {

    public void doGet(HttpServletRequest request,
                      HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("text/html");

        // Obtener datos dinámicos de la BD telito_bodeguero
        MovimientoInventarioDao movimientoDao = new MovimientoInventarioDao();
        ArrayList<MovimientoInventarioBean> listaMovimientos = movimientoDao.obtenerMovimientos();

        // Enviar datos a la JSP
        request.setAttribute("listaMovimientos", listaMovimientos);

        // Forward a la JSP que mantiene el diseño
// LÍNEA CORREGIDA
        String vista = "/MovimientoProducto/product-movement.jsp";        RequestDispatcher rd = request.getRequestDispatcher(vista);
        rd.forward(request, response);
    }

    public void doPost(HttpServletRequest request,
                       HttpServletResponse response) throws IOException, ServletException {
        // Por ahora solo manejamos GET para mostrar datos
        // POST se puede implementar después para agregar nuevos movimientos
        doGet(request, response);
    }
}