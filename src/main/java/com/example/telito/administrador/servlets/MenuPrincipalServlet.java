package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.administrador.daos.AuditoriaDAO;
import com.example.telito.administrador.daos.ReporteDAO;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Map;

// Dashboard principal del administrador con estadísticas del sistema
@WebServlet(name = "MenuPrincipalServlet", value = "/inicio")
public class MenuPrincipalServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a MenuPrincipalServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }

        response.setContentType("text/html");

        UsuarioDAO usuarioDAO = new UsuarioDAO();
        AlertaDAO alertaDAO = new AlertaDAO();
        ReporteDAO reporteDAO = new ReporteDAO();
        AuditoriaDAO auditoriaDAO = new AuditoriaDAO();

        // Estadísticas de usuarios
        int totalUsuarios = usuarioDAO.contarTotalUsuarios();
        int usuariosBaneados = usuarioDAO.contarUsuariosBaneados();
        int usuariosActivos = totalUsuarios - usuariosBaneados;
        int alertasAbiertas = alertaDAO.contarAlertasAbiertas();
        
        // Métricas del sistema
        int totalProductos = reporteDAO.contarProductos();
        int totalLotes = reporteDAO.contarLotes();
        int eficienciaLogistica = reporteDAO.calcularEficienciaLogistica();
        int rutasActivas = reporteDAO.contarRutasActivas();
        
        // Estadísticas de auditoría
        Map<String, Integer> statsAuditoria = auditoriaDAO.obtenerEstadisticas();
        int accionesHoy = statsAuditoria.getOrDefault("accionesHoy", 0);
        int accionesSemana = statsAuditoria.getOrDefault("accionesSemana", 0);
        int accionesFallidas = statsAuditoria.getOrDefault("accionesFallidas", 0);
        
        // Porcentaje de usuarios activos
        double porcentajeActivos = totalUsuarios > 0 ? 
            (usuariosActivos * 100.0 / totalUsuarios) : 0;

        // Pasar datos a la vista
        request.setAttribute("totalUsuarios", totalUsuarios);
        request.setAttribute("usuariosBaneados", usuariosBaneados);
        request.setAttribute("usuariosActivos", usuariosActivos);
        request.setAttribute("porcentajeActivos", Math.round(porcentajeActivos));
        request.setAttribute("alertasAbiertas", alertasAbiertas);
        request.setAttribute("totalProductos", totalProductos);
        request.setAttribute("totalLotes", totalLotes);
        request.setAttribute("eficienciaLogistica", eficienciaLogistica);
        request.setAttribute("rutasActivas", rutasActivas);
        request.setAttribute("accionesHoy", accionesHoy);
        request.setAttribute("accionesSemana", accionesSemana);
        request.setAttribute("accionesFallidas", accionesFallidas);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/menu-principal.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
