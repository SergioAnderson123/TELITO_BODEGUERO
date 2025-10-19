package com.example.telito.administrador.servlets;

import com.example.telito.administrador.services.EvaluadorAlertasService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet para evaluar alertas manualmente.
 * Útil para testing y para ejecutar evaluaciones bajo demanda.
 */
@WebServlet(name = "EvaluarAlertasServlet", value = "/EvaluarAlertasServlet")
public class EvaluarAlertasServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action") == null ? "evaluar" : request.getParameter("action");
        HttpSession session = request.getSession();
        EvaluadorAlertasService evaluador = new EvaluadorAlertasService();
        
        switch (action) {
            case "evaluar":
                try {
                    int eventosGenerados = evaluador.evaluarTodasLasAlertas();
                    session.setAttribute("successMsg", 
                        String.format("Evaluación completada. Se generaron %d nuevos eventos de alerta.", eventosGenerados));
                } catch (Exception e) {
                    session.setAttribute("errorMsg", "Error al evaluar las alertas: " + e.getMessage());
                }
                break;
                
            case "limpiar":
                try {
                    int eventosEliminados = evaluador.limpiarEventosAntiguos();
                    session.setAttribute("successMsg", 
                        String.format("Limpieza completada. Se eliminaron %d eventos antiguos.", eventosEliminados));
                } catch (Exception e) {
                    session.setAttribute("errorMsg", "Error al limpiar eventos antiguos: " + e.getMessage());
                }
                break;
        }
        
        // Redirigir de vuelta a la gestión de alertas
        response.sendRedirect(request.getContextPath() + "/AlertaServlet");
    }
}
