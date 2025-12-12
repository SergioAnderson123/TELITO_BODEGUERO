<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.example.telito.util.SecurityManager" %>
<%
    // Generar token CSRF si no existe (fallback por si acceden directamente al JSP)
    if (request.getAttribute("csrfToken") == null) {
        String csrfToken = SecurityManager.generarTokenCSRF(request.getSession(true));
        request.setAttribute("csrfToken", csrfToken);
    }
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Telito Bodeguero</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --primary-color: #20c997; /* verde más claro (accent green) */
            --secondary-color: #83c5be; /* seafoam como en módulos */
            --success-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --light-color: #edf6f9;
            --dark-color: #2b2d42;
        }

        body {
            /* Fondo con el verde más claro */
            background-color: #1aa87e;
            min-height: 100vh;
            font-family: 'Poppins', sans-serif;
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
            padding: 45px 50px;
            width: 100%;
            max-width: 520px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
            z-index: 2;
            transform: scale(0.9);
            transform-origin: center center;
        }

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        /* Estilo para el Logo */
        .login-header .logo {
            margin-bottom: 15px;
        }

        .login-header .logo img {
            max-width: 80px; /* <-- ¡PUEDES AJUSTAR ESTE TAMAÑO! */
            height: auto;
            opacity: 0.9;
        }

        .login-header h1 {
            color: var(--primary-color);
            font-weight: 600;
            font-size: 1.8rem;
            margin-bottom: 5px;
        }

        .login-header p {
            color: #7f8c8d;
            font-size: 0.95rem;
            margin: 0;
        }

        /* Estilo para el Slogan */
        .login-header p.slogan {
            color: #555;
            font-size: 1.1rem;
            font-weight: 500;
            margin-top: 5px; /* <--- AJUSTA ESTE VALOR (puedes probar con 5px, 10px, etc.) */
        }

        .form-floating {
            margin-bottom: 20px;
        }

        .form-floating .form-control {
            border: 2px solid #e9ecef;
            border-radius: 12px;
            padding: 0.875rem 1rem 0.875rem 3rem;
            font-size: 1rem;
            transition: all 0.3s ease;
            box-sizing: border-box;
            width: 100%;
            min-height: 58px;
            line-height: 1.5;
            vertical-align: middle;
        }
        

        .form-floating .form-control:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        }

        .form-floating {
            position: relative;
        }
        
        .form-floating label {
            position: absolute;
            top: 0;
            left: 0;
            height: 100%;
            padding: 0.875rem 1rem 0.875rem 3rem;
            pointer-events: none;
            border: 2px solid transparent;
            transform-origin: 0 0;
            transition: opacity 0.1s ease-in-out, transform 0.1s ease-in-out;
            color: #6c757d;
            font-weight: 500;
            opacity: 0.65;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            max-width: 100%;
            line-height: 1.5;
            display: flex;
            align-items: center;
        }
        
        .form-floating .input-icon {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #6c757d;
            z-index: 3;
            pointer-events: none;
            transition: color 0.3s ease;
            font-size: 1rem;
            line-height: 1;
            margin-top: 0;
        }
        
        .form-floating .form-control:focus ~ .input-icon,
        .form-floating.focused .input-icon {
            color: var(--secondary-color);
        }
        
        /* Ocultar label cuando hay placeholder visible o cuando el input tiene valor */
        .form-floating .form-control:focus ~ label,
        .form-floating .form-control:not(:placeholder-shown) ~ label {
            opacity: 0;
            transform: scale(1) translateY(0) translateX(0);
        }
        
        /* Mostrar placeholder solo cuando el input está vacío */
        .form-floating .form-control::placeholder {
            opacity: 0;
            transition: opacity 0.2s ease;
        }
        
        .form-floating .form-control:placeholder-shown::placeholder {
            opacity: 0.7;
        }
        
        .form-floating .form-control:not(:placeholder-shown)::placeholder {
            opacity: 0;
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
            text-transform: uppercase;
            letter-spacing: 0.5px;

            /* --- MODIFICACIONES AQUÍ --- */
            background-size: 200% auto; /* Hacemos el fondo más grande */
            transition: all 0.4s ease-in-out; /* Hacemos la transición más suave */
        }

        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(52, 152, 219, 0.3);
            color: white;

            /* --- MODIFICACIÓN AQUÍ --- */
            background-position: right center; /* Mueve el gradiente */
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .btn-home {
            width: 100%;
            border-radius: 12px;
            padding: 10px 20px;
            font-weight: 500;
            border: 2px solid var(--secondary-color);
            color: var(--secondary-color);
            background: transparent;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-home:hover {
            background-color: var(--secondary-color);
            color: var(--primary-color);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(131, 197, 190, 0.3);
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

        /* CSS para las partículas */
        #tsparticles {
            position: fixed; /* Lo fija en la pantalla */
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1; /* Lo pone DETRÁS de tu tarjeta de login */
        }


        /* Responsive */
        @media (max-width: 576px) {
            .login-card {
                padding: 35px 25px;
                margin: 10px;
                max-width: 100%;
            }

            .login-header .logo {
                font-size: 2.5rem;
            }

            .login-header h1 {
                font-size: 1.5rem;
            }
            
            /* Ajustar inputs para móvil */
            .form-floating .form-control {
                font-size: 16px; /* Previene zoom en iOS */
                padding: 0.875rem 0.75rem 0.875rem 2.75rem;
                min-height: 54px;
                line-height: 1.5;
                vertical-align: middle;
            }
            
            .form-floating label {
                padding: 0.875rem 0.75rem 0.875rem 2.75rem;
                line-height: 54px;
                display: block;
            }
            
            .form-floating .input-icon {
                left: 0.75rem;
            }
            
            .form-floating label {
                font-size: 0.85rem;
                padding: 0.875rem 0.75rem 0.875rem 2.75rem;
                max-width: 100%;
            }
            
            /* Asegurar que el texto no se salga */
            .form-control {
                max-width: 100%;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            
            small.text-muted {
                font-size: 0.8rem !important;
            }
        }
        
        @media (min-width: 577px) and (max-width: 768px) {
            .login-card {
                max-width: 480px;
                padding: 40px 35px;
            }
        }
    </style>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>

<div id="tsparticles"></div>

<div class="login-container">
    <div class="login-card">

        <div class="login-header">
            <div class="logo">
                <img src="<%= request.getContextPath() %>/images/warehouse-svgrepo-com.svg" alt="Logo Telito Bodeguero">
            </div>

            <h1>Bienvenido a Telito Bodeguero</h1>
            <p class="slogan">Tu bodega, bajo control.</p>
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
            <input type="hidden" name="csrfToken" value="<%= request.getAttribute("csrfToken") != null ? request.getAttribute("csrfToken") : "" %>">

            <div class="form-floating">
                <i class="fas fa-user input-icon"></i>
                <input type="text" class="form-control" id="email" name="email" placeholder="Usuario, email o código productor" required autocomplete="username">
                <label for="email">Usuario, email o código productor</label>
            </div>
            <small class="text-muted d-block mb-3" style="font-size: 0.85rem; line-height: 1.4;">
                <i class="fas fa-info-circle me-1"></i>
                Los productores pueden usar su código (ej: PROD-0001) para iniciar sesión
            </small>

            <div class="form-floating">
                <i class="fas fa-lock input-icon"></i>
                <input type="password" class="form-control" id="password" name="password" placeholder="Contraseña" required autocomplete="current-password">
                <label for="password">Contraseña</label>
            </div>
            
            <div class="text-end mb-3">
                <a href="<%= request.getContextPath() %>/acceso/recuperar?action=solicitar" 
                   style="color: var(--primary-color); text-decoration: none; font-size: 0.9rem;">
                    <i class="fas fa-key me-1"></i>¿Olvidaste tu contraseña?
                </a>
            </div>

            <button type="submit" class="btn btn-login" id="btnLogin">
                <i class="fas fa-sign-in-alt me-2"></i>
                Iniciar Sesión
            </button>
        </form>

        <div class="text-center mt-3">
            <a href="<%= request.getContextPath() %>/" class="btn-home">
                <i class="fas fa-home me-2"></i>
                Volver al Inicio
            </a>
        </div>

        <div class="login-footer">
            <p><i class="fas fa-shield-alt me-1"></i> Acceso seguro y protegido</p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/tsparticles-slim@2.12.0/tsparticles.slim.bundle.min.js"></script>

<script>
    // Validación del formulario y partículas
    document.addEventListener('DOMContentLoaded', function() {

        // --- 1. CÓDIGO DE VALIDACIÓN (Limpio) ---
        const form = document.querySelector('form');
        const emailInput = document.getElementById('email');
        const passwordInput = document.getElementById('password');

        form.addEventListener('submit', function(e) {
            let isValid = true;

            emailInput.classList.remove('is-invalid');
            passwordInput.classList.remove('is-invalid');

            const errorAlert = document.getElementById('errorAlert');
            if (errorAlert) {
                errorAlert.style.display = 'none';
            }

            if (!emailInput.value.trim()) {
                emailInput.classList.add('is-invalid');
                isValid = false;
            }

            if (!passwordInput.value.trim()) {
                passwordInput.classList.add('is-invalid');
                isValid = false;
            }

            if (!isValid) {
                e.preventDefault();
                if (errorAlert && (!errorAlert.style.display || errorAlert.style.display === 'none')) {
                    const errorMessageText = document.getElementById('errorMessageText');
                    if (errorMessageText && !errorMessageText.textContent) {
                        errorMessageText.textContent = 'Por favor, complete todos los campos.';
                    }
                    errorAlert.style.display = 'block';
                    errorAlert.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                }
            }
        });

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
            
            // Manejar el estado cuando hay valor
            if (input.value) {
                input.parentElement.classList.add('focused');
            }
        });

        // --- 2. CÓDIGO DE PARTÍCULAS (Limpio) ---
        tsParticles.load("tsparticles", {
            particles: {
                number: { value: 80, density: { enable: true, value_area: 800 } },
                color: { value: "#83c5be" },
                shape: { type: "circle" },
                opacity: { value: 0.5, random: true },
                size: { value: 3, random: { enable: true, minimumValue: 1 } },
                links: {
                    color: "#83c5be", // Tu --secondary-color
                    distance: 150,
                    enable: true,
                    opacity: 0.4,
                    width: 1,
                },
                move: {
                    enable: true,
                    speed: 2,
                    direction: "none",
                    out_mode: "out",
                },
            },
            interactivity: {
                events: {
                    onhover: { enable: true, mode: "repulse" }, // Reaccionan al mouse
                    onclick: { enable: true, mode: "push" },  // Reaccionan al click
                },
                modes: {
                    repulse: { distance: 100 },
                    push: { particles_nb: 4 },
                },
            },
            retina_detect: true,
        });

    });
</script>
</body>
</html>