package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Rol;
import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import com.example.telito.administrador.daos.RolDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

/**
 * Servlet temporal para crear usuarios de prueba.
 * SOLO PARA DESARROLLO - ELIMINAR EN PRODUCCIÓN
 */
@WebServlet(name = "CrearUsuariosPruebaServlet", value = "/crear-usuarios-prueba")
public class CrearUsuariosPruebaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Crear Usuarios de Prueba</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 40px; }");
        out.println(".success { color: green; background: #e8f5e8; padding: 10px; border-radius: 5px; }");
        out.println(".error { color: red; background: #ffe8e8; padding: 10px; border-radius: 5px; }");
        out.println("</style></head><body>");
        
        try {
            // Crear roles primero
            crearRolesPrueba();
            
            // Crear usuarios de prueba
            crearUsuariosPrueba();
            
            out.println("<h1>✅ Usuarios de Prueba Creados Exitosamente</h1>");
            out.println("<div class='success'>");
            out.println("<h2>Credenciales de Acceso:</h2>");
            out.println("<ul>");
            out.println("<li><strong>Administrador:</strong> admin@telito.com / admin123</li>");
            out.println("<li><strong>Logística:</strong> logistica@telito.com / logistica123</li>");
            out.println("<li><strong>Productor:</strong> productor@telito.com / productor123</li>");
            out.println("<li><strong>Almacén:</strong> almacen@telito.com / almacen123</li>");
            out.println("<li><strong>Prueba:</strong> test@telito.com / test123</li>");
            out.println("</ul>");
            out.println("</div>");
            
            out.println("<p><a href='" + request.getContextPath() + "/LoginServlet'>Ir al Login</a></p>");
            
        } catch (Exception e) {
            out.println("<h1>❌ Error al Crear Usuarios</h1>");
            out.println("<div class='error'>");
            out.println("<p>Error: " + e.getMessage() + "</p>");
            out.println("</div>");
            e.printStackTrace();
        }
        
        out.println("</body></html>");
    }
    
    private void crearRolesPrueba() throws Exception {
        // Los roles se crearán automáticamente si no existen
        // Esto es solo para asegurar que estén disponibles
    }
    
    private void crearUsuariosPrueba() throws Exception {
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        RolDAO rolDAO = new RolDAO();
        
        // Obtener roles disponibles
        ArrayList<Rol> roles = rolDAO.listarRoles();
        if (roles.isEmpty()) {
            throw new Exception("No hay roles disponibles. Crear roles primero.");
        }
        
        // Crear usuarios de prueba
        Usuario[] usuariosPrueba = {
            crearUsuario("Juan", "Administrador", "admin@telito.com", "admin123", "Administrador", roles),
            crearUsuario("María", "Logística", "logistica@telito.com", "logistica123", "Logística", roles),
            crearUsuario("Carlos", "Productor", "productor@telito.com", "productor123", "Productor", roles),
            crearUsuario("Ana", "Almacén", "almacen@telito.com", "almacen123", "Almacén", roles),
            crearUsuario("Pedro", "Prueba", "test@telito.com", "test123", "Administrador", roles)
        };
        
        for (Usuario usuario : usuariosPrueba) {
            try {
                usuarioDAO.crearUsuario(usuario);
            } catch (Exception e) {
                // Ignorar errores de usuarios duplicados
                System.out.println("Usuario ya existe: " + usuario.getEmail());
            }
        }
    }
    
    private Usuario crearUsuario(String nombres, String apellidos, String email, 
                                String password, String nombreRol, ArrayList<Rol> roles) {
        Usuario usuario = new Usuario();
        usuario.setNombres(nombres);
        usuario.setApellidos(apellidos);
        usuario.setEmail(email);
        usuario.setPassword(password);
        usuario.setActivo(true);
        
        // Buscar el rol correspondiente
        for (Rol rol : roles) {
            if (rol.getNombre().equalsIgnoreCase(nombreRol)) {
                usuario.setRol(rol);
                break;
            }
        }
        
        return usuario;
    }
}
