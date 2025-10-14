package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.*; // Importa todos tus beans
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao;
import com.example.telito.almacen.daos.PedidoDao;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Importante para obtener el usuario

import java.io.IOException;
import java.util.ArrayList;

@WebServlet("/almacen/PedidoServlet")
public class PedidoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- TU MÉTODO doGet ESTÁ PERFECTO, NO NECESITA CAMBIOS ---
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        PedidoDao pedidoDao = new PedidoDao();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                int registrosPorPagina = 10;
                String pageStr = request.getParameter("page");
                int paginaActual = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
                int totalRegistros = pedidoDao.contarPedidos();
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                int offset = (paginaActual - 1) * registrosPorPagina;
                ArrayList<Pedido> listaPaginada = pedidoDao.listarPedidosPaginados(offset, registrosPorPagina);

                request.setAttribute("listaPedidos", listaPaginada);
                request.setAttribute("paginaActual", paginaActual);
                request.setAttribute("totalPaginas", totalPaginas);

                view = request.getRequestDispatcher("/almacen/pedidos/listaPedidos.jsp");
                view.forward(request, response);
                break;

            case "preparar":
                int idPedido = Integer.parseInt(request.getParameter("id"));
                Pedido pedido = pedidoDao.buscarPedidoPorId(idPedido);

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
     * MÉTODO COMPLETAMENTE IMPLEMENTADO
     * Procesa el formulario de "Finalizar preparación", descuenta el stock y registra los movimientos.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtenemos el usuario de la sesión para registrar quién hizo el movimiento
        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
        int usuarioId = (usuario != null) ? usuario.getIdUsuario() : 1; // Usamos 1 como fallback si no hay sesión

        // Instanciamos los DAOs
        PedidoDao pedidoDao = new PedidoDao();
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        int idPedido = Integer.parseInt(request.getParameter("id_pedido"));

        // Volvemos a buscar el pedido para tener la información completa de sus items
        Pedido pedido = pedidoDao.buscarPedidoPorId(idPedido);

        if (pedido != null) {
            boolean stockSuficiente = true;

            // --- PASO 1: BUCLE DE VERIFICACIÓN ---
            // Primero, revisamos que todo esté en orden antes de hacer cambios en la BD.
            for (PedidoItem item : pedido.getItems()) {
                // Leemos el ID del lote que el usuario seleccionó para este producto
                String idLoteSeleccionadoStr = request.getParameter("lote_seleccionado_" + item.getProductoId());

                if (idLoteSeleccionadoStr == null || idLoteSeleccionadoStr.isEmpty()) {
                    stockSuficiente = false;
                    request.setAttribute("error", "Debe seleccionar un lote para el producto: " + item.getNombreProducto());
                    break;
                }

                int idLote = Integer.parseInt(idLoteSeleccionadoStr);
                Lote lote = loteDao.buscarLotePorId(idLote);

                if (lote == null || lote.getStockActual() < item.getCantidadRequerida()) {
                    stockSuficiente = false;
                    request.setAttribute("error", "Stock insuficiente en el lote seleccionado para: " + item.getNombreProducto());
                    break;
                }
            }

            // --- PASO 2: EJECUCIÓN ---
            // Si todas las verificaciones pasaron, procedemos a actualizar la base de datos.
            if (stockSuficiente) {
                for (PedidoItem item : pedido.getItems()) {
                    int idLote = Integer.parseInt(request.getParameter("lote_seleccionado_" + item.getProductoId()));
                    Lote lote = loteDao.buscarLotePorId(idLote);

                    int nuevoStock = lote.getStockActual() - item.getCantidadRequerida();

                    // 1. Actualizamos el stock del lote
                    loteDao.actualizarStock(idLote, nuevoStock);

                    // 2. Registramos el movimiento de salida
                    Movimiento movimiento = new Movimiento();
                    movimiento.setLoteId(idLote);
                    movimiento.setPedidoId(idPedido);
                    movimiento.setUsuarioId(usuarioId); // Guardamos quién hizo el despacho
                    movimiento.setTipoMovimiento("Salida");
                    movimiento.setCantidad(item.getCantidadRequerida());
                    movimiento.setMotivo("Pedido cliente"); // Motivo estandarizado
                    movimientoDao.registrarMovimiento(movimiento);
                }

                // 3. Actualizamos el estado del pedido a "Despachado"
                pedidoDao.actualizarEstado(idPedido, "Despachado");

                // 4. Redirigimos a la lista de pedidos
                response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
            } else {
                // Si hubo un error, volvemos a cargar la página de preparación mostrando el mensaje de error
                request.setAttribute("pedido", pedidoDao.buscarPedidoPorId(idPedido));
                RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/pedidos/prepararPedido.jsp");
                dispatcher.forward(request, response);
            }
        } else {
            // Si por alguna razón el pedido no se encuentra, volvemos a la lista
            response.sendRedirect(request.getContextPath() + "/almacen/PedidoServlet");
        }
    }
}