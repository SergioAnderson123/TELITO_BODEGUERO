<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Telito Bodeguero - Sistema de gestión inteligente de inventarios para bodegas de todos los tamaños. Control preciso, reportes en tiempo real y alertas automáticas.">
    <title>Telito Bodeguero - Sistema de Gestión de Inventarios Inteligente</title>

    <!-- Fuentes -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- AOS Animation Library -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">

    <style>
        :root {
            --primary-brown: #6F4E37;
            --primary-brown-dark: #5a3e2a;
            --secondary-brown: #8B6F47;
            --accent-beige: #C9A87A;
            --accent-gold: #D4A574;
            --accent-yellow: #E8B86D;
            --light-beige: #FFFEF9;
            --medium-beige: #F5DEB3;
            --gradient-brown: linear-gradient(135deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            --gradient-beige: linear-gradient(135deg, #D4A574 0%, #C9A87A 100%);
            --gradient-gold: linear-gradient(135deg, #E8B86D 0%, #D4A574 100%);
            --dark: #1a1a1a;
            --gray: #6c757d;
            --light: #f8f9fa;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            overflow-x: hidden;
            color: var(--dark);
            background: white;
        }

        /* ============================================
           PARTÍCULAS DE FONDO
        ============================================ */
        #tsparticles {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            opacity: 0.3;
        }

        /* ============================================
           NAVBAR MODERNA
        ============================================ */
        .navbar-custom {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.08);
            padding: 1.2rem 0;
            transition: all 0.3s ease;
        }

        .navbar-custom.scrolled {
            padding: 0.8rem 0;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.12);
        }

        .navbar-brand {
            font-weight: 800;
            font-size: 1.5rem;
            color: var(--primary-brown) !important;
            display: flex;
            align-items: center;
            gap: 15px;
            transition: transform 0.3s ease;
            text-decoration: none;
        }

        .navbar-brand:hover {
            transform: translateY(-2px);
        }

        .navbar-brand img {
            height: 55px;
            filter: drop-shadow(0 3px 12px rgba(111, 78, 55, 0.4));
            transition: all 0.3s ease;
        }
        
        .navbar-brand:hover img {
            transform: scale(1.05);
            filter: drop-shadow(0 5px 20px rgba(111, 78, 55, 0.5));
        }
        
        .brand-text {
            font-size: 1.6rem;
            font-weight: 900;
            background: var(--gradient-brown);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            letter-spacing: -0.5px;
            line-height: 1.2;
        }

        .nav-link-custom {
            color: var(--dark) !important;
            font-weight: 500;
            font-size: 0.95rem;
            margin: 0 1rem;
            position: relative;
            transition: color 0.3s ease;
            text-decoration: none;
            padding-bottom: 5px;
        }

        .nav-link-custom::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 0;
            height: 3px;
            background: var(--gradient-brown);
            border-radius: 2px;
            transition: width 0.3s ease;
        }

        .nav-link-custom:hover::after,
        .nav-link-custom.active::after {
            width: 100%;
        }

        .nav-link-custom:hover {
            color: var(--primary-brown) !important;
        }

        .btn-login-custom {
            background: var(--gradient-beige);
            color: white;
            font-weight: 600;
            padding: 0.7rem 2rem;
            border-radius: 50px;
            border: none;
            box-shadow: 0 4px 15px rgba(212, 165, 116, 0.3);
            transition: all 0.3s ease;
        }

        .btn-login-custom:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(212, 165, 116, 0.4);
            color: white;
            background: var(--gradient-gold);
        }

        /* ============================================
           HERO SECTION MEJORADO
        ============================================ */
        .hero-section {
            min-height: 100vh;
            display: flex;
            align-items: center;
            background: var(--gradient-brown);
            position: relative;
            overflow: hidden;
            padding: 8rem 0 4rem;
        }

        .hero-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg width="60" height="60" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="grid" width="60" height="60" patternUnits="userSpaceOnUse"><circle cx="5" cy="5" r="2" fill="rgba(255,255,255,0.15)"/><circle cx="30" cy="30" r="1.5" fill="rgba(255,255,255,0.1)"/></pattern></defs><rect width="100%" height="100%" fill="url(%23grid)"/></svg>');
            opacity: 1;
        }
        
        .hero-section::after {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle at 30% 50%, rgba(212, 165, 116, 0.15) 0%, transparent 50%),
                        radial-gradient(circle at 70% 50%, rgba(201, 168, 122, 0.15) 0%, transparent 50%);
            animation: float 20s ease-in-out infinite;
        }
        
        @keyframes float {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            33% { transform: translate(30px, -30px) rotate(5deg); }
            66% { transform: translate(-20px, 20px) rotate(-5deg); }
        }

        .hero-content {
            position: relative;
            z-index: 3;
            color: white;
        }

        .hero-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            padding: 0.6rem 1.5rem;
            border-radius: 50px;
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 2rem;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .hero-title {
            font-size: 4.5rem;
            font-weight: 900;
            line-height: 1.1;
            margin-bottom: 1.5rem;
            text-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
        }

        .hero-subtitle {
            font-size: 1.4rem;
            font-weight: 400;
            max-width: 650px;
            margin: 0 auto 3rem;
            opacity: 0.95;
            line-height: 1.7;
        }

        .hero-buttons {
            display: flex;
            gap: 1.5rem;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn-hero-primary {
            background: white;
            color: var(--primary-brown);
            font-weight: 700;
            font-size: 1.1rem;
            padding: 1rem 3rem;
            border-radius: 50px;
            border: none;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .btn-hero-primary:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
            background: var(--light-beige);
            color: var(--primary-brown);
        }

        .btn-hero-secondary {
            background: transparent;
            color: white;
            font-weight: 600;
            font-size: 1.1rem;
            padding: 1rem 3rem;
            border-radius: 50px;
            border: 2px solid white;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .btn-hero-secondary:hover {
            background: white;
            color: var(--primary-brown);
            transform: translateY(-5px);
        }

        .hero-stats {
            display: flex;
            gap: 4rem;
            justify-content: center;
            margin-top: 4rem;
            flex-wrap: wrap;
        }

        .stat-item {
            text-align: center;
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 900;
            display: inline;
        }

        .stat-label {
            font-size: 1rem;
            opacity: 0.9;
            display: block;
            margin-top: 0.5rem;
        }

        /* ============================================
           CARACTERÍSTICAS REDISEÑADAS
        ============================================ */
        .features-section {
            padding: 8rem 0;
            background: linear-gradient(180deg, #ffffff 0%, #f8f9fa 50%, #ffffff 100%);
            position: relative;
            overflow: hidden;
        }
        
        .features-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg width="80" height="80" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="dots" width="80" height="80" patternUnits="userSpaceOnUse"><circle cx="40" cy="40" r="1" fill="rgba(0,109,119,0.05)"/></pattern></defs><rect width="100%" height="100%" fill="url(%23dots)"/></svg>');
            opacity: 1;
        }

        .section-header {
            text-align: center;
            max-width: 700px;
            margin: 0 auto 5rem;
        }

        .section-badge {
            display: inline-block;
            background: var(--light-beige);
            color: var(--primary-brown);
            padding: 0.5rem 1.5rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 1.5rem;
        }

        .section-title {
            font-size: 3rem;
            font-weight: 900;
            color: var(--primary-brown);
            margin-bottom: 1.5rem;
        }

        .section-description {
            font-size: 1.2rem;
            color: var(--gray);
            line-height: 1.7;
        }

        .feature-card-modern {
            background: white;
            border-radius: 20px;
            padding: 3rem 2rem;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            border: 2px solid #f0f0f0;
            height: 100%;
        }

        .feature-card-modern:hover {
            transform: translateY(-10px);
            border-color: var(--accent-beige);
            box-shadow: 0 20px 50px rgba(111, 78, 55, 0.15);
        }

        .feature-icon-modern {
            width: 80px;
            height: 80px;
            background: var(--gradient-brown);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 2rem;
            box-shadow: 0 10px 30px rgba(111, 78, 55, 0.2);
        }

        .feature-icon-modern i {
            font-size: 2.5rem;
            color: white;
        }

        .feature-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-brown);
            margin-bottom: 1rem;
        }

        .feature-description {
            color: var(--gray);
            line-height: 1.7;
            font-size: 1rem;
        }

        /* ============================================
           SECCIÓN DE BENEFICIOS
        ============================================ */
        .benefits-section {
            padding: 8rem 0;
            background: linear-gradient(135deg, #FFFEF9 0%, #F5DEB3 100%);
            position: relative;
            overflow: hidden;
        }
        
        .benefits-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="boxes" width="100" height="100" patternUnits="userSpaceOnUse"><rect x="0" y="0" width="50" height="50" fill="none" stroke="rgba(111,78,55,0.08)" stroke-width="1"/><rect x="50" y="50" width="50" height="50" fill="none" stroke="rgba(111,78,55,0.08)" stroke-width="1"/></pattern></defs><rect width="100%" height="100%" fill="url(%23boxes)"/></svg>');
            opacity: 1;
        }

        .benefit-item {
            display: flex;
            align-items: start;
            gap: 1.5rem;
            margin-bottom: 2.5rem;
        }

        .benefit-icon {
            width: 60px;
            height: 60px;
            min-width: 60px;
            background: var(--gradient-brown);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 20px rgba(111, 78, 55, 0.2);
        }

        .benefit-icon i {
            font-size: 1.8rem;
            color: white;
        }

        .benefit-content h4 {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary-brown);
            margin-bottom: 0.8rem;
        }

        .benefit-content p {
            color: var(--gray);
            line-height: 1.7;
            margin: 0;
        }

        /* ============================================
           CTA SECTION
        ============================================ */
        .cta-section {
            padding: 6rem 0;
            background: var(--gradient-brown);
            color: white;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .cta-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg width="50" height="50" xmlns="http://www.w3.org/2000/svg"><defs><pattern id="circles" width="50" height="50" patternUnits="userSpaceOnUse"><circle cx="25" cy="25" r="2" fill="rgba(255,255,255,0.2)"/><circle cx="0" cy="0" r="1" fill="rgba(255,255,255,0.15)"/><circle cx="50" cy="50" r="1" fill="rgba(255,255,255,0.15)"/></pattern></defs><rect width="100%" height="100%" fill="url(%23circles)"/></svg>');
            opacity: 1;
        }
        
        .cta-section::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: radial-gradient(ellipse at top, rgba(255, 255, 255, 0.1) 0%, transparent 60%);
        }

        .cta-content {
            position: relative;
            z-index: 2;
        }

        .cta-title {
            font-size: 3rem;
            font-weight: 900;
            margin-bottom: 1.5rem;
        }

        .cta-subtitle {
            font-size: 1.3rem;
            margin-bottom: 3rem;
            opacity: 0.95;
        }

        /* ============================================
           FOOTER MODERNO
        ============================================ */
        .footer-modern {
            background: var(--dark);
            color: white;
            padding: 4rem 0 2rem;
        }

        .footer-brand {
            font-size: 1.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            color: var(--accent-beige);
        }

        .footer-description {
            color: rgba(255, 255, 255, 0.7);
            line-height: 1.7;
            margin-bottom: 2rem;
        }

        .footer-links h5 {
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: var(--accent-beige);
        }

        .footer-links ul {
            list-style: none;
            padding: 0;
        }

        .footer-links ul li {
            margin-bottom: 0.8rem;
        }

        .footer-links ul li a {
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-links ul li a:hover {
            color: var(--accent-beige);
        }

        .footer-bottom {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            margin-top: 3rem;
            padding-top: 2rem;
            text-align: center;
            color: rgba(255, 255, 255, 0.5);
        }

        /* ============================================
           RESPONSIVE
        ============================================ */
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2.5rem;
            }
            
            .hero-subtitle {
                font-size: 1.1rem;
            }
            
            .section-title {
                font-size: 2rem;
            }
            
            .hero-stats {
                gap: 2rem;
            }
            
            .stat-number {
                font-size: 2rem;
            }

            .cta-title {
                font-size: 2rem;
            }
        }
    </style>
