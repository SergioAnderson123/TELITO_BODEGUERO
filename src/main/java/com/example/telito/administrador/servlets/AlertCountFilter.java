package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.AlertaDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Un filtro se ejecuta para CADA petición que llega al servidor. Lo uso para que el contador
// de alertas esté siempre actualizado, sin importar en qué página esté el usuario.
@WebFilter(filterName = "AlertCountFilter", urlPatterns = {"/*"})
public class AlertCountFilter implements Filter {

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        // No ejecuto la consulta para los archivos de CSS, JS, etc., para no sobrecargar la BD.
        if (!path.startsWith("/assets")) {
            HttpSession session = httpRequest.getSession();
            AlertaDAO alertaDAO = new AlertaDAO();
            // Llamo al método que cuenta las reglas activas.
            int reglasActivas = alertaDAO.contarReglasDeAlertaActivas();
            // Guardo el número en la sesión para poder usarlo en cualquier JSP.
            session.setAttribute("alertasAbiertas", reglasActivas);
        }

        // Le digo a la petición que continúe su camino normal.
        chain.doFilter(request, response);
    }

    public void init(FilterConfig filterConfig) throws ServletException {
        // Este método se ejecuta cuando el filtro se inicia. No lo necesito ahora.
    }

    public void destroy() {
        // Se ejecuta cuando el filtro se destruye. Tampoco lo necesito.
    }
}
