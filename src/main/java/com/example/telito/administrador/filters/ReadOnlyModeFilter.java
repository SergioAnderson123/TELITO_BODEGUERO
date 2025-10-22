package com.example.telito.administrador.filters;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "ReadOnlyModeFilter", urlPatterns = {"/*"})
public class ReadOnlyModeFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession();

        // Activar/desactivar modo readonly desde query param
        String mode = req.getParameter("mode");
        if ("readonly".equalsIgnoreCase(mode)) {
            session.setAttribute("readonly", Boolean.TRUE);
        } else if ("edit".equalsIgnoreCase(mode)) {
            session.removeAttribute("readonly");
        }

        Boolean readonly = (Boolean) session.getAttribute("readonly");
        String method = req.getMethod();
        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // Excluir recursos estáticos
        if (uri.startsWith(ctx + "/assets/") || uri.startsWith(ctx + "/css/") || uri.startsWith(ctx + "/js/") || uri.startsWith(ctx + "/images/")) {
            chain.doFilter(request, response);
            return;
        }

        // Inyectar flag para vistas
        if (Boolean.TRUE.equals(readonly) && "GET".equalsIgnoreCase(method)) {
            request.setAttribute("readonly", true);
        }

        // Bloquear métodos no-GET en modo readonly
        if (Boolean.TRUE.equals(readonly) && !"GET".equalsIgnoreCase(method)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Acción bloqueada en modo solo lectura");
            return;
        }

        chain.doFilter(request, response);
    }
}
