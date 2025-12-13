package com.example.telito.gerente.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.gerente.daos.RecepcionDAO;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**
 * Servlet para gestionar las recepciones de productos por el Gerente de Tienda.
 */
@WebServlet("/gerente-tienda/GerenteTiendaServlet")
public class GerenteTiendaServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(GerenteTiendaServlet.class);
    private RecepcionDAO recepcionDAO = new RecepcionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederGerenteTienda(session)) {
            logger.warn("🚨 ACCESO DENEGADO: Usuario sin rol de Gerente de Tienda intentó acceder desde: {}", 
                       request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getDistritoId() == null) {
            logger.error("Usuario sin distrito asignado intentó acceder al módulo de Gerente de Tienda");
            session.setAttribute("errorMsg", "No tienes un distrito asignado. Contacta al administrador.");
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }
        
        int distritoId = usuario.getDistritoId();
        String action = request.getParameter("action");
        
        if (action == null || action.isEmpty()) {
            action = "dashboard";
        }
        
        logger.debug("Procesando acción GET: {} para distrito: {}", action, distritoId);
        
        switch (action) {
            case "dashboard":
                mostrarDashboard(request, response, distritoId);
                break;
            case "recepciones-pendientes":
                listarRecepcionesPendientes(request, response, distritoId);
                break;
            case "confirmar-recepcion":
                mostrarFormularioConfirmarRecepcion(request, response, distritoId);
                break;
            case "historial":
                listarHistorialRecepciones(request, response, distritoId);
                break;
            default:
                logger.warn("Acción GET no reconocida: {}", action);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederGerenteTienda(session)) {
            logger.warn("🚨 ACCESO DENEGADO: Usuario sin rol de Gerente de Tienda intentó acceder (POST) desde: {}", 
                       request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || usuario.getDistritoId() == null) {
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }
        
        int distritoId = usuario.getDistritoId();
        String action = request.getParameter("action");
        
        if (action == null || action.isEmpty()) {
            action = "confirmar";
        }
        
        logger.debug("Procesando acción POST: {} para distrito: {}", action, distritoId);
        
        switch (action) {
            case "confirmar":
                confirmarRecepcion(request, response, distritoId, session);
                break;
            default:
                logger.warn("Acción POST no reconocida: {}", action);
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Acción no válida");
                break;
        }
    }

    /**
     * Muestra el dashboard del Gerente de Tienda con métricas.
     */
    private void mostrarDashboard(HttpServletRequest request, HttpServletResponse response, int distritoId)
            throws ServletException, IOException {
        
        int recepcionesPendientes = recepcionDAO.contarPlanesPendientes(distritoId);
        int recepcionesCompletadas = recepcionDAO.contarHistorialRecepciones(distritoId);
        
        request.setAttribute("recepcionesPendientes", recepcionesPendientes);
        request.setAttribute("recepcionesCompletadas", recepcionesCompletadas);
        
        RequestDispatcher view = request.getRequestDispatcher("/gerente-tienda/dashboard.jsp");
        view.forward(request, response);
    }

    /**
     * Lista las recepciones pendientes para el distrito del gerente.
     */
    private void listarRecepcionesPendientes(HttpServletRequest request, HttpServletResponse response, int distritoId)
            throws ServletException, IOException {
        
        String estadoFiltro = request.getParameter("estado");
        var planes = recepcionDAO.listarPlanesPorDistrito(distritoId, estadoFiltro);
        
        request.setAttribute("planes", planes);
        request.setAttribute("estadoFiltro", estadoFiltro);
        
        RequestDispatcher view = request.getRequestDispatcher("/gerente-tienda/recepciones-pendientes.jsp");
        view.forward(request, response);
    }

    /**
     * Muestra el formulario para confirmar la recepción de un plan específico.
     */
    private void mostrarFormularioConfirmarRecepcion(HttpServletRequest request, HttpServletResponse response, int distritoId)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        String idPlanStr = request.getParameter("id_plan");
        if (idPlanStr == null || idPlanStr.isEmpty()) {
            if (session != null) {
                session.setAttribute("errorMsg", "ID de plan no especificado.");
            }
            response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
            return;
        }
        
        try {
            int idPlan = Integer.parseInt(idPlanStr);
            var plan = recepcionDAO.obtenerPlanPorId(idPlan, distritoId);
            
            if (plan == null) {
                if (session != null) {
                    session.setAttribute("errorMsg", "Plan de transporte no encontrado o no pertenece a tu distrito.");
                }
                response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
                return;
            }
            
            // Solo se puede confirmar recepción si está "En Ruta" o "Salida"
            if (!"En Ruta".equals(plan.getEstado()) && !"Salida".equals(plan.getEstado())) {
                if (session != null) {
                    session.setAttribute("errorMsg", "Este plan no está disponible para recepción. Estado: " + plan.getEstado());
                }
                response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
                return;
            }
            
            request.setAttribute("plan", plan);
            RequestDispatcher view = request.getRequestDispatcher("/gerente-tienda/confirmar-recepcion.jsp");
            view.forward(request, response);
            
        } catch (NumberFormatException e) {
            logger.error("ID de plan inválido: {}", idPlanStr);
            if (session != null) {
                session.setAttribute("errorMsg", "ID de plan inválido.");
            }
            response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
        }
    }

    /**
     * Confirma la recepción de un plan de transporte.
     */
    private void confirmarRecepcion(HttpServletRequest request, HttpServletResponse response, int distritoId, HttpSession session)
            throws IOException {
        
        String idPlanStr = request.getParameter("id_plan");
        if (idPlanStr == null || idPlanStr.isEmpty()) {
            session.setAttribute("errorMsg", "ID de plan no especificado.");
            response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
            return;
        }
        
        try {
            int idPlan = Integer.parseInt(idPlanStr);
            boolean confirmado = recepcionDAO.confirmarRecepcion(idPlan, distritoId);
            
            if (confirmado) {
                logger.info("Recepción confirmada exitosamente. Plan ID: {}, Distrito ID: {}", idPlan, distritoId);
                session.setAttribute("successMsg", "Recepción confirmada exitosamente.");
            } else {
                logger.warn("No se pudo confirmar la recepción. Plan ID: {}, Distrito ID: {}", idPlan, distritoId);
                session.setAttribute("errorMsg", "No se pudo confirmar la recepción. Verifica que el plan pertenezca a tu distrito y esté en estado válido.");
            }
            
            response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
            
        } catch (NumberFormatException e) {
            logger.error("ID de plan inválido: {}", idPlanStr);
            session.setAttribute("errorMsg", "ID de plan inválido.");
            response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
        }
    }

    /**
     * Lista el historial de recepciones completadas.
     */
    private void listarHistorialRecepciones(HttpServletRequest request, HttpServletResponse response, int distritoId)
            throws ServletException, IOException {
        
        int page = parseInteger(request.getParameter("page"), 1);
        int size = parseInteger(request.getParameter("size"), 10);
        if (page < 1) page = 1;
        if (size < 1) size = 10;
        
        var planes = recepcionDAO.listarHistorialRecepciones(distritoId, page, size);
        int totalRows = recepcionDAO.contarHistorialRecepciones(distritoId);
        int totalPages = (int) Math.ceil(totalRows / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;
        
        request.setAttribute("planes", planes);
        request.setAttribute("currentPage", page);
        request.setAttribute("size", size);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRows", totalRows);
        
        RequestDispatcher view = request.getRequestDispatcher("/gerente-tienda/historial-recepciones.jsp");
        view.forward(request, response);
    }

    /**
     * Método auxiliar para parsear enteros de forma segura.
     */
    private int parseInteger(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}

