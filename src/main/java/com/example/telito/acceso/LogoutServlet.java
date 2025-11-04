package com.example.telito.acceso;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.util.SecurityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet para cerrar sesión de usuario
 */
@WebServlet(name = "LogoutServlet", value = "/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Obtener el usuario de la sesión antes de invalidarla
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            
            if (usuario != null) {
                // Eliminar sesión del registro de SecurityManager
                String sessionId = session.getId();
                SecurityManager.eliminarSesion(usuario.getIdUsuario(), sessionId);
                System.out.println("✓ Logout: Usuario ID " + usuario.getIdUsuario() + " cerró sesión");
            }
            
            // Invalidar la sesión completamente
            session.invalidate();
        }
        
        // Redirigir al login con mensaje de exito
        response.sendRedirect(request.getContextPath() + "/acceso/login?mensaje=Sesion cerrada correctamente");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}

