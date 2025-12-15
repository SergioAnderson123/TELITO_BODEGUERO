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
            document.documentElement.style.backgroundColor = '#edf6f9';
            document.documentElement.style.margin = '0';
            document.documentElement.style.padding = '0';
            if (document.body) {
                document.body.style.backgroundColor = '#edf6f9';
                document.body.style.margin = '0';
                document.body.style.padding = '0';
            } else {
                document.addEventListener('DOMContentLoaded', function() {
                    document.body.style.backgroundColor = '#edf6f9';
                    document.body.style.margin = '0';
                    document.body.style.padding = '0';
                });
            }
        })();
    </script>
    <style>
        /* CRÍTICO: Prevenir flash de fondo azul - debe estar ANTES de cualquier otro CSS */
        html, body {
            background-color: #edf6f9 !important;
            margin: 0 !important;
            padding: 0 !important;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif !important;
        }
        .dashboard-main-wrapper {
            background-color: #edf6f9 !important;
            min-height: 100vh !important;
        }
        .dashboard-wrapper {
            background-color: #edf6f9 !important;
        }
        .dashboard-content {
            background-color: #edf6f9 !important;
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
        <div class="dashboard-content">
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
        border-left: 4px solid #00a896;
    }
    
    .page-header .pageheader-title {
        color: #00a896;
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
        background: linear-gradient(90deg, #00a896 0%, #83c5be 100%);
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

    /* Colores originales restaurados */
    .logistica-card .report-card-header {
        background: linear-gradient(135deg, #17a2b8 0%, #20c997 100%);
    }

    .logistica-card:hover {
        border-color: #17a2b8;
    }

    .logistica-card .stat-number {
        color: #17a2b8;
    }

    .logistica-card .report-action {
        color: #17a2b8;
    }

    .productor-card .report-card-header {
        background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    }

    .productor-card:hover {
        border-color: #28a745;
    }

    .productor-card .stat-number {
        color: #28a745;
    }

    .productor-card .report-action {
        color: #28a745;
    }

    .almacen-card .report-card-header {
        background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
    }

    .almacen-card:hover {
        border-color: #ffc107;
    }

    .almacen-card .stat-number {
        color: #fd7e14;
    }

    .almacen-card .report-action {
        color: #fd7e14;
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
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Asegurar que el fondo se mantenga correcto durante toda la carga
    (function() {
        function setBackground() {
            document.documentElement.style.backgroundColor = '#edf6f9';
            if (document.body) {
                document.body.style.backgroundColor = '#edf6f9';
            }
            var wrapper = document.querySelector('.dashboard-main-wrapper');
            if (wrapper) {
                wrapper.style.backgroundColor = '#edf6f9';
            }
            var content = document.querySelector('.dashboard-content');
            if (content) {
                content.style.backgroundColor = '#edf6f9';
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
</script>
</body>
</html>