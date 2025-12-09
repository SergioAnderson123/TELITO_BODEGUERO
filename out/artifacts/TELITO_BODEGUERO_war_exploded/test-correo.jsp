<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.util.EmailUtil" %>
<%
    String mensaje = "";
    String tipoMensaje = "";
    
    // Verificar si se envió un correo
    if ("POST".equals(request.getMethod())) {
        String emailDestino = request.getParameter("email");
        
        if (emailDestino != null && !emailDestino.trim().isEmpty()) {
            // Enviar correo de prueba simple
            boolean enviado = EmailUtil.sendEmail(
                emailDestino,
                "TELITO BODEGUERO - Prueba de Correo",
                "Este es un correo de prueba del sistema TELITO BODEGUERO.\n\n" +
                "Si recibiste este correo, la configuración de email está funcionando correctamente.\n\n" +
                "Saludos,\n" +
                "Sistema TELITO BODEGUERO"
            );
            
            if (enviado) {
                mensaje = "✓ Correo enviado exitosamente a: " + emailDestino + ". Revisa tu bandeja de entrada.";
                tipoMensaje = "success";
            } else {
                mensaje = "✗ Error al enviar el correo. Verifica la configuración en email.properties.";
                tipoMensaje = "error";
            }
        } else {
            mensaje = "⚠ Por favor, ingresa un email válido.";
            tipoMensaje = "warning";
        }
    }
    
    // Verificar configuración
    boolean configurado = EmailUtil.isEmailConfigured();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Prueba de Correo - TELITO BODEGUERO</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .status {
            padding: 15px;
            margin: 15px 0;
            border-radius: 5px;
        }
        .status.success { background: #d4edda; color: #155724; }
        .status.error { background: #f8d7da; color: #721c24; }
        .status.warning { background: #fff3cd; color: #856404; }
        .status.info { background: #d1ecf1; color: #0c5460; }
        input[type="email"] {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        button {
            background: #667eea;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
        }
        button:hover { background: #5568d3; }
        button:disabled { background: #ccc; cursor: not-allowed; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📧 Prueba de Correo - TELITO BODEGUERO</h1>
        
        <% if (!configurado) { %>
            <div class="status error">
                <strong>⚠ Configuración Incompleta:</strong><br>
                Configura tu email en: <code>src/main/resources/email.properties</code>
            </div>
        <% } else { %>
            <div class="status info">
                <strong>✓ Configuración Verificada:</strong><br>
                Sistema listo para enviar correos.
            </div>
        <% } %>
        
        <% if (!mensaje.isEmpty()) { %>
            <div class="status <%= tipoMensaje %>"><%= mensaje %></div>
        <% } %>
        
        <form method="POST" action="test-correo.jsp">
            <label for="email"><strong>Email de Destino:</strong></label>
            <input 
                type="email" 
                id="email" 
                name="email" 
                placeholder="tu@email.com" 
                required
                value="<%= request.getParameter("email") != null ? request.getParameter("email") : "sergiomeneses893@gmail.com" %>"
            >
            <button type="submit" <%= !configurado ? "disabled" : "" %>>
                Enviar Correo de Prueba
            </button>
        </form>
    </div>
</body>
</html>

