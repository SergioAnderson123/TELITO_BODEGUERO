package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.*;
import com.example.telito.almacen.daos.*;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

@WebServlet("/almacen/EntradaServlet")
public class EntradaServlet extends HttpServlet {

    /**
     * El método doGet no necesita cambios.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                int registrosPorPagina = 10;
                String pageStr = request.getParameter("page");
                int paginaActual = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
                int totalRegistros = ordenCompraDao.contarOrdenesPendientes();
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                int offset = (paginaActual - 1) * registrosPorPagina;
                ArrayList<OrdenCompra> listaPaginada = ordenCompraDao.listarOrdenesPaginadas(offset, registrosPorPagina);

                request.setAttribute("listaOrdenes", listaPaginada);
                request.setAttribute("paginaActual", paginaActual);
                request.setAttribute("totalPaginas", totalPaginas);

                view = request.getRequestDispatcher("/almacen/entradas/listaOrdenes.jsp");
                view.forward(request, response);
                break;

            case "recibir":
                int idOrden = Integer.parseInt(request.getParameter("id"));
                OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);
                request.setAttribute("ordenCompra", oc);

                UbicacionDao ubicacionDao = new UbicacionDao();
                request.setAttribute("listaUbicaciones", ubicacionDao.listar());
                DistritoDao distritoDao = new DistritoDao();
                request.setAttribute("listaDistritos", distritoDao.listar());

                view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                view.forward(request, response);
                break;
        }
    }

    /**
     * MÉTODO COMPLETAMENTE MODIFICADO
     * Procesa el formulario para CREAR un nuevo lote y registrar el movimiento.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
        int usuarioId = (usuario != null) ? usuario.getIdUsuario() : 1;

        OrdenCompraDao ordenCompraDao = new OrdenCompraDao();
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        int idOrden = Integer.parseInt(request.getParameter("id_orden_compra"));

        try {
            // 1. Leemos los datos del formulario
            String codigoLote = request.getParameter("codigo_lote");
            String fechaVencimientoStr = request.getParameter("fecha_vencimiento");
            int idUbicacion = Integer.parseInt(request.getParameter("ubicacion_id"));
            int idDistrito = Integer.parseInt(request.getParameter("distrito_id"));

            // Convertimos la fecha del formato del input a un objeto Date de SQL
            SimpleDateFormat formato = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date utilDate = formato.parse(fechaVencimientoStr);
            java.sql.Date fechaVencimientoSQL = new java.sql.Date(utilDate.getTime());

            // 2. Buscamos la orden de compra para obtener la cantidad y el ID del producto
            OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);

            // 3. Creamos el nuevo objeto Lote con todos sus datos
            Lote nuevoLote = new Lote();
            nuevoLote.setCodigoLote(codigoLote);
            nuevoLote.setStockActual(oc.getCantidad());
            nuevoLote.setFechaVencimiento(fechaVencimientoSQL);
            nuevoLote.setProductoId(oc.getProductoId());
            nuevoLote.setUbicacionId(idUbicacion);
            nuevoLote.setDistritoId(idDistrito);
            nuevoLote.setEstado("Registrado"); // <-- Asignamos el estado directamente
            int nuevoLoteId = loteDao.crearLote(nuevoLote);

            // 4. Registramos el movimiento de entrada
            Movimiento movimiento = new Movimiento();
            movimiento.setLoteId(nuevoLoteId);
            movimiento.setUsuarioId(usuarioId);
            movimiento.setOrdenCompraId(idOrden);
            movimiento.setTipoMovimiento("Entrada");
            movimiento.setCantidad(oc.getCantidad());
            movimiento.setMotivo("Recepción de OC: " + oc.getNumeroOrden());
            movimientoDao.registrarMovimiento(movimiento);

            // 5. Actualizamos el estado de la orden a "Recibido"
            ordenCompraDao.actualizarEstado(idOrden, "Recibido");

            // 6. Redirigimos a la lista de inventario para ver el nuevo lote
            response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");

        } catch (Exception e) {
            e.printStackTrace();
            // Si algo falla, volvemos a mostrar el formulario con un mensaje de error
            request.setAttribute("error", "Ocurrió un error. Verifique todos los datos.");
            request.setAttribute("ordenCompra", ordenCompraDao.buscarOrdenPorId(idOrden));
            // (código para reenviar al JSP)
            RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
            view.forward(request, response);
        }
    }
}