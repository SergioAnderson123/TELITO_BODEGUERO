package com.example.telito.administrador.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;

@WebServlet(name = "AdminPushServlet", value = "/AdminPushServlet")
public class AdminPushServlet extends HttpServlet {

    private String user = "root";
    private String pass = "root";
    private String url = "jdbc:mysql://localhost:3306/telito_bodeguero";

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
        return DriverManager.getConnection(url, user, pass);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action") == null ? "send" : request.getParameter("action");
        HttpSession session = request.getSession();

        if ("send".equals(action)) {
            String mensaje = request.getParameter("msg");
            if (mensaje == null || mensaje.isBlank()) {
                mensaje = "Aviso del administrador para logística";
            }

            // Por defecto, rol logística = 3 (ajustar según configuración real)
            int rolDestinoId = 3;

            try (Connection conn = getConnection()) {
                String sql = "INSERT INTO alertas_evento (tipo_alerta, mensaje, severidad, rol_destino_id) VALUES (?, ?, ?, ?)";
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, "ADMIN_PUSH");
                    pstmt.setString(2, mensaje);
                    pstmt.setString(3, "INFO");
                    pstmt.setInt(4, rolDestinoId);
                    pstmt.executeUpdate();
                }
                session.setAttribute("successMsg", "Notificación enviada a Logística.");
            } catch (SQLException e) {
                e.printStackTrace();
                session.setAttribute("errorMsg", "Error al enviar notificación: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/administrador/menu-principal.jsp");
    }
}


