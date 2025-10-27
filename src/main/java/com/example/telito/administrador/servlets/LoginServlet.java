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
import java.io.OutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "LoginServlet", value = "/acceso/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/acceso/login");
            return;
        }

        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            Usuario usuario = (Usuario) session.getAttribute("usuario");
            redirigirSegunRol(request, response, usuario.getRol().getNombre());
            return;
        }

        // Generar desafío matemático simple y guardarlo en sesión
        int a = 2 + (int)(Math.random() * 8); // 2..9
        int b = 2 + (int)(Math.random() * 8);
        HttpSession captchaSession = request.getSession(true);
        captchaSession.setAttribute("captchaAnswer", a + b);
        request.setAttribute("captchaQuestion", a + " + " + b + " = ?");

        RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
        view.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Anti-bot: validar honeypot y desafío matemático
        String website = request.getParameter("website");
        if (website != null && !website.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Verificación anti-bot fallida.");
            // Regenerar pregunta
            int a = 2 + (int)(Math.random() * 8);
            int b = 2 + (int)(Math.random() * 8);
            HttpSession s = request.getSession(true);
            s.setAttribute("captchaAnswer", a + b);
            request.setAttribute("captchaQuestion", a + " + " + b + " = ?");
            RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
            view.forward(request, response);
            return;
        }

        String captchaAnswerStr = request.getParameter("captcha_answer");
        HttpSession s = request.getSession(false);
        Integer expected = (s != null) ? (Integer) s.getAttribute("captchaAnswer") : null;
        boolean captchaOk = false;
        try {
            int provided = Integer.parseInt(captchaAnswerStr);
            captchaOk = (expected != null && provided == expected);
        } catch (Exception ignored) { }
        if (!captchaOk) {
            request.setAttribute("errorMsg", "Respuesta del desafío incorrecta. Inténtalo nuevamente.");
            // Regenerar pregunta
            int na = 2 + (int)(Math.random() * 8);
            int nb = 2 + (int)(Math.random() * 8);
            HttpSession ns = request.getSession(true);
            ns.setAttribute("captchaAnswer", na + nb);
            request.setAttribute("captchaQuestion", na + " + " + nb + " = ?");
            RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
            view.forward(request, response);
            return;
        }

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Por favor, complete todos los campos.");
            RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
            view.forward(request, response);
            return;
        }

        UsuarioDAO usuarioDAO = new UsuarioDAO();
        Usuario usuario = usuarioDAO.autenticarUsuario(email.trim(), password.trim());

        if (usuario != null && usuario.isActivo()) {
            HttpSession session = request.getSession();
            session.setAttribute("usuario", usuario);
            session.setAttribute("usuarioNombre", usuario.getNombres() + " " + usuario.getApellidos());
            session.setAttribute("usuarioRol", usuario.getRol().getNombre());

            redirigirSegunRol(request, response, usuario.getRol().getNombre());
        } else {
            request.setAttribute("errorMsg", "Credenciales incorrectas o usuario inactivo.");
            RequestDispatcher view = request.getRequestDispatcher("/login.jsp");
            view.forward(request, response);
        }
    }

    private void redirigirSegunRol(HttpServletRequest request, HttpServletResponse response, String rolNombre) throws IOException {
        String contextPath = request.getContextPath();

        switch (rolNombre.toLowerCase()) {
            case "administrador":
                response.sendRedirect(contextPath + "/inicio");
                break;
            case "logística":
            case "logistica":
                // Corregido: Redirigir al servlet de inventario, que es la página principal de logística
                response.sendRedirect(contextPath + "/InventarioServlet");
                break;
            case "almacenero":
                response.sendRedirect(contextPath + "/almacen/index.jsp");
                break;
            case "productor":
                response.sendRedirect(contextPath + "/productor/index.jsp");
                break;
            default:
                response.sendRedirect(contextPath + "/acceso/login");
                break;
        }
    }
}
