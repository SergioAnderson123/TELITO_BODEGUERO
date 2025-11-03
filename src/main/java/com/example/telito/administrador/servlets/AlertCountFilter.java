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
        // IMPORTANTE: Usar getSession(false) para NO crear sesiones automáticamente
        // En ventana incógnita NO debería haber cookie de sesión, así que NO debe crear sesión nueva
        if (!path.startsWith("/assets")) {
            HttpSession session = httpRequest.getSession(false); // NO crear sesión si no existe
            if (session != null) {
                // Solo actualizar contador si la sesión ya existe (usuario autenticado)
                AlertaDAO alertaDAO = new AlertaDAO();
                // Llamo al método que cuenta las reglas activas.
                int reglasActivas = alertaDAO.contarReglasDeAlertaActivas();
                // Guardo el número en la sesión para poder usarlo en cualquier JSP.
                session.setAttribute("alertasAbiertas", reglasActivas);
            }
            // Si session == null, significa que no hay cookie de sesión (ventana incógnita o sin login)
            // En ese caso, NO crear sesión nueva - AuthFilter se encargará de redirigir al login
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
