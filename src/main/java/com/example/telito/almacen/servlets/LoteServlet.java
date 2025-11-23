package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.almacen.beans.Usuario;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao;
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

@WebServlet("/almacen/LoteServlet")
public class LoteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a LoteServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        LoteDao loteDao = new LoteDao();
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");

        switch (action) {
            case "lista":
                // Parámetros de paginación
                String pageStr = request.getParameter("page");
                int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
                if (page < 1) page = 1;

                // Parámetros de filtros
                String busqueda = request.getParameter("busqueda");
                String estado = request.getParameter("estado");

                // Se llaman a los métodos del DAO con filtros
                ArrayList<Lote> listaLotes = loteDao.listarLotesRegistrados(page, busqueda, estado);
                int totalRegistros = loteDao.contarTotalLotesRegistrados(busqueda, estado);

                int registrosPorPagina = 10;
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                if (totalPaginas == 0) totalPaginas = 1;
                if (page > totalPaginas) page = totalPaginas;

                request.setAttribute("listaLotes", listaLotes);
                request.setAttribute("currentPage", page);
                request.setAttribute("size", registrosPorPagina);
                request.setAttribute("totalPages", totalPaginas);
                request.setAttribute("totalRows", totalRegistros);
                request.setAttribute("baseUrl", request.getContextPath() + "/almacen/LoteServlet");
                request.setAttribute("itemName", "lotes");
                request.setAttribute("busqueda", busqueda);
                request.setAttribute("estadoFiltro", estado);

                RequestDispatcher view = request.getRequestDispatcher("/almacen/lotes/gestionarStock.jsp");
                view.forward(request, response);
                break;

            case "ajustar":
                int idLote = Integer.parseInt(request.getParameter("id"));
                Lote lote = loteDao.buscarLotePorId(idLote);

                if (lote != null) {
                    // Obtener historial de ajustes para este lote
                    MovimientoDao movimientoDao = new MovimientoDao();
                    ArrayList<com.example.telito.almacen.beans.Movimiento> historialAjustes = 
                        movimientoDao.listarAjustesPorLote(idLote);
                    
                    request.setAttribute("lote", lote);
                    request.setAttribute("historialAjustes", historialAjustes);
                    RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/lotes/ajustarInventario.jsp");
                    dispatcher.forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                }
                break;
                
            case "obtenerResumenLotes":
                // Endpoint para obtener resumen de lotes por producto (AJAX)
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                
                try {
                    int productoId = Integer.parseInt(request.getParameter("productoId"));
                    ArrayList<Object[]> resumenLotes = loteDao.obtenerResumenLotesPorProducto(productoId);
                    
                    // Construir JSON
                    StringBuilder json = new StringBuilder();
                    json.append("{\"success\": true, \"lotes\": [");
                    
                    for (int i = 0; i < resumenLotes.size(); i++) {
                        Object[] loteData = resumenLotes.get(i);
                        if (i > 0) json.append(",");
                        json.append("{");
                        json.append("\"idLote\": ").append(loteData[0]).append(",");
                        json.append("\"codigoLote\": \"").append(loteData[1]).append("\",");
                        json.append("\"stockActual\": ").append(loteData[2]).append(",");
                        String fecha = loteData[3] != null ? loteData[3].toString() : "";
                        json.append("\"fechaVencimiento\": ").append(fecha.isEmpty() ? "null" : "\"" + fecha + "\"").append(",");
                        json.append("\"unidadesPorPaquete\": ").append(loteData[4]).append(",");
                        json.append("\"paquetes\": ").append(loteData[5]);
                        json.append("}");
                    }
                    
                    json.append("]}");
                    response.getWriter().write(json.toString());
                    
                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"success\": false, \"message\": \"Error al obtener resumen de lotes\"}");
                }
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que el usuario tenga rol de almacenero
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a LoteServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        // Tu método doPost para "guardarAjuste" ya está correcto y no necesita cambios.
        String action = request.getParameter("action");
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        switch (action) {
            case "guardarAjuste":
                int idLote = Integer.parseInt(request.getParameter("idLote"));
                int stockOriginal = Integer.parseInt(request.getParameter("stockActual"));
                int cantidadContada = Integer.parseInt(request.getParameter("cantidadContada"));
                String motivoAjuste = request.getParameter("motivo");

                // La sesión ya fue obtenida en la verificación de autorización arriba
                com.example.telito.administrador.beans.Usuario usuarioSesion = 
                    (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                int usuarioId = (usuarioSesion != null) ? usuarioSesion.getIdUsuario() : 1;

                int diferencia = cantidadContada - stockOriginal;

                if (diferencia != 0) {
                    String tipoMovimiento = (diferencia > 0) ? "Entrada" : "Salida";

                    Movimiento movimiento = new Movimiento();
                    movimiento.setLoteId(idLote);
                    movimiento.setUsuarioId(usuarioId);
                    movimiento.setTipoMovimiento(tipoMovimiento);
                    movimiento.setCantidad(Math.abs(diferencia));
                    movimiento.setMotivo("Ajuste de inventario: " + motivoAjuste);
                    movimiento.setPedidoId(null);
                    movimiento.setOrdenCompraId(null);

                    movimientoDao.registrarMovimiento(movimiento);
                    loteDao.actualizarStock(idLote, cantidadContada);
                }

                response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                break;
        }
    }
}