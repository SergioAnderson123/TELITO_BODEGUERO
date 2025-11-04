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

        // Obtener parámetros de búsqueda y filtros
        String busqueda = request.getParameter("busqueda");
        String estado = request.getParameter("estado");

        // Parámetros de paginación
        int page = 1;
        int size = 10;
        try { 
            page = Integer.parseInt(request.getParameter("page")); 
        } catch (Exception ignored) {}
        try { 
            size = Integer.parseInt(request.getParameter("size")); 
        } catch (Exception ignored) {}
        if (page < 1) page = 1;
        if (size < 1) size = 10;

        // Obtener datos agrupados por producto desde el DAO
        InventarioDao inventarioDao = new InventarioDao();
        int totalRows = inventarioDao.contarInventarioAgrupado(busqueda, estado);
        int totalPages = (int) Math.ceil(totalRows / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;
        
        ArrayList<InventarioBean> listaInventario = inventarioDao.obtenerInventarioAgrupado(busqueda, estado, page, size);

        // Enviar datos a la JSP
        request.setAttribute("listaInventario", listaInventario);
        request.setAttribute("busqueda", busqueda);
        request.setAttribute("estadoFiltro", estado);
        request.setAttribute("currentPage", page);
        request.setAttribute("size", size);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("baseUrl", request.getContextPath() + "/InventarioServlet");
        request.setAttribute("itemName", "productos");

        // Forward a la JSP
        String vista = "/logistica/Inventario/inventario.jsp";
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