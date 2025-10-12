package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.administrador.daos.UsuarioDAO;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "MenuPrincipalServlet", value = "/inicio")
public class MenuPrincipalServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html");

        UsuarioDAO usuarioDAO = new UsuarioDAO();
        AlertaDAO alertaDAO = new AlertaDAO();

        // Obtenemos las estadísticas de los DAOs
        int totalUsuarios = usuarioDAO.contarTotalUsuarios();
        int usuariosBaneados = usuarioDAO.contarUsuariosBaneados();
        int alertasAbiertas = alertaDAO.contarAlertasAbiertas(); // Nueva lógica dinámica

        // Las ponemos en el request para que el JSP las pueda leer
        request.setAttribute("totalUsuarios", totalUsuarios);
        request.setAttribute("usuariosBaneados", usuariosBaneados);
        request.setAttribute("alertasAbiertas", alertasAbiertas); // Nuevo atributo

        // Enviamos la petición al JSP para que renderice la vista
        RequestDispatcher dispatcher = request.getRequestDispatcher("/administrador/menu-principal.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
