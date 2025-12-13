package com.example.telito.administrador.servlets;

import com.example.telito.administrador.services.AuditoriaCleanupService;
import com.example.telito.util.AuthorizationHelper;
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
 * Servlet para ejecutar manualmente la limpieza de auditoría.
 * También muestra estadísticas y configuración del sistema.
 * 
 * @author Telito Bodeguero
 * @version 1.0
 */
@WebServlet(name = "AuditoriaCleanupServlet", value = "/AuditoriaCleanupServlet")
public class AuditoriaCleanupServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(AuditoriaCleanupServlet.class);
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            logger.warn("🚨 Acceso denegado a limpieza de auditoría desde: {}", request.getRemoteAddr());
            response.sendRedirect(AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath()));
            return;
        }
        
        // Redirigir a la página de auditoría con mensaje
        request.getSession().setAttribute("cleanupAvailable", true);
        response.sendRedirect(request.getContextPath() + "/AuditoriaServlet");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar que el usuario tenga rol de administrador
        HttpSession session = request.getSession(false);
        if (!AuthorizationHelper.puedeAccederAdministrador(session)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"success\": false, \"message\": \"Acceso denegado\"}");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("ejecutar_limpieza".equals(action)) {
            ejecutarLimpieza(request, response);
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Acción no válida\"}");
        }
    }
    
    /**
     * Ejecuta la limpieza de auditoría y retorna el resultado en JSON.
     */
    private void ejecutarLimpieza(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            logger.info("🧹 Iniciando limpieza manual de auditoría por usuario: {}", 
                    request.getSession().getAttribute("username"));
            
            AuditoriaCleanupService cleanupService = new AuditoriaCleanupService();
            AuditoriaCleanupService.ResultadoLimpieza resultado = cleanupService.ejecutarLimpieza();
            
            // Construir respuesta JSON
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"success\": ").append(resultado.exito).append(",");
            json.append("\"message\": \"").append(escapeJson(resultado.mensaje)).append("\",");
            json.append("\"registrosTotalesAntes\": ").append(resultado.registrosTotalesAntes).append(",");
            json.append("\"registrosTotalesDespues\": ").append(resultado.registrosTotalesDespues).append(",");
            json.append("\"registrosEliminados\": ").append(resultado.registrosEliminados).append(",");
            json.append("\"reporteEnviado\": ").append(resultado.reporteEnviado).append(",");
            json.append("\"espacioLiberadoKB\": ").append(resultado.espacioLiberadoKB);
            json.append("}");
            
            response.getWriter().write(json.toString());
            
            logger.info("✅ Limpieza completada: {}", resultado);
            
        } catch (Exception e) {
            logger.error("❌ Error al ejecutar limpieza de auditoría", e);
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    /**
     * Escapa caracteres especiales para JSON.
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
