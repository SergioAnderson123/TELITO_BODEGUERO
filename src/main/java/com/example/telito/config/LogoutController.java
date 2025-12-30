package com.example.telito.config;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.util.SecurityManager;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

/**
 * Controlador Spring MVC para manejar el cierre de sesión
 * Esto asegura que funcione correctamente tanto con Spring Boot directo como con Tomcat externo
 */
@Controller
public class LogoutController {

    @GetMapping("/logout")
    @PostMapping("/logout")
    public String logout(HttpServletRequest request) {
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
        
        // Redirigir al login con mensaje de éxito
        return "redirect:/acceso/login?mensaje=Sesion cerrada correctamente";
    }
}

