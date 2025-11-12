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

@WebServlet("/almacen/MovimientoServlet")
public class MovimientoServlet extends HttpServlet {

// En tu archivo: MovimientoServlet.java

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar que el usuario tenga rol de almacenero
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

        // Obtener el usuario de la sesión (establecido por LoginServlet y protegido por AuthFilter)
        com.example.telito.administrador.beans.Usuario usuarioSesion = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        
        // Crear un bean compatible para este módulo si es necesario
        Usuario usuarioLogueado = null;
        if (usuarioSesion != null) {
            usuarioLogueado = new Usuario();
            usuarioLogueado.setIdUsuario(usuarioSesion.getIdUsuario());
            usuarioLogueado.setNombres(usuarioSesion.getNombres());
        }

        switch (action) {
            case "listar":
                int registrosPorPagina = 10;
                String pageStr = request.getParameter("page");
                int paginaActual = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);
                if (paginaActual < 1) paginaActual = 1;

                String filtro = request.getParameter("filtro");
                int totalRegistros;
                ArrayList<Movimiento> listaMovimientos;

                if ("mios".equals(filtro) && usuarioLogueado != null) {
                    int usuarioId = usuarioLogueado.getIdUsuario();
                    totalRegistros = movimientoDao.contarMovimientosPorUsuario(usuarioId);
                    int offset = (paginaActual - 1) * registrosPorPagina;
                    listaMovimientos = movimientoDao.listarMovimientosPorUsuarioPaginado(usuarioId, registrosPorPagina, offset);
                } else {
                    totalRegistros = movimientoDao.contarTotalMovimientos();
                    int offset = (paginaActual - 1) * registrosPorPagina;
                    listaMovimientos = movimientoDao.listarMovimientosPaginado(registrosPorPagina, offset);
                }

                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);
                if (totalPaginas == 0) totalPaginas = 1;

                request.setAttribute("listaMovimientos", listaMovimientos);
                request.setAttribute("filtroActual", filtro);
                request.setAttribute("currentPage", paginaActual);
                request.setAttribute("size", registrosPorPagina);
                request.setAttribute("totalPages", totalPaginas);
                request.setAttribute("totalRows", totalRegistros);
                request.setAttribute("baseUrl", request.getContextPath() + "/almacen/MovimientoServlet");
                request.setAttribute("itemName", "movimientos");

                RequestDispatcher view = request.getRequestDispatcher("/almacen/movimientos/historialMovimientos.jsp");
                view.forward(request, response);
                break;
        }
    }
}