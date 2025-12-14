package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.almacen.beans.Usuario; // Asegúrate de importar tu bean de Usuario
import com.example.telito.almacen.daos.MovimientoDao;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // Importa HttpSession

import java.io.IOException;
import java.util.ArrayList;

// Gestión de movimientos de inventario (historial de entradas y salidas)
@WebServlet("/almacen/MovimientoServlet")
public class MovimientoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Solo almaceneros
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAlmacen(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de almacenero intentó acceder a MovimientoServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        MovimientoDao movimientoDao = new MovimientoDao();

        // Obtener usuario de la sesión
        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        
        // Crear bean compatible para este módulo
        Usuario usuarioLogueado = null;
        if (usuarioSesion != null) {
            usuarioLogueado = new Usuario();
            usuarioLogueado.setIdUsuario(usuarioSesion.getIdUsuario());
            usuarioLogueado.setNombres(usuarioSesion.getNombres());
        }

        switch (action) {
            case "listar":
                try {
                    int registrosPorPagina = 5;
                    String pageStr = request.getParameter("page");
                    int paginaActual = 1;
                    try {
                        if (pageStr != null && !pageStr.isEmpty()) {
                            paginaActual = Integer.parseInt(pageStr);
                        }
                    } catch (NumberFormatException e) {
                        paginaActual = 1;
                    }
                    if (paginaActual < 1) paginaActual = 1;

                    // Filtros
                    String filtro = request.getParameter("filtro");
                    String busqueda = request.getParameter("busqueda");
                    String tipoMovimiento = request.getParameter("tipo");

                    int totalRegistros;
                    ArrayList<Movimiento> listaMovimientos;

                    // Filtrar por usuario si se solicita
                    if ("mios".equals(filtro) && usuarioLogueado != null) {
                        int usuarioId = usuarioLogueado.getIdUsuario();
                        totalRegistros = movimientoDao.contarMovimientosPorUsuario(usuarioId, busqueda, tipoMovimiento);
                        int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                        if (totalPaginas == 0) totalPaginas = 1;
                        if (paginaActual > totalPaginas) paginaActual = totalPaginas;
                        int offset = (paginaActual - 1) * registrosPorPagina;
                        listaMovimientos = movimientoDao.listarMovimientosPorUsuarioPaginado(usuarioId, registrosPorPagina, offset, busqueda, tipoMovimiento);
                    } else {
                        totalRegistros = movimientoDao.contarTotalMovimientos(busqueda, tipoMovimiento, filtro);
                        int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                        if (totalPaginas == 0) totalPaginas = 1;
                        if (paginaActual > totalPaginas) paginaActual = totalPaginas;
                        int offset = (paginaActual - 1) * registrosPorPagina;
                        listaMovimientos = movimientoDao.listarMovimientosPaginado(registrosPorPagina, offset, busqueda, tipoMovimiento);
                    }

                    int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                    if (totalPaginas == 0) totalPaginas = 1;

                    // Calcular estadísticas (sin filtros para obtener totales reales)
                    int totalMovimientos = movimientoDao.contarTotalMovimientos(null, null, null);
                    int movimientosEntrada = movimientoDao.contarMovimientosEntrada(null);
                    int movimientosSalida = movimientoDao.contarMovimientosSalida(null);
                    int movimientosAjuste = movimientoDao.contarMovimientosAjuste(null);

                    request.setAttribute("listaMovimientos", listaMovimientos);
                    request.setAttribute("filtroActual", filtro);
                    request.setAttribute("currentPage", paginaActual);
                    request.setAttribute("size", registrosPorPagina);
                    request.setAttribute("totalPages", totalPaginas);
                    request.setAttribute("totalRows", totalRegistros);
                    request.setAttribute("totalMovimientos", totalMovimientos);
                    request.setAttribute("movimientosEntrada", movimientosEntrada);
                    request.setAttribute("movimientosSalida", movimientosSalida);
                    request.setAttribute("movimientosAjuste", movimientosAjuste);
                    request.setAttribute("baseUrl", request.getContextPath() + "/almacen/MovimientoServlet");
                    request.setAttribute("itemName", "movimientos");
                    request.setAttribute("busqueda", busqueda);
                    request.setAttribute("tipoFiltro", tipoMovimiento);

                    RequestDispatcher view = request.getRequestDispatcher("/almacen/movimientos/historialMovimientos.jsp");
                    view.forward(request, response);
                } catch (Exception e) {
                    System.err.println("Error en MovimientoServlet - case listar: " + e.getMessage());
                    e.printStackTrace();
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al cargar el historial de movimientos: " + e.getMessage());
                }
                break;
        }
    }
}