</head>

<body>

<!-- ============================================
     NAVBAR
============================================ -->
<nav class="navbar navbar-expand-lg navbar-custom fixed-top">
    <div class="container">
        <a class="navbar-brand" href="#">
            <img src="<%= request.getContextPath() %>/images/logo.svg" alt="Telito Bodeguero">
            <span class="brand-text">Telito Bodeguero</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center">
                <li class="nav-item">
                    <a class="nav-link-custom active" href="#inicio">Inicio</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link-custom" href="#caracteristicas">Características</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link-custom" href="#beneficios">Beneficios</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link-custom" href="#contacto">Contacto</a>
                </li>
                <li class="nav-item ms-3">
                    <a href="<%= request.getContextPath() %>/acceso/login" class="btn btn-login-custom">
                        <i class="fas fa-sign-in-alt me-2"></i>Iniciar Sesión
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ============================================
     HERO SECTION
============================================ -->
<section class="hero-section" id="inicio">
    <div class="container">
        <div class="hero-content text-center" data-aos="fade-up">
            <div class="hero-badge">
                <i class="fas fa-warehouse me-2"></i>
                Gestión Inteligente de Inventarios
            </div>
            <h1 class="hero-title">
                El Poder de tu Bodega,<br>
                <span class="text-white">Simplificado</span>
            </h1>
            <p class="hero-subtitle">
                La solución definitiva para gestionar tu inventario, pedidos y despachos en un solo lugar.
                Preciso, rápido y siempre disponible en la nube.
            </p>
            <div class="hero-buttons">
                <a href="<%= request.getContextPath() %>/acceso/login" class="btn btn-hero-primary">
                    <i class="fas fa-rocket me-2"></i>Comenzar Ahora
                </a>
                <a href="#caracteristicas" class="btn btn-hero-secondary">
                    <i class="fas fa-play-circle me-2"></i>Ver Demo
                </a>
            </div>

            <!-- Estadísticas -->
            <div class="hero-stats" data-aos="fade-up" data-aos-delay="200">
                <div class="stat-item">
                    <span class="stat-number counter" data-target="99">0</span><span class="stat-number">%</span>
                    <span class="stat-label">Precisión en Inventarios</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number counter" data-target="50">0</span><span class="stat-number">%</span>
                    <span class="stat-label">Reducción de Tiempos</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number counter" data-target="24">0</span><span class="stat-number">/7</span>
                    <span class="stat-label">Acceso en la Nube</span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ============================================
     CARACTERÍSTICAS
