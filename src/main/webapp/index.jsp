<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio - Telito Bodeguero</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        :root {
            --primary-color: #006d77;
            --secondary-color: #83c5be;
            --light-color: #f8f9fa;
            --dark-color: #343a40;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--primary-color); /* Fondo base para el hero */
            color: var(--dark-color);
        }

        /* --- 1. Fondo de Partículas (Idéntico al login) --- */
        #tsparticles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1; /* Detrás de todo */
        }

        /* --- 2. Barra de Navegación --- */
        .navbar {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
            padding: 0.75rem 0;
        }

        .navbar-brand img {
            height: 40px; /* Tamaño del logo en la barra */
        }

        .navbar-brand span {
            font-weight: 600;
            font-size: 1.25rem;
            color: white;
            margin-left: 10px;
        }

        .navbar-nav .nav-link {
            color: rgba(255, 255, 255, 0.85);
            font-weight: 500;
            margin: 0 0.5rem;
            transition: color 0.3s ease;
        }

        .navbar-nav .nav-link:hover {
            color: white;
        }

        .btn-login-nav {
            border: 2px solid var(--secondary-color);
            color: var(--secondary-color);
            font-weight: 600;
            padding: 0.5rem 1.25rem;
            border-radius: 50px;
            transition: all 0.3s ease;
        }

        .btn-login-nav:hover {
            background-color: var(--secondary-color);
            color: var(--primary-color);
        }

        /* --- 3. Sección Héroe --- */
        .hero-section {
            min-height: 90vh; /* Ocupa casi toda la pantalla */
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: white;
            padding: 4rem 0;
        }

        .hero-section h1 {
            font-size: 3.5rem;
            font-weight: 700;
            text-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .hero-section p.lead {
            font-size: 1.25rem;
            font-weight: 400;
            max-width: 600px;
            margin: 1.5rem auto 2rem;
            color: rgba(255, 255, 255, 0.9);
        }

        .btn-primary-hero {
            background-color: var(--secondary-color);
            border-color: var(--secondary-color);
            color: var(--primary-color);
            font-weight: 600;
            font-size: 1.1rem;
            padding: 0.75rem 2rem;
            border-radius: 50px;
            margin: 0 0.5rem;
            transition: all 0.3s ease;
        }

        .btn-primary-hero:hover {
            background-color: #6eb9b3; /* Un tono más claro de secondary */
            border-color: #6eb9b3;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }

        /* --- 4. Sección de Características --- */
        /* Esta sección rompe con el fondo de partículas */
        .features-section {
            background-color: white;
            padding: 6rem 0;
            position: relative; /* Para que esté sobre las partículas */
            z-index: 2; /* Importante */
        }

        .section-title {
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 3rem;
        }

        .feature-icon {
            font-size: 3rem;
            color: var(--secondary-color);
            margin-bottom: 1.5rem;
        }

        .feature-card h3 {
            color: var(--primary-color);
            font-weight: 600;
            margin-bottom: 1rem;
        }

        /* --- 5. Footer --- */
        .footer {
            background-color: var(--dark-color);
            color: rgba(255, 255, 255, 0.7);
            padding: 2rem 0;
            position: relative; /* Para que esté sobre las partículas */
            z-index: 2; /* Importante */
        }

    </style>
</head>
<body>

<div id="tsparticles"></div>

<nav class="navbar navbar-expand-lg fixed-top navbar-dark">
    <div class="container">
        <a class="navbar-brand d-flex align-items-center" href="#">
            <img src="<%= request.getContextPath() %>/images/warehouse-svgrepo-com.svg" alt="Telito Bodeguero Logo">
            <span>Telito Bodeguero</span>
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto mb-2 mb-lg-0 align-items-center">
                <li class="nav-item">
                    <a class="nav-link active" href="#">Inicio</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#features">Características</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#">Precios</a>
                </li>
                <li class="nav-item ms-lg-3">
                    <a class="btn btn-login-nav" href="<%= request.getContextPath() %>/acceso/login">
                        Iniciar Sesión
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<header class="hero-section">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <h1 class="display-3">El Poder de tu Bodega, Simplificado.</h1>
                <p class="lead">
                    La solución definitiva para gestionar tu inventario, pedidos y despachos en un solo lugar.
                    Preciso, rápido y siempre en la nube.
                </p>
                <a href="#" class="btn btn-primary-hero">Solicitar una Demo</a>
            </div>
        </div>
    </div>
</header>

<main>
    <section id="features" class="features-section">
        <div class="container">
            <h2 class="text-center section-title">¿Por qué Telito Bodeguero?</h2>

            <div class="row text-center g-4">
                <div class="col-md-4 feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-boxes-stacked"></i>
                    </div>
                    <h3>Control de Inventario</h3>
                    <p>Sabe exactamente qué tienes, dónde está y cuánto vale, todo en tiempo real.</p>
                </div>

                <div class="col-md-4 feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-truck-fast"></i>
                    </div>
                    <h3>Gestión de Pedidos</h3>
                    <p>Procesa entradas y salidas sin errores, desde la compra hasta el despacho al cliente.</p>
                </div>

                <div class="col-md-4 feature-card">
                    <div class="feature-icon">
                        <i class="fas fa-chart-pie"></i>
                    </div>
                    <h3>Reportes Inteligentes</h3>
                    <p>Toma decisiones con datos reales sobre tu rotación de stock, productos más vendidos y más.</p>
                </div>
            </div>
        </div>
    </section>
</main>

<footer class="footer">
    <div class="container">
        <p>&copy; 2025 Telito Bodeguero. Todos los derechos reservados.</p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/tsparticles-slim@2.12.0/tsparticles.slim.bundle.min.js"></script>

<script>
    // Configuración de Partículas (La misma de tu login)
    document.addEventListener('DOMContentLoaded', function() {
        tsParticles.load("tsparticles", {
            particles: {
                number: { value: 80, density: { enable: true, value_area: 800 } },
                color: { value: "#83c5be" },
                shape: { type: "circle" },
                opacity: { value: 0.5, random: true },
                size: { value: 3, random: { enable: true, minimumValue: 1 } },
                links: {
                    color: "#83c5be",
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
                    onhover: { enable: true, mode: "repulse" },
                    onclick: { enable: true, mode: "push" },
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