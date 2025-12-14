package com.example.telito.administrador.servlets;

import com.example.telito.logistica.beans.InventarioBean;
import com.example.telito.logistica.daos.InventarioDao;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.LoteDao;
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

// Vista consolidada de inventario desde todas las perspectivas (Logística, Almacén, Productores)
@WebServlet(name = "InventarioGeneralServlet", value = "/administrador/inventario-general")
public class InventarioGeneralServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a InventarioGeneralServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        // Inventario desde perspectiva de Logística (agrupado por producto)
        InventarioDao inventarioDao = new InventarioDao();
        ArrayList<InventarioBean> listaLogistica = inventarioDao.obtenerInventarioAgrupado(null, null, 1, 100);
        request.setAttribute("listaLogistica", listaLogistica);

        // Inventario desde perspectiva de Almacén (lotes registrados)
        LoteDao loteDao = new LoteDao();
        ArrayList<Lote> listaAlmacen = loteDao.listarLotesRegistrados(1);
        request.setAttribute("listaAlmacen", listaAlmacen);

        // Inventario desde perspectiva de Productores (productos activos)
        ProductoDAO productoDao = new ProductoDAO();
        ArrayList<Producto> listaProductores = productoDao.listarProductos();
        request.setAttribute("listaProductores", listaProductores);

        RequestDispatcher rd = request.getRequestDispatcher("/administrador/inventario-general.jsp");
        rd.forward(request, response);
    }
}