============================================ -->
<section class="features-section" id="caracteristicas">
    <div class="container">
        <div class="section-header" data-aos="fade-up">
            <span class="section-badge">FUNCIONALIDADES</span>
            <h2 class="section-title">Todo lo que Necesitas en una Sola Plataforma</h2>
            <p class="section-description">
                Sistema completo e integrado para maximizar la eficiencia de tu operación logística
            </p>
        </div>

        <div class="row g-4">
            <!-- Feature 1: Control de Inventario -->
            <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="100">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern">
                        <i class="fas fa-boxes"></i>
                    </div>
                    <h3 class="feature-title">Control de Inventario en Tiempo Real</h3>
                    <p class="feature-description">
                        Monitorea tus existencias al instante. Recibe alertas automáticas de stock mínimo
                        y mantén un control preciso de cada producto en tu bodega.
                    </p>
                    <ul class="list-unstyled mt-3">
                        <li><i class="fas fa-check text-success me-2"></i>Alertas de stock crítico</li>
                        <li><i class="fas fa-check text-success me-2"></i>Trazabilidad por lote</li>
                        <li><i class="fas fa-check text-success me-2"></i>Control de ubicaciones</li>
                    </ul>
                </div>
            </div>

            <!-- Feature 2: Gestión de Órdenes -->
            <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="200">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern">
                        <i class="fas fa-file-invoice"></i>
                    </div>
                    <h3 class="feature-title">Gestión Integral de Órdenes</h3>
                    <p class="feature-description">
                        Administra órdenes de compra y venta desde un solo lugar. Automatiza flujos
                        de trabajo y reduce errores humanos.
                    </p>
                    <ul class="list-unstyled mt-3">
                        <li><i class="fas fa-check text-success me-2"></i>Órdenes de compra automatizadas</li>
                        <li><i class="fas fa-check text-success me-2"></i>Seguimiento de proveedores</li>
                        <li><i class="fas fa-check text-success me-2"></i>Historial completo</li>
                    </ul>
                </div>
            </div>

            <!-- Feature 3: Reportes Inteligentes -->
            <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="300">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <h3 class="feature-title">Reportes y Análisis Avanzados</h3>
                    <p class="feature-description">
                        Toma decisiones basadas en datos reales. Genera reportes detallados y visualiza
                        métricas clave de tu operación.
                    </p>
                    <ul class="list-unstyled mt-3">
                        <li><i class="fas fa-check text-success me-2"></i>Dashboard en tiempo real</li>
                        <li><i class="fas fa-check text-success me-2"></i>Exportación a Excel/PDF</li>
                        <li><i class="fas fa-check text-success me-2"></i>Análisis predictivo</li>
                    </ul>
                </div>
            </div>

            <!-- Feature 4: Planes de Transporte -->
            <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="100">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern">
                        <i class="fas fa-truck"></i>
                    </div>
                    <h3 class="feature-title">Logística y Despachos</h3>
                    <p class="feature-description">
                        Optimiza tus rutas de entrega. Planifica y gestiona despachos eficientemente
                        con nuestro módulo de transporte integrado.
                    </p>
                    <ul class="list-unstyled mt-3">
                        <li><i class="fas fa-check text-success me-2"></i>Programación de rutas</li>
                        <li><i class="fas fa-check text-success me-2"></i>Seguimiento de entregas</li>
                        <li><i class="fas fa-check text-success me-2"></i>Gestión de transportistas</li>
                    </ul>
                </div>
            </div>

            <!-- Feature 5: Alertas Automáticas -->
            <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="200">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern">
                        <i class="fas fa-bell"></i>
                    </div>
                    <h3 class="feature-title">Sistema de Alertas Inteligente</h3>
                    <p class="feature-description">
                        Recibe notificaciones automáticas sobre eventos críticos. Mantente informado
                        sin necesidad de revisar constantemente el sistema.
                    </p>
                    <ul class="list-unstyled mt-3">
                        <li><i class="fas fa-check text-success me-2"></i>Notificaciones por email</li>
                        <li><i class="fas fa-check text-success me-2"></i>Alertas personalizables</li>
                        <li><i class="fas fa-check text-success me-2"></i>Priorización automática</li>
                    </ul>
                </div>
            </div>

            <!-- Feature 6: Multi-usuario -->
            <div class="col-lg-4 col-md-6" data-aos="fade-up" data-aos-delay="300">
                <div class="feature-card-modern">
                    <div class="feature-icon-modern">
                        <i class="fas fa-users"></i>
                    </div>
                    <h3 class="feature-title">Gestión Multi-usuario</h3>
                    <p class="feature-description">
                        Roles y permisos diferenciados. Desde administradores hasta operarios,
                        cada usuario tiene acceso a lo que necesita.
                    </p>
                    <ul class="list-unstyled mt-3">
                        <li><i class="fas fa-check text-success me-2"></i>Control de accesos</li>
                        <li><i class="fas fa-check text-success me-2"></i>Perfiles personalizados</li>
                        <li><i class="fas fa-check text-success me-2"></i>Auditoría de acciones</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ============================================
     BENEFICIOS
