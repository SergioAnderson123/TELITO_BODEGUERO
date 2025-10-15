package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.OrdenCompraBean;
import com.example.telito.logistica.daos.OrdenCompraDao;
import com.example.telito.logistica.daos.ProductoDao;
import com.example.telito.logistica.daos.ProveedorDao;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "OrdenCompraServlet", value = "/orden-compra")
public class OrdenCompraServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");

        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        ProductoDao productoDao = new ProductoDao();
        ProveedorDao proveedorDao = new ProveedorDao();
        RequestDispatcher rd;

        switch (action) {
            case "listar":
                // === SECCIÓN MODIFICADA PARA MANEJAR FILTROS ===

                // 1. Leemos los parámetros del formulario de búsqueda
                String busqueda = request.getParameter("busqueda");
                String proveedorId = request.getParameter("proveedor");
                String estado = request.getParameter("estado");

                // 2. Obtenemos la lista de órdenes (ahora filtrada)
                //    Pasamos los filtros al método del DAO
                ArrayList<OrdenCompraBean> listaOrdenes = ordenCompraDao.obtenerOrdenes(busqueda, proveedorId, estado);

                // 3. Obtenemos la lista de proveedores para el menú del filtro
                request.setAttribute("listaProveedores", proveedorDao.listarProveedores());

                // 4. Enviamos la lista de órdenes filtrada a la vista
                request.setAttribute("listaOrdenes", listaOrdenes);

                rd = request.getRequestDispatcher("/logistica/OrdenLista/purchase-order.jsp");
                rd.forward(request, response);
                break;

            case "crear":
                request.setAttribute("listaProductos", productoDao.listarProductos());
                request.setAttribute("listaProveedores", proveedorDao.listarProveedores());
                rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                rd.forward(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // (El método doPost para guardar no cambia)
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();

        if ("guardar".equals(action)) {
            int proveedorId = Integer.parseInt(request.getParameter("proveedor_id"));
            int productoId = Integer.parseInt(request.getParameter("producto_id"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            double montoTotal = Double.parseDouble(request.getParameter("monto_total"));

            int usuarioId = 1;
            // dejamos que DB genere id y nosotros mostraremos OC### en la vista
            ordenCompraDao.crearOrdenCompra(null, proveedorId, productoId, cantidad, usuarioId, montoTotal);
            response.sendRedirect(request.getContextPath() + "/orden-compra");
        } else {
            doGet(request, response);
        }
    }
}