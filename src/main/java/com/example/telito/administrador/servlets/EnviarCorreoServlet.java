package com.example.telito.administrador.servlets;

import com.example.telito.administrador.daos.AlertaDAO;
import com.example.telito.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;

/**
 * Servlet para enviar correos de prueba o alertas manualmente.
 * Útil para probar la configuración de correo o enviar notificaciones bajo demanda.
 */
@WebServlet(name = "EnviarCorreoServlet", value = "/EnviarCorreoServlet")
public class EnviarCorreoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("test".equals(action)) {
            enviarCorreoPrueba(request, response);
        } else if ("alertas".equals(action)) {
            enviarAlertasPorRol(request, response);
        } else {
            request.setAttribute("error", "Acción no válida");
            request.getRequestDispatcher("/administrador/enviar-correo.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("test".equals(action)) {
            enviarCorreoPrueba(request, response);
        } else if ("alertas".equals(action)) {
            enviarAlertasPorRol(request, response);
        } else {
            doGet(request, response);
        }
    }

    /**
     * Envía un correo de prueba a una dirección específica.
     */
    private void enviarCorreoPrueba(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String emailDestino = request.getParameter("email");
        
        if (emailDestino == null || emailDestino.trim().isEmpty()) {
            request.setAttribute("error", "Por favor, ingrese un email válido");
            request.getRequestDispatcher("/administrador/enviar-correo.jsp").forward(request, response);
            return;
        }

        String asunto = "TELITO BODEGUERO - Correo de Prueba";
        String mensaje = """
                Este es un correo de prueba del sistema TELITO BODEGUERO.

                Si recibiste este correo, la configuración de email está funcionando correctamente.

                Saludos,
                Sistema TELITO BODEGUERO
                """;

        boolean enviado = EmailUtil.sendEmail(emailDestino, asunto, mensaje);
        
        if (enviado) {
            request.getSession().setAttribute("successMsg", 
                "✓ Correo de prueba enviado exitosamente a: %s".formatted(emailDestino));
        } else {
            request.setAttribute("error", 
                "✗ Error al enviar correo de prueba. Verifique la configuración de email.");
        }
        
        request.getRequestDispatcher("/administrador/enviar-correo.jsp").forward(request, response);
    }

    /**
     * Envía alertas activas por correo a un rol específico.
     */
    private void enviarAlertasPorRol(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String rolNombre = request.getParameter("rol");
        
        if (rolNombre == null || rolNombre.trim().isEmpty()) {
            request.setAttribute("error", "Por favor, seleccione un rol");
            request.getRequestDispatcher("/administrador/enviar-correo.jsp").forward(request, response);
            return;
        }

        AlertaDAO alertaDAO = new AlertaDAO();
        ArrayList<String> mensajes = alertaDAO.listarAlertasParaRol(rolNombre.toUpperCase());
        
        if (mensajes.isEmpty()) {
            request.setAttribute("info", 
                "No hay alertas activas para el rol: %s".formatted(rolNombre));
        } else {
            int correosEnviados = alertaDAO.enviarAlertasPorCorreo(
                rolNombre.toUpperCase(), 
                "Alertas del Sistema - %s".formatted(rolNombre), 
                mensajes
            );
            
            if (correosEnviados > 0) {
                request.getSession().setAttribute("successMsg", 
                    "✓ Se enviaron %d correo(s) con %d alerta(s) al rol: %s"
                        .formatted(correosEnviados, mensajes.size(), rolNombre));
            } else {
                request.setAttribute("error", 
                    "✗ No se pudieron enviar los correos. Verifique la configuración de email.");
            }
        }
        
        request.getRequestDispatcher("/administrador/enviar-correo.jsp").forward(request, response);
    }
}

