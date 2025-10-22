<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
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
                    <h2 class="pageheader-title"><i class="fas fa-chart-pie me-2"></i>Reportes Globales</h2>
                    <p class="pageheader-text">Elige el tablero de indicadores que deseas visualizar.</p>
                </div>

                <div class="row g-4">
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
                                    <h4 class="report-title">Reporte Logística</h4>
                                    <p class="report-description">Análisis completo de movimientos, distribución y transporte de productos</p>
                                    <div class="report-stats">
                                        <div class="stat-item">
                                            <span class="stat-number">15</span>
                                            <span class="stat-label">Rutas Activas</span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-number">98%</span>
                                            <span class="stat-label">Eficiencia</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="report-card-footer">
                                    <span class="report-action">Ver Reporte <i class="fas fa-arrow-right"></i></span>
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
                                    <h4 class="report-title">Reporte Productor</h4>
                                    <p class="report-description">Seguimiento de producción, lotes, costos y fechas de caducidad</p>
                                    <div class="report-stats">
                                        <div class="stat-item">
                                            <span class="stat-number">42</span>
                                            <span class="stat-label">Productores</span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-number">156</span>
                                            <span class="stat-label">Lotes</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="report-card-footer">
                                    <span class="report-action">Ver Reporte <i class="fas fa-arrow-right"></i></span>
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
                                    <h4 class="report-title">Reporte Almacén</h4>
                                    <p class="report-description">Control de inventario, entradas, salidas y ajustes de stock</p>
                                    <div class="report-stats">
                                        <div class="stat-item">
                                            <span class="stat-number">2,847</span>
                                            <span class="stat-label">Productos</span>
                                        </div>
                                        <div class="stat-item">
                                            <span class="stat-number">12</span>
                                            <span class="stat-label">Ubicaciones</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="report-card-footer">
                                    <span class="report-action">Ver Reporte <i class="fas fa-arrow-right"></i></span>
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
    /* Estilos para las tarjetas de reporte */
    .report-card {
        background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
        border-radius: 20px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        transition: all 0.3s ease;
        overflow: hidden;
        position: relative;
        height: 100%;
    }

    .report-card:hover {
        transform: translateY(-10px);
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
    }

    .report-card a {
        color: inherit;
        display: block;
        height: 100%;
    }

    /* Header de la tarjeta */
    .report-card-header {
        position: relative;
        padding: 30px 30px 20px;
        background: linear-gradient(135deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
        color: white;
    }

    .report-icon {
        font-size: 3rem;
        margin-bottom: 15px;
        opacity: 0.9;
    }

    .report-badge {
        position: absolute;
        top: 20px;
        right: 20px;
        background: rgba(255, 255, 255, 0.2);
        padding: 10px;
        border-radius: 50%;
        font-size: 1.2rem;
    }

    /* Body de la tarjeta */
    .report-card-body {
        padding: 30px;
    }

    .report-title {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--turquoise-dark);
        margin-bottom: 15px;
    }

    .report-description {
        color: var(--text-muted);
        font-size: 1rem;
        line-height: 1.6;
        margin-bottom: 25px;
    }

    /* Estadísticas */
    .report-stats {
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
    .report-card-footer {
        padding: 20px 30px;
        background: #f8f9fa;
        border-top: 1px solid #e9ecef;
    }

    .report-action {
        color: var(--turquoise-dark);
        font-weight: 600;
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
    }

    .report-action i {
        margin-left: 8px;
        transition: transform 0.3s ease;
    }

    .report-card:hover .report-action i {
        transform: translateX(5px);
    }

    /* Colores específicos para cada tipo de reporte */
    .logistica-card .report-card-header {
        background: linear-gradient(135deg, #17a2b8 0%, #20c997 100%);
    }

    .productor-card .report-card-header {
        background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
    }

    .almacen-card .report-card-header {
        background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
    }

    /* Responsive */
    @media (max-width: 768px) {
        .report-card-header {
            padding: 20px 20px 15px;
        }

        .report-card-body {
            padding: 20px;
        }

        .report-card-footer {
            padding: 15px 20px;
        }

        .report-icon {
            font-size: 2.5rem;
        }

        .report-title {
            font-size: 1.3rem;
        }

        .stat-number {
            font-size: 1.5rem;
        }
    }
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>