package com.example.telito.almacen.servlets;

import com.example.telito.almacen.beans.Movimiento;
import com.example.telito.almacen.beans.Usuario; // Asegúrate de importar tu bean de Usuario
import com.example.telito.almacen.daos.MovimientoDao;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        MovimientoDao movimientoDao = new MovimientoDao();

        // Obtenemos la sesión para saber qué usuario está logueado
        HttpSession session = request.getSession();
        // Reemplaza "usuarioLogueado" con el nombre del atributo que usas en tu LoginServlet
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");


        switch (action) {
            case "listar":
                int registrosPorPagina = 15;
                String pageStr = request.getParameter("page");
                int paginaActual = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);

                // Leemos el nuevo parámetro de filtro
                String filtro = request.getParameter("filtro");

                int totalRegistros;
                ArrayList<Movimiento> listaMovimientos;

                // --- INICIO: LÓGICA DE FILTRADO ---
                // Si el filtro es "mios" y hay un usuario en la sesión...
                if ("mios".equals(filtro) && usuarioLogueado != null) {
                    int usuarioId = usuarioLogueado.getIdUsuario();

                    // Contamos y listamos solo los movimientos de ese usuario
                    totalRegistros = movimientoDao.contarMovimientosPorUsuario(usuarioId);
                    int offset = (paginaActual - 1) * registrosPorPagina;
                    listaMovimientos = movimientoDao.listarMovimientosPorUsuarioPaginado(usuarioId, registrosPorPagina, offset);

                } else {
                    // Si no, mostramos todos los movimientos (comportamiento por defecto)
                    totalRegistros = movimientoDao.contarTotalMovimientos();
                    int offset = (paginaActual - 1) * registrosPorPagina;
                    listaMovimientos = movimientoDao.listarMovimientosPaginado(registrosPorPagina, offset);
                }
                // --- FIN: LÓGICA DE FILTRADO ---

                int totalPaginas = (int) Math.ceil((double) totalRegistros / registrosPorPagina);

                // Enviamos todos los datos necesarios al JSP
                request.setAttribute("listaMovimientos", listaMovimientos);
                request.setAttribute("paginaActual", paginaActual);
                request.setAttribute("totalPaginas", totalPaginas);
                // También enviamos el filtro actual para que el JSP lo recuerde
                request.setAttribute("filtroActual", filtro);

                RequestDispatcher view = request.getRequestDispatcher("/almacen/movimientos/historialMovimientos.jsp");
                view.forward(request, response);
                break;
        }
    }
}