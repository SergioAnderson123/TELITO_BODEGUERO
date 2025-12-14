package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.ConfiguracionSistemaDAO;
import com.example.telito.administrador.services.AuditoriaService;
import com.example.telito.util.AuthorizationHelper;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

// Gestión de configuraciones avanzadas del sistema
@WebServlet(name = "ConfiguracionAvanzadaServlet", value = "/ConfiguracionAvanzadaServlet")
public class ConfiguracionAvanzadaServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a ConfiguracionAvanzadaServlet desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        ConfiguracionSistemaDAO configDAO = new ConfiguracionSistemaDAO();
        
        // Obtener configuraciones agrupadas por categoría
        var configuraciones = configDAO.listarPorCategoria();
        
        request.setAttribute("configuraciones", configuraciones);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/configuracion-avanzada.jsp");
        dispatcher.forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Solo administradores
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            System.err.println("🚨 ACCESO DENEGADO: Usuario sin rol de administrador intentó acceder a ConfiguracionAvanzadaServlet (POST) desde: " + 
                             request.getRemoteAddr());
            String redirectUrl = AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
            response.sendRedirect(redirectUrl);
            return;
        }
        
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        ConfiguracionSistemaDAO configDAO = new ConfiguracionSistemaDAO();
        
        String action = request.getParameter("action");
        
        if ("actualizar".equals(action)) {
            // Recopilar todas las configuraciones del formulario
            Map<String, String> configuraciones = new HashMap<>();
            
            // Configuraciones de email
            String emailHost = request.getParameter("email.smtp.host");
            String emailPort = request.getParameter("email.smtp.port");
            String emailFrom = request.getParameter("email.from");
            String emailFromName = request.getParameter("email.from.name");
            String emailEnabled = request.getParameter("email.enabled");
            
            if (emailHost != null) configuraciones.put("email.smtp.host", emailHost);
            if (emailPort != null) configuraciones.put("email.smtp.port", emailPort);
            if (emailFrom != null) configuraciones.put("email.from", emailFrom);
            if (emailFromName != null) configuraciones.put("email.from.name", emailFromName);
            if (emailEnabled != null) configuraciones.put("email.enabled", emailEnabled);
            
            // Configuraciones de Notificaciones
            String notifBienvenida = request.getParameter("notificaciones.bienvenida.enabled");
            String notifActualizacion = request.getParameter("notificaciones.actualizacion.enabled");
            String notifAlertas = request.getParameter("notificaciones.alertas.enabled");
            String notifReportes = request.getParameter("notificaciones.reportes.enabled");
            
            if (notifBienvenida != null) configuraciones.put("notificaciones.bienvenida.enabled", notifBienvenida);
            if (notifActualizacion != null) configuraciones.put("notificaciones.actualizacion.enabled", notifActualizacion);
            if (notifAlertas != null) configuraciones.put("notificaciones.alertas.enabled", notifAlertas);
            if (notifReportes != null) configuraciones.put("notificaciones.reportes.enabled", notifReportes);
            
            // Configuraciones del Sistema
            String sistemaNombre = request.getParameter("sistema.nombre");
            String sistemaTimezone = request.getParameter("sistema.timezone");
            String sistemaIdioma = request.getParameter("sistema.idioma");
            String sistemaPaginacion = request.getParameter("sistema.paginacion.size");
            String auditoriaEnabled = request.getParameter("sistema.auditoria.enabled");
            String auditoriaRetention = request.getParameter("sistema.auditoria.retention.days");
            
            if (sistemaNombre != null) configuraciones.put("sistema.nombre", sistemaNombre);
            if (sistemaTimezone != null) configuraciones.put("sistema.timezone", sistemaTimezone);
            if (sistemaIdioma != null) configuraciones.put("sistema.idioma", sistemaIdioma);
            if (sistemaPaginacion != null) configuraciones.put("sistema.paginacion.size", sistemaPaginacion);
            if (auditoriaEnabled != null) configuraciones.put("sistema.auditoria.enabled", auditoriaEnabled);
            if (auditoriaRetention != null) configuraciones.put("sistema.auditoria.retention.days", auditoriaRetention);
            
            // Configuraciones de Seguridad
            String segPasswordMin = request.getParameter("seguridad.password.min.length");
            String segPasswordUpper = request.getParameter("seguridad.password.require.uppercase");
            String segPasswordNumbers = request.getParameter("seguridad.password.require.numbers");
            String segSessionTimeout = request.getParameter("seguridad.session.timeout");
            String segMaxLoginAttempts = request.getParameter("seguridad.max.login.attempts");
            
            if (segPasswordMin != null) configuraciones.put("seguridad.password.min.length", segPasswordMin);
            if (segPasswordUpper != null) configuraciones.put("seguridad.password.require.uppercase", segPasswordUpper);
            if (segPasswordNumbers != null) configuraciones.put("seguridad.password.require.numbers", segPasswordNumbers);
            if (segSessionTimeout != null) configuraciones.put("seguridad.session.timeout", segSessionTimeout);
            if (segMaxLoginAttempts != null) configuraciones.put("seguridad.max.login.attempts", segMaxLoginAttempts);
            
            // Configuraciones de Reportes
            String reportesMaxRows = request.getParameter("reportes.excel.max.rows");
            String reportesMaxSize = request.getParameter("reportes.email.max.size.mb");
            
            if (reportesMaxRows != null) configuraciones.put("reportes.excel.max.rows", reportesMaxRows);
            if (reportesMaxSize != null) configuraciones.put("reportes.email.max.size.mb", reportesMaxSize);
            
            try {
                // Actualizar todas las configuraciones
                configDAO.actualizarMultiples(configuraciones, usuario.getIdUsuario());
                
                // Registrar en auditoría
                AuditoriaService.registrarAccion(
                    usuario,
                    AuditoriaService.ACCION_ACTUALIZAR_CONFIGURACION,
                    AuditoriaService.MODULO_SISTEMA,
                    "Configuraciones del sistema actualizadas",
                    request
                );
                
                session.setAttribute("successMsg", "Configuraciones actualizadas exitosamente.");
            } catch (Exception e) {
                session.setAttribute("errorMsg", "Error al actualizar configuraciones: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/ConfiguracionAvanzadaServlet");
    }
}

