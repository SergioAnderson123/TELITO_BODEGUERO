<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Telito Bodeguero</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        :root {
            --primary-color: #006d77; /* turquesa oscuro como en módulos */
            --secondary-color: #83c5be; /* seafoam como en módulos */
            --success-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --light-color: #edf6f9;
            --dark-color: #2b2d42;
        }

        body {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .login-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
            padding: 40px;
            width: 100%;
            max-width: 450px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-header .logo {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        .login-header h1 {
            color: var(--primary-color);
            font-weight: 700;
            font-size: 1.8rem;
            margin-bottom: 5px;
        }

        .login-header p {
            color: #7f8c8d;
            font-size: 0.95rem;
            margin: 0;
        }

        .form-floating {
            margin-bottom: 20px;
        }

        .form-floating .form-control {
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 1rem 0.75rem;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-floating .form-control:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        }

        .form-floating label {
            color: #6c757d;
            font-weight: 500;
        }

        .btn-login {
            background: linear-gradient(135deg, var(--secondary-color) 0%, var(--primary-color) 100%);
            border: none;
            border-radius: 12px;
            padding: 12px 30px;
            font-weight: 600;
            font-size: 1.1rem;
            color: white;
            width: 100%;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(52, 152, 219, 0.3);
            color: white;
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .alert {
            border-radius: 12px;
            border: none;
            margin-bottom: 20px;
            padding: 15px 20px;
            font-weight: 500;
        }

        .alert-danger {
            background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
            color: #c62828;
        }

        .login-footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }

        .login-footer p {
            color: #6c757d;
            font-size: 0.9rem;
            margin: 0;
        }

        .form-floating .form-control.is-invalid {
            border-color: var(--danger-color);
        }

        .invalid-feedback {
            font-weight: 500;
        }

        /* Animaciones */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .login-card {
            animation: fadeInUp 0.6s ease-out;
        }

        /* Responsive */
        @media (max-width: 576px) {
            .login-card {
                padding: 30px 20px;
                margin: 10px;
            }
            
            .login-header .logo {
                font-size: 2.5rem;
            }
            
            .login-header h1 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-card">
            <div class="login-header">
                <div class="logo">
                    <i class="fas fa-warehouse"></i>
                </div>
                <h1>Bienvenido a Telito Bodeguero</h1>
                <p>Sistema de Gestión de Bodega</p>
            </div>

            <%-- Mostrar mensajes de error --%>
            <div id="errorAlert" style="display: none;">
                <div class="alert alert-danger" role="alert" id="errorMessageDiv">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <span id="errorMessageText"></span>
                </div>
            </div>
            <% if (request.getAttribute("errorMsg") != null) { %>
            <div class="alert alert-danger" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i>
                <%= request.getAttribute("errorMsg") %>
            </div>
            <% } %>

            <form method="POST" action="<%= request.getContextPath() %>/acceso/login" novalidate id="loginForm">
                <%-- Token CSRF para prevenir ataques - Generado por el servlet --%>
                <input type="hidden" name="csrfToken" value="<%= request.getAttribute("csrfToken") != null ? request.getAttribute("csrfToken") : "" %>">
                
                <div class="form-floating">
                    <input type="text" class="form-control" id="email" name="email" placeholder="Correo electrónico o nombre de usuario" required autocomplete="username">
                    <label for="email"><i class="fas fa-user me-2"></i>Correo electrónico o nombre de usuario</label>
                </div>

                <div class="form-floating">
                    <input type="password" class="form-control" id="password" name="password" placeholder="Contraseña" required autocomplete="current-password">
                    <label for="password"><i class="fas fa-lock me-2"></i>Contraseña</label>
                </div>

                <button type="submit" class="btn btn-login" id="btnLogin">
                    <i class="fas fa-sign-in-alt me-2"></i>
                    Iniciar Sesión
                </button>
            </form>

            <div class="login-footer">
                <p><i class="fas fa-shield-alt me-1"></i> Acceso seguro y protegido</p>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Validación del formulario
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('form');
            const emailInput = document.getElementById('email');
            const passwordInput = document.getElementById('password');

            form.addEventListener('submit', function(e) {
                let isValid = true;

                // Limpiar validaciones anteriores
                emailInput.classList.remove('is-invalid');
                passwordInput.classList.remove('is-invalid');
                
                // Ocultar mensaje de error anterior
                const errorAlert = document.getElementById('errorAlert');
                if (errorAlert) {
                    errorAlert.style.display = 'none';
                }

                // Validar email o nombre de usuario (puede ser email o nombre)
                if (!emailInput.value.trim()) {
                    emailInput.classList.add('is-invalid');
                    isValid = false;
                }
                // Ya no validamos formato de email estricto, puede ser nombre de usuario

                // Validar contraseña
                if (!passwordInput.value.trim()) {
                    passwordInput.classList.add('is-invalid');
                    isValid = false;
                }

                if (!isValid) {
                    e.preventDefault();
                    // Mostrar mensaje de error
                    if (errorAlert) {
                        const errorMessageText = document.getElementById('errorMessageText');
                        if (errorMessageText) {
                            errorMessageText.textContent = 'Por favor, complete todos los campos.';
                        }
                        errorAlert.style.display = 'block';
                        // Hacer scroll al mensaje de error
                        errorAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                    }
                }
            });

            // Función ya no necesaria ya que aceptamos email o nombre de usuario
            // function isValidEmail(email) {
            //     const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            //     return emailRegex.test(email);
            // }

            // Efecto de focus en los inputs
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.parentElement.classList.add('focused');
                });
                
                input.addEventListener('blur', function() {
                    if (!this.value) {
                        this.parentElement.classList.remove('focused');
                    }
                });
            });
        });
    </script>
</body>
</html>
