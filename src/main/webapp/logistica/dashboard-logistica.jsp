<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.logistica.servlets.DashboardLogisticaServlet.MetricasLogistica" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    MetricasLogistica metricas = (MetricasLogistica) request.getAttribute("metricas");
    if (metricas == null) {
        metricas = new MetricasLogistica();
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Dashboard Logístico"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value="Dashboard"/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header pt-1 pb-1 d-flex justify-content-between align-items-center flex-wrap">
                            <div>
                                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem;">
                                    <i class="fas fa-chart-line me-2"></i>Dashboard Logístico
                                </h2>
                                <p class="pageheader-text mb-0" style="font-size: 0.85rem;">
                                    Resumen de operaciones logísticas y métricas clave.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Alertas críticas -->
                <% if (metricas.getAlertasCriticas() > 0) { %>
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <strong>Atención:</strong> Tienes <%= metricas.getAlertasCriticas() %> alerta(s) crítica(s) que requieren atención inmediata.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <!-- Primera fila: Órdenes de Compra -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-warning border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Órdenes Pendientes</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getOrdenesPendientes() %></h2>
                                        <small class="text-muted">Requieren atención</small>
                                    </div>
                                    <div class="stat-icon text-warning ms-2">
                                        <i class="fas fa-file-invoice-dollar"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-info border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">En Proceso</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getOrdenesEnProceso() %></h2>
                                        <small class="text-muted">Órdenes activas</small>
                                    </div>
                                    <div class="stat-icon text-info ms-2">
                                        <i class="fas fa-cog"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-success border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Recibidas</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getOrdenesRecibidas() %></h2>
                                        <small class="text-muted">Total: <%= metricas.getTotalOrdenes() %></small>
                                    </div>
                                    <div class="stat-icon text-success ms-2">
                                        <i class="fas fa-check-circle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-primary border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Total Órdenes</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getTotalOrdenes() %></h2>
                                        <small class="text-muted">Todas las órdenes</small>
                                    </div>
                                    <div class="stat-icon text-primary ms-2">
                                        <i class="fas fa-list"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Segunda fila: Planes de Transporte -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-warning border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Planes Pendientes</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getPlanesPendientes() %></h2>
                                        <small class="text-muted">Por iniciar</small>
                                    </div>
                                    <div class="stat-icon text-warning ms-2">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-info border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">En Ruta</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getPlanesActivos() %></h2>
                                        <small class="text-muted">Activos ahora</small>
                                    </div>
                                    <div class="stat-icon text-info ms-2">
                                        <i class="fas fa-truck"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-success border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Completados</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getPlanesCompletados() %></h2>
                                        <small class="text-muted">Total: <%= metricas.getTotalPlanes() %></small>
                                    </div>
                                    <div class="stat-icon text-success ms-2">
                                        <i class="fas fa-check-double"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-primary border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Eficiencia</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= String.format("%.1f", metricas.getEficienciaEntregas()) %>%</h2>
                                        <small class="text-muted">Entregas a tiempo</small>
                                    </div>
                                    <div class="stat-icon text-primary ms-2">
                                        <i class="fas fa-chart-line"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tercera fila: Movimientos y Alertas -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-info border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Movimientos Hoy</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getMovimientosHoy() %></h2>
                                        <small class="text-muted">Últimas 24 horas</small>
                                    </div>
                                    <div class="stat-icon text-info ms-2">
                                        <i class="fas fa-exchange-alt"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-primary border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Movimientos Semana</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getMovimientosSemana() %></h2>
                                        <small class="text-muted">Últimos 7 días</small>
                                    </div>
                                    <div class="stat-icon text-primary ms-2">
                                        <i class="fas fa-calendar-week"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-danger border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Alertas Críticas</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getAlertasCriticas() %></h2>
                                        <small class="text-muted">Requieren atención</small>
                                    </div>
                                    <div class="stat-icon text-danger ms-2">
                                        <i class="fas fa-exclamation-triangle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Accesos rápidos -->
                <div class="row mt-2">
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="fas fa-bolt me-2"></i>Accesos Rápidos</h5>
                            </div>
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/orden-compra" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-file-invoice-dollar" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Órdenes de Compra</h6>
                                                <span class="text-muted small">Gestionar órdenes</span>
                                            </div>
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/planes-transporte" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-truck" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Planes de Transporte</h6>
                                                <span class="text-muted small">Distribución</span>
                                            </div>
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/InventarioServlet" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-warehouse" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Inventario</h6>
                                                <span class="text-muted small">Gestionar stock</span>
                                            </div>
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/MovimientoProductoServlet" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-exchange-alt" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Movimientos</h6>
                                                <span class="text-muted small">Ver historial</span>
                                            </div>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/logistica/layouts/footer.jsp" />
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

