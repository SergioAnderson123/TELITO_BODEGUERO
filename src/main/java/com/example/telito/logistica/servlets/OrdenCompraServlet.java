package com.example.telito.logistica.servlets;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.example.telito.logistica.beans.OrdenCompraBean;
import com.example.telito.logistica.beans.ProductoBean;
import com.example.telito.logistica.beans.DistritoBean;
import com.example.telito.logistica.daos.OrdenCompraDao;
import com.example.telito.logistica.daos.ProductoDao;
import com.example.telito.logistica.daos.ProveedorDao;
import com.example.telito.logistica.daos.ZonaDao;
import com.example.telito.logistica.daos.DistritoDao;

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
                request.setAttribute("listaProductores", proveedorDao.listarProductores());
                ZonaDao zonaDao = new ZonaDao();
                request.setAttribute("listaZonas", zonaDao.listarZonas());
                rd = request.getRequestDispatcher("/logistica/OrdenLista/form_orden_compra.jsp");
                rd.forward(request, response);
                break;
                
            case "obtenerProductosPorProductor":
                // Endpoint JSON: obtener productos de un productor
                int productorId = Integer.parseInt(request.getParameter("productorId"));
                ArrayList<ProductoBean> productos = productoDao.listarProductosPorProductor(productorId);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                // Construir JSON manualmente
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < productos.size(); i++) {
                    ProductoBean p = productos.get(i);
                    if (i > 0) json.append(",");
                    json.append("{")
                        .append("\"id\":").append(p.getId()).append(",")
                        .append("\"nombre\":\"").append(p.getNombre().replace("\"", "\\\"")).append("\",")
                        .append("\"precio\":").append(p.getPrecio())
                        .append("}");
                }
                json.append("]");
                
                response.getWriter().write(json.toString());
                return;
                
            case "obtenerDistritosPorZona":
                // Endpoint JSON: obtener distritos de una zona
                int zonaId = Integer.parseInt(request.getParameter("zonaId"));
                DistritoDao distritoDao = new DistritoDao();
                ArrayList<DistritoBean> distritos = distritoDao.listarDistritosPorZona(zonaId);
                
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                // Construir JSON manualmente
                StringBuilder jsonDistritos = new StringBuilder("[");
                for (int i = 0; i < distritos.size(); i++) {
                    DistritoBean d = distritos.get(i);
                    if (i > 0) jsonDistritos.append(",");
                    jsonDistritos.append("{")
                        .append("\"id\":").append(d.getId()).append(",")
                        .append("\"nombre\":\"").append(d.getNombre().replace("\"", "\\\"")).append("\"")
                        .append("}");
                }
                jsonDistritos.append("]");
                
                response.getWriter().write(jsonDistritos.toString());
                return;
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
            int productorId = Integer.parseInt(request.getParameter("productor_id"));
            int productoId = Integer.parseInt(request.getParameter("producto_id"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));
            int distritoId = Integer.parseInt(request.getParameter("distrito_id"));
            double montoTotal = Double.parseDouble(request.getParameter("monto_total"));

            // Obtener el usuario de la sesión (logística)
            com.example.telito.administrador.beans.Usuario usuario = 
                (com.example.telito.administrador.beans.Usuario) request.getSession().getAttribute("usuario");
            int usuarioId = usuario != null ? usuario.getIdUsuario() : 1;
            
            // Guardar la orden de compra
            ordenCompraDao.crearOrdenCompra(null, productorId, productoId, cantidad, usuarioId, montoTotal, distritoId);
            response.sendRedirect(request.getContextPath() + "/orden-compra");
        } else {
            doGet(request, response);
        }
    }
}