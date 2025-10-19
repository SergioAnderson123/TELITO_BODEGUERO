package com.example.telito.administrador.servlets;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Filtro de autenticación para proteger páginas que requieren login.
 * Verifica que el usuario tenga una sesión activa antes de acceder a recursos protegidos.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/administrador/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Inicialización del filtro si es necesaria
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Obtener la sesión actual
        HttpSession session = httpRequest.getSession(false);
        
        // Verificar si hay una sesión activa y un usuario logueado
        if (session == null || session.getAttribute("usuarioSesion") == null) {
            // No hay sesión activa, redirigir al login
            String loginUrl = httpRequest.getContextPath() + "/LoginServlet";
            httpResponse.sendRedirect(loginUrl);
            return;
        }
        
        // Hay sesión activa, continuar con la cadena de filtros
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Limpieza del filtro si es necesaria
    }
}
