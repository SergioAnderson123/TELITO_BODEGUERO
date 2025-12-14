package com.example.telito.administrador.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Filtro para modo solo lectura - bloquea POST/PUT/DELETE cuando está activo
@WebFilter(filterName = "ReadOnlyModeFilter", urlPatterns = {"/*"})
public class ReadOnlyModeFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        // getSession(false) no crea sesión nueva si no existe
        HttpSession session = req.getSession(false);
        
        // Activar/desactivar modo readonly desde query param
        if (session != null) {
            String mode = req.getParameter("mode");
            if ("readonly".equalsIgnoreCase(mode)) {
                session.setAttribute("readonly", Boolean.TRUE);
            } else if ("edit".equalsIgnoreCase(mode)) {
                session.removeAttribute("readonly");
            }
        }

        Boolean readonly = (session != null) ? (Boolean) session.getAttribute("readonly") : null;
        String method = req.getMethod();
        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // Permitir recursos estáticos siempre
        if (uri.startsWith(ctx + "/assets/") || uri.startsWith(ctx + "/css/") || uri.startsWith(ctx + "/js/") || uri.startsWith(ctx + "/images/")) {
            chain.doFilter(request, response);
            return;
        }

        // Inyectar flag readonly en la vista
        if (Boolean.TRUE.equals(readonly) && "GET".equalsIgnoreCase(method)) {
            request.setAttribute("readonly", true);
        }

        // Bloquear POST/PUT/DELETE en modo readonly
        if (Boolean.TRUE.equals(readonly) && !"GET".equalsIgnoreCase(method)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Acción bloqueada en modo solo lectura");
            return;
        }

        chain.doFilter(request, response);
    }
}