============================================ -->
<section class="benefits-section" id="beneficios">
    <div class="container">
        <div class="section-header" data-aos="fade-up">
            <span class="section-badge">VENTAJAS COMPETITIVAS</span>
            <h2 class="section-title">¿Por Qué Elegir Telito Bodeguero?</h2>
            <p class="section-description">
                Una solución diseñada para crecer contigo, desde pequeñas tiendas hasta grandes operaciones logísticas
            </p>
        </div>

        <div class="row align-items-center">
            <div class="col-lg-6" data-aos="fade-right">
                <div class="benefit-item">
                    <div class="benefit-icon">
                        <i class="fas fa-bolt"></i>
                    </div>
                    <div class="benefit-content">
                        <h4>Implementación Rápida</h4>
                        <p>Configura tu sistema en minutos, no en semanas. Sin instalaciones complejas ni
                        infraestructura costosa. Accede desde cualquier navegador.</p>
                    </div>
                </div>

                <div class="benefit-item">
                    <div class="benefit-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <div class="benefit-content">
                        <h4>Seguridad Garantizada</h4>
                        <p>Tus datos protegidos con tecnología de encriptación de última generación.
                        Backups automáticos y recuperación ante desastres incluida.</p>
                    </div>
                </div>

                <div class="benefit-item">
                    <div class="benefit-icon">
                        <i class="fas fa-sync-alt"></i>
                    </div>
                    <div class="benefit-content">
                        <h4>Actualizaciones Automáticas</h4>
                        <p>Siempre tendrás la última versión con nuevas funcionalidades. Sin interrupciones
                        de servicio ni procesos manuales de actualización.</p>
                    </div>
                </div>
            </div>

            <div class="col-lg-6" data-aos="fade-left">
                <div class="benefit-item">
                    <div class="benefit-icon">
                        <i class="fas fa-chart-pie"></i>
                    </div>
                    <div class="benefit-content">
                        <h4>Escalabilidad Ilimitada</h4>
                        <p>Desde 10 hasta 100,000 productos. El sistema crece a tu ritmo sin necesidad
                        de cambiar de plataforma o perder información.</p>
                    </div>
                </div>

                <div class="benefit-item">
                    <div class="benefit-icon">
                        <i class="fas fa-headset"></i>
                    </div>
                    <div class="benefit-content">
                        <h4>Soporte Técnico Incluido</h4>
                        <p>Equipo de expertos disponible para resolver tus dudas. Capacitación personalizada
                        y documentación completa a tu disposición.</p>
                    </div>
                </div>

                <div class="benefit-item">
                    <div class="benefit-icon">
                        <i class="fas fa-dollar-sign"></i>
                    </div>
                    <div class="benefit-content">
                        <h4>ROI Inmediato</h4>
                        <p>Reduce costos operativos hasta un 40%. Elimina errores de inventario y optimiza
                        tus recursos humanos desde el primer día.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ============================================
     CTA SECTION
