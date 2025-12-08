package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.AlertaGeneradaDAO;
import com.example.telito.administrador.daos.AlertaDAO;
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
import java.util.HashMap;
import java.util.Map;

@WebServlet("/administrador/DashboardAlertasServlet")
public class DashboardAlertasServlet extends HttpServlet {
    
    private final AlertaGeneradaDAO alertaGeneradaDAO = new AlertaGeneradaDAO();
    private final AlertaDAO alertaDAO = new AlertaDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a DashboardAlertasServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        try {
            // Obtener métricas
            Map<String, Integer> alertasPorNivel = alertaGeneradaDAO.contarAlertasPorNivel();
            Map<String, Integer> alertasPorTipo = alertaGeneradaDAO.contarAlertasPorTipo();
            int totalAlertasActivas = alertaGeneradaDAO.contarAlertasActivas();
            
            // Obtener lista de alertas activas
            ArrayList<Map<String, Object>> alertasActivas = alertaGeneradaDAO.listarAlertasActivas(20);
            
            // Obtener reglas activas
            int reglasActivas = alertaDAO.contarReglasDeAlertaActivas();
            
            // Pasar datos a la vista
            request.setAttribute("alertasPorNivel", alertasPorNivel);
            request.setAttribute("alertasPorTipo", alertasPorTipo);
            request.setAttribute("totalAlertasActivas", totalAlertasActivas);
            request.setAttribute("alertasActivas", alertasActivas);
            request.setAttribute("reglasActivas", reglasActivas);
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/dashboard-alertas.jsp");
            dispatcher.forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el dashboard de alertas: " + e.getMessage());
            RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/dashboard-alertas.jsp");
            dispatcher.forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("marcarLeida".equals(action)) {
            try {
                int idAlerta = Integer.parseInt(request.getParameter("id"));
                alertaGeneradaDAO.marcarComoLeida(idAlerta);
                response.getWriter().write("{\"success\": true}");
            } catch (Exception e) {
                response.getWriter().write("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
            }
        }
    }
}

