package com.example.telito.administrador.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet de inicio que maneja la redirección según el estado de la sesión.
 * Si el usuario ya está logueado, lo redirige al menú principal.
 * Si no, lo redirige al login.
 */
@WebServlet(name = "InicioServlet", value = "/home")
public class InicioServlet extends HttpServlet {

    /**
     * Maneja las solicitudes GET para determinar la redirección.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session != null && session.getAttribute("usuarioSesion") != null) {
            // Usuario ya está logueado, redirigir al menú principal
            response.sendRedirect(request.getContextPath() + "/administrador/menu-principal.jsp");
        } else {
            // Usuario no está logueado, redirigir al login
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
        }
    }

    /**
     * Maneja las solicitudes POST de la misma manera que GET.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
