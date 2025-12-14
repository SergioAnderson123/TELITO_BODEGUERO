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

// Maneja el login y logout del sistema
@WebServlet(name = "LoginServlet", value = "/acceso/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        // Si viene el parámetro logout, invalidar sesión y redirigir
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                // Eliminar sesión del registro de SecurityManager
                Usuario usuario = (Usuario) session.getAttribute("usuario");
                if (usuario != null) {
                    String sessionId = session.getId();
                    // Limpiar registro de sesión activa
                    SecurityManager.eliminarSesion(usuario.getIdUsuario(), sessionId);
                    System.out.println("✓ Logout: Usuario ID " + usuario.getIdUsuario() + " cerró sesión");
                    
                    // Guardar en auditoría antes de invalidar
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

        // Si ya hay sesión activa y válida, redirigir al módulo correspondiente
        // Si no, mostrar el formulario de login
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            
            if (usuario != null && usuario.isActivo()) {
                String sessionId = session.getId();
                // Verificar que la sesión esté registrada en SecurityManager
                if (SecurityManager.sesionAutorizada(usuario.getIdUsuario(), sessionId)) {
                    redirigirSegunRol(request, response, usuario.getRol().getNombre());
                    return;
                } else {
                    // Sesión no autorizada, posible ventana incógnita
                    System.err.println("🚨 SEGURIDAD: Sesión no autorizada detectada en login - Usuario ID " + 
                                     usuario.getIdUsuario() + ", Sesión: " + sessionId);
                    session.invalidate();
                }
            } else {
                // Usuario inactivo, limpiar todo
                if (usuario != null) {
                    SecurityManager.eliminarSesion(usuario.getIdUsuario(), session.getId());
                }
                session.invalidate();
            }
        }
        
        // Mostrar formulario de login con token CSRF
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

        // Validaciones de seguridad antes de autenticar
        // Campos vacíos
        if (emailOUsuario == null || emailOUsuario.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Por favor, complete todos los campos.");
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // Validar token CSRF - obtener sesión sin crear una nueva
        HttpSession sessionActual = request.getSession(false);
        
        // Si no hay sesión, expiró - mostrar login de nuevo
        if (sessionActual == null) {
            System.err.println("⚠ SEGURIDAD: Sesión expiró antes del login desde: " + request.getRemoteAddr());
            request.setAttribute("errorMsg", "Su sesión ha expirado. Por favor, intente nuevamente.");
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // Verificar que el token CSRF sea válido
        if (!SecurityManager.validarTokenCSRF(sessionActual, csrfToken)) {
            System.err.println("🚨 SEGURIDAD: Token CSRF inválido desde: " + request.getRemoteAddr() + 
                             " - Token recibido: [" + (csrfToken != null ? csrfToken : "null") + 
                             "] - Token esperado: [" + sessionActual.getAttribute("csrfToken") + "]");
            request.setAttribute("errorMsg", "Solicitud no válida. Por favor, intente nuevamente.");
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // Verificar bloqueo por intentos fallidos
        if (SecurityManager.estaBloqueada(emailOUsuario)) {
            int minutosRestantes = SecurityManager.obtenerTiempoBloqueoRestante(emailOUsuario);
            System.err.println("🚨 SEGURIDAD: Intento de login con cuenta bloqueada: " + emailOUsuario);
            request.setAttribute("errorMsg", 
                String.format("Cuenta temporalmente bloqueada por múltiples intentos fallidos. " +
                            "Intente nuevamente en %d minuto(s).", minutosRestantes));
            generarTokenYMostrarLogin(request, response);
            return;
        }
        
        // Intentar autenticar usuario
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario usuario = usuarioDAO.autenticarUsuario(emailOUsuario.trim(), password.trim());

        if (usuario != null && usuario.isActivo()) {
            // Validar activación de cuenta
            // Usuarios antiguos (sin fecha_activacion) se activan automáticamente
            if (!usuario.isCuentaActivada()) {
                java.sql.Timestamp fechaActivacion = usuario.getFechaActivacion();
                if (fechaActivacion == null) {
                    // Usuario antiguo, activar automáticamente
                    System.out.println("ℹ Usuario antiguo detectado - activando cuenta automáticamente: " + usuario.getEmail());
                    usuarioDAO.actualizarEstadoActivacion(usuario.getIdUsuario(), true);
                } else {
                    // Usuario nuevo sin activar, bloquear login
                    System.err.println("⚠ SEGURIDAD: Intento de login con cuenta no activada - Usuario ID " + 
                                     usuario.getIdUsuario() + " desde " + request.getRemoteAddr());
                    
                    request.setAttribute("errorMsg", 
                        "Tu cuenta no ha sido activada. Por favor, revisa tu correo electrónico y haz clic en el enlace de activación. " +
                        "Si no recibiste el correo, contacta al administrador.");
                    generarTokenYMostrarLogin(request, response);
                    return;
                }
            }
            
            // Login exitoso - configurar sesión
            SecurityManager.resetearIntentosFallidos(emailOUsuario);
            
            // Invalidar sesión anterior si existe
            if (sessionActual != null) {
                sessionActual.invalidate();
            }
            
            // Crear nueva sesión
            HttpSession session = request.getSession(true);
            String sessionId = session.getId();
            
            // Verificar si ya hay otra sesión activa (evitar múltiples sesiones)
            if (SecurityManager.tieneOtraSesionActiva(usuario.getIdUsuario(), sessionId)) {
                System.err.println("🚨 SEGURIDAD: Intento de login con sesión activa existente - Usuario ID " + 
                                 usuario.getIdUsuario() + " desde " + request.getRemoteAddr());
                
                session.invalidate();
                request.setAttribute("errorMsg", 
                    "Ya existe una sesión activa para este usuario en otro navegador o ventana. " +
                    "Por favor, cierre la otra sesión primero desde el menú de usuario, o espere a que expire (30 minutos de inactividad).");
                generarTokenYMostrarLogin(request, response);
                return;
            }
            
            // Timeout de 30 minutos de inactividad
            session.setMaxInactiveInterval(30 * 60);
            
            // Guardar datos en sesión
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioNombre", usuario.getNombres() + " " + usuario.getApellidos());
            session.setAttribute("usuarioRol", usuario.getRol().getNombre());
            session.setAttribute("sesionActiva", true);
            session.setAttribute("sessionId", sessionId);
            session.setAttribute("ipAddress", request.getRemoteAddr());
            session.setAttribute("userAgent", request.getHeader("User-Agent"));
            session.setAttribute("ultimaActividad", System.currentTimeMillis());
            
            // Registrar sesión en SecurityManager
            boolean sesionRegistrada = SecurityManager.registrarSesion(usuario.getIdUsuario(), sessionId);
            
            if (!sesionRegistrada) {
                // No debería pasar, pero por seguridad...
                System.err.println("🚨 SEGURIDAD: Error al registrar sesión - Usuario ID " + usuario.getIdUsuario());
                session.invalidate();
                request.setAttribute("errorMsg", 
                    "Error al crear sesión. Por favor, intente nuevamente.");
                generarTokenYMostrarLogin(request, response);
                return;
            }
            
            // Generar token CSRF para esta sesión
            SecurityManager.generarTokenCSRF(session);
            
            System.out.println("✓ Login exitoso: Usuario ID " + usuario.getIdUsuario() + 
                             " (" + usuario.getEmail() + ") desde " + request.getRemoteAddr());
            
            // Registrar en auditoría
            AuditoriaService.registrarAccion(
                usuario,
                AuditoriaService.ACCION_LOGIN,
                AuditoriaService.MODULO_SEGURIDAD,
                "Login exitoso desde IP: " + request.getRemoteAddr(),
                request
            );
            
            redirigirSegunRol(request, response, usuario.getRol().getNombre());
        } else {
            // Login fallido - registrar intento y mostrar error
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
            
            // Registrar en auditoría (sin usuario porque no se autenticó)
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
    
    // Genera token CSRF y muestra el formulario de login
    private void generarTokenYMostrarLogin(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        String csrfToken = SecurityManager.generarTokenCSRF(session);
        request.setAttribute("csrfToken", csrfToken);
        
        RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
        view.forward(request, response);
    }

    // Redirige al dashboard según el rol del usuario
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
            case "gerente de tienda":
                response.sendRedirect(contextPath + "/gerente-tienda/index.jsp");
                break;
            default:
                response.sendRedirect(contextPath + "/acceso/login");
                break;
        }
    }
}
