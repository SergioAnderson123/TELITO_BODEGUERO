package com.example.telito.util;

import jakarta.servlet.http.HttpSession;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

/**
 * Gestor de seguridad para controlar sesiones activas y seguridad del sistema.
 * Previene múltiples sesiones simultáneas del mismo usuario.
 */
public class SecurityManager {
    
    // Almacenar sesiones activas por ID de usuario: Map<userId, sessionId>
    private static final Map<Integer, String> sesionesActivasPorUsuario = new ConcurrentHashMap<>();
    
    // Almacenar intentos de login fallidos: Map<emailOrUser, count>
    private static final Map<String, Integer> intentosLoginFallidos = new ConcurrentHashMap<>();
    
    // Almacenar timestamps de últimos intentos: Map<emailOrUser, timestamp>
    private static final Map<String, Long> ultimosIntentos = new ConcurrentHashMap<>();
    
    // Configuración de seguridad
    private static final int MAX_INTENTOS_LOGIN = 5;
    private static final long TIEMPO_BLOQUEO_MINUTOS = 15; // 15 minutos
    private static final long TIEMPO_BLOQUEO_MS = TIEMPO_BLOQUEO_MINUTOS * 60 * 1000;
    
    /**
     * Registra una sesión activa para un usuario.
     * Si el usuario ya tiene una sesión activa, NO permite registrar otra nueva.
     * 
     * @param usuarioId ID del usuario
     * @param sessionId ID de la sesión actual
     * @return true si se registró exitosamente, false si ya había otra sesión activa
     */
    public static synchronized boolean registrarSesion(int usuarioId, String sessionId) {
        String sesionAnterior = sesionesActivasPorUsuario.get(usuarioId);
        
        if (sesionAnterior != null && !sesionAnterior.equals(sessionId)) {
            // Ya existe otra sesión activa para este usuario - NO PERMITIR NUEVA SESIÓN
            System.err.println("🚨 SEGURIDAD: Usuario ID " + usuarioId + " ya tiene sesión activa (ID: " + sesionAnterior + ") - Rechazando nueva sesión: " + sessionId);
            return false;
        }
        
        // Si no hay sesión anterior o es la misma sesión, registrar
        sesionesActivasPorUsuario.put(usuarioId, sessionId);
        System.out.println("✓ Sesión registrada para usuario ID " + usuarioId + " (Sesión: " + sessionId + ")");
        return true;
    }
    
    /**
     * Elimina una sesión activa cuando el usuario cierra sesión.
     * 
     * @param usuarioId ID del usuario
     * @param sessionId ID de la sesión a eliminar
     */
    public static synchronized void eliminarSesion(int usuarioId, String sessionId) {
        String sesionActiva = sesionesActivasPorUsuario.get(usuarioId);
        if (sesionActiva != null && sesionActiva.equals(sessionId)) {
            sesionesActivasPorUsuario.remove(usuarioId);
            System.out.println("✓ Sesión eliminada para usuario ID " + usuarioId);
        }
    }
    
    /**
     * Verifica si un usuario tiene una sesión activa diferente a la actual.
     * 
     * @param usuarioId ID del usuario
     * @param sessionId ID de la sesión actual
     * @return true si hay otra sesión activa, false si no hay o es la misma
     */
    public static boolean tieneOtraSesionActiva(int usuarioId, String sessionId) {
        String sesionActiva = sesionesActivasPorUsuario.get(usuarioId);
        return sesionActiva != null && !sesionActiva.equals(sessionId);
    }
    
    /**
     * Verifica si una sesión está autorizada (es la sesión activa registrada).
     * 
     * @param usuarioId ID del usuario
     * @param sessionId ID de la sesión a verificar
     * @return true si la sesión está autorizada, false si no
     */
    public static boolean sesionAutorizada(int usuarioId, String sessionId) {
        String sesionActiva = sesionesActivasPorUsuario.get(usuarioId);
        return sesionActiva != null && sesionActiva.equals(sessionId);
    }
    
    /**
     * Registra un intento de login fallido.
     * 
     * @param emailOUsuario Email o nombre de usuario que intentó iniciar sesión
     */
    public static synchronized void registrarIntentoFallido(String emailOUsuario) {
        String clave = emailOUsuario.toLowerCase().trim();
        int intentos = intentosLoginFallidos.getOrDefault(clave, 0);
        intentosLoginFallidos.put(clave, intentos + 1);
        ultimosIntentos.put(clave, System.currentTimeMillis());
        
        System.out.println("⚠ SEGURIDAD: Intento de login fallido para: " + emailOUsuario + 
                          " (Intento #" + (intentos + 1) + ")");
        
        // Logging de seguridad
        if (intentos + 1 >= MAX_INTENTOS_LOGIN) {
            System.err.println("🚨 ALERTA DE SEGURIDAD: Múltiples intentos de login fallidos para: " + emailOUsuario);
        }
    }
    
    /**
     * Resetea los intentos de login fallidos después de un login exitoso.
     * 
     * @param emailOUsuario Email o nombre de usuario
     */
    public static synchronized void resetearIntentosFallidos(String emailOUsuario) {
        String clave = emailOUsuario.toLowerCase().trim();
        intentosLoginFallidos.remove(clave);
        ultimosIntentos.remove(clave);
    }
    
    /**
     * Verifica si una cuenta está bloqueada por múltiples intentos fallidos.
     * 
     * @param emailOUsuario Email o nombre de usuario
     * @return true si está bloqueada, false si no
     */
    public static synchronized boolean estaBloqueada(String emailOUsuario) {
        String clave = emailOUsuario.toLowerCase().trim();
        int intentos = intentosLoginFallidos.getOrDefault(clave, 0);
        
        if (intentos < MAX_INTENTOS_LOGIN) {
            return false;
        }
        
        // Verificar si el tiempo de bloqueo ha expirado
        Long ultimoIntento = ultimosIntentos.get(clave);
        if (ultimoIntento != null) {
            long tiempoTranscurrido = System.currentTimeMillis() - ultimoIntento;
            if (tiempoTranscurrido > TIEMPO_BLOQUEO_MS) {
                // El tiempo de bloqueo ha expirado, desbloquear
                intentosLoginFallidos.remove(clave);
                ultimosIntentos.remove(clave);
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Obtiene el número de intentos de login fallidos restantes.
     * 
     * @param emailOUsuario Email o nombre de usuario
     * @return Número de intentos restantes antes del bloqueo
     */
    public static synchronized int obtenerIntentosRestantes(String emailOUsuario) {
        String clave = emailOUsuario.toLowerCase().trim();
        int intentos = intentosLoginFallidos.getOrDefault(clave, 0);
        return Math.max(0, MAX_INTENTOS_LOGIN - intentos);
    }
    
    /**
     * Obtiene el tiempo restante de bloqueo en minutos.
     * 
     * @param emailOUsuario Email o nombre de usuario
     * @return Minutos restantes de bloqueo, o 0 si no está bloqueada
     */
    public static synchronized int obtenerTiempoBloqueoRestante(String emailOUsuario) {
        String clave = emailOUsuario.toLowerCase().trim();
        
        if (!estaBloqueada(emailOUsuario)) {
            return 0;
        }
        
        Long ultimoIntento = ultimosIntentos.get(clave);
        if (ultimoIntento != null) {
            long tiempoTranscurrido = System.currentTimeMillis() - ultimoIntento;
            long tiempoRestante = TIEMPO_BLOQUEO_MS - tiempoTranscurrido;
            return (int) Math.ceil(tiempoRestante / (60.0 * 1000.0));
        }
        
        return 0;
    }
    
    /**
     * Genera un token CSRF único para la sesión.
     * 
     * @param session Sesión HTTP
     * @return Token CSRF generado
     */
    public static String generarTokenCSRF(HttpSession session) {
        String token = java.util.UUID.randomUUID().toString();
        session.setAttribute("csrfToken", token);
        return token;
    }
    
    /**
     * Verifica si un token CSRF es válido para la sesión.
     * 
     * @param session Sesión HTTP
     * @param token Token a verificar
     * @return true si el token es válido, false si no
     */
    public static boolean validarTokenCSRF(HttpSession session, String token) {
        if (session == null || token == null) {
            return false;
        }
        
        String tokenSesion = (String) session.getAttribute("csrfToken");
        return tokenSesion != null && tokenSesion.equals(token);
    }
    
    /**
     * Limpia sesiones inactivas del registro (útil para limpieza periódica).
     */
    public static synchronized void limpiarSesionesInactivas() {
        // Este método puede ser llamado periódicamente para limpiar sesiones que ya expiraron
        // Por ahora, las sesiones se eliminan cuando se hace logout o cuando se detecta otra sesión
        System.out.println("🧹 Limpieza de sesiones inactivas (sesiones activas: " + sesionesActivasPorUsuario.size() + ")");
    }
}

