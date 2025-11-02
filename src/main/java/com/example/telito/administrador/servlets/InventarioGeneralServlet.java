package com.example.telito.administrador.servlets;

import com.example.telito.logistica.beans.InventarioBean;
import com.example.telito.logistica.daos.InventarioDao;
import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.LoteDao;
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

@WebServlet(name = "InventarioGeneralServlet", value = "/administrador/inventario-general")
public class InventarioGeneralServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Logística (inventario agrupado por producto)
        InventarioDao inventarioDao = new InventarioDao();
        ArrayList<InventarioBean> listaLogistica = inventarioDao.obtenerInventarioAgrupado(null, null, 1, 100);
        request.setAttribute("listaLogistica", listaLogistica);

        // Almacén (primer página de lotes registrados)
        LoteDao loteDao = new LoteDao();
        ArrayList<Lote> listaAlmacen = loteDao.listarLotesRegistrados(1);
        request.setAttribute("listaAlmacen", listaAlmacen);

        // Productores (todos los productos activos)
        ProductoDAO productoDao = new ProductoDAO();
        ArrayList<Producto> listaProductores = productoDao.listarProductos();
        request.setAttribute("listaProductores", listaProductores);

        RequestDispatcher rd = request.getRequestDispatcher("/administrador/inventario-general.jsp");
        rd.forward(request, response);
    }
}
