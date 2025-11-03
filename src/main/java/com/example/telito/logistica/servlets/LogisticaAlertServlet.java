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

        // Opción para enviar correos automáticamente si hay alertas
        // Si no se especifica el parámetro, por defecto NO envía (para evitar spam)
        // Pero se puede habilitar con ?enviarCorreo=true o crear un job programado
        String enviarCorreo = request.getParameter("enviarCorreo");
        if ("true".equalsIgnoreCase(enviarCorreo) && !mensajes.isEmpty()) {
            int correosEnviados = alertaDAO.enviarAlertasPorCorreo("LOGISTICA", "Alertas del Sistema - Logística", mensajes);
            request.getSession().setAttribute("successMsg", "Se enviaron " + correosEnviados + " correo(s) de alerta exitosamente.");
        } else if (mensajes.isEmpty()) {
            request.getSession().setAttribute("infoMsg", "No hay alertas activas para el rol LOGISTICA.");
        }

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
