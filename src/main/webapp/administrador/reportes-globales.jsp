<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Reportes Globales - Telito Bodeguero</title>
    <script>
        // CRÍTICO: Establecer fondo inmediatamente ANTES de que se cargue cualquier CSS
        (function() {
            document.documentElement.style.backgroundColor = '#FFFEF9';
            document.documentElement.style.margin = '0';
            document.documentElement.style.padding = '0';
            if (document.body) {
                document.body.style.backgroundColor = '#FFFEF9';
                document.body.style.margin = '0';
                document.body.style.padding = '0';
            } else {
                document.addEventListener('DOMContentLoaded', function() {
                    document.body.style.backgroundColor = '#FFFEF9';
                    document.body.style.margin = '0';
                    document.body.style.padding = '0';
                });
            }
        })();
    </script>
    <style>
        /* CRÍTICO: Prevenir flash de fondo azul - debe estar ANTES de cualquier otro CSS */
        html, body {
            background-color: #FFFEF9 !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif !important;
        }
        .dashboard-main-wrapper {
            background-color: #FFFEF9 !important;
            min-height: 100vh !important;
        }
        .dashboard-wrapper {
            background-color: #FFFEF9 !important;
        }
        .dashboard-content {
            background-color: #FFFEF9 !important;
        }
        .container-fluid {
            background-color: transparent !important;
        }
    </style>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Reportes Globales"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Reportes'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <!-- Pantalla de carga - solo sobre el contenido principal -->
        <div id="loadingOverlay" class="loading-overlay">
            <div class="loading-content">
                <div class="spinner-container">
                    <div class="spinner"></div>
                </div>
                <p class="loading-text">Cargando reportes...</p>
            </div>
        </div>
        <div class="dashboard-content" id="dashboardContent" style="opacity: 0;">
            <div class="container-fluid px-4">
                <div class="page-header mb-4">
                    <h2 class="pageheader-title mb-0">
                        <i class="fas fa-chart-line me-2"></i>Reportes Globales
                    </h2>
                </div>

                <div class="row g-4 mb-5">
                    <div class="col-lg-4 col-md-6">
                        <div class="report-card logistica-card">
                            <a href="<%= request.getContextPath() %>/administrador/reportes?action=logistica" class="text-decoration-none">
                                <div class="report-card-header">
                                    <div class="report-icon logistica-icon">
                                        <i class="fas fa-truck-fast"></i>
                                    </div>
                                    <div class="report-badge logistica-badge">
                                        <i class="fas fa-chart-line"></i>
                                    </div>
                                </div>
                                <div class="report-card-body">
                                    <h4 class="report-title">Logística</h4>
                                    <p class="report-description">Análisis completo de movimientos, distribución, planes de transporte y eficiencia operativa</p>
                                    <div class="report-stats">
                                        <div class="stat-item">
                                            <span class="stat-number"><%= request.getAttribute("rutasActivas") != null ? request.getAttribute("rutasActivas") : "12" %></span>
                                            <span class="stat-label">Rutas Activas</span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-number"><%= request.getAttribute("eficiencia") != null ? request.getAttribute("eficiencia") + "%" : "94%" %></span>
                                            <span class="stat-label">Eficiencia</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="report-card-footer">
                                    <span class="report-action">Ver Dashboard <i class="fas fa-arrow-right"></i></span>
                                </div>
                            </a>
                        </div>
                    </div>

                    <div class="col-lg-4 col-md-6">
                        <div class="report-card productor-card">
                            <a href="<%= request.getContextPath() %>/administrador/reportes?action=productor" class="text-decoration-none">
                                <div class="report-card-header">
                                    <div class="report-icon productor-icon">
                                        <i class="fas fa-seedling"></i>
                                    </div>
                                    <div class="report-badge productor-badge">
                                        <i class="fas fa-chart-bar"></i>
                                    </div>
                                </div>
                                <div class="report-card-body">
                                    <h4 class="report-title">Productor</h4>
                                    <p class="report-description">Seguimiento de producción, gestión de lotes, control de costos y fechas de caducidad</p>
                                    <div class="report-stats">
                                        <div class="stat-item">
                                            <span class="stat-number"><%= request.getAttribute("productores") != null ? request.getAttribute("productores") : "8" %></span>
                                            <span class="stat-label">Productores</span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-number"><%= request.getAttribute("lotes") != null ? request.getAttribute("lotes") : "45" %></span>
                                            <span class="stat-label">Lotes</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="report-card-footer">
                                    <span class="report-action">Ver Dashboard <i class="fas fa-arrow-right"></i></span>
                                </div>
                            </a>
                        </div>
                    </div>

                    <div class="col-lg-4 col-md-6">
                        <div class="report-card almacen-card">
                            <a href="<%= request.getContextPath() %>/administrador/reportes?action=almacen" class="text-decoration-none">
                                <div class="report-card-header">
                                    <div class="report-icon almacen-icon">
                                        <i class="fas fa-warehouse"></i>
                                    </div>
                                    <div class="report-badge almacen-badge">
                                        <i class="fas fa-chart-pie"></i>
                                    </div>
                                </div>
                                <div class="report-card-body">
                                    <h4 class="report-title">Almacén</h4>
                                    <p class="report-description">Control de inventario, gestión de entradas y salidas, ajustes de stock y ubicaciones</p>
                                    <div class="report-stats">
                                        <div class="stat-item">
                                            <span class="stat-number"><%= request.getAttribute("productos") != null ? request.getAttribute("productos") : "156" %></span>
                                            <span class="stat-label">Productos</span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-number"><%= request.getAttribute("ubicaciones") != null ? request.getAttribute("ubicaciones") : "24" %></span>
                                            <span class="stat-label">Ubicaciones</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="report-card-footer">
                                    <span class="report-action">Ver Dashboard <i class="fas fa-arrow-right"></i></span>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<style>
    /* =====================
       ESTILOS MEJORADOS PARA REPORTES GLOBALES (COMPACTOS)
    ====================== */
    
    /* Header simplificado */
    .page-header {
        background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        padding: 20px;
        border-radius: 12px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        border-left: 4px solid #6F4E37;
    }
    
    .page-header .pageheader-title {
        color: #6F4E37;
        font-weight: 700;
        font-size: 1.5rem;
    }

    /* Tarjetas de reporte compactas */
    .report-card {
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        overflow: hidden;
        position: relative;
        height: 100%;
        border: 2px solid transparent;
    }

    .report-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #6F4E37 0%, #8B6F47 100%);
        transform: scaleX(0);
        transition: transform 0.4s ease;
    }

    .report-card:hover::before {
        transform: scaleX(1);
    }

    .report-card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
    }

    .report-card a {
        color: inherit;
        display: flex;
        flex-direction: column;
        height: 100%;
    }

    /* Header de la tarjeta compacto */
    .report-card-header {
        position: relative;
        padding: 25px 25px;
        color: white;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .report-icon {
        font-size: 2.5rem;
        opacity: 0.95;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        animation: float 3s ease-in-out infinite;
    }

    @keyframes float {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-8px); }
    }

    .report-badge {
        background: rgba(255, 255, 255, 0.25);
        padding: 10px;
        border-radius: 12px;
        font-size: 1.2rem;
        backdrop-filter: blur(10px);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    /* Body de la tarjeta compacto */
    .report-card-body {
        padding: 20px 25px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
    }

    .report-title {
        font-size: 1.3rem;
        font-weight: 700;
        color: #2b2d42;
        margin-bottom: 12px;
    }

    .report-description {
        color: #6c757d;
        font-size: 0.9rem;
        line-height: 1.5;
        margin-bottom: 18px;
        flex-grow: 1;
    }

    /* Estadísticas compactas */
    .report-stats {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
        margin-bottom: 15px;
    }

    .stat-item {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        padding: 12px;
        border-radius: 10px;
        text-align: center;
        border: 1px solid #dee2e6;
        transition: all 0.3s ease;
    }

    .stat-item:hover {
        transform: scale(1.05);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    .stat-number {
        display: block;
        font-size: 1.5rem;
        font-weight: 800;
        color: #2b2d42;
    }

    .stat-label {
        font-size: 0.75rem;
        color: #6c757d;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-weight: 600;
        margin-top: 4px;
        display: block;
    }

    /* Footer de la tarjeta compacto */
    .report-card-footer {
        padding: 15px 25px;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-top: 1px solid #dee2e6;
    }

    .report-action {
        font-weight: 700;
        font-size: 0.9rem;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .report-action i {
        margin-left: 8px;
        transition: transform 0.3s ease;
        font-size: 1rem;
    }

    .report-card:hover .report-action i {
        transform: translateX(5px);
    }

    /* Colores con gradientes de logística */
    .logistica-card .report-card-header {
        background: linear-gradient(135deg, #D4A574 0%, #C9A87A 100%);
    }

    .logistica-card:hover {
        border-color: #D4A574;
    }

    .logistica-card .stat-number {
        color: #D4A574;
    }

    .logistica-card .report-action {
        color: #D4A574;
    }

    .productor-card .report-card-header {
        background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
    }

    .productor-card:hover {
        border-color: #6F4E37;
    }

    .productor-card .stat-number {
        color: #6F4E37;
    }

    .productor-card .report-action {
        color: #6F4E37;
    }

    .almacen-card .report-card-header {
        background: linear-gradient(135deg, #E8B86D 0%, #D4A574 100%);
    }

    .almacen-card:hover {
        border-color: #E8B86D;
    }

    .almacen-card .stat-number {
        color: #E8B86D;
    }

    .almacen-card .report-action {
        color: #E8B86D;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .page-header {
            padding: 15px;
        }
        
        .page-header .pageheader-title {
            font-size: 1.3rem;
        }
        
        .report-card-header {
            padding: 20px;
        }

        .report-card-body {
            padding: 15px 20px;
        }

        .report-card-footer {
            padding: 12px 20px;
        }

        .report-icon {
            font-size: 2rem;
        }

        .report-badge {
            font-size: 1rem;
            padding: 8px;
        }

        .report-title {
            font-size: 1.1rem;
        }

        .stat-number {
            font-size: 1.3rem;
        }
        
        .report-stats {
            gap: 8px;
        }
    }

    /* Animaciones */
    @keyframes slideInUp {
        from {
            opacity: 0;
            transform: translateY(20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .report-card {
        animation: slideInUp 0.5s ease-out;
    }

    .report-card:nth-child(1) {
        animation-delay: 0.1s;
    }

    .report-card:nth-child(2) {
        animation-delay: 0.2s;
    }

    .report-card:nth-child(3) {
        animation-delay: 0.3s;
    }
    
    /* =====================
       PANTALLA DE CARGA
    ====================== */
    
    .loading-overlay {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(255, 254, 249, 0);
        backdrop-filter: blur(0px);
        -webkit-backdrop-filter: blur(0px);
        z-index: 9999;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 1;
        transition: opacity 0.5s ease-out;
        animation: blurIn 0.3s ease-out 0.3s forwards;
    }
    
    @keyframes blurIn {
        to {
            background-color: rgba(255, 254, 249, 0.85);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }
    }
    
    .dashboard-wrapper {
        position: relative;
    }
    
    .loading-overlay.hidden {
        opacity: 0;
        pointer-events: none;
    }
    
    .loading-content {
        text-align: center;
        color: #6F4E37;
    }
    
    .spinner-container {
        margin-bottom: 20px;
        animation: fadeIn 0.2s ease-out 0.2s both;
    }
    
    @keyframes fadeIn {
        from {
            opacity: 0;
        }
        to {
            opacity: 1;
        }
    }
    
    .spinner {
        width: 60px;
        height: 60px;
        border: 6px solid rgba(111, 78, 55, 0.2);
        border-top-color: #6F4E37;
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin: 0 auto;
    }
    
    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }
    
    .loading-text {
        font-size: 1.1rem;
        font-weight: 600;
        color: #6F4E37;
        margin: 0;
        letter-spacing: 0.5px;
        animation: fadeInUp 0.2s ease-out;
        animation-fill-mode: both;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    </style>

<script>
    // =====================
    // PANTALLA DE CARGA
    // =====================
    (function() {
        function initLoadingScreen() {
            var loadingOverlay = document.getElementById('loadingOverlay');
            var dashboardContent = document.getElementById('dashboardContent');
            
            // Ocultar el contenido al inicio
            if (dashboardContent) {
                dashboardContent.style.opacity = '0';
                dashboardContent.style.transition = 'opacity 0.5s ease-in';
            }
            
            if (loadingOverlay) {
                // Asegurar que el overlay esté visible
                loadingOverlay.style.display = 'flex';
                loadingOverlay.style.opacity = '1';
                
                // Ocultar el overlay y mostrar el contenido después de 0.5 segundos
                setTimeout(function() {
                    loadingOverlay.classList.add('hidden');
                    // Mostrar el contenido
                    if (dashboardContent) {
                        dashboardContent.style.opacity = '1';
                    }
                    // Remover el elemento del DOM después de la animación
                    setTimeout(function() {
                        if (loadingOverlay && loadingOverlay.parentNode) {
                            loadingOverlay.parentNode.removeChild(loadingOverlay);
                        }
                    }, 500); // Después de que termine la animación de fade out
                }, 500); // 0.5 segundos
            }
        }
        
        // Ejecutar cuando el DOM esté listo
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initLoadingScreen);
        } else {
            // Si el DOM ya está cargado, ejecutar inmediatamente
            initLoadingScreen();
        }
    })();
    
    // Asegurar que el fondo se mantenga correcto durante toda la carga
    (function() {
        function setBackground() {
            document.documentElement.style.backgroundColor = '#FFFEF9';
            if (document.body) {
                document.body.style.backgroundColor = '#FFFEF9';
            }
            var wrapper = document.querySelector('.dashboard-main-wrapper');
            if (wrapper) {
                wrapper.style.backgroundColor = '#FFFEF9';
            }
            var content = document.querySelector('.dashboard-content');
            if (content) {
                content.style.backgroundColor = '#FFFEF9';
            }
        }
        
        // Ejecutar inmediatamente
        setBackground();
        
        // Ejecutar cuando el DOM esté listo
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', setBackground);
        }
        
        // Ejecutar cuando la ventana esté completamente cargada
        window.addEventListener('load', setBackground);
    })();
    
    // Asegurar que los dropdowns de Bootstrap funcionen correctamente
    document.addEventListener('DOMContentLoaded', function() {
        // Esperar a que Bootstrap esté completamente cargado
        if (typeof bootstrap !== 'undefined') {
            // Inicializar todos los dropdowns
            var dropdownElementList = [].slice.call(document.querySelectorAll('[data-bs-toggle="dropdown"]'));
            var dropdownList = dropdownElementList.map(function (dropdownToggleEl) {
                return new bootstrap.Dropdown(dropdownToggleEl);
            });
        } else {
            // Si Bootstrap aún no está cargado, esperar un poco más
            setTimeout(function() {
                if (typeof bootstrap !== 'undefined') {
                    var dropdownElementList = [].slice.call(document.querySelectorAll('[data-bs-toggle="dropdown"]'));
                    var dropdownList = dropdownElementList.map(function (dropdownToggleEl) {
                        return new bootstrap.Dropdown(dropdownToggleEl);
                    });
                }
            }, 100);
        }
    });
</script>
</body>
</html>