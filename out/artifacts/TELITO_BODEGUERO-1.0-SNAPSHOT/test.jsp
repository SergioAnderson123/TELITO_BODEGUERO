<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prueba - Telito Bodeguero</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            max-width: 600px;
            margin: 0 auto;
        }
        .success {
            color: #27ae60;
            font-size: 18px;
            font-weight: bold;
        }
        .info {
            background: #e8f4fd;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .btn {
            background: #3498db;
            color: white;
            padding: 10px 20px;
            text-decoration: none;
            border-radius: 5px;
            display: inline-block;
            margin: 10px 5px;
        }
        .btn:hover {
            background: #2980b9;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 ¡Proyecto TELITO_BODEGUERO Funcionando!</h1>
        
        <div class="success">
            ✅ Servidor Tomcat funcionando correctamente
        </div>
        
        <div class="info">
            <h3>Información del Sistema:</h3>
            <p><strong>Servidor:</strong> <%= application.getServerInfo() %></p>
            <p><strong>Contexto:</strong> <%= request.getContextPath() %></p>
            <p><strong>Fecha:</strong> <%= new java.util.Date() %></p>
        </div>
        
        <h3>Enlaces de Prueba:</h3>
        <a href="<%= request.getContextPath() %>/LoginServlet" class="btn">🔐 Ir al Login</a>
        <a href="<%= request.getContextPath() %>/welcome.jsp" class="btn">🏠 Página de Bienvenida</a>
        
        <div class="info">
            <h3>Próximos Pasos:</h3>
            <ol>
                <li>Verificar que la base de datos esté conectada</li>
                <li>Probar el sistema de login</li>
                <li>Verificar la redirección por roles</li>
            </ol>
        </div>
    </div>
</body>
</html>
