<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Activación de Cuenta - Telito Bodeguero</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary-color: #006d77;
            --secondary-color: #83c5be;
        }
        
        body {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            min-height: 100vh;
            font-family: 'Poppins', sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .activation-container {
            max-width: 500px;
            width: 100%;
        }
        
        .activation-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 40px;
            text-align: center;
            transform: scale(0.9);
            transform-origin: center center;
        }
        
        .activation-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }
        
        .activation-icon.success {
            color: #28a745;
        }
        
        .activation-icon.error {
            color: #dc3545;
        }
        
        .activation-card h1 {
            color: var(--primary-color);
            font-weight: 600;
            font-size: 1.8rem;
            margin-bottom: 15px;
        }
        
        .activation-card p {
            color: #555;
            font-size: 1rem;
            line-height: 1.6;
            margin-bottom: 25px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--secondary-color) 0%, var(--primary-color) 100%);
            border: none;
            border-radius: 12px;
            padding: 12px 30px;
            font-weight: 600;
            font-size: 1rem;
            color: white;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 109, 119, 0.3);
            color: white;
        }
        
        .alert {
            border-radius: 12px;
            border: none;
            padding: 15px 20px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
            color: #155724;
        }
        
        .alert-danger {
            background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
            color: #721c24;
        }
    </style>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="activation-container">
        <div class="activation-card">
            <% if (request.getAttribute("exito") != null && (Boolean) request.getAttribute("exito")) { %>
                <!-- Activación exitosa -->
                <div class="activation-icon success">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h1>¡Cuenta Activada!</h1>
                <p><%= request.getAttribute("mensaje") != null ? request.getAttribute("mensaje") : "Tu cuenta ha sido activada exitosamente." %></p>
                <a href="<%= request.getContextPath() %>/acceso/login" class="btn-primary">
                    <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
                </a>
            <% } else { %>
                <!-- Error en activación -->
                <div class="activation-icon error">
                    <i class="fas fa-times-circle"></i>
                </div>
                <h1>Error en la Activación</h1>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <%= request.getAttribute("error") != null ? request.getAttribute("error") : "El token de activación es inválido o ha expirado." %>
                </div>
                <p>Si necesitas un nuevo enlace de activación, por favor contacta al administrador del sistema.</p>
                <a href="<%= request.getContextPath() %>/acceso/login" class="btn-primary">
                    <i class="fas fa-arrow-left me-2"></i>Volver al Login
                </a>
            <% } %>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

