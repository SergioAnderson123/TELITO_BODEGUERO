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

// En tu archivo: MovimientoServlet.java

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- INICIO: CÓDIGO TEMPORAL PARA SIMULAR LOGIN (BORRAR LUEGO) ---
        HttpSession session = request.getSession();

        // Para probar, creamos un usuario "falso" y lo ponemos en la sesión.
        // Cambia el ID para probar con diferentes usuarios.
        Usuario usuarioSimulado = new Usuario();
        usuarioSimulado.setIdUsuario(1); // <-- CAMBIA ESTE NÚMERO (1, 2, etc.) PARA PROBAR
        usuarioSimulado.setNombres("Usuario de Prueba"); // Nombre opcional para depuración

        // Lo guardamos en la sesión con la clave que el resto del código espera.
        session.setAttribute("usuarioLogueado", usuarioSimulado);
        // --- FIN: CÓDIGO TEMPORAL ---


        // El resto de tu código no necesita cambios y ahora funcionará
        String action = request.getParameter("action") == null ? "listar" : request.getParameter("action");
        MovimientoDao movimientoDao = new MovimientoDao();

        // El servlet ahora obtiene el usuario que acabamos de simular
        Usuario usuarioLogueado = (Usuario) session.getAttribute("usuarioLogueado");

        switch (action) {
            case "listar":
                int registrosPorPagina = 15;
                String pageStr = request.getParameter("page");
                int paginaActual = (pageStr == null || pageStr.isEmpty()) ? 1 : Integer.parseInt(pageStr);

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

                request.setAttribute("listaMovimientos", listaMovimientos);
                request.setAttribute("paginaActual", paginaActual);
                request.setAttribute("totalPaginas", totalPaginas);
                request.setAttribute("filtroActual", filtro);

                RequestDispatcher view = request.getRequestDispatcher("/almacen/movimientos/historialMovimientos.jsp");
                view.forward(request, response);
                break;
        }
    }
}