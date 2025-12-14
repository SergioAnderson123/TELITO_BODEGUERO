package com.example.telito.administrador.servlets;

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

// Activación de cuentas mediante tokens enviados por email
@WebServlet(name = "ActivacionServlet", value = "/acceso/activar")
public class ActivacionServlet extends HttpServlet {
    
    private static final Logger logger = LoggerFactory.getLogger(ActivacionServlet.class);
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String token = request.getParameter("token");
        
        if (token == null || token.trim().isEmpty()) {
            // Sin token, mostrar formulario de reenvío
            request.setAttribute("error", "Token de activación no proporcionado.");
            RequestDispatcher view = request.getRequestDispatcher("/acceso/activacion.jsp");
            view.forward(request, response);
            return;
        }
        
        // Validar token
        String ipAddress = request.getRemoteAddr();
        String userAgent = request.getHeader("User-Agent");
        
        int usuarioId = TokenService.validarYUsarTokenActivacion(token.trim(), ipAddress, userAgent);
        
        if (usuarioId > 0) {
            // Activación exitosa
            logger.info("✓ Cuenta activada exitosamente para usuario ID: {}", usuarioId);
            request.setAttribute("exito", true);
            request.setAttribute("mensaje", "¡Tu cuenta ha sido activada exitosamente! Ya puedes iniciar sesión.");
        } else {
            // Token inválido o expirado
            logger.warn("⚠ Intento de activación con token inválido o expirado desde IP: {}", ipAddress);
            request.setAttribute("error", "El token de activación es inválido o ha expirado. Por favor, solicita un nuevo enlace de activación.");
        }
        
        RequestDispatcher view = request.getRequestDispatcher("/acceso/activacion.jsp");
        view.forward(request, response);
    }
}

