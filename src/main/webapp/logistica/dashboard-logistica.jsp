<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.logistica.servlets.DashboardLogisticaServlet.MetricasLogistica" %>
<%@ page import="java.util.List" %>
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
    <style>
        /* CRÍTICO: Eliminar TODAS las restricciones y forzar el mismo tamaño que Productor */
        .dashboard-wrapper {
            width: calc(100% - 250px) !important;
        }
        .dashboard-content {
            padding: 30px !important;
            width: 100% !important;
            max-width: 100% !important;
            box-sizing: border-box !important;
        }
        .dashboard-content .container-fluid {
            width: 100% !important;
            max-width: 100% !important;
            padding-left: 15px !important;
            padding-right: 15px !important;
            margin-left: 0 !important;
            margin-right: 0 !important;
            box-sizing: border-box !important;
        }
        /* Asegurar box-sizing consistente */
        .dashboard-content .row,
        .dashboard-content .row > [class*="col-"],
        .dashboard-content .stat-card {
            box-sizing: border-box !important;
        }
        /* CRÍTICO: Eliminar completamente el padding de 30px que tiene .card en el CSS global */
        .dashboard-content .stat-card,
        .dashboard-content .stat-card.card {
            padding: 0 !important;
            margin: 0 !important;
            margin-bottom: 0 !important;
            height: 100% !important;
            width: 100% !important;
            box-shadow: 0 2px 6px rgba(0,0,0,0.05) !important;
            background: var(--white) !important;
            border-radius: 15px !important;
        }
        .dashboard-content .stat-card .card-body {
            padding: 0.5rem !important;
            padding-top: 0.75rem !important;
            padding-bottom: 0.75rem !important;
            width: 100% !important;
        }
        /* Asegurar que las filas ocupen todo el ancho disponible */
        .dashboard-content .row.g-2 {
            --bs-gutter-x: 0.5rem;
            --bs-gutter-y: 0.5rem;
            margin-left: calc(var(--bs-gutter-x) * -0.5) !important;
            margin-right: calc(var(--bs-gutter-x) * -0.5) !important;
            width: 100% !important;
            max-width: 100% !important;
        }
        .dashboard-content .row.g-2 > [class*="col-"] {
            padding-left: calc(var(--bs-gutter-x) * 0.5) !important;
            padding-right: calc(var(--bs-gutter-x) * 0.5) !important;
        }
        /* CRÍTICO: Forzar que las columnas col-xl-3 ocupen exactamente 25% del ancho - igual que productor */
        @media (min-width: 1200px) {
            .dashboard-content .row.g-2 .col-xl-3 {
                flex: 0 0 25% !important;
                max-width: 25% !important;
                width: 25% !important;
                min-width: 0 !important;
            }
        }
        /* Asegurar que en todas las pantallas grandes el ancho sea consistente */
        @media (min-width: 1400px) {
            .dashboard-content .container-fluid {
                max-width: 100% !important;
                width: 100% !important;
            }
            .dashboard-content .row.g-2 .col-xl-3 {
                flex: 0 0 25% !important;
                max-width: 25% !important;
                width: 25% !important;
            }
        }
        /* Sobrescribir estilos globales para que los quick-link-card tengan el mismo tamaño que en Productor */
        .dashboard-content .quick-link-card,
        .dashboard-content .quick-link-card.card {
            padding: 0 !important;
            margin-bottom: 0 !important;
        }
        .dashboard-content .quick-link-card .card-body {
            padding: 0.5rem !important;
            padding-top: 0.75rem !important;
            padding-bottom: 0.75rem !important;
        }
    </style>
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-warning border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Órdenes Pendientes</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getOrdenesPendientes() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Requieren atención</small>
                                    </div>
                                    <div class="stat-icon text-warning ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-file-invoice-dollar"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-info border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">En Proceso</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getOrdenesEnProceso() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Órdenes activas</small>
                                    </div>
                                    <div class="stat-icon text-info ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-cog"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-success border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Recibidas</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getOrdenesRecibidas() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Total: <%= metricas.getTotalOrdenes() %></small>
                                    </div>
                                    <div class="stat-icon text-success ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-check-circle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-danger border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Stock Bajo</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getProductosStockBajo() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Productos críticos</small>
                                    </div>
                                    <div class="stat-icon text-danger ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-exclamation-circle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Segunda fila: Planes de Transporte y Alertas -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-warning border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Planes Pendientes</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getPlanesPendientes() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Por iniciar</small>
                                    </div>
                                    <div class="stat-icon text-warning ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-info border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">En Ruta</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getPlanesActivos() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Activos ahora</small>
                                    </div>
                                    <div class="stat-icon text-info ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-truck"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-success border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Completados</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getPlanesCompletados() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Total: <%= metricas.getTotalPlanes() %></small>
                                    </div>
                                    <div class="stat-icon text-success ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-check-double"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border-start border-warning border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Sin Stock</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getProductosSinStock() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Productos agotados</small>
                                    </div>
                                    <div class="stat-icon text-warning ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-box-open"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tercera fila: Alertas Críticas (solo si hay alertas) -->
                <% if (metricas.getAlertasCriticas() > 0) { %>
                <div class="row g-2 mb-3">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                        <div class="card stat-card shadow-sm border border-danger border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Alertas Críticas</h6>
                                        <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getAlertasCriticas() %></h2>
                                        <small style="font-size: 0.8rem; color: #4a4a4a;">Requieren atención</small>
                                    </div>
                                    <div class="stat-icon text-danger ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                        <i class="fas fa-exclamation-triangle"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                </div>

                <!-- Accesos rápidos -->
                <div class="row mt-2 mb-4">
                    <div class="col-12">
                        <h5 class="mb-3 pageheader-title" style="font-size: 1.15rem;">
                            <i class="fas fa-bolt text-primary me-2"></i>Accesos rápidos
                        </h5>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-2">
                        <a href="<%= request.getContextPath() %>/orden-compra" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="mb-1" style="color: #006d77;">
                                    <i class="fas fa-file-invoice-dollar" style="font-size: 1.9rem;"></i>
                                </div>
                                <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Órdenes de Compra</h6>
                                <span style="font-size: 0.8rem; color: #4a4a4a;">Gestionar órdenes</span>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-2">
                        <a href="<%= request.getContextPath() %>/planes-transporte" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="mb-1" style="color: #006d77;">
                                    <i class="fas fa-truck" style="font-size: 1.9rem;"></i>
                                </div>
                                <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Planes de Transporte</h6>
                                <span style="font-size: 0.8rem; color: #4a4a4a;">Distribución</span>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-2">
                        <a href="<%= request.getContextPath() %>/InventarioServlet" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="mb-1" style="color: #006d77;">
                                    <i class="fas fa-warehouse" style="font-size: 1.9rem;"></i>
                                </div>
                                <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Inventario</h6>
                                <span style="font-size: 0.8rem; color: #4a4a4a;">Gestionar stock</span>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-3 col-md-6 mb-2">
                        <a href="<%= request.getContextPath() %>/MovimientoProductoServlet" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                            <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                                <div class="mb-1" style="color: #006d77;">
                                    <i class="fas fa-exchange-alt" style="font-size: 1.9rem;"></i>
                                </div>
                                <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Movimientos</h6>
                                <span style="font-size: 0.8rem; color: #4a4a4a;">Ver historial</span>
                            </div>
                        </a>
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

