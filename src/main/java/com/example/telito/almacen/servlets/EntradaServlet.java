package com.example.inventario.servlets;

import com.example.inventario.beans.Lote;
import com.example.inventario.beans.Movimiento;
import com.example.inventario.beans.OrdenCompra;
import com.example.inventario.daos.LoteDao;
import com.example.inventario.daos.MovimientoDao;
import com.example.inventario.daos.OrdenCompraDao;

import com.example.inventario.daos.UbicacionDao;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

@WebServlet(name = "EntradaServlet", value = "/EntradaServlet")
public class EntradaServlet extends HttpServlet {

    /**
     * Se encarga de mostrar las páginas: la lista de órdenes o el formulario de recepción.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                // Muestra la lista de órdenes de compra pendientes
                request.setAttribute("listaOrdenes", ordenCompraDao.listarOrdenesPendientes());
                view = request.getRequestDispatcher("entradas/listaOrdenes.jsp");
                view.forward(request, response);
                break;

            case "recibir":
                // Muestra el formulario para recibir una orden específica
                int idOrden = Integer.parseInt(request.getParameter("id"));
                OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);
                request.setAttribute("ordenCompra", oc);
                UbicacionDao ubicacionDao = new UbicacionDao();
                request.setAttribute("listaUbicaciones", ubicacionDao.listar());
                view = request.getRequestDispatcher("entradas/registrarEntrada.jsp");
                view.forward(request, response);
                break;
        }
    }

    /**
     * Procesa los datos del formulario de recepción para crear un nuevo lote.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Se instancian todos los DAOs necesarios
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        try {
            // 1. Se leen los datos del formulario
            int idOrden = Integer.parseInt(request.getParameter("id_orden_compra"));
            String codigoLote = request.getParameter("codigo_lote");
            Date fechaVencimiento = Date.valueOf(request.getParameter("fecha_vencimiento"));
            int idUbicacion = Integer.parseInt(request.getParameter("ubicacion_id"));

            // Se busca la orden de compra original para obtener datos que no vienen en el form
            OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);

            // 2. Se crea el nuevo lote en la base de datos
            Lote nuevoLote = new Lote();
            nuevoLote.setCodigoLote(codigoLote);
            nuevoLote.setStockActual(oc.getCantidad()); // El stock inicial es la cantidad de la orden
            nuevoLote.setFechaVencimiento(fechaVencimiento);
            nuevoLote.setProductoId(oc.getProductoId());
            nuevoLote.setUbicacionId(idUbicacion);
            int nuevoLoteId = loteDao.crearLote(nuevoLote); // El método DAO devuelve el ID del nuevo lote

            // 3. Se registra el movimiento de entrada en el historial
            Movimiento movimiento = new Movimiento();
            movimiento.setLoteId(nuevoLoteId);
            movimiento.setOrdenCompraId(idOrden);
            movimiento.setTipoMovimiento("entrada");
            movimiento.setCantidad(oc.getCantidad());
            movimiento.setMotivo("Recepción de Orden de Compra: "); // Asumiendo que OC tiene este campo
            movimientoDao.registrarMovimiento(movimiento);

            // 4. Se actualiza el estado de la orden de compra a "Recibido"
            ordenCompraDao.actualizarEstado(idOrden, "Recibido");

            // 5. Se redirige a la lista de inventario principal para ver el nuevo lote
            response.sendRedirect(request.getContextPath() + "/LoteServlet");

        } catch (NumberFormatException | NullPointerException e) {
            // Manejo de error si los datos del formulario son inválidos
            // Podrías reenviar al formulario con un mensaje de error
            response.sendRedirect(request.getContextPath() + "/EntradaServlet");
        }
    }
}