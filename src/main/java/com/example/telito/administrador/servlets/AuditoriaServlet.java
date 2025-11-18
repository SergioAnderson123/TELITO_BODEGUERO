package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.AuditoriaDAO;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "AuditoriaServlet", value = "/AuditoriaServlet")
public class AuditoriaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a AuditoriaServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        AuditoriaDAO auditoriaDAO = new AuditoriaDAO();
        
        // Obtener parámetros de filtro
        String usuarioId = request.getParameter("usuario_id");
        String accion = request.getParameter("accion");
        String modulo = request.getParameter("modulo");
        String estado = request.getParameter("estado");
        String fechaDesde = request.getParameter("fecha_desde");
        String fechaHasta = request.getParameter("fecha_hasta");
        
        // Paginación
        int page = 1;
        int size = 20;
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                page = Integer.parseInt(pageParam);
            }
            String sizeParam = request.getParameter("size");
            if (sizeParam != null && !sizeParam.isEmpty()) {
                size = Integer.parseInt(sizeParam);
            }
        } catch (NumberFormatException e) {
            // Usar valores por defecto
        }
        
        // Obtener registros de auditoría
        var listaAuditoria = auditoriaDAO.listarAuditoria(
            usuarioId, accion, modulo, estado, fechaDesde, fechaHasta, page, size
        );
        
        // Contar total de registros
        int totalRegistros = auditoriaDAO.contarAuditoria(
            usuarioId, accion, modulo, estado, fechaDesde, fechaHasta
        );
        
        int totalPages = (int) Math.ceil((double) totalRegistros / size);
        
        // Atributos para el JSP
        request.setAttribute("listaAuditoria", listaAuditoria);
        request.setAttribute("totalRegistros", totalRegistros);
        request.setAttribute("page", page);
        request.setAttribute("size", size);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("usuarioId", usuarioId);
        request.setAttribute("accion", accion);
        request.setAttribute("modulo", modulo);
        request.setAttribute("estado", estado);
        request.setAttribute("fechaDesde", fechaDesde);
        request.setAttribute("fechaHasta", fechaHasta);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/auditoria.jsp");
        dispatcher.forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

