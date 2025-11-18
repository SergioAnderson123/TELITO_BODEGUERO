package com.example.telito.almacen.servlets;

import com.example.telito.administrador.beans.Producto;
import com.example.telito.administrador.daos.ProductoDAO;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;

/**
 * Servlet para que almacén pueda ver productos (acceso limitado - solo lectura).
 * Almacén NO puede crear, editar o eliminar productos, solo consultarlos.
 */
@WebServlet("/almacen/ProductoAlmacenServlet")
public class ProductoAlmacenServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a ProductoAlmacenServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "listar";
        }
        
        ProductoDAO productoDAO = new ProductoDAO();
        
        switch (action) {
            case "listar":
                // Listar productos (solo lectura)
                String busqueda = request.getParameter("busqueda");
                ArrayList<Producto> listaProductos = productoDAO.listarProductos();
                
                // Filtrar por búsqueda si existe
                if (busqueda != null && !busqueda.trim().isEmpty()) {
                    String busquedaLower = busqueda.toLowerCase();
                    ArrayList<Producto> productosFiltrados = new ArrayList<>();
                    for (Producto p : listaProductos) {
                        if (p.getNombre().toLowerCase().contains(busquedaLower) ||
                            p.getCodigoSku().toLowerCase().contains(busquedaLower) ||
                            (p.getDescripcion() != null && p.getDescripcion().toLowerCase().contains(busquedaLower))) {
                            productosFiltrados.add(p);
                        }
                    }
                    listaProductos = productosFiltrados;
                }
                
                request.setAttribute("listaProductos", listaProductos);
                request.setAttribute("busqueda", busqueda);
                RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/productos/listaProductos.jsp");
                dispatcher.forward(request, response);
                break;
                
            case "ver":
                // Ver detalles de un producto (solo lectura)
                try {
                    int productoId = Integer.parseInt(request.getParameter("id"));
                    // Obtener producto de la lista (ya que no hay método obtenerPorId en ProductoDAO)
                    ArrayList<Producto> todosProductos = productoDAO.listarProductos();
                    Producto producto = null;
                    for (Producto p : todosProductos) {
                        if (p.getIdProducto() == productoId) {
                            producto = p;
                            break;
                        }
                    }
                    
                    if (producto != null) {
                        request.setAttribute("producto", producto);
                        RequestDispatcher view = request.getRequestDispatcher("/almacen/productos/verProducto.jsp");
                        view.forward(request, response);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/almacen/ProductoAlmacenServlet");
                    }
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/almacen/ProductoAlmacenServlet");
                }
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/almacen/ProductoAlmacenServlet");
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Almacén NO puede crear, editar o eliminar productos
        // Redirigir a la lista
        response.sendRedirect(request.getContextPath() + "/almacen/ProductoAlmacenServlet");
    }
}

