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
        <div class="dashboard-content">
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
        background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
        overflow: hidden;
        position: relative;
        height: 100%;
    }

    .config-card:hover {
        transform: translateY(-10px);
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    }

    .config-card a {
        color: inherit;
        display: block;
        height: 100%;
    }

    /* Header de la tarjeta */
    .config-card-header {
        position: relative;
        padding: 30px 30px 20px;
        background: linear-gradient(135deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
        color: white;
    }

    .config-icon {
        font-size: 3rem;
        margin-bottom: 15px;
        opacity: 0.9;
    }

    .config-badge {
        position: absolute;
        top: 20px;
        right: 20px;
        background: rgba(255, 255, 255, 0.2);
        padding: 10px;
        border-radius: 50%;
        font-size: 1.2rem;
    }

    /* Body de la tarjeta */
    .config-card-body {
        padding: 30px;
    }

    .config-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--turquoise-dark);
        margin-bottom: 15px;
    }

    .config-description {
        color: var(--text-muted);
        font-size: 1rem;
        line-height: 1.6;
        margin-bottom: 25px;
    }

    /* Estadísticas */
    .config-stats {
        display: flex;
        justify-content: space-between;
        margin-bottom: 20px;
    }

    .stat-item {
        text-align: center;
    }

    .stat-number {
        display: block;
        font-size: 1.8rem;
        font-weight: 700;
        color: var(--turquoise-dark);
    }

    .stat-label {
        font-size: 0.85rem;
        color: var(--text-muted);
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    /* Footer de la tarjeta */
    .config-card-footer {
        padding: 20px 30px;
        background: #f8f9fa;
        border-top: 1px solid #e9ecef;
    }

    .config-action {
        color: var(--turquoise-dark);
        font-weight: 600;
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
    }

    .config-action i {
        margin-left: 8px;
        transition: transform 0.3s ease;
    }

    .config-card:hover .config-action i {
        transform: translateX(5px);
    }

    /* Colores específicos para cada tipo de configuración */
    .stock-card .config-card-header {
        background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
    }

    .alert-card .config-card-header {
        background: linear-gradient(135deg, #dc3545 0%, #e83e8c 100%);
    }

    .template-card .config-card-header {
        background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
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
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>