<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recuperación de Contraseña - Telito Bodeguero</title>
    
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
        
        .recovery-container {
            max-width: 500px;
            width: 100%;
        }
        
        .recovery-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 40px;
            transform: scale(0.9);
            transform-origin: center center;
        }
        
        .recovery-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .recovery-icon {
            font-size: 48px;
            color: var(--primary-color);
            margin-bottom: 15px;
        }
        
        .recovery-card h1 {
            color: var(--primary-color);
            font-weight: 600;
            font-size: 1.8rem;
            margin-bottom: 10px;
        }
        
        .recovery-card p {
            color: #555;
            font-size: 0.95rem;
            margin-bottom: 25px;
        }
        
        .form-floating {
            margin-bottom: 20px;
        }
        
        .form-floating .form-control {
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 0.875rem 1rem;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        
        .form-floating .form-control:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.25);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--secondary-color) 0%, var(--primary-color) 100%);
            border: none;
            border-radius: 12px;
            padding: 12px 30px;
            font-weight: 600;
            font-size: 1rem;
            color: white;
            width: 100%;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 109, 119, 0.3);
            color: white;
        }
        
        .btn-secondary {
            background: transparent;
            border: 2px solid var(--secondary-color);
            border-radius: 12px;
            padding: 10px 20px;
            font-weight: 500;
            color: var(--secondary-color);
            width: 100%;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .btn-secondary:hover {
            background-color: var(--secondary-color);
            color: var(--primary-color);
            transform: translateY(-2px);
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
        
        .password-strength {
            font-size: 0.85rem;
            margin-top: 5px;
        }
        
        .password-strength.weak {
            color: #dc3545;
        }
        
        .password-strength.medium {
            color: #ffc107;
        }
        
        .password-strength.strong {
            color: #28a745;
        }
    </style>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="recovery-container">
        <div class="recovery-card">
            <div class="recovery-header">
                <div class="recovery-icon">
                    <i class="fas fa-key"></i>
                </div>
                <h1>Recuperación de Contraseña</h1>
            </div>
            
            <%-- Mostrar mensajes --%>
            <% if (request.getAttribute("exito") != null && (Boolean) request.getAttribute("exito")) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle me-2"></i>
                    <%= request.getAttribute("mensaje") != null ? request.getAttribute("mensaje") : "Se ha enviado un correo con las instrucciones." %>
                </div>
                <a href="<%= request.getContextPath() %>/acceso/login" class="btn-secondary">
                    <i class="fas fa-arrow-left me-2"></i>Volver al Login
                </a>
            <% } else { %>
                <%-- Mostrar errores --%>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                
                <%-- Formulario de solicitud o cambio de contraseña --%>
                <% if (request.getAttribute("tokenValido") != null && (Boolean) request.getAttribute("tokenValido")) { %>
                    <%-- Formulario para cambiar contraseña --%>
                    <form method="POST" action="<%= request.getContextPath() %>/acceso/recuperar" id="formCambiarContrasena">
                        <input type="hidden" name="action" value="cambiar">
                        <input type="hidden" name="token" value="<%= request.getAttribute("token") != null ? request.getAttribute("token") : "" %>">
                        
                        <div class="form-floating mb-3">
                            <input type="password" class="form-control" id="nueva_contrasena" name="nueva_contrasena" 
                                   placeholder="Nueva Contraseña" required minlength="8">
                            <label for="nueva_contrasena">
                                <i class="fas fa-lock me-2"></i>Nueva Contraseña
                            </label>
                            <div class="password-strength" id="passwordStrength"></div>
                            <small class="text-muted">Mínimo 8 caracteres, incluyendo letras y números</small>
                        </div>
                        
                        <div class="form-floating mb-3">
                            <input type="password" class="form-control" id="confirmar_contrasena" name="confirmar_contrasena" 
                                   placeholder="Confirmar Contraseña" required minlength="8">
                            <label for="confirmar_contrasena">
                                <i class="fas fa-lock me-2"></i>Confirmar Contraseña
                            </label>
                            <div id="passwordMatch" class="mt-2"></div>
                        </div>
                        
                        <button type="submit" class="btn-primary">
                            <i class="fas fa-save me-2"></i>Cambiar Contraseña
                        </button>
                    </form>
                <% } else { %>
                    <%-- Formulario para solicitar recuperación --%>
                    <p>Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.</p>
                    
                    <form method="POST" action="<%= request.getContextPath() %>/acceso/recuperar" id="formSolicitarRecuperacion">
                        <input type="hidden" name="action" value="solicitar">
                        
                        <div class="form-floating mb-3">
                            <input type="email" class="form-control" id="email" name="email" 
                                   placeholder="Correo Electrónico" required>
                            <label for="email">
                                <i class="fas fa-envelope me-2"></i>Correo Electrónico
                            </label>
                        </div>
                        
                        <button type="submit" class="btn-primary">
                            <i class="fas fa-paper-plane me-2"></i>Enviar Enlace de Recuperación
                        </button>
                    </form>
                <% } %>
                
                <div class="text-center mt-3">
                    <a href="<%= request.getContextPath() %>/acceso/login" class="btn-secondary">
                        <i class="fas fa-arrow-left me-2"></i>Volver al Login
                    </a>
                </div>
            <% } %>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Validación de fortaleza de contraseña
        const nuevaContrasena = document.getElementById('nueva_contrasena');
        const confirmarContrasena = document.getElementById('confirmar_contrasena');
        const passwordStrength = document.getElementById('passwordStrength');
        const passwordMatch = document.getElementById('passwordMatch');
        
        if (nuevaContrasena) {
            nuevaContrasena.addEventListener('input', function() {
                const password = this.value;
                let strength = '';
                let strengthClass = '';
                
                if (password.length === 0) {
                    strength = '';
                } else if (password.length < 8) {
                    strength = 'Débil - Mínimo 8 caracteres';
                    strengthClass = 'weak';
                } else if (!/(?=.*[a-zA-Z])(?=.*[0-9])/.test(password)) {
                    strength = 'Débil - Debe incluir letras y números';
                    strengthClass = 'weak';
                } else if (password.length < 12) {
                    strength = 'Media';
                    strengthClass = 'medium';
                } else {
                    strength = 'Fuerte';
                    strengthClass = 'strong';
                }
                
                passwordStrength.textContent = strength;
                passwordStrength.className = 'password-strength ' + strengthClass;
            });
        }
        
        // Validación de coincidencia de contraseñas
        if (confirmarContrasena) {
            confirmarContrasena.addEventListener('input', function() {
                if (nuevaContrasena.value !== this.value) {
                    passwordMatch.innerHTML = '<small class="text-danger"><i class="fas fa-times-circle me-1"></i>Las contraseñas no coinciden</small>';
                } else {
                    passwordMatch.innerHTML = '<small class="text-success"><i class="fas fa-check-circle me-1"></i>Las contraseñas coinciden</small>';
                }
            });
        }
        
        // Validación del formulario
        const formCambiarContrasena = document.getElementById('formCambiarContrasena');
        if (formCambiarContrasena) {
            formCambiarContrasena.addEventListener('submit', function(e) {
                const password = nuevaContrasena.value;
                const confirm = confirmarContrasena.value;
                
                if (password.length < 8) {
                    e.preventDefault();
                    alert('La contraseña debe tener al menos 8 caracteres.');
                    return false;
                }
                
                if (!/(?=.*[a-zA-Z])(?=.*[0-9])/.test(password)) {
                    e.preventDefault();
                    alert('La contraseña debe incluir letras y números.');
                    return false;
                }
                
                if (password !== confirm) {
                    e.preventDefault();
                    alert('Las contraseñas no coinciden.');
                    return false;
                }
            });
        }
    </script>
</body>
</html>

