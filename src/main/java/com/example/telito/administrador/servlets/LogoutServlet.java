package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.util.SecurityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

// Maneja el cierre de sesión
@WebServlet(name = "LogoutServlet", value = "/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Obtener usuario antes de invalidar
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            
            if (usuario != null) {
                // Limpiar registro de sesión activa
                String sessionId = session.getId();
                SecurityManager.eliminarSesion(usuario.getIdUsuario(), sessionId);
                System.out.println("✓ Logout: Usuario ID " + usuario.getIdUsuario() + " cerró sesión");
            }
            
            session.invalidate();
        }
        
        response.sendRedirect(request.getContextPath() + "/acceso/login");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
