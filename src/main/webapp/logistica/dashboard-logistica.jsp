<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.logistica.servlets.DashboardLogisticaServlet.MetricasLogistica" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    MetricasLogistica metricas = (MetricasLogistica) request.getAttribute("metricas");
    if (metricas == null) {
        metricas = new MetricasLogistica();
    }
    List ultimasOrdenes = (List) request.getAttribute("ultimasOrdenes");
    List ultimosMovimientos = (List) request.getAttribute("ultimosMovimientos");
    String ordenesPorMesJson = (String) request.getAttribute("ordenesPorMesJson");
    String ordenesPorMesDataJson = (String) request.getAttribute("ordenesPorMesDataJson");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Dashboard Logístico"/>
    </jsp:include>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
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
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-danger border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
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

                <!-- Gráfico de Tendencias -->
                <div class="row mb-3">
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title mb-3" style="font-size: 1.1rem;">
                                    <i class="fas fa-chart-line text-primary me-2"></i>Órdenes por Mes (Últimos 6 meses)
                                </h5>
                                <div style="position: relative; height: 300px;">
                                    <canvas id="ordenesPorMesChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Actividad Reciente -->
                <div class="row mb-3">
                    <div class="col-lg-6 mb-3">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title mb-3" style="font-size: 1.1rem;">
                                    <i class="fas fa-file-invoice-dollar text-primary me-2"></i>Últimas Órdenes
                                </h5>
                                <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                                    <table class="table table-sm table-hover mb-0">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th style="font-size: 0.85rem;">Orden</th>
                                                <th style="font-size: 0.85rem;">Producto</th>
                                                <th style="font-size: 0.85rem;">Estado</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (ultimasOrdenes != null && !ultimasOrdenes.isEmpty()) { %>
                                                <% for (int i = 0; i < Math.min(5, ultimasOrdenes.size()); i++) { %>
                                                    <% com.example.telito.logistica.beans.OrdenCompraBean orden = (com.example.telito.logistica.beans.OrdenCompraBean) ultimasOrdenes.get(i); %>
                                                    <tr>
                                                        <td style="font-size: 0.85rem;"><%= orden.getNumeroOrden() != null ? orden.getNumeroOrden() : "N/A" %></td>
                                                        <td style="font-size: 0.85rem;"><%= orden.getNombreProducto() != null ? orden.getNombreProducto() : "N/A" %></td>
                                                        <td>
                                                            <span class="badge 
                                                                <%= orden.getEstado() != null && orden.getEstado().equals("Pendiente") ? "bg-warning" : 
                                                                    orden.getEstado() != null && orden.getEstado().equals("En Proceso") ? "bg-info" : 
                                                                    orden.getEstado() != null && orden.getEstado().equals("Recibido") ? "bg-success" : "bg-secondary" %>" 
                                                                style="font-size: 0.75rem;">
                                                                <%= orden.getEstado() != null ? orden.getEstado() : "N/A" %>
                                                            </span>
                                                        </td>
                                                    </tr>
                                                <% } %>
                                            <% } else { %>
                                                <tr>
                                                    <td colspan="3" class="text-center text-muted" style="font-size: 0.85rem;">No hay órdenes recientes</td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6 mb-3">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <h5 class="card-title mb-3" style="font-size: 1.1rem;">
                                    <i class="fas fa-exchange-alt text-primary me-2"></i>Últimos Movimientos
                                </h5>
                                <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                                    <table class="table table-sm table-hover mb-0">
                                        <thead class="table-light sticky-top">
                                            <tr>
                                                <th style="font-size: 0.85rem;">Fecha</th>
                                                <th style="font-size: 0.85rem;">Producto</th>
                                                <th style="font-size: 0.85rem;">Tipo</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (ultimosMovimientos != null && !ultimosMovimientos.isEmpty()) { %>
                                                <% for (int i = 0; i < Math.min(5, ultimosMovimientos.size()); i++) { %>
                                                    <% com.example.telito.logistica.beans.MovimientoInventarioBean movimiento = (com.example.telito.logistica.beans.MovimientoInventarioBean) ultimosMovimientos.get(i); %>
                                                    <tr>
                                                        <td style="font-size: 0.85rem;"><%= movimiento.getFechaFormateada() != null ? movimiento.getFechaFormateada() : "N/A" %></td>
                                                        <td style="font-size: 0.85rem;"><%= movimiento.getNombreProducto() != null ? movimiento.getNombreProducto() : "N/A" %></td>
                                                        <td>
                                                            <span class="badge 
                                                                <%= movimiento.getTipo() != null && movimiento.getTipo().equals("Entrada") ? "bg-success" : 
                                                                    movimiento.getTipo() != null && movimiento.getTipo().equals("Salida") ? "bg-danger" : "bg-secondary" %>" 
                                                                style="font-size: 0.75rem;">
                                                                <%= movimiento.getTipo() != null ? movimiento.getTipo() : "N/A" %>
                                                            </span>
                                                        </td>
                                                    </tr>
                                                <% } %>
                                            <% } else { %>
                                                <tr>
                                                    <td colspan="3" class="text-center text-muted" style="font-size: 0.85rem;">No hay movimientos recientes</td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
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
<script>
    // Gráfico de órdenes por mes
    document.addEventListener('DOMContentLoaded', function() {
        try {
            const ordenesPorMesLabels = JSON.parse('<%= ordenesPorMesJson != null ? ordenesPorMesJson : "[]" %>');
            const ordenesPorMesData = JSON.parse('<%= ordenesPorMesDataJson != null ? ordenesPorMesDataJson : "[]" %>');
            
            const ctx = document.getElementById('ordenesPorMesChart');
            if (ctx) {
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: ordenesPorMesLabels,
                        datasets: [{
                            label: 'Órdenes de Compra',
                            data: ordenesPorMesData,
                            borderColor: 'rgba(54, 162, 235, 1)',
                            backgroundColor: 'rgba(54, 162, 235, 0.1)',
                            borderWidth: 2,
                            fill: true,
                            tension: 0.4,
                            pointRadius: 4,
                            pointHoverRadius: 6,
                            pointBackgroundColor: 'rgba(54, 162, 235, 1)',
                            pointBorderColor: '#fff',
                            pointBorderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: true,
                                position: 'top',
                                labels: {
                                    font: {
                                        size: 13,
                                        family: "'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', sans-serif"
                                    },
                                    padding: 15
                                }
                            },
                            tooltip: {
                                backgroundColor: 'rgba(0, 0, 0, 0.7)',
                                titleFont: {
                                    size: 14,
                                    weight: 'bold'
                                },
                                bodyFont: {
                                    size: 13
                                },
                                padding: 12,
                                cornerRadius: 4,
                                callbacks: {
                                    label: function(context) {
                                        return 'Órdenes: ' + context.parsed.y;
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    stepSize: 1,
                                    font: {
                                        size: 12
                                    }
                                },
                                grid: {
                                    color: '#e9e9e9',
                                    drawBorder: false
                                }
                            },
                            x: {
                                ticks: {
                                    font: {
                                        size: 12
                                    }
                                },
                                grid: {
                                    display: false
                                }
                            }
                        }
                    }
                });
            }
        } catch (e) {
            console.error("Error al renderizar el gráfico de órdenes por mes:", e);
        }
    });
</script>
</body>
</html>

