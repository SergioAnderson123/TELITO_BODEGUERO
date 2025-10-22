package com.example.telito.administrador.servlets;

import com.example.telito.administrador.beans.Usuario;
import com.example.telito.administrador.daos.UsuarioDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("LoginServlet doGet ejecutándose...");
        
        // Si ya está logueado, redirigir según su rol
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            System.out.println("Usuario ya logueado: " + usuario.getEmail());
            redirigirSegunRol(response, usuario.getRol().getNombre());
            return;
        }
        
        System.out.println("Mostrando formulario de login...");
        // Mostrar formulario de login
        RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
        view.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Por favor, complete todos los campos.");
            RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
            view.forward(request, response);
            return;
        }
        
        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario usuario = usuarioDAO.autenticarUsuario(email.trim(), password.trim());
        
        if (usuario != null && usuario.isActivo()) {
            // Login exitoso
            HttpSession session = request.getSession();
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioNombre", usuario.getNombres() + " " + usuario.getApellidos());
            session.setAttribute("usuarioRol", usuario.getRol().getNombre());
            
            // Redirigir según el rol
            redirigirSegunRol(response, usuario.getRol().getNombre());
        } else {
            // Login fallido
            request.setAttribute("errorMsg", "Credenciales incorrectas o usuario inactivo.");
            RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
            view.forward(request, response);
        }
    }
    
    private void redirigirSegunRol(HttpServletResponse response, String rolNombre) throws IOException {
        String contextPath = response.encodeRedirectURL("");
        
        switch (rolNombre.toLowerCase()) {
            case "administrador":
                response.sendRedirect(contextPath + "/administrador/menu-principal.jsp");
                break;
            case "logística":
            case "logistica":
                response.sendRedirect(contextPath + "/logistica/index.jsp");
                break;
            case "almacenero":
                response.sendRedirect(contextPath + "/almacen/index.jsp");
                break;
            case "productor":
                response.sendRedirect(contextPath + "/productor/index.jsp");
                break;
            default:
                response.sendRedirect(contextPath + "/LoginServlet");
                break;
        }
    }
}
