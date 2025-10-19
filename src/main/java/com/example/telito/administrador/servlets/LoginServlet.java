package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.utils.AdminLogger;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet para manejar el login de usuarios.
 * Implementa el patrón de sesiones con HttpSession y hash de contraseñas.
 */
@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

    /**
     * Maneja las solicitudes GET para mostrar el formulario de login.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Verificar si ya hay una sesión activa
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuarioSesion") != null) {
            // Si ya está logueado, redirigir al menú principal
            response.sendRedirect(request.getContextPath() + "/administrador/menu-principal.jsp");
            return;
        }
        
        // Mostrar el formulario de login
        RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
        view.forward(request, response);
    }

    /**
     * Maneja las solicitudes POST para procesar el login.
     * Incluye validación robusta, logging de seguridad y manejo de errores mejorado.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Validación básica de parámetros
        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            AdminLogger.warn(String.format("Login attempt with empty fields from IP: %s", getClientIP(request)));
            response.sendRedirect(request.getContextPath() + "/LoginServlet?error=campos_vacios");
            return;
        }
        
        // Limpiar y normalizar email
        email = email.trim().toLowerCase();
        
        // Validación adicional de email
        if (!isValidEmail(email)) {
            AdminLogger.warn(String.format("Login attempt with invalid email format: %s from IP: %s", email, getClientIP(request)));
            response.sendRedirect(request.getContextPath() + "/LoginServlet?error=email_invalido");
            return;
        }
        
        try {
            // Validar credenciales usando hash SHA-256
            UsuarioDAO usuarioDAO = new UsuarioDAO();
            Usuario usuario = usuarioDAO.validarCredenciales(email, password);
            
            if (usuario != null) {
                // Login exitoso - crear sesión
                HttpSession session = request.getSession();
                session.setAttribute("usuarioSesion", usuario);
                
                // Configurar tiempo de inactividad (30 minutos)
                session.setMaxInactiveInterval(30 * 60);
                
                // Logging de login exitoso
                AdminLogger.logLoginAttempt(email, true);
                AdminLogger.info(String.format("User %s logged in successfully from IP: %s", email, getClientIP(request)));
                
                // Redirigir según el rol del usuario
                String redirectUrl = obtenerUrlPorRol(usuario.getRol().getNombre());
                response.sendRedirect(request.getContextPath() + redirectUrl);
                
            } else {
                // Login fallido
                AdminLogger.logLoginAttempt(email, false);
                AdminLogger.warn(String.format("Failed login attempt for email: %s from IP: %s", email, getClientIP(request)));
                response.sendRedirect(request.getContextPath() + "/LoginServlet?error=credenciales_invalidas");
            }
            
        } catch (Exception e) {
            AdminLogger.error(String.format("Error during login process for email: %s from IP: %s", email, getClientIP(request)), e);
            response.sendRedirect(request.getContextPath() + "/LoginServlet?error=error_interno");
        }
    }

    /**
     * Obtiene la URL de redirección según el rol del usuario.
     * 
     * @param nombreRol nombre del rol del usuario
     * @return URL de redirección
     */
    private String obtenerUrlPorRol(String nombreRol) {
        switch (nombreRol.toLowerCase()) {
            case "administrador":
                return "/administrador/menu-principal.jsp";
            case "almacén":
            case "almacen":
                return "/almacen/index.jsp";
            case "logística":
            case "logistica":
                return "/logistica/index.jsp";
            case "productor":
                return "/productor/index.jsp";
            default:
                return "/administrador/menu-principal.jsp";
        }
    }
    
    /**
     * Valida el formato del email usando una expresión regular simple.
     * 
     * @param email el email a validar
     * @return true si el formato es válido, false en caso contrario
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.length() > 100) {
            return false;
        }
        
        // Expresión regular simple para validar email
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        return email.matches(emailRegex);
    }
    
    /**
     * Obtiene la dirección IP del cliente.
     * Considera proxies y headers X-Forwarded-For.
     * 
     * @param request la solicitud HTTP
     * @return la dirección IP del cliente
     */
    private String getClientIP(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIP = request.getHeader("X-Real-IP");
        if (xRealIP != null && !xRealIP.isEmpty()) {
            return xRealIP;
        }
        
        return request.getRemoteAddr();
    }
}
