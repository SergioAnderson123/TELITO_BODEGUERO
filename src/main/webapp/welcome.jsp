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
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
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
        
        .role-options {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        
        .role-options a {
            display: block;
            padding: 18px 24px;
            background: #007aff;
            color: white;
            text-decoration: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 500;
            transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            border: none;
            position: relative;
            overflow: hidden;
        }
        
        .role-options a::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }
        
        .role-options a:hover {
            background: #0056d6;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 122, 255, 0.3);
        }
        
        .role-options a:hover::before {
            left: 100%;
        }
        
        .role-options a:active {
            transform: translateY(0);
            box-shadow: 0 4px 15px rgba(0, 122, 255, 0.2);
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
</head>
<body>
    <div class="container">
        <h1>Bienvenido a Telito Bodeguero</h1>
        <p class="subtitle">Por favor, selecciona tu rol para continuar:</p>
        <div class="role-options">
            <a href="${pageContext.request.contextPath}/inicio">Administrador</a>
            <a href="${pageContext.request.contextPath}/ProductorServlet">Productor</a>
            <a href="${pageContext.request.contextPath}/InventarioServlet">Logistica</a>
            <a href="${pageContext.request.contextPath}/almacen/LoteServlet">Almacen</a>
        </div>
    </div>
</body>
</html>
