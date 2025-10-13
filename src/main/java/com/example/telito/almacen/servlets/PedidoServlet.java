package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.almacen.beans.Pedido;
import com.example.telito.almacen.beans.PedidoItem;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao;
import com.example.telito.almacen.daos.PedidoDao;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;

@WebServlet("/almacen/PedidoServlet")

public class PedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        PedidoDao pedidoDao = new PedidoDao();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                // 1. Definir registros por página
                int registrosPorPagina = 10;

                // 2. Obtener la página actual desde el parámetro URL (default: 1)
                String pageStr = request.getParameter("page");
                int paginaActual = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);

                // 3. Calcular el total de páginas
                int totalRegistros = pedidoDao.contarPedidos();
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);

                // 4. Calcular el OFFSET para la consulta
                int offset = (paginaActual - 1) * registrosPorPagina;

                // 5. Obtener la lista paginada desde el DAO
                ArrayList<Pedido> listaPaginada = pedidoDao.listarPedidosPaginados(offset, registrosPorPagina);

                // 6. Enviar todos los datos necesarios al JSP
                request.setAttribute("listaPedidos", listaPaginada);
                request.setAttribute("paginaActual", paginaActual);
                request.setAttribute("totalPaginas", totalPaginas);

                view = request.getRequestDispatcher("/almacen/pedidos/listaPedidos.jsp");
                view.forward(request, response);
                break;

            case "preparar":
                int idPedido = Integer.parseInt(request.getParameter("id"));
                Pedido pedido = pedidoDao.buscarPedidoPorId(idPedido);

                // ----- LÍNEAS DE DEPURACIÓN -----
                System.out.println("--- Depurando PedidoServlet ---");
                System.out.println("Buscando items para el pedido ID: " + idPedido);
                if (pedido != null) {
                    System.out.println("Items encontrados en la base de datos: " + pedido.getItems().size());
                } else {
                    System.out.println("¡No se encontró el pedido con ese ID!");
                }

                if (pedido != null) {
                    request.setAttribute("pedido", pedido);
                    view = request.getRequestDispatcher("/almacen/pedidos/prepararPedido.jsp");
                    view.forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
                }
                break;
        }
    }

    /**
     * Este método se encarga de PROCESAR el formulario de "Finalizar preparación".
     * Descuenta el stock y registra el movimiento.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        PedidoDao pedidoDao = new PedidoDao();
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        int idPedido = Integer.parseInt(request.getParameter("id_pedido"));
        Pedido pedido = pedidoDao.buscarPedidoPorId(idPedido);

        if (pedido != null) {
            boolean stockSuficiente = true;

            // --- BUCLE DE VERIFICACIÓN (ahora lee la selección del usuario) ---
            for (PedidoItem item : pedido.getItems()) {
                // CAMBIO: Leemos el ID del lote que el usuario seleccionó en el formulario
                String idLoteSeleccionadoStr = request.getParameter("lote_seleccionado_" + item.getProductoId());

                // Verificamos si se seleccionó una opción para este producto
                if (idLoteSeleccionadoStr == null) {
                    stockSuficiente = false;
                    request.setAttribute("error", "Debe seleccionar un lote para el producto: " + item.getNombreProducto());
                    break; // Salimos del bucle si falta una selección
                }

                int idLote = Integer.parseInt(idLoteSeleccionadoStr);
                Lote lote = loteDao.buscarLotePorId(idLote);

                // La validación de stock sigue siendo la misma
                if (lote == null || lote.getStockActual() < item.getCantidadRequerida()) {
                    stockSuficiente = false;
                    request.setAttribute("error", "No hay stock suficiente en el lote seleccionado para: " + item.getNombreProducto());
                    break; // Salimos del bucle si no hay stock
                }
            }

            // --- Si todas las verificaciones pasaron, procedemos a despachar ---
            if (stockSuficiente) {
                for (PedidoItem item : pedido.getItems()) {
                    // CAMBIO: Leemos de nuevo la selección para asegurar consistencia
                    int idLote = Integer.parseInt(request.getParameter("lote_seleccionado_" + item.getProductoId()));
                    Lote lote = loteDao.buscarLotePorId(idLote);

                    int nuevoStock = lote.getStockActual() - item.getCantidadRequerida();

                    // 1. Actualizamos el stock del LOTE SELECCIONADO
                    loteDao.actualizarStock(idLote, nuevoStock);

                    // 2. Registramos el movimiento
                    Movimiento movimiento = new Movimiento();
                    movimiento.setLoteId(idLote);
                    movimiento.setPedidoId(idPedido);
                    movimiento.setTipoMovimiento("Salida");
                    movimiento.setCantidad(item.getCantidadRequerida());
                    movimiento.setMotivo("Despacho de pedido: " + pedido.getNumeroPedido());
                    movimientoDao.registrarMovimiento(movimiento);
                }

                // 3. Actualizamos el estado del pedido
                pedidoDao.actualizarEstado(idPedido, "Despachado");

                // 4. Redirigimos a la lista principal
                response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
            } else {
                // Si hubo un error de stock o selección, reenviamos al formulario
                request.setAttribute("pedido", pedidoDao.buscarPedidoPorId(idPedido)); // Re-cargamos los datos del pedido
                RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/pedidos/prepararPedido.jsp");
                dispatcher.forward(request, response);
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
        }
    }

}