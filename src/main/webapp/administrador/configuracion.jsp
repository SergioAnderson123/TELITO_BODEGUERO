<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.administrador.daos.ProductoDAO" %>
<%@ page import="com.example.telito.administrador.daos.StockMinimoDAO" %>

<%
    // Calcular estadísticas para la card de Gestión de Stock Mínimo
    ProductoDAO productoDAO = new ProductoDAO();
    StockMinimoDAO stockMinimoDAO = new StockMinimoDAO();
    
    // Productos activos sin configuración (disponibles para configurar)
    int productosSinConfiguracion = productoDAO.contarProductosSinConfiguracion();
    int productosConfigurados = stockMinimoDAO.contarTotalConfiguraciones();
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Configuración"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Configuracion'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <!-- Pantalla de carga - solo sobre el contenido principal -->
        <div id="loadingOverlay" class="loading-overlay">
            <div class="loading-content">
                <div class="spinner-container">
                    <div class="spinner"></div>
                </div>
                <p class="loading-text">Cargando configuración...</p>
            </div>
        </div>
        <div class="dashboard-content" id="dashboardContent" style="opacity: 0;">
            <div class="row g-4 justify-content-center">
                <div class="col-lg-4 col-md-6">
                    <div class="config-card alert-card">
                        <a href="<%= request.getContextPath() %>/AlertaServlet" class="text-decoration-none">
                            <div class="config-card-header">
                                <div class="config-icon alert-icon">
                                    <i class="fas fa-bell"></i>
                                </div>
                                <div class="config-badge alert-badge">
                                    <i class="fas fa-cog"></i>
                                </div>
                            </div>
                            <div class="config-card-body">
                                <h4 class="config-title">Gestión de Alertas</h4>
                                <p class="config-description">Crea y administra las reglas de notificación del sistema</p>
                                <div class="config-stats">
                                    <div class="stat-item">
                                        <span class="stat-number">6</span>
                                        <span class="stat-label">Reglas</span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-number">4</span>
                                        <span class="stat-label">Tipos</span>
                                    </div>
                                </div>
                            </div>
                            <div class="config-card-footer">
                                <span class="config-action">Gestionar <i class="fas fa-arrow-right"></i></span>
                            </div>
                        </a>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="config-card stock-card">
                        <a href="<%= request.getContextPath() %>/StockMinimoServlet?action=listar" class="text-decoration-none">
                            <div class="config-card-header">
                                <div class="config-icon stock-icon">
                                    <i class="fas fa-triangle-exclamation"></i>
                                </div>
                                <div class="config-badge stock-badge">
                                    <i class="fas fa-box"></i>
                                </div>
                            </div>
                            <div class="config-card-body">
                                <h4 class="config-title">Gestión de Stock Mínimo</h4>
                                <p class="config-description">Configura los umbrales de stock mínimo para cada producto</p>
                                <div class="config-stats">
                                    <div class="stat-item">
                                        <span class="stat-number"><%= productosSinConfiguracion %></span>
                                        <span class="stat-label">Productos a Configurar</span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-number"><%= productosConfigurados %></span>
                                        <span class="stat-label">Configurados</span>
                                    </div>
                                </div>
                            </div>
                            <div class="config-card-footer">
                                <span class="config-action">Configurar <i class="fas fa-arrow-right"></i></span>
                            </div>
                        </a>
                    </div>
                </div>

                <div class="col-lg-4 col-md-6">
                    <div class="config-card template-card">
                        <a href="<%= request.getContextPath() %>/PlantillaServlet" class="text-decoration-none">
                            <div class="config-card-header">
                                <div class="config-icon template-icon">
                                    <i class="fas fa-file-excel"></i>
                                </div>
                                <div class="config-badge template-badge">
                                    <i class="fas fa-upload"></i>
                                </div>
                            </div>
                            <div class="config-card-body">
                                <h4 class="config-title">Gestión de Plantillas</h4>
                                <p class="config-description">Administra las plantillas para la carga masiva de datos</p>
                                <div class="config-stats">
                                    <div class="stat-item">
                                        <span class="stat-number">5</span>
                                        <span class="stat-label">Plantillas</span>
                                    </div>
                                    <div class="stat-item">
                                        <span class="stat-number">3</span>
                                        <span class="stat-label">Activas</span>
                                    </div>
                                </div>
                            </div>
                            <div class="config-card-footer">
                                <span class="config-action">Administrar <i class="fas fa-arrow-right"></i></span>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<style>
    /* Estilos para las tarjetas de configuración */
    .config-card {
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        overflow: hidden;
        position: relative;
        height: 100%;
        border: 2px solid transparent;
    }

    .config-card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
    }

    .config-card a {
        color: inherit;
        display: block;
        height: 100%;
    }

    /* Header de la tarjeta */
    .config-card-header {
        position: relative;
        padding: 25px 25px;
        color: white;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .config-icon {
        font-size: 2.5rem;
        opacity: 0.95;
        text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        animation: float 3s ease-in-out infinite;
    }

    @keyframes float {
        0%, 100% { transform: translateY(0); }
        50% { transform: translateY(-8px); }
    }

    .config-badge {
        background: rgba(255, 255, 255, 0.25);
        padding: 10px;
        border-radius: 12px;
        font-size: 1.2rem;
        backdrop-filter: blur(10px);
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    /* Body de la tarjeta */
    .config-card-body {
        padding: 20px 25px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
    }

    .config-title {
        font-size: 1.3rem;
        font-weight: 700;
        color: #2b2d42;
        margin-bottom: 12px;
    }

    /* Colores de títulos según el tipo de tarjeta - Replicando Reportes Globales */
    .alert-card .config-title {
        color: #D4A574;
    }

    .stock-card .config-title {
        color: #6F4E37;
    }

    .template-card .config-title {
        color: #E8B86D;
    }

    .config-description {
        color: #6c757d;
        font-size: 0.9rem;
        line-height: 1.5;
        margin-bottom: 18px;
        flex-grow: 1;
    }

    /* Estadísticas */
    .config-stats {
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

    /* Colores de estadísticas según el tipo de tarjeta - Replicando Reportes Globales */
    .alert-card .stat-number {
        color: #D4A574;
    }

    .stock-card .stat-number {
        color: #6F4E37;
    }

    .template-card .stat-number {
        color: #E8B86D;
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

    /* Footer de la tarjeta */
    .config-card-footer {
        padding: 15px 25px;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-top: 1px solid #dee2e6;
    }

    .config-action {
        font-weight: 700;
        font-size: 0.9rem;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* Colores de acción según el tipo de tarjeta - Replicando Reportes Globales */
    .alert-card .config-action {
        color: #D4A574;
    }

    .stock-card .config-action {
        color: #6F4E37;
    }

    .template-card .config-action {
        color: #E8B86D;
    }

    .config-action i {
        margin-left: 8px;
        transition: transform 0.3s ease;
    }

    .config-card:hover .config-action i {
        transform: translateX(5px);
    }

    /* Colores específicos para cada tipo de configuración - Replicando colores de Reportes Globales */
    .alert-card .config-card-header {
        background: linear-gradient(135deg, #D4A574 0%, #C9A87A 100%);
    }

    .alert-card:hover {
        border-color: #D4A574;
    }

    .stock-card .config-card-header {
        background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
    }

    .stock-card:hover {
        border-color: #6F4E37;
    }

    .template-card .config-card-header {
        background: linear-gradient(135deg, #E8B86D 0%, #D4A574 100%);
    }

    .template-card:hover {
        border-color: #E8B86D;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .config-card-header {
            padding: 20px 20px 15px;
        }

        .config-card-body {
            padding: 20px;
        }

        .config-card-footer {
            padding: 15px 20px;
        }

        .config-icon {
            font-size: 2.5rem;
        }

        .config-title {
            font-size: 1.3rem;
        }

        .stat-number {
            font-size: 1.5rem;
        }
    }
    
    /* Asegurar que los enlaces funcionen en móvil */
    .config-card a {
        display: block;
        width: 100%;
        height: 100%;
        text-decoration: none;
        color: inherit;
        -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
        touch-action: manipulation;
        position: relative;
        z-index: 1;
    }
    
    .config-card {
        cursor: pointer;
        -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
        touch-action: manipulation;
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