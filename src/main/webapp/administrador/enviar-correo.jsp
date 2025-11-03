<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.util.EmailUtil" %>
<%
    String mensaje = "";
    String tipoMensaje = "";
    
    // Verificar si se envió un correo
    if ("POST".equals(request.getMethod())) {
        String emailDestino = request.getParameter("email");
        String tipoPrueba = request.getParameter("tipo_prueba");
        
        if (emailDestino != null && !emailDestino.trim().isEmpty()) {
            boolean enviado = false;
            
            if ("simple".equals(tipoPrueba)) {
                // Correo de texto simple
                enviado = EmailUtil.sendEmail(
                    emailDestino,
                    "TELITO BODEGUERO - Prueba de Correo",
                    "Este es un correo de prueba del sistema TELITO BODEGUERO.\n\n" +
                    "Si recibiste este correo, la configuración de email está funcionando correctamente.\n\n" +
                    "Saludos,\n" +
                    "Sistema TELITO BODEGUERO"
                );
            } else if ("html".equals(tipoPrueba)) {
                // Correo HTML
                enviado = EmailUtil.sendEmail(
                    emailDestino,
                    "TELITO BODEGUERO - Prueba de Correo HTML",
                    "<h1>Prueba de Correo HTML</h1>" +
                    "<p>Este es un correo de prueba en formato <strong>HTML</strong> del sistema TELITO BODEGUERO.</p>" +
                    "<p>Si recibiste este correo con formato, significa que el envío HTML está funcionando correctamente.</p>" +
                    "<hr>" +
                    "<p><em>Sistema TELITO BODEGUERO</em></p>",
                    true
                );
            } else if ("alerta".equals(tipoPrueba)) {
                // Alerta del sistema
                enviado = EmailUtil.sendSystemAlert(
                    emailDestino,
                    "Prueba de Alerta",
                    "Este es un mensaje de alerta de prueba del sistema."
                );
            } else if ("alerta_html".equals(tipoPrueba)) {
                // Alerta HTML del sistema
                enviado = EmailUtil.sendSystemAlertHTML(
                    emailDestino,
                    "Prueba de Alerta HTML",
                    "Este es un mensaje de alerta en formato HTML de prueba del sistema."
                );
            }
            
            if (enviado) {
                mensaje = "✓ Correo enviado exitosamente a: " + emailDestino + ". Revisa tu bandeja de entrada.";
                tipoMensaje = "success";
            } else {
                mensaje = "✗ Error al enviar el correo. Verifica la configuración en email.properties y los logs del servidor.";
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
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Prueba de Correos"/>
    </jsp:include>
    <style>
        .email-test-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 20px;
        }
        .email-test-card h3 {
            color: var(--turquoise-dark);
            margin-bottom: 20px;
            font-weight: 700;
        }
        .status-message {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
            font-size: 14px;
        }
        .status-message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .status-message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .status-message.warning {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        .status-message.info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }
        .radio-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-top: 15px;
        }
        .radio-option {
            display: flex;
            align-items: center;
            padding: 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .radio-option:hover {
            border-color: var(--turquoise-dark);
            background-color: var(--seafoam-light);
        }
        .radio-option input[type="radio"] {
            margin-right: 12px;
            cursor: pointer;
            width: 18px;
            height: 18px;
        }
        .radio-option label {
            margin: 0;
            cursor: pointer;
            font-weight: normal;
            color: var(--text-dark);
        }
        .btn-send-email {
            background: linear-gradient(135deg, var(--turquoise-dark) 0%, #055e68 100%);
            color: white;
            padding: 14px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-send-email:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 109, 119, 0.4);
        }
        .btn-send-email:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Configuracion"/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-4">
                <h2 class="pageheader-title" style="font-weight: 700;">
                    <i class="fas fa-envelope me-2"></i>Prueba de Correos
                </h2>
                <p class="pageheader-text">Sistema TELITO BODEGUERO - Envío de Correos Electrónicos</p>
            </div>

            <div class="row">
                <div class="col-xl-8 col-lg-10 col-md-12 mx-auto">
                    <div class="email-test-card">
                        <% if (!configurado) { %>
                            <div class="status-message error">
                                <strong>⚠ Configuración Incompleta:</strong><br>
                                Por favor, configura tu email y contraseña en el archivo:<br>
                                <code>src/main/resources/email.properties</code>
                            </div>
                        <% } else { %>
                            <div class="status-message info">
                                <strong>✓ Configuración Verificada:</strong><br>
                                El sistema está listo para enviar correos.
                            </div>
                        <% } %>

                        <% if (!mensaje.isEmpty()) { %>
                            <div class="status-message <%= tipoMensaje %>">
                                <%= mensaje %>
                            </div>
                        <% } %>

                        <form method="POST" action="<%= request.getContextPath() %>/administrador/enviar-correo.jsp">
                            <div class="mb-3">
                                <label for="email" class="form-label" style="font-weight: 600; color: var(--text-dark);">
                                    <i class="fas fa-envelope me-2"></i>Email de Destino:
                                </label>
                                <input 
                                    type="email" 
                                    class="form-control" 
                                    id="email" 
                                    name="email" 
                                    placeholder="tu@email.com" 
                                    required
                                    value="<%= request.getParameter("email") != null ? request.getParameter("email") : "sergiomeneses893@gmail.com" %>"
                                >
                            </div>

                            <div class="mb-4">
                                <label class="form-label" style="font-weight: 600; color: var(--text-dark);">
                                    <i class="fas fa-list me-2"></i>Tipo de Prueba:
                                </label>
                                <div class="radio-group">
                                    <div class="radio-option">
                                        <input type="radio" id="simple" name="tipo_prueba" value="simple" checked>
                                        <label for="simple">📝 Correo de Texto Simple</label>
                                    </div>
                                    <div class="radio-option">
                                        <input type="radio" id="html" name="tipo_prueba" value="html">
                                        <label for="html">🎨 Correo HTML</label>
                                    </div>
                                    <div class="radio-option">
                                        <input type="radio" id="alerta" name="tipo_prueba" value="alerta">
                                        <label for="alerta">⚠️ Alerta del Sistema (Texto)</label>
                                    </div>
                                    <div class="radio-option">
                                        <input type="radio" id="alerta_html" name="tipo_prueba" value="alerta_html">
                                        <label for="alerta_html">⚠️ Alerta del Sistema (HTML)</label>
                                    </div>
                                </div>
                            </div>

                            <button type="submit" class="btn-send-email" <%= !configurado ? "disabled title='Configura el email primero'" : "" %>>
                                <i class="fas fa-paper-plane me-2"></i>Enviar Correo de Prueba
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/administrador/layouts/footer.jsp" />
</body>
</html>