============================================ -->
<section class="cta-section" id="contacto">
    <div class="container">
        <div class="cta-content" data-aos="zoom-in">
            <h2 class="cta-title">¿Listo para Transformar tu Bodega?</h2>
            <p class="cta-subtitle">
                Únete a cientos de empresas que ya optimizaron su gestión de inventarios
            </p>
            <div class="hero-buttons">
                <a href="<%= request.getContextPath() %>/acceso/login" class="btn btn-hero-primary">
                    <i class="fas fa-user-plus me-2"></i>Crear Cuenta Gratis
                </a>
                <a href="#" class="btn btn-hero-secondary">
                    <i class="fas fa-phone me-2"></i>Contáctanos
                </a>
            </div>
        </div>
    </div>
</section>

<!-- ============================================
     FOOTER
============================================ -->
<footer class="footer-modern">
    <div class="container">
        <div class="row">
            <div class="col-lg-4 mb-4">
                <div class="footer-brand">
                    <i class="fas fa-warehouse me-2"></i>Telito Bodeguero
                </div>
                <p class="footer-description">
                    La plataforma más completa para la gestión inteligente de inventarios,
                    diseñada para empresas que buscan eficiencia y crecimiento.
                </p>
            </div>

            <div class="col-lg-2 col-md-4 mb-4">
                <div class="footer-links">
                    <h5>Producto</h5>
                    <ul>
                        <li><a href="#caracteristicas">Características</a></li>
                        <li><a href="#beneficios">Beneficios</a></li>
                        <li><a href="#">Precios</a></li>
                        <li><a href="#">Demo</a></li>
                    </ul>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 mb-4">
                <div class="footer-links">
                    <h5>Empresa</h5>
                    <ul>
                        <li><a href="#">Sobre Nosotros</a></li>
                        <li><a href="#">Blog</a></li>
                        <li><a href="#">Contacto</a></li>
                        <li><a href="#">Carreras</a></li>
                    </ul>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 mb-4">
                <div class="footer-links">
                    <h5>Soporte</h5>
                    <ul>
                        <li><a href="#">Centro de Ayuda</a></li>
                        <li><a href="#">Documentación</a></li>
                        <li><a href="#">API</a></li>
                        <li><a href="#">Estado del Sistema</a></li>
                    </ul>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 mb-4">
                <div class="footer-links">
                    <h5>Legal</h5>
                    <ul>
                        <li><a href="#">Términos de Uso</a></li>
                        <li><a href="#">Privacidad</a></li>
                        <li><a href="#">Cookies</a></li>
                        <li><a href="#">Licencias</a></li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="footer-bottom">
            <p class="mb-0">&copy; 2025 Telito Bodeguero. Todos los derechos reservados.</p>
        </div>
    </div>
