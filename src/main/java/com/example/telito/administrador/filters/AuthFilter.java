package com.example.telito.administrador.filters;

import com.example.telito.administrador.beans.Usuario;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
    "/administrador/*",
    "/almacen/*", 
    "/logistica/*",
    "/productor/*",
    "/UsuarioServlet",
    "/ProductoServlet",
    "/AlertaServlet",
    "/administrador/reportes"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Inicialización del filtro
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // URLs que no requieren autenticación
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        if (requestURI.equals(contextPath + "/") || 
            requestURI.equals(contextPath + "/LoginServlet") ||
            requestURI.equals(contextPath + "/welcome.jsp") ||
            requestURI.equals(contextPath + "/login.jsp") ||
            requestURI.startsWith(contextPath + "/assets/") ||
            requestURI.startsWith(contextPath + "/css/") ||
            requestURI.startsWith(contextPath + "/js/") ||
            requestURI.startsWith(contextPath + "/images/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Verificar si hay sesión activa
        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            // No hay sesión activa, redirigir al login
            httpResponse.sendRedirect(contextPath + "/LoginServlet");
            return;
        }
        
        // Verificar que el usuario esté activo
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (!usuario.isActivo()) {
            // Usuario inactivo, invalidar sesión y redirigir al login
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/LoginServlet");
            return;
        }
        
        // Continuar con la cadena de filtros
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Limpieza del filtro
    }
}
