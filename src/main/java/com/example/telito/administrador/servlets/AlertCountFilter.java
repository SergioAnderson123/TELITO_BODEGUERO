package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.AlertaDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Actualiza el contador de alertas en cada petición para mantenerlo actualizado
@WebFilter(filterName = "AlertCountFilter", urlPatterns = {"/*"})
public class AlertCountFilter implements Filter {

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        // Saltar recursos estáticos para no sobrecargar la BD
        // getSession(false) no crea sesión nueva
        if (!path.startsWith("/assets")) {
            HttpSession session = httpRequest.getSession(false);
            if (session != null) {
                // Actualizar contador solo si hay sesión activa
                AlertaDAO alertaDAO = new AlertaDAO();
                int reglasActivas = alertaDAO.contarReglasDeAlertaActivas();
                session.setAttribute("alertasAbiertas", reglasActivas);
            }
        }

        chain.doFilter(request, response);
    }

    public void init(FilterConfig filterConfig) throws ServletException {
        // Sin inicialización necesaria
    }

    public void destroy() {
        // Sin limpieza necesaria
    }
}