</footer>

<!-- Partículas de Fondo -->
<div id="tsparticles"></div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/tsparticles@2.12.0/tsparticles.bundle.min.js"></script>
<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>

<script>
    // Inicializar AOS (Animate On Scroll)
    AOS.init({
        duration: 800,
        easing: 'ease-in-out',
        once: true,
        offset: 100
    });

    // Navbar scroll effect
    window.addEventListener('scroll', function() {
        const navbar = document.querySelector('.navbar-custom');
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // Counter animation
    function animateCounter(element) {
        const target = parseInt(element.getAttribute('data-target'));
        const duration = 2000;
        const step = target / (duration / 16);
        let current = 0;

        const timer = setInterval(() => {
            current += step;
            if (current >= target) {
                element.textContent = target;
                clearInterval(timer);
            } else {
                element.textContent = Math.floor(current);
            }
        }, 16);
    }

    // Iniciar contadores cuando sean visibles
    const counterObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                counterObserver.unobserve(entry.target);
            }
        });
    });

    document.querySelectorAll('.counter').forEach(counter => {
        counterObserver.observe(counter);
    });

    // Configuración de Partículas
    tsParticles.load("tsparticles", {
        background: {
            color: {
                value: "transparent"
            }
        },
        fpsLimit: 60,
        particles: {
            number: {
                value: 80,
                density: {
                    enable: true,
                    value_area: 800
                }
            },
            color: {
                value: "#C9A87A"
            },
            shape: {
                type: "circle"
            },
            opacity: {
                value: 0.5,
                random: false
            },
            size: {
                value: 3,
                random: true
            },
            line_linked: {
                enable: true,
                distance: 150,
                color: "#C9A87A",
                opacity: 0.4,
                width: 1
            },
            move: {
                enable: true,
                speed: 2,
                direction: "none",
                random: false,
                straight: false,
                out_mode: "out",
                bounce: false
            }
        },
        interactivity: {
            detect_on: "canvas",
            events: {
                onhover: {
                    enable: true,
                    mode: "grab"
                },
                onclick: {
                    enable: true,
                    mode: "push"
                },
                resize: true
            },
            modes: {
                grab: {
                    distance: 140,
                    line_linked: {
                        opacity: 1
                    }
                },
                push: {
                    particles_nb: 4
                }
            }
        },
        retina_detect: true
    });

    // Smooth scroll para los enlaces de navegación
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
</script>

</body>
</html>
