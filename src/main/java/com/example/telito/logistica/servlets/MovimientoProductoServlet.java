package com.example.telito.logistica.servlets;

import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.example.telito.logistica.beans.MovimientoInventarioBean;
import com.example.telito.logistica.daos.MovimientoInventarioDao;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet("/MovimientoProductoServlet")
public class MovimientoProductoServlet extends HttpServlet {

    public void doGet(HttpServletRequest request,
                      HttpServletResponse response) throws IOException, ServletException {
        // Verificar que el usuario tenga rol de logística
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederLogistica(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de logística intentó acceder a MovimientoProductoServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        response.setContentType("text/html");

        // Obtener parámetros de búsqueda y filtros
        String busqueda = request.getParameter("busqueda");
        String tipo = request.getParameter("tipo");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");

        // Parámetros de paginación
        int page = 1;
        int size = 5;
        try { 
            page = Integer.parseInt(request.getParameter("page")); 
        } catch (Exception ignored) {}
        try { 
            size = Integer.parseInt(request.getParameter("size")); 
        } catch (Exception ignored) {}
        if (page < 1) page = 1;
        if (size < 1) size = 5;

        // Obtener datos filtrados desde el DAO
        MovimientoInventarioDao movimientoDao = new MovimientoInventarioDao();
        int totalRows = movimientoDao.contarMovimientos(busqueda, tipo, fechaDesde, fechaHasta);
        int totalPages = (int) Math.ceil(totalRows / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        ArrayList<MovimientoInventarioBean> listaMovimientos = movimientoDao.obtenerMovimientos(busqueda, tipo, fechaDesde, fechaHasta, page, size);

        // Contar totales de Entradas y Salidas con los mismos filtros (excepto tipo)
        int totalEntradas = movimientoDao.contarMovimientos(busqueda, "Entrada", fechaDesde, fechaHasta);
        int totalSalidas = movimientoDao.contarMovimientos(busqueda, "Salida", fechaDesde, fechaHasta);
        int totalAjustes = movimientoDao.contarMovimientos(busqueda, "Ajuste", fechaDesde, fechaHasta);

        // Enviar datos a la JSP
        request.setAttribute("listaMovimientos", listaMovimientos);
        request.setAttribute("busqueda", busqueda);
        request.setAttribute("tipoFiltro", tipo);
        request.setAttribute("fechaDesdeFiltro", fechaDesde);
        request.setAttribute("fechaHastaFiltro", fechaHasta);
        request.setAttribute("currentPage", page);
        request.setAttribute("size", size);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRows", totalRows);
        request.setAttribute("totalEntradas", totalEntradas);
        request.setAttribute("totalSalidas", totalSalidas);
        request.setAttribute("totalAjustes", totalAjustes);
        request.setAttribute("baseUrl", request.getContextPath() + "/MovimientoProductoServlet");
        request.setAttribute("itemName", "movimientos");

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