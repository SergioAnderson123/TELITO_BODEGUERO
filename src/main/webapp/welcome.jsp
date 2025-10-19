<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bienvenido a Telito Bodeguero</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 60px 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            max-width: 500px;
            width: 100%;
            text-align: center;
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
        
        h1 {
            font-size: 2.5rem;
            font-weight: 600;
            color: #1d1d1f;
            margin-bottom: 16px;
            letter-spacing: -0.02em;
        }
        
        .subtitle {
            font-size: 1.1rem;
            color: #86868b;
            margin-bottom: 40px;
            font-weight: 400;
        }
        
        .login-button {
            display: inline-block;
            padding: 18px 36px;
            background: linear-gradient(135deg, #36a39a 0%, #006d77 100%);
            color: white;
            text-decoration: none;
            border-radius: 12px;
            font-size: 1.1rem;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            border: none;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(54, 163, 154, 0.3);
        }
        
        .login-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }
        
        .login-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(54, 163, 154, 0.4);
            color: white;
            text-decoration: none;
        }
        
        .login-button:hover::before {
            left: 100%;
        }
        
        .login-button:active {
            transform: translateY(0);
            box-shadow: 0 4px 15px rgba(54, 163, 154, 0.2);
        }
        
        .features {
            margin-top: 40px;
            text-align: left;
        }
        
        .feature-item {
            display: flex;
            align-items: center;
            margin-bottom: 12px;
            color: #666;
            font-size: 0.9rem;
        }
        
        .feature-item i {
            color: #36a39a;
            margin-right: 8px;
            width: 16px;
        }
        
        /* Responsive design */
        @media (max-width: 768px) {
            .container {
                padding: 40px 30px;
                margin: 20px;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .subtitle {
                font-size: 1rem;
            }
        }
        
        @media (max-width: 480px) {
            .container {
                padding: 30px 20px;
            }
            
            h1 {
                font-size: 1.8rem;
            }
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <div class="container">
        <div class="brand-icon">
            <i class="fas fa-warehouse"></i>
        </div>
        <h1>Telito Bodeguero</h1>
        <p class="subtitle">Sistema de gestión de bodega integrado</p>
        
        <a href="${pageContext.request.contextPath}/home" class="login-button">
            <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
        </a>
        
        <div class="features">
            <div class="feature-item">
                <i class="fas fa-check"></i>
                Gestión completa de inventario
            </div>
            <div class="feature-item">
                <i class="fas fa-check"></i>
                Control de usuarios y roles
            </div>
            <div class="feature-item">
                <i class="fas fa-check"></i>
                Reportes y estadísticas avanzadas
            </div>
            <div class="feature-item">
                <i class="fas fa-check"></i>
                Seguridad con sesiones protegidas
            </div>
        </div>
    </div>
</body>
</html>
