package com.example.telito.administrador.filters;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.util.SecurityManager;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

// NOTA: Este filtro está configurado en web.xml para garantizar el orden de ejecución
// y asegurar que se ejecute ANTES que otros filtros que puedan crear sesiones
// NO usar @WebFilter aquí para evitar conflictos con web.xml
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
        String path = requestURI.substring(contextPath.length());
        
        // Permitir acceso sin autenticación solo a estas rutas específicas
        if (path.equals("/") || 
            path.equals("/acceso/login") ||
            path.equals("/login") ||
            path.equals("/welcome.jsp") ||
            path.equals("/login.jsp") ||
            path.startsWith("/assets/") ||
            path.startsWith("/css/") ||
            path.startsWith("/js/") ||
            path.startsWith("/images/") ||
            path.startsWith("/uploads/")) {
            chain.doFilter(request, response);
            return;
        }
        
        // TODAS LAS DEMÁS RUTAS REQUIEREN AUTENTICACIÓN - CONTINUAR CON VALIDACIÓN
        
        // ========== VALIDACIÓN PRINCIPAL DE SESIÓN ==========
        // IMPORTANTE: getSession(false) NO crea una sesión nueva si no existe
        // En ventana incógnita NO debería haber cookie de sesión, así que retornará null
        HttpSession session = httpRequest.getSession(false);
        
        // 1. PRIMERO: Verificar que exista una sesión HTTP (cookie de sesión)
        if (session == null) {
            // NO hay cookie de sesión (ventana incógnita o sesión expirada)
            System.err.println("🚨 SEGURIDAD: Acceso denegado - No hay sesión HTTP (posible ventana incógnita) desde: " + 
                             httpRequest.getRemoteAddr() + " | URI: " + requestURI);
            httpResponse.sendRedirect(contextPath + "/acceso/login");
            return;
        }
        
        // 2. Verificar que la sesión tenga los atributos necesarios
        if (session.getAttribute("usuario") == null || 
            session.getAttribute("sesionActiva") == null) {
            // Sesión existe pero NO está autenticada (no tiene atributos de usuario)
            System.err.println("🚨 SEGURIDAD: Acceso denegado - Sesión sin autenticación desde: " + 
                             httpRequest.getRemoteAddr() + " | Sesión ID: " + session.getId());
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/acceso/login");
            return;
        }
        
        // 2. Verificar que el usuario esté activo
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (usuario == null || !usuario.isActivo()) {
            // Usuario nulo o inactivo
            if (usuario != null) {
                SecurityManager.eliminarSesion(usuario.getIdUsuario(), session.getId());
                System.err.println("🚨 SEGURIDAD: Usuario inactivo intentando acceder - Usuario ID " + 
                                 usuario.getIdUsuario() + " desde: " + httpRequest.getRemoteAddr());
            }
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/acceso/login");
            return;
        }
        
        // ========== VALIDACIONES DE SEGURIDAD ADICIONALES ==========
        
        // 1. Verificar que la sesión esté autorizada (previene sesiones duplicadas o no válidas)
        String sessionId = session.getId();
        if (!SecurityManager.sesionAutorizada(usuario.getIdUsuario(), sessionId)) {
            System.err.println("🚨 SEGURIDAD: Sesión no autorizada detectada - Usuario ID " + 
                             usuario.getIdUsuario() + ", Sesión: " + sessionId);
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/acceso/login");
            return;
        }
        
        // 2. Verificar si hay otra sesión activa (posible intento de acceso desde otra ubicación)
        if (SecurityManager.tieneOtraSesionActiva(usuario.getIdUsuario(), sessionId)) {
            System.err.println("🚨 SEGURIDAD: Múltiples sesiones detectadas - Usuario ID " + 
                             usuario.getIdUsuario() + ". Invalidando sesión actual.");
            SecurityManager.eliminarSesion(usuario.getIdUsuario(), sessionId);
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/acceso/login");
            return;
        }
        
        // 3. Verificar que la sesión no haya expirado (validación adicional)
        long ahora = System.currentTimeMillis();
        Long ultimaActividad = (Long) session.getAttribute("ultimaActividad");
        if (ultimaActividad != null) {
            long tiempoInactivo = ahora - ultimaActividad;
            // Si ha pasado más de 30 minutos, invalidar sesión
            if (tiempoInactivo > 30 * 60 * 1000) {
                System.out.println("⚠ Sesión expirada por inactividad - Usuario ID " + usuario.getIdUsuario());
                SecurityManager.eliminarSesion(usuario.getIdUsuario(), sessionId);
                session.invalidate();
                httpResponse.sendRedirect(contextPath + "/acceso/login");
                return;
            }
        }
        
        // 4. Verificar cambio de IP o User-Agent (posible sesión robada)
        String ipGuardada = (String) session.getAttribute("ipAddress");
        String userAgentGuardado = (String) session.getAttribute("userAgent");
        String ipActual = httpRequest.getRemoteAddr();
        String userAgentActual = httpRequest.getHeader("User-Agent");
        
        // Comentado por ahora para no ser demasiado restrictivo
        // Puedes descomentar si quieres validar IP y User-Agent
        /*
        if (ipGuardada != null && !ipGuardada.equals(ipActual)) {
            System.err.println("🚨 SEGURIDAD: Cambio de IP detectado - Usuario ID " + 
                             usuario.getIdUsuario() + " (IP anterior: " + ipGuardada + 
                             ", IP actual: " + ipActual + ")");
            SecurityManager.eliminarSesion(usuario.getIdUsuario(), sessionId);
            session.invalidate();
            httpResponse.sendRedirect(contextPath + "/acceso/login");
            return;
        }
        */
        
        // Actualizar tiempo de última actividad
        session.setAttribute("ultimaActividad", ahora);
        
        // Continuar con la cadena de filtros
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Limpieza del filtro
    }
}

