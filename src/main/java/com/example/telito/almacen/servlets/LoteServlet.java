package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Movimiento; // Importar Movimiento
import com.example.telito.almacen.beans.Usuario; // Importar Usuario
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao; // Importar MovimientoDao
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Importar HttpSession

import java.io.IOException;
import java.util.ArrayList;

@WebServlet("/almacen/LoteServlet")
public class LoteServlet extends HttpServlet {

    // El método doGet se encarga de MOSTRAR las páginas (SIN CAMBIOS)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LoteDao loteDao = new LoteDao();
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");

        switch (action) {
            case "lista":
                // Esta lógica de paginación está correcta
                String pageStr = request.getParameter("page");
                int page = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);

                ArrayList<Lote> listaLotes = loteDao.listarLotes(page); // Asumiendo que este método existe
                int totalRegistros = loteDao.contarTotalLotes(); // Asumiendo que este método existe

                int registrosPorPagina = 10;
                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);

                request.setAttribute("listaLotes", listaLotes);
                request.setAttribute("paginaActual", page);
                request.setAttribute("totalPaginas", totalPaginas);

                RequestDispatcher view = request.getRequestDispatcher("/almacen/lotes/gestionarStock.jsp");
                view.forward(request, response);
                break;

            case "ajustar":
                // Esta lógica para mostrar el formulario de ajuste es correcta
                int idLote = Integer.parseInt(request.getParameter("id"));
                Lote lote = loteDao.buscarLotePorId(idLote);

                if (lote != null) {
                    request.setAttribute("lote", lote); // El JSP que te envié espera el atributo "lote"
                    RequestDispatcher dispatcher = request.getRequestDispatcher("/almacen/lotes/ajustarInventario.jsp");
                    dispatcher.forward(request, response);
                } else {
                    response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                }
                break;
        }
    }

    // El método doPost se encarga de PROCESAR los datos del formulario de ajuste (COMPLETAMENTE MODIFICADO)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        LoteDao loteDao = new LoteDao();
        MovimientoDao movimientoDao = new MovimientoDao();

        switch (action) {
            case "guardarAjuste":
                // 1. Obtenemos los datos del formulario
                int idLote = Integer.parseInt(request.getParameter("idLote"));
                int stockOriginal = Integer.parseInt(request.getParameter("stockActual"));
                int cantidadContada = Integer.parseInt(request.getParameter("cantidadContada"));
                String motivoAjuste = request.getParameter("motivo");

                // 2. Obtenemos el usuario de la sesión
                HttpSession session = request.getSession();
                Usuario usuario = (Usuario) session.getAttribute("usuarioLogueado");
                // Si no hay usuario en sesión, asignamos un ID por defecto para que no falle (en un sistema real, esto no debería pasar)
                int usuarioId = (usuario != null) ? usuario.getIdUsuario() : 1;

                // 3. Calculamos la diferencia para saber si hubo un cambio
                int diferencia = cantidadContada - stockOriginal;

                // 4. Solo si hubo un cambio, registramos el movimiento y actualizamos el stock
                if (diferencia != 0) {
                    String tipoMovimiento = (diferencia > 0) ? "Entrada" : "Salida";

                    Movimiento movimiento = new Movimiento();
                    movimiento.setLoteId(idLote);
                    movimiento.setUsuarioId(usuarioId);
                    movimiento.setTipoMovimiento(tipoMovimiento);
                    movimiento.setCantidad(Math.abs(diferencia)); // La cantidad del movimiento es siempre positiva
                    movimiento.setMotivo("Ajuste de inventario: " + motivoAjuste);
                    movimiento.setPedidoId(null); // No está asociado a un pedido
                    movimiento.setOrdenCompraId(null); // No está asociado a una orden de compra

                    // 5. Guardamos en la base de datos
                    movimientoDao.registrarMovimiento(movimiento);
                    loteDao.actualizarStock(idLote, cantidadContada);
                }

                // 6. Redirigimos al usuario a la lista principal
                response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
                break;

            // Aquí puedes agregar otros casos para otros formularios POST en el futuro
        }
    }
}