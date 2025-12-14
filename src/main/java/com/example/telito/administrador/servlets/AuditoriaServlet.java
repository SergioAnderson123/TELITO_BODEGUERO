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

// Visualización de registros de auditoría con filtros
@WebServlet(name = "AuditoriaServlet", value = "/AuditoriaServlet")
public class AuditoriaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Solo administradores
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
        int size = 5;
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
        if (size < 1) size = 5;
        
        // Obtener registros paginados
        var listaAuditoria = auditoriaDAO.listarAuditoria(
            usuarioId, accion, modulo, estado, fechaDesde, fechaHasta, page, size
        );
        
        // Calcular totales para paginación
        int totalRegistros = auditoriaDAO.contarAuditoria(
            usuarioId, accion, modulo, estado, fechaDesde, fechaHasta
        );
        
        int totalPages = (int) Math.ceil((double) totalRegistros / size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;
        
        // Estadísticas generales (sin filtros)
        java.util.Map<String, Integer> stats = auditoriaDAO.obtenerEstadisticas();
        int totalRegistrosAuditoria = auditoriaDAO.contarAuditoria(null, null, null, null, null, null);
        int accionesHoy = stats.getOrDefault("accionesHoy", 0);
        int accionesFallidas = stats.getOrDefault("accionesFallidas", 0);
        
        // Pasar datos a la vista
        request.setAttribute("listaAuditoria", listaAuditoria);
        request.setAttribute("totalRegistros", totalRegistros);
        request.setAttribute("page", page);
        request.setAttribute("currentPage", page);
        request.setAttribute("size", size);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("usuarioId", usuarioId);
        request.setAttribute("accion", accion);
        request.setAttribute("modulo", modulo);
        request.setAttribute("estado", estado);
        request.setAttribute("fechaDesde", fechaDesde);
        request.setAttribute("fechaHasta", fechaHasta);
        request.setAttribute("totalRegistrosAuditoria", totalRegistrosAuditoria);
        request.setAttribute("accionesHoy", accionesHoy);
        request.setAttribute("accionesFallidas", accionesFallidas);
        request.setAttribute("baseUrl", request.getContextPath() + "/AuditoriaServlet");
        request.setAttribute("itemName", "registros de auditoría");
        // Parámetros para paginación
        if (usuarioId != null && !usuarioId.isEmpty()) {
            request.setAttribute("param1Name", "usuario_id");
            request.setAttribute("param1Value", usuarioId);
        }
        if (accion != null && !accion.isEmpty()) {
            request.setAttribute("param2Name", "accion");
            request.setAttribute("param2Value", accion);
        }
        if (modulo != null && !modulo.isEmpty()) {
            request.setAttribute("param3Name", "modulo");
            request.setAttribute("param3Value", modulo);
        }
        if (estado != null && !estado.isEmpty()) {
            request.setAttribute("param4Name", "estado");
            request.setAttribute("param4Value", estado);
        }
        if (fechaDesde != null && !fechaDesde.isEmpty()) {
            request.setAttribute("param5Name", "fecha_desde");
            request.setAttribute("param5Value", fechaDesde);
        }
        if (fechaHasta != null && !fechaHasta.isEmpty()) {
            request.setAttribute("param6Name", "fecha_hasta");
            request.setAttribute("param6Value", fechaHasta);
        }
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/auditoria.jsp");
        dispatcher.forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

