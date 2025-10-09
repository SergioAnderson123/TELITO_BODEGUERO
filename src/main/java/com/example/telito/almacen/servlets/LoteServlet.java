package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.daos.LoteDao;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// Esta anotación mapea el servlet a la URL /LoteServlet
@WebServlet("/almacen/LoteServlet")
public class LoteServlet extends HttpServlet {

    // El método doGet se encarga de MOSTRAR las páginas
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Se crea una instancia del DAO para poder usar sus métodos
        LoteDao loteDao = new LoteDao();
        // Se lee el parámetro 'action' de la URL. Si no existe, se asume "lista".
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");

        switch (action) {
            case "lista":
                // 1. Obtener la lista de lotes del DAO
                request.setAttribute("listaLotes", loteDao.listarLotes());
                // 2. Enviar los datos al JSP para que los muestre
                RequestDispatcher view = request.getRequestDispatcher("/almacen/lotes/gestionarStock.jsp");
                view.forward(request, response);
                break;

            case "ajustar":
                // 1. Obtener el ID del lote desde la URL
                int idLote = Integer.parseInt(request.getParameter("id"));
                // 2. Pedirle al DAO los datos de ESE lote específico
                Lote lote = loteDao.buscarLotePorId(idLote);

                if (lote != null) {
                    // 3. Guardar el lote encontrado en el request
                    request.setAttribute("loteAjustar", lote);
                    // 4. Enviar al usuario al formulario de ajuste
                    RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/lotes/ajustar.jsp");
                    dispatcher.forward(request, response);
                } else {
                    // Si no se encuentra un lote con ese ID, se redirige a la lista
                    response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                }
                break;
        }
    }

    // El método doPost se encarga de RECIBIR DATOS de los formularios
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Leer los parámetros que vienen del formulario de ajustar.jsp
        int idLote = Integer.parseInt(request.getParameter("id_lote"));
        int nuevoStock = Integer.parseInt(request.getParameter("stock_actual"));

        // 2. Llamar al DAO para que ejecute el UPDATE en la base de datos
        LoteDao loteDao = new LoteDao();
        loteDao.actualizarStock(idLote, nuevoStock);

        // 3. Redirigir al usuario de vuelta al servlet (esto ejecutará el doGet de nuevo)
        response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
    }
}

