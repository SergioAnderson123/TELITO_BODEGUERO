<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Iniciar Sesión – Telito Bodeguero</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Sistema de gestión de bodega - Telito Bodeguero">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .login-container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 3rem;
            width: 100%;
            max-width: 450px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .login-header h1 {
            color: #2d3748;
            font-weight: 700;
            margin-bottom: 0.5rem;
            font-size: 2rem;
        }
        
        .login-header p {
            color: #718096;
            font-size: 1rem;
        }
        
        .brand-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #36a39a 0%, #006d77 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem;
            box-shadow: 0 10px 20px rgba(54, 163, 154, 0.3);
        }
        
        .brand-icon i {
            font-size: 2.5rem;
            color: white;
        }
        
        .form-control {
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 1rem 1.25rem;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.8);
        }
        
        .form-control:focus {
            border-color: #36a39a;
            box-shadow: 0 0 0 3px rgba(54, 163, 154, 0.1);
            background: white;
        }
        
        .form-label {
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 0.75rem;
        }
        
        .btn-login {
            background: linear-gradient(135deg, #36a39a 0%, #006d77 100%);
            border: none;
            border-radius: 12px;
            padding: 1rem 2rem;
            font-weight: 600;
            font-size: 1.1rem;
            color: white;
            width: 100%;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(54, 163, 154, 0.3);
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(54, 163, 154, 0.4);
            color: white;
        }
        
        .alert {
            border-radius: 12px;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
        }
        
        .alert-danger {
            background: rgba(245, 101, 101, 0.1);
            color: #e53e3e;
            border-left: 4px solid #e53e3e;
        }
        
        .alert-success {
            background: rgba(56, 178, 172, 0.1);
            color: #38b2ac;
            border-left: 4px solid #38b2ac;
        }
        
        .input-group {
            position: relative;
            margin-bottom: 1.5rem;
        }
        
        .input-group i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #a0aec0;
            z-index: 10;
        }
        
        .input-group .form-control {
            padding-left: 3rem;
        }
        
        .footer-text {
            text-align: center;
            margin-top: 2rem;
            color: #718096;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <div class="brand-icon">
                <i class="fas fa-warehouse"></i>
            </div>
            <h1>Telito Bodeguero</h1>
            <p>Inicia sesión para acceder al sistema</p>
        </div>

        <!-- Mostrar mensajes de error o éxito -->
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
            <div class="alert alert-danger" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i><%= mensaje %>
            </div>
        <%
            }
            
            if (logout != null && logout.equals("success")) {
        %>
            <div class="alert alert-success" role="alert">
                <i class="fas fa-check-circle me-2"></i>Sesión cerrada correctamente.
            </div>
        <%
            }
        %>

        <form action="<%= request.getContextPath() %>/LoginServlet" method="POST">
            <div class="input-group">
                <i class="fas fa-envelope"></i>
                <input type="email" class="form-control" id="email" name="email" 
                       placeholder="Correo electrónico" required>
            </div>

            <div class="input-group">
                <i class="fas fa-lock"></i>
                <input type="password" class="form-control" id="password" name="password" 
                       placeholder="Contraseña" required>
            </div>

            <button type="submit" class="btn btn-login">
                <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
            </button>
        </form>

        <div class="footer-text">
            <p>&copy; 2024 Telito Bodeguero. Todos los derechos reservados.</p>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-focus en el primer campo
        document.getElementById('email').focus();
        
        // Limpiar mensajes después de 5 segundos
        setTimeout(() => {
            const alerts = document.querySelectorAll('.alert');
            alerts.forEach(alert => {
                alert.style.transition = 'opacity 0.5s ease';
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 500);
            });
        }, 5000);
    </script>
</body>
</html>
