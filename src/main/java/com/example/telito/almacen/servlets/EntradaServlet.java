package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Lote;
import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.almacen.beans.OrdenCompra;
import com.example.telito.almacen.beans.Usuario; // Importar Usuario
import com.example.telito.almacen.daos.LoteDao;
import com.example.telito.almacen.daos.MovimientoDao;
import com.example.telito.almacen.daos.OrdenCompraDao;
import com.example.telito.almacen.daos.UbicacionDao;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Importar HttpSession
import java.text.SimpleDateFormat; // <-- Importa la clase para formatear fechas
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import com.example.telito.almacen.daos.DistritoDao;

@WebServlet("/almacen/EntradaServlet")
public class EntradaServlet extends HttpServlet {

    /**
     * Se encarga de mostrar las páginas: la lista de órdenes o el formulario de recepción.
     * (ESTE MÉTODO ESTÁ CORRECTO Y NO NECESITA CAMBIOS)
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

                // AÑADIR ESTAS LÍNEAS
                DistritoDao distritoDao = new DistritoDao();
                request.setAttribute("listaDistritos", distritoDao.listar());

                view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
                view.forward(request, response);
                break;
        }
    }

    /**
     * Procesa los datos del formulario de recepción para crear un nuevo lote.
     * (MÉTODO COMPLETAMENTE CORREGIDO Y MEJORADO)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ... (código para obtener el usuario y los DAOs) ...
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
            String fechaVencimientoStr = request.getParameter("fecha_vencimiento"); // Leemos la fecha como texto
            int idUbicacion = Integer.parseInt(request.getParameter("ubicacion_id"));
            int idDistrito = Integer.parseInt(request.getParameter("distrito_id"));
            // --- INICIO DE LA CORRECCIÓN DE FECHA ---
            // Creamos un formateador que entiende el formato "yyyy-MM-dd" que envía el input type="date"
            SimpleDateFormat formato = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date utilDate = formato.parse(fechaVencimientoStr);
            java.sql.Date fechaVencimiento = new java.sql.Date(utilDate.getTime());
            // --- FIN DE LA CORRECCIÓN DE FECHA ---

            OrdenCompra oc = ordenCompraDao.buscarOrdenPorId(idOrden);

            Lote nuevoLote = new Lote();
            nuevoLote.setCodigoLote(codigoLote);
            nuevoLote.setStockActual(oc.getCantidad());
            nuevoLote.setFechaVencimiento(fechaVencimiento);
            nuevoLote.setProductoId(oc.getProductoId());
            nuevoLote.setUbicacionId(idUbicacion);
            nuevoLote.setDistritoId(idDistrito);
            int nuevoLoteId = loteDao.crearLote(nuevoLote);

            Movimiento movimiento = new Movimiento();
            movimiento.setLoteId(nuevoLoteId);
            movimiento.setUsuarioId(usuarioId);
            movimiento.setOrdenCompraId(idOrden);
            movimiento.setTipoMovimiento("Entrada");
            movimiento.setCantidad(oc.getCantidad());
            movimiento.setMotivo("Recepción de OC: " + oc.getNumeroOrden());
            movimientoDao.registrarMovimiento(movimiento);

            ordenCompraDao.actualizarEstado(idOrden, "Recibido");

            response.sendRedirect(request.getContextPath() + "/almacen/EntradaServlet");

        } catch (Exception e) {
            // AÑADIR ESTO PARA DEPURACIÓN: Imprime el error en la consola del servidor
            e.printStackTrace();

            // El resto de tu manejo de errores que reenvía al formulario
            request.setAttribute("error", "Ocurrió un error. Verifique que todos los campos estén correctos.");
            request.setAttribute("ordenCompra", ordenCompraDao.buscarOrdenPorId(idOrden));
            UbicacionDao ubicacionDao = new UbicacionDao();
            request.setAttribute("listaUbicaciones", ubicacionDao.listar());

            RequestDispatcher view = request.getRequestDispatcher("/almacen/entradas/registrarEntrada.jsp");
            view.forward(request, response);
        }
    }
}