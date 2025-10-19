<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prueba de Login - Telito Bodeguero</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); max-width: 500px; margin: 0 auto; }
        h1 { color: #333; text-align: center; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
        input[type="email"], input[type="password"] { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 16px; }
        .btn { background: #007bff; color: white; padding: 12px 30px; border: none; border-radius: 5px; font-size: 16px; cursor: pointer; width: 100%; }
        .btn:hover { background: #0056b3; }
        .alert { padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .alert-danger { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .info { background: #d1ecf1; color: #0c5460; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 Login - Telito Bodeguero</h1>
        
        <div class="info">
            <strong>Credenciales de prueba:</strong><br>
            Email: admin@telito.com<br>
            Contraseña: admin123
        </div>

        <%
            String error = request.getParameter("error");
            String logout = request.getParameter("logout");
            
            if (error != null) {
                String mensaje = "";
                switch (error) {
                    case "campos_vacios":
                        mensaje = "Por favor, complete todos los campos.";
                        break;
                    case "credenciales_invalidas":
                        mensaje = "Email o contraseña incorrectos.";
                        break;
                    default:
                        mensaje = "Error al iniciar sesión.";
                }
        %>
            <div class="alert alert-danger">
                <strong>Error:</strong> <%= mensaje %>
            </div>
        <%
            }
            
            if (logout != null && logout.equals("success")) {
        %>
            <div class="alert alert-success">
                <strong>Éxito:</strong> Sesión cerrada correctamente.
            </div>
        <%
            }
        %>

        <form action="<%= request.getContextPath() %>/LoginServlet" method="POST">
            <div class="form-group">
                <label for="email">Correo electrónico:</label>
                <input type="email" id="email" name="email" required placeholder="admin@telito.com">
            </div>

            <div class="form-group">
                <label for="password">Contraseña:</label>
                <input type="password" id="password" name="password" required placeholder="admin123">
            </div>

            <button type="submit" class="btn">Iniciar Sesión</button>
        </form>
        
        <div style="text-align: center; margin-top: 20px;">
            <a href="<%= request.getContextPath() %>/crear-usuarios-prueba" style="color: #007bff; text-decoration: none;">
                Crear usuarios de prueba
            </a>
        </div>
    </div>
</body>
</html>
