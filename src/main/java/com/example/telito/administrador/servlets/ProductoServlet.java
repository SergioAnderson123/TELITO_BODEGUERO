package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Producto;
import com.example.telito.administrador.daos.ProductoDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "ProductoServlet", value = "/ProductoServlet")
public class ProductoServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "listarInventario" : request.getParameter("action");
        ProductoDAO productoDAO = new ProductoDAO();

        switch (action) {
            case "listarInventario": {
                ArrayList<Producto> listaProductos = productoDAO.listarProductos();
                request.setAttribute("lista", listaProductos);
                RequestDispatcher rd = request.getRequestDispatcher("/administrador/inventario-general.jsp");
                rd.forward(request, response);
                break;
            }
            case "listarStock": {
                ArrayList<Producto> listaProductos = productoDAO.listarProductos();
                request.setAttribute("lista", listaProductos);
                RequestDispatcher rd = request.getRequestDispatcher("/administrador/gestion-stock.jsp");
                rd.forward(request, response);
                break;
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "" : request.getParameter("action");
        ProductoDAO productoDAO = new ProductoDAO();

        if ("guardarStock".equals(action)) {

            String[] productoIds = request.getParameterValues("productoId");

            if (productoIds != null) {
                for (String idStr : productoIds) {
                    try {
                        int productoId = Integer.parseInt(idStr);
                        String stockMinimoStr = request.getParameter("stockMinimo_" + productoId);
                        int stockMinimo = Integer.parseInt(stockMinimoStr);
                        productoDAO.actualizarStockMinimo(productoId, stockMinimo);
                    } catch (NumberFormatException e) {
                        System.out.println("Error al procesar el producto con ID: " + idStr);
                        e.printStackTrace();
                    }
                }
            }
            response.sendRedirect(request.getContextPath() + "/ProductoServlet?action=listarStock");
        }
    }
}