package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.almacen.beans.Usuario;
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao;
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

        LoteDao loteDao = new LoteDao();
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");

        switch (action) {
            case "lista":
                // --- INICIO DE LA MODIFICACIÓN ---
                String pageStr = request.getParameter("page");
                int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);

                // Se llaman a los nuevos métodos del DAO que filtran por estado "Registrado"
                ArrayList<Lote> listaLotes = loteDao.listarLotesRegistrados(page);
                int totalRegistros = loteDao.contarTotalLotesRegistrados();
                // --- FIN DE LA MODIFICACIÓN ---

                int registrosPorPagina = 10;
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);

                request.setAttribute("listaLotes", listaLotes);
                request.setAttribute("paginaActual", page);
                request.setAttribute("totalPaginas", totalPaginas);

                RequestDispatcher view = request.getRequestDispatcher("/almacen/lotes/gestionarStock.jsp");
                view.forward(request, response);
                break;

            case "ajustar":
                // Esta parte no necesita cambios
                int idLote = Integer.parseInt(request.getParameter("id"));
                Lote lote = loteDao.buscarLotePorId(idLote);

                if (lote != null) {
                    request.setAttribute("lote", lote);
                    RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/lotes/ajustarInventario.jsp");
                    dispatcher.forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                }
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

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

                HttpSession session = request.getSession();
                Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
                int usuarioId = (usuario != null) ? usuario.getIdUsuario() : 1;

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