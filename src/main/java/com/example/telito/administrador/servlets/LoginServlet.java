package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.services.AuditoriaService;
import com.example.telito.util.SecurityManager;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import com.fasterxml.jackson.databind.ObjectMapper;

@WebServlet(name = "LoginServlet", value = "/acceso/login")
public class LoginServlet extends HttpServlet {
    
    private static final String RECAPTCHA_SECRET_KEY = "6LdmmuwrAAAAALqItgI0K57xTnkT_nOZdBM7kTq7";
    private static final String RECAPTCHA_VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                // Eliminar sesión del registro de SecurityManager
                Usuario usuario = (Usuario) session.getAttribute("usuario");
                if (usuario != null) {
                    String sessionId = session.getId();
                    SecurityManager.eliminarSesion(usuario.getIdUsuario(), sessionId);
                    System.out.println("✓ Logout: Usuario ID " + usuario.getIdUsuario() + " cerró sesión");
                    
                    // Registrar logout en auditoría
                    AuditoriaService.registrarAccion(
                        usuario,
                        AuditoriaService.ACCION_LOGOUT,
                        AuditoriaService.MODULO_SEGURIDAD,
                        "Logout exitoso desde IP: " + request.getRemoteAddr(),
                        request
                    );
                }
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }

        // Verificar si hay sesión activa en ESTA petición (NO redirigir automáticamente desde login)
        // Si el usuario quiere acceder a otras páginas, el AuthFilter se encargará de validar
        // Pero desde la página de login, SIEMPRE debe mostrar el formulario de login
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            
            // Si hay una sesión válida Y está autorizada en SecurityManager
            if (usuario != null && usuario.isActivo()) {
                String sessionId = session.getId();
                // Verificar que la sesión esté autorizada (registrada en SecurityManager)
                if (SecurityManager.sesionAutorizada(usuario.getIdUsuario(), sessionId)) {
                    // Sesión válida y autorizada, redirigir al módulo correspondiente
                    redirigirSegunRol(request, response, usuario.getRol().getNombre());
                    return;
                } else {
                    // Sesión no autorizada (posible ventana incógnita o sesión inválida)
                    System.err.println("🚨 SEGURIDAD: Sesión no autorizada detectada en login - Usuario ID " + 
                                     usuario.getIdUsuario() + ", Sesión: " + sessionId);
                    session.invalidate();
                }
            } else {
                // Usuario inactivo o nulo, invalidar sesión
                if (usuario != null) {
                    SecurityManager.eliminarSesion(usuario.getIdUsuario(), session.getId());
                }
                session.invalidate();
            }
        }
        
        // Si llegamos aquí, NO hay sesión válida o no está autorizada - MOSTRAR LOGIN

        // No hay sesión activa o fue invalidada, mostrar login
        // Generar token CSRF para el formulario de login
        HttpSession nuevaSession = request.getSession(true);
        String csrfToken = SecurityManager.generarTokenCSRF(nuevaSession);
        request.setAttribute("csrfToken", csrfToken);
        
        RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
        view.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String emailOUsuario = request.getParameter("email"); // Puede ser email o nombre de usuario
        String password = request.getParameter("password");
        String csrfToken = request.getParameter("csrfToken");
        String recaptchaResponse = request.getParameter("g-recaptcha-response");

        // ========== VALIDACIONES DE SEGURIDAD ==========
        
        // 1. Validar campos vacíos
        if (emailOUsuario == null || emailOUsuario.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Por favor, complete todos los campos.");
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // 2. Validar reCAPTCHA
        if (recaptchaResponse == null || recaptchaResponse.trim().isEmpty()) {
            System.err.println("🚨 SEGURIDAD: Intento de login sin reCAPTCHA desde: " + request.getRemoteAddr());
            request.setAttribute("errorMsg", "Por favor, completa la verificación reCAPTCHA.");
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        if (!verificarRecaptcha(recaptchaResponse)) {
            System.err.println("🚨 SEGURIDAD: Intento de login con reCAPTCHA inválido desde: " + request.getRemoteAddr());
            request.setAttribute("errorMsg", "La verificación reCAPTCHA falló. Por favor, intente nuevamente.");
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // 3. Validar token CSRF
        HttpSession sessionActual = request.getSession(false);
        if (!SecurityManager.validarTokenCSRF(sessionActual, csrfToken)) {
            System.err.println("🚨 SEGURIDAD: Intento de login con token CSRF inválido desde: " + 
                             request.getRemoteAddr());
            request.setAttribute("errorMsg", "Solicitud no válida. Por favor, intente nuevamente.");
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // 4. Verificar si la cuenta está bloqueada por múltiples intentos fallidos
        if (SecurityManager.estaBloqueada(emailOUsuario)) {
            int minutosRestantes = SecurityManager.obtenerTiempoBloqueoRestante(emailOUsuario);
            System.err.println("🚨 SEGURIDAD: Intento de login con cuenta bloqueada: " + emailOUsuario);
            request.setAttribute("errorMsg", 
                String.format("Cuenta temporalmente bloqueada por múltiples intentos fallidos. " +
                            "Intente nuevamente en %d minuto(s).", minutosRestantes));
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // ========== INTENTO DE AUTENTICACIÓN ==========
        
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario usuario = usuarioDAO.autenticarUsuario(emailOUsuario.trim(), password.trim());

        if (usuario != null && usuario.isActivo()) {
            // ========== VALIDAR ACTIVACIÓN DE CUENTA ==========
            // Solo validar activación si la cuenta fue creada después de implementar el sistema de activación
            // Si cuenta_activada es false pero el usuario es antiguo (sin fecha_activacion), permitir login
            if (!usuario.isCuentaActivada()) {
                // Verificar si es un usuario antiguo (creado antes del sistema de activación)
                // Si fecha_activacion es NULL, es un usuario antiguo y se permite el login
                java.sql.Timestamp fechaActivacion = usuario.getFechaActivacion();
                if (fechaActivacion == null) {
                    // Usuario antiguo sin fecha_activacion - activar automáticamente y permitir login
                    System.out.println("ℹ Usuario antiguo detectado - activando cuenta automáticamente: " + usuario.getEmail());
                    usuarioDAO.actualizarEstadoActivacion(usuario.getIdUsuario(), true);
                    // Continuar con el login normalmente
                } else {
                    // Usuario nuevo con fecha_activacion pero cuenta no activada - bloquear
                    System.err.println("⚠ SEGURIDAD: Intento de login con cuenta no activada - Usuario ID " + 
                                     usuario.getIdUsuario() + " desde " + request.getRemoteAddr());
                    
                    request.setAttribute("errorMsg", 
                        "Tu cuenta no ha sido activada. Por favor, revisa tu correo electrónico y haz clic en el enlace de activación. " +
                        "Si no recibiste el correo, contacta al administrador.");
                    generarTokenYMostrarLogin(request, response);
                    return;
                }
            }
            
            // ========== LOGIN EXITOSO ==========
            
            // Verificar ANTES de crear sesión si el usuario ya tiene una sesión activa
            String sessionIdTentativo = request.getSession(true).getId();
            if (SecurityManager.tieneOtraSesionActiva(usuario.getIdUsuario(), sessionIdTentativo)) {
                // Ya existe otra sesión activa para este usuario - RECHAZAR EL LOGIN
                System.err.println("🚨 SEGURIDAD: Intento de login con sesión activa existente - Usuario ID " + 
                                 usuario.getIdUsuario() + " desde " + request.getRemoteAddr());
                
                // Invalidar la sesión temporal que se creó
                HttpSession tempSession = request.getSession(false);
                if (tempSession != null) {
                    tempSession.invalidate();
                }
                
                request.setAttribute("errorMsg", 
                    "Ya existe una sesión activa para este usuario en otro navegador o ventana. " +
                    "Por favor, cierre la otra sesión primero desde el menú de usuario, o espere a que expire (30 minutos de inactividad).");
                generarTokenYMostrarLogin(request, response);
                return;
            }
            
            // Resetear intentos fallidos
            SecurityManager.resetearIntentosFallidos(emailOUsuario);
            
            // Invalidar cualquier sesión anterior del mismo navegador si existe
            if (sessionActual != null) {
                sessionActual.invalidate();
            }
            
            // Crear nueva sesión
            HttpSession session = request.getSession(true);
            
            // Configurar timeout de sesión (30 minutos de inactividad)
            session.setMaxInactiveInterval(30 * 60);
            
            // Guardar información de seguridad en sesión
            String sessionId = session.getId();
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioNombre", usuario.getNombres() + " " + usuario.getApellidos());
            session.setAttribute("usuarioRol", usuario.getRol().getNombre());
            session.setAttribute("sesionActiva", true);
            session.setAttribute("sessionId", sessionId);
            session.setAttribute("ipAddress", request.getRemoteAddr());
            session.setAttribute("userAgent", request.getHeader("User-Agent"));
            session.setAttribute("ultimaActividad", System.currentTimeMillis());
            
            // Registrar sesión en SecurityManager (previene múltiples sesiones)
            boolean sesionRegistrada = SecurityManager.registrarSesion(usuario.getIdUsuario(), sessionId);
            
            if (!sesionRegistrada) {
                // Este caso no debería ocurrir porque ya verificamos arriba, pero por seguridad...
                System.err.println("🚨 SEGURIDAD: Error al registrar sesión - Usuario ID " + usuario.getIdUsuario());
                session.invalidate();
                request.setAttribute("errorMsg", 
                    "Error al crear sesión. Por favor, intente nuevamente.");
                generarTokenYMostrarLogin(request, response);
                return;
            }
            
            // Generar nuevo token CSRF para la sesión activa
            SecurityManager.generarTokenCSRF(session);
            
            System.out.println("✓ Login exitoso: Usuario ID " + usuario.getIdUsuario() + 
                             " (" + usuario.getEmail() + ") desde " + request.getRemoteAddr());
            
            // Registrar login exitoso en auditoría
            AuditoriaService.registrarAccion(
                usuario,
                AuditoriaService.ACCION_LOGIN,
                AuditoriaService.MODULO_SEGURIDAD,
                "Login exitoso desde IP: " + request.getRemoteAddr(),
                request
            );
            
            redirigirSegunRol(request, response, usuario.getRol().getNombre());
        } else {
            // ========== LOGIN FALLIDO ==========
            
            // Registrar intento fallido
            SecurityManager.registrarIntentoFallido(emailOUsuario);
            
            int intentosRestantes = SecurityManager.obtenerIntentosRestantes(emailOUsuario);
            String mensajeError = "Credenciales incorrectas o usuario inactivo.";
            
            if (intentosRestantes > 0 && intentosRestantes < 5) {
                mensajeError += String.format(" Intentos restantes: %d", intentosRestantes);
            } else if (SecurityManager.estaBloqueada(emailOUsuario)) {
                int minutosRestantes = SecurityManager.obtenerTiempoBloqueoRestante(emailOUsuario);
                mensajeError = String.format("Cuenta bloqueada temporalmente. Intente nuevamente en %d minuto(s).", 
                                           minutosRestantes);
            }
            
            System.err.println("⚠ SEGURIDAD: Intento de login fallido para: " + emailOUsuario + 
                             " desde " + request.getRemoteAddr());
            
            // Registrar intento de login fallido en auditoría (sin usuario, ya que no se autenticó)
            AuditoriaService.registrarAccion(
                null, // Usuario no autenticado
                AuditoriaService.ACCION_LOGIN,
                AuditoriaService.MODULO_SEGURIDAD,
                "Intento de login fallido para: " + emailOUsuario + " desde IP: " + request.getRemoteAddr(),
                null,
                null,
                "FALLIDO",
                "Credenciales incorrectas o usuario inactivo",
                request
            );
            
            request.setAttribute("errorMsg", mensajeError);
            generarTokenYMostrarLogin(request, response);
        }
    }
    
    /**
     * Genera un token CSRF y muestra la página de login.
     */
    private void generarTokenYMostrarLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        String csrfToken = SecurityManager.generarTokenCSRF(session);
        request.setAttribute("csrfToken", csrfToken);
        
        RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
        view.forward(request, response);
    }

    private void redirigirSegunRol(HttpServletRequest request, HttpServletResponse response, String rolNombre) throws IOException {
        String contextPath = request.getContextPath();

        switch (rolNombre.toLowerCase()) {
            case "administrador":
                response.sendRedirect(contextPath + "/inicio");
                break;
            case "logística":
            case "logistica":
                // Redirigir al dashboard logístico
                response.sendRedirect(contextPath + "/logistica/DashboardLogisticaServlet");
                break;
            case "almacenero":
                response.sendRedirect(contextPath + "/almacen/index.jsp");
                break;
            case "productor":
                response.sendRedirect(contextPath + "/productor/DashboardProductorServlet");
                break;
            default:
                response.sendRedirect(contextPath + "/acceso/login");
                break;
        }
    }
    
    /**
     * Verifica el token de reCAPTCHA con Google.
     * 
     * @param recaptchaResponse Token de respuesta de reCAPTCHA
     * @return true si el token es válido, false en caso contrario
     */
    private boolean verificarRecaptcha(String recaptchaResponse) {
        if (recaptchaResponse == null || recaptchaResponse.isEmpty()) {
            return false;
        }
        
        try {
            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(10))
                    .build();
            
            String params = "secret=" + RECAPTCHA_SECRET_KEY + "&response=" + recaptchaResponse;
            
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(RECAPTCHA_VERIFY_URL))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(params))
                    .build();
            
            HttpResponse<String> httpResponse = client.send(request, HttpResponse.BodyHandlers.ofString());
            
            ObjectMapper mapper = new ObjectMapper();
            RecaptchaResponse jsonResponse = mapper.readValue(httpResponse.body(), RecaptchaResponse.class);
            
            return jsonResponse.isSuccess();
            
        } catch (Exception e) {
            System.err.println("Error al verificar reCAPTCHA: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Clase interna para mapear la respuesta de reCAPTCHA.
     */
    public static class RecaptchaResponse {
        private boolean success;
        private String challenge_ts;
        private String hostname;
        private String[] errorCodes;
        
        public boolean isSuccess() {
            return success;
        }
        
        public void setSuccess(boolean success) {
            this.success = success;
        }
        
        public String getChallenge_ts() {
            return challenge_ts;
        }
        
        public void setChallenge_ts(String challenge_ts) {
            this.challenge_ts = challenge_ts;
        }
        
        public String getHostname() {
            return hostname;
        }
        
        public void setHostname(String hostname) {
            this.hostname = hostname;
        }
        
        public String[] getErrorCodes() {
            return errorCodes;
        }
        
        public void setErrorCodes(String[] errorCodes) {
            this.errorCodes = errorCodes;
        }
    }
}
