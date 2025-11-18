package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.util.TokenService;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Servlet para manejar la recuperación de contraseñas.
 * 
 * MEJORAS SOBRE TELITO_RRHH:
 * - Validación de fortaleza de contraseña
 * - Confirmación de contraseña
 * - Hash seguro de contraseñas (SHA-256)
 * - Validación de token más robusta
 * - Mejor manejo de errores
 * 
 * @author Telito Bodeguero
 * @version 2.0
 */
@WebServlet(name = "PasswordResetServlet", value = "/acceso/recuperar")
public class PasswordResetServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(PasswordResetServlet.class);
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String token = request.getParameter("token");
        
        // Si hay un token pero no hay action, asumir que se debe verificar el token
        if (action == null && token != null && !token.trim().isEmpty()) {
            action = "verificarToken";
        }
        
        if (action == null) {
            action = "solicitar";
        }
        
        switch (action) {
            case "solicitar":
                // Mostrar formulario de solicitud de recuperación
                mostrarFormularioSolicitud(request, response);
                break;
                
            case "verificarToken":
                // Verificar token y mostrar formulario de cambio de contraseña
                if (token == null || token.trim().isEmpty()) {
                    request.setAttribute("error", "Token de recuperación no proporcionado.");
                    mostrarFormularioSolicitud(request, response);
                    return;
                }
                
                String ipAddress = request.getRemoteAddr();
                String userAgent = request.getHeader("User-Agent");
                
                int usuarioId = TokenService.validarTokenRecuperacion(token.trim(), ipAddress, userAgent);
                
                if (usuarioId > 0) {
                    // Token válido, mostrar formulario de cambio de contraseña
                    request.setAttribute("token", token);
                    request.setAttribute("tokenValido", true);
                    RequestDispatcher view = request.getRequestDispatcher("/acceso/recuperar-contrasena.jsp");
                    view.forward(request, response);
                } else {
                    // Token inválido o expirado
                    request.setAttribute("error", "El token de recuperación es inválido o ha expirado. Por favor, solicita un nuevo enlace.");
                    mostrarFormularioSolicitud(request, response);
                }
                break;
                
            default:
                mostrarFormularioSolicitud(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "solicitar";
        }
        
        switch (action) {
            case "solicitar":
                procesarSolicitudRecuperacion(request, response);
                break;
                
            case "cambiar":
                procesarCambioContrasena(request, response);
                break;
                
            default:
                mostrarFormularioSolicitud(request, response);
                break;
        }
    }
    
    /**
     * Muestra el formulario de solicitud de recuperación.
     */
    private void mostrarFormularioSolicitud(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        RequestDispatcher view = request.getRequestDispatcher("/acceso/recuperar-contrasena.jsp");
        view.forward(request, response);
    }
    
    /**
     * Procesa la solicitud de recuperación de contraseña.
     */
    private void procesarSolicitudRecuperacion(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Por favor, ingresa tu dirección de correo electrónico.");
            mostrarFormularioSolicitud(request, response);
            return;
        }
        
        try {
            String ipAddress = request.getRemoteAddr();
            String userAgent = request.getHeader("User-Agent");
            
            // Crear token de recuperación (no revela si el email existe por seguridad)
            String token = TokenService.crearTokenRecuperacion(email.trim(), ipAddress, userAgent);
            
            if (token != null) {
                // Token creado exitosamente, enviar email
                UsuarioDAO usuarioDAO = new UsuarioDAO();
                Usuario usuario = usuarioDAO.obtenerUsuarioPorEmail(email.trim());
                
                if (usuario != null) {
                    String nombreUsuario = usuario.getNombres() + " " + usuario.getApellidos();
                    String contextPath = request.getContextPath();
                    
                    // Enviar email de recuperación
                    boolean emailEnviado = com.example.telito.util.EmailService.enviarCorreoRecuperacion(
                        email.trim(), nombreUsuario, token, contextPath
                    );
                    
                    if (emailEnviado) {
                        logger.info("✓ Email de recuperación enviado a: {}", email);
                        request.setAttribute("exito", true);
                        request.setAttribute("mensaje", 
                            "Si el correo electrónico existe en nuestro sistema, recibirás un enlace " +
                            "para restablecer tu contraseña en los próximos minutos. " +
                            "Por favor, revisa tu bandeja de entrada y carpeta de spam.");
                    } else {
                        logger.error("✗ Error al enviar email de recuperación a: {}", email);
                        request.setAttribute("error", 
                            "Hubo un error al enviar el correo de recuperación. Por favor, intenta nuevamente más tarde.");
                    }
                } else {
                    // No revelar que el email no existe (por seguridad)
                    request.setAttribute("exito", true);
                    request.setAttribute("mensaje", 
                        "Si el correo electrónico existe en nuestro sistema, recibirás un enlace " +
                        "para restablecer tu contraseña en los próximos minutos.");
                }
            } else {
                // No revelar que el email no existe (por seguridad)
                request.setAttribute("exito", true);
                request.setAttribute("mensaje", 
                    "Si el correo electrónico existe en nuestro sistema, recibirás un enlace " +
                    "para restablecer tu contraseña en los próximos minutos.");
            }
            
        } catch (SecurityException e) {
            logger.warn("⚠ Límite de solicitudes alcanzado para: {}", email);
            request.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            logger.error("✗ Error al procesar solicitud de recuperación", e);
            request.setAttribute("error", "Hubo un error al procesar tu solicitud. Por favor, intenta nuevamente más tarde.");
        }
        
        mostrarFormularioSolicitud(request, response);
    }
    
    /**
     * Procesa el cambio de contraseña.
     */
    private void procesarCambioContrasena(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        String nuevaContrasena = request.getParameter("nueva_contrasena");
        String confirmarContrasena = request.getParameter("confirmar_contrasena");
        
        // Validaciones
        if (token == null || token.trim().isEmpty()) {
            request.setAttribute("error", "Token de recuperación no proporcionado.");
            mostrarFormularioSolicitud(request, response);
            return;
        }
        
        if (nuevaContrasena == null || nuevaContrasena.trim().isEmpty()) {
            request.setAttribute("error", "Por favor, ingresa una nueva contraseña.");
            request.setAttribute("token", token);
            request.setAttribute("tokenValido", true);
            RequestDispatcher view = request.getRequestDispatcher("/acceso/recuperar-contrasena.jsp");
            view.forward(request, response);
            return;
        }
        
        if (!nuevaContrasena.equals(confirmarContrasena)) {
            request.setAttribute("error", "Las contraseñas no coinciden.");
            request.setAttribute("token", token);
            request.setAttribute("tokenValido", true);
            RequestDispatcher view = request.getRequestDispatcher("/acceso/recuperar-contrasena.jsp");
            view.forward(request, response);
            return;
        }
        
        // Validar fortaleza de contraseña
        if (!validarFortalezaContrasena(nuevaContrasena)) {
            request.setAttribute("error", 
                "La contraseña debe tener al menos 8 caracteres, incluyendo letras y números.");
            request.setAttribute("token", token);
            request.setAttribute("tokenValido", true);
            RequestDispatcher view = request.getRequestDispatcher("/acceso/recuperar-contrasena.jsp");
            view.forward(request, response);
            return;
        }
        
        // Validar token
        String ipAddress = request.getRemoteAddr();
        String userAgent = request.getHeader("User-Agent");
        
        int usuarioId = TokenService.validarTokenRecuperacion(token.trim(), ipAddress, userAgent);
        
        if (usuarioId <= 0) {
            request.setAttribute("error", "El token de recuperación es inválido o ha expirado.");
            mostrarFormularioSolicitud(request, response);
            return;
        }
        
        // Cambiar contraseña
        try {
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            String contrasenaHash = hashPassword(nuevaContrasena);
            
            boolean actualizado = usuarioDAO.actualizarContrasena(usuarioId, contrasenaHash);
            
            if (actualizado) {
                // Marcar token como usado
                TokenService.marcarTokenRecuperacionComoUsado(token.trim(), ipAddress, userAgent);
                
                logger.info("✓ Contraseña actualizada exitosamente para usuario ID: {}", usuarioId);
                request.setAttribute("exito", true);
                request.setAttribute("mensaje", 
                    "Tu contraseña ha sido restablecida exitosamente. Ya puedes iniciar sesión con tu nueva contraseña.");
                
                // Redirigir al login después de 3 segundos
                response.setHeader("Refresh", "3;url=" + request.getContextPath() + "/acceso/login");
            } else {
                request.setAttribute("error", "Hubo un error al actualizar tu contraseña. Por favor, intenta nuevamente.");
            }
            
        } catch (Exception e) {
            logger.error("✗ Error al cambiar contraseña", e);
            request.setAttribute("error", "Hubo un error al cambiar tu contraseña. Por favor, intenta nuevamente.");
        }
        
        RequestDispatcher view = request.getRequestDispatcher("/acceso/recuperar-contrasena.jsp");
        view.forward(request, response);
    }
    
    /**
     * Valida la fortaleza de una contraseña.
     */
    private boolean validarFortalezaContrasena(String contrasena) {
        // Al menos 8 caracteres, incluyendo letras y números
        if (contrasena.length() < 8) {
            return false;
        }
        
        boolean tieneLetras = contrasena.matches(".*[a-zA-Z].*");
        boolean tieneNumeros = contrasena.matches(".*[0-9].*");
        
        return tieneLetras && tieneNumeros;
    }
    
    /**
     * Genera un hash SHA-256 de una contraseña.
     */
    private String hashPassword(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            logger.error("Error al generar hash de contraseña", e);
            throw new RuntimeException("Error al generar hash de contraseña", e);
        }
    }
}

