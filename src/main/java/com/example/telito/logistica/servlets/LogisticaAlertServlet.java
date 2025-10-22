package com.example.telito.logistica.servlets;

import com.example.telito.administrador.daos.AlertaDAO;
import com.google.gson.Gson;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

@WebServlet(name = "LogisticaAlertServlet", value = "/logistica/alertas")
public class LogisticaAlertServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        AlertaDAO alertaDAO = new AlertaDAO();
        ArrayList<String> mensajes = alertaDAO.listarAlertasParaRol("LOGISTICA");

        String format = request.getParameter("format");
        if ("json".equalsIgnoreCase(format)) {
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print(new Gson().toJson(mensajes));
            }
            return;
        }

        request.setAttribute("mensajes", mensajes);
        RequestDispatcher view = request.getRequestDispatcher("/logistica/alertas.jsp");
        view.forward(request, response);
    }
}
