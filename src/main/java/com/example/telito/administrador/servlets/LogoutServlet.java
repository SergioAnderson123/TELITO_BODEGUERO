package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.utils.AdminLogger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet para manejar el logout de usuarios.
 * Invalida la sesión y redirige al login.
 */
@WebServlet(name = "LogoutServlet", value = "/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    /**
     * Maneja las solicitudes GET y POST para cerrar sesión.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        procesarLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        procesarLogout(request, response);
    }

    /**
     * Procesa el logout invalidando la sesión.
     * Incluye logging de seguridad y limpieza completa de la sesión.
     * 
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws IOException si ocurre un error de redirección
     */
    private void procesarLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Obtener información del usuario antes de invalidar la sesión
            Usuario usuario = (Usuario) session.getAttribute("usuarioSesion");
            String userEmail = usuario != null ? usuario.getEmail() : "unknown";
            
            // Logging del logout
            AdminLogger.info(String.format("User %s logged out successfully", userEmail));
            
            // Invalidar completamente la sesión
            session.invalidate();
        }
        
        // Redirigir al login con mensaje de confirmación
        response.sendRedirect(request.getContextPath() + "/LoginServlet?logout=success");
    }
}
