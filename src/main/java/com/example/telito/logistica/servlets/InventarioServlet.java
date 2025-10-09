package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.InventarioBean;
import com.example.telito.logistica.daos.InventarioDao;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "InventarioServlet", value = "/InventarioServlet")
public class InventarioServlet extends HttpServlet {

    public void doGet(HttpServletRequest request,
                      HttpServletResponse response) throws IOException, ServletException {
        response.setContentType("text/html");

        // Obtener datos dinámicos de la BD telito_bodeguero - tabla lotes
        InventarioDao inventarioDao = new InventarioDao();
        ArrayList<InventarioBean> listaInventario = inventarioDao.obtenerInventario();

        // Enviar datos a la JSP
        request.setAttribute("listaInventario", listaInventario);

        // Forward a la JSP que mantiene el diseño idéntico
        // LÍNEA CORREGIDA
        String vista = "/Inventario/inventario.jsp";
        RequestDispatcher rd = request.getRequestDispatcher(vista);
        rd.forward(request, response);
    }

    public void doPost(HttpServletRequest request,
                       HttpServletResponse response) throws IOException, ServletException {
        // Por ahora solo manejamos GET para mostrar datos
        // POST se puede implementar después para actualizar stock o agregar lotes
        doGet(request, response);
    }
}