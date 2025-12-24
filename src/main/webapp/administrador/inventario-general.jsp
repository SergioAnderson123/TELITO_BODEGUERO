<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.util.Map" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Inventario General"/>
    </jsp:include>
    <style>
        /* Mejoras en las pestañas para que sean más visibles */
        .nav-tabs {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            padding: 0.5rem 0.5rem 0 0.5rem;
            border-radius: 12px 12px 0 0;
        }
        
        .nav-tabs .nav-link {
            color: rgba(255, 255, 255, 0.9);
            font-weight: 500;
            border: none;
            border-bottom: 3px solid transparent;
            padding: 0.75rem 1.5rem;
            transition: all 0.3s ease;
            border-radius: 8px 8px 0 0;
            margin-right: 0.25rem;
        }
        
        .nav-tabs .nav-link:hover {
            border-bottom-color: rgba(255, 255, 255, 0.5);
            color: #ffffff;
            background-color: rgba(255, 255, 255, 0.15);
        }
        
        .nav-tabs .nav-link.active {
            color: #6F4E37 !important;
            background-color: #ffffff;
            border-bottom-color: #ffffff;
            font-weight: 700;
            box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.1);
        }
        
        .tab-content {
            padding-top: 0;
        }
        
        .table thead th { 
            vertical-align: middle; 
        }
        
        /* Eliminar espacios en blanco innecesarios */
        .tab-pane {
            min-height: auto;
        }
        
        .table-responsive {
            margin-bottom: 0;
        }
        
        /* Asegurar que no haya espacios en blanco en las tablas */
        .dataTables_wrapper {
            padding: 0;
        }
        
        /* Estilos para tabs internos en acordeones */
        .nav-tabs-sm {
            border-bottom: 2px solid #e9ecef;
            background: #ffffff !important;
            padding: 0.5rem 0;
        }
        
        .nav-tabs-sm .nav-link {
            font-size: 0.85rem;
            padding: 0.5rem 1rem;
            border: none;
            border-bottom: 2px solid transparent;
            color: #6c757d;
            transition: all 0.3s ease;
            background: #ffffff !important;
        }
        
        .nav-tabs-sm .nav-link:hover {
            color: #6F4E37 !important;
            border-bottom-color: rgba(0, 168, 150, 0.3);
            background: #ffffff !important;
        }
        
        .nav-tabs-sm .nav-link.active {
            color: #6F4E37 !important;
            background: #ffffff !important;
            border-bottom-color: #6F4E37 !important;
            font-weight: 600;
        }
        
        .nav-tabs-sm .nav-link:not(.active) {
            color: #6c757d !important;
            background: #ffffff !important;
        }
        
        /* Asegurar que los tab-pane internos tengan fondo blanco */
        .accordion-body .tab-pane {
            background: #ffffff !important;
        }
        
        .accordion-body .tab-content {
            background: #ffffff !important;
        }
        
        .accordion-body {
            background: #ffffff !important;
        }
        
        /* Estilos para las tablas igual que gestión de usuarios */
        .inventario-table {
            width: 100% !important;
            font-size: 0.9rem;
            margin-bottom: 0 !important;
        }
        
        .inventario-table th,
        .inventario-table td {
            padding: 0.35rem 0.5rem;
            font-size: 0.85rem;
        }
        
        /* Ocultar solo el selector de cantidad de registros */
        .dataTables_length {
            display: none !important;
        }
        
        /* Estilos para los filtros */
        .filtros-container {
            background: #f8f9fa;
            padding: 0.75rem;
            border-radius: 8px;
            margin-bottom: 0.75rem;
        }
        
        /* Asegurar que las tablas no tengan espacios en blanco */
        .tab-pane {
            display: none;
        }
        
        .tab-pane.active {
            display: block !important;
        }
        
        /* Responsive para Inventario General */
        @media (max-width: 768px) {
            .filtros-container {
                padding: 0.5rem !important;
            }
            .filtros-container .row {
                margin-left: -0.25rem !important;
                margin-right: -0.25rem !important;
            }
            .filtros-container [class*="col-"] {
                padding-left: 0.25rem !important;
                padding-right: 0.25rem !important;
                margin-bottom: 0.5rem;
            }
            .filtros-container .form-select,
            .filtros-container .form-control {
                font-size: 0.85rem !important;
                padding: 0.35rem 0.5rem !important;
            }
            .filtros-container .btn {
                width: 100%;
                font-size: 0.85rem !important;
                padding: 0.4rem 0.75rem !important;
            }
            .accordion-button {
                flex-direction: column;
                align-items: flex-start !important;
                padding: 0.75rem 1rem !important;
            }
            .accordion-button .d-flex {
                flex-direction: column;
                width: 100%;
            }
            .accordion-button .badge {
                margin-top: 0.5rem;
                margin-right: 0.5rem;
                font-size: 0.7rem !important;
            }
            .accordion-body {
                padding: 0.75rem !important;
            }
            .nav-tabs-sm {
                flex-wrap: wrap;
            }
            .nav-tabs-sm .nav-link {
                padding: 0.4rem 0.6rem !important;
                font-size: 0.75rem !important;
                margin-bottom: 0.25rem;
            }
            .table th, .table td {
                padding: 0.3rem 0.4rem !important;
                font-size: 0.75rem !important;
            }
            .table th {
                font-size: 0.7rem !important;
            }
            .badge {
                font-size: 0.65rem !important;
                padding: 0.2rem 0.4rem !important;
            }
        }
        
        @media (max-width: 576px) {
            .page-header {
                padding: 10px !important;
            }
            .pageheader-title {
                font-size: 1.1rem !important;
            }
            .pageheader-text {
                font-size: 0.8rem !important;
            }
            .nav-tabs {
                padding: 0.5rem !important;
            }
            .nav-tabs .nav-link {
                padding: 0.4rem 0.6rem !important;
                font-size: 0.8rem !important;
                margin-bottom: 0.25rem;
            }
            .accordion-button {
                font-size: 0.85rem !important;
            }
            .accordion-button strong {
                font-size: 0.9rem !important;
            }
        }
        
        /* Ocultar la búsqueda de DataTables ya que usamos filtros personalizados */
        .dataTables_filter {
            display: none !important;
        }
        
        /* Ajustar la paginación para que esté abajo */
        .dataTables_wrapper .dataTables_paginate {
            margin-top: 1rem;
            text-align: right;
        }
        
        /* Ajustar el info para que esté abajo a la izquierda */
        .dataTables_wrapper .dataTables_info {
            margin-top: 1rem;
            padding-top: 0.5rem;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Inventario'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid px-4">
                <div class="page-header mb-3 d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-boxes-stacked me-2"></i>Inventario General</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Vista de solo lectura consolidada de Logística, Almacén y Productores.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <a href="${pageContext.request.contextPath}/administrador/InventarioGeneralReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <a href="${pageContext.request.contextPath}/administrador/InventarioGeneralReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </a>
                    </div>
                </div>

                <!-- Mensajes de alerta -->
                <c:if test="${not empty sessionScope.mensaje}">
                    <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                        ${sessionScope.mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                    </div>
                    <c:remove var="mensaje" scope="session"/>
                    <c:remove var="tipoMensaje" scope="session"/>
                </c:if>

                <!-- Sistema de Pestañas -->
                <div class="card shadow-sm">
                    <div class="card-header" style="padding: 0; border-bottom: none;">
                        <ul class="nav nav-tabs" id="inventarioTabs" role="tablist" style="border-bottom: none;">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link ${tabActivo == 'logistica' ? 'active' : ''}" id="logistica-tab" data-bs-toggle="tab" data-bs-target="#logistica" type="button" role="tab" aria-controls="logistica" aria-selected="${tabActivo == 'logistica' ? 'true' : 'false'}">
                                    <i class="fas fa-truck-fast me-2"></i>Logística
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link ${tabActivo == 'almacen' ? 'active' : ''}" id="almacen-tab" data-bs-toggle="tab" data-bs-target="#almacen" type="button" role="tab" aria-controls="almacen" aria-selected="${tabActivo == 'almacen' ? 'true' : 'false'}">
                                    <i class="fas fa-warehouse me-2"></i>Almacén
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link ${tabActivo == 'productores' ? 'active' : ''}" id="productores-tab" data-bs-toggle="tab" data-bs-target="#productores" type="button" role="tab" aria-controls="productores" aria-selected="${tabActivo == 'productores' ? 'true' : 'false'}">
                                    <i class="fas fa-user-tie me-2"></i>Productores
                                </button>
                            </li>
                        </ul>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <div class="tab-content" id="inventarioTabsContent">
                            <!-- Pestaña Logística -->
                            <div class="tab-pane fade ${tabActivo == 'logistica' ? 'show active' : ''}" id="logistica" role="tabpanel" aria-labelledby="logistica-tab">
                                <!-- Filtros -->
                                <div class="filtros-container">
                                    <form id="filtroLogistica" method="get" action="${pageContext.request.contextPath}/administrador/inventario-general" class="row g-2 mb-0" style="margin-bottom: 0 !important;">
                                        <input type="hidden" name="tab" value="logistica"/>
                                        <div class="col-md-4">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                            <input type="text" class="form-control form-control-sm shadow-sm" id="buscarLogistica" name="busquedaLogistica" value="${busquedaLogistica != null ? busquedaLogistica : ''}" placeholder="SKU, producto..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-info-circle me-1"></i>Estado</label>
                                            <select class="form-select form-select-sm shadow-sm" id="estadoLogistica" name="filtroLogistica" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <option value="">Todos</option>
                                                <option value="En Stock" ${filtroLogistica == 'En Stock' ? 'selected' : ''}>En Stock</option>
                                                <option value="Poco Stock" ${filtroLogistica == 'Poco Stock' ? 'selected' : ''}>Poco Stock</option>
                                                <option value="Sin Stock" ${filtroLogistica == 'Sin Stock' ? 'selected' : ''}>Sin Stock</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <button type="button" class="btn btn-sm btn-primary shadow-sm w-100" id="btnBuscarLogistica" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-search me-1"></i>Buscar
                                            </button>
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <button type="button" class="btn btn-sm btn-outline-secondary shadow-sm w-100" id="btnLimpiarLogistica" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                                            </button>
                                        </div>
                                    </form>
                                </div>
                                <div class="table-responsive">
                                    <table id="tablaLogistica" class="table table-hover align-middle mb-0 inventario-table" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%;">
                                        <thead class="table-light">
                                        <tr>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-barcode me-1"></i>SKU</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-box me-1"></i>Producto</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-cubes me-1"></i>Paquetes</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-dollar-sign me-1"></i>Precio por Paquete</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-coins me-1"></i>Costo por Unidad</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-info-circle me-1"></i>Estado</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:choose>
                                            <c:when test="${empty listaLogistica}">
                                                <tr>
                                                    <td colspan="6" class="text-center py-5 text-muted" style="font-size: 0.85rem;">
                                                        <div class="text-muted">
                                                            <i class="fas fa-inbox fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                            <p class="mb-0">No hay datos de logística disponibles</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="it" items="${listaLogistica}">
                                                    <tr class="align-middle">
                                                        <td style="padding: 0.35rem 0.5rem;">
                                                            <strong style="font-size: 0.85rem;">${it.codigoSKU}</strong>
                                                        </td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${it.nombreProducto}</td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${it.paquetesDisponibles}</td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">S/. <fmt:formatNumber value="${it.precioPorPaquete}" minFractionDigits="2"/></td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">S/. <fmt:formatNumber value="${it.costoPorUnidad}" minFractionDigits="2"/></td>
                                                        <td style="padding: 0.35rem 0.5rem;">
                                                            <c:choose>
                                                                <c:when test="${it.estadoStock == 'En Stock'}">
                                                                    <span class="badge shadow-sm" style="background-color: #c8e6c9; color: #2e7d32; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-check-circle me-1"></i>En stock
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${it.estadoStock == 'Poco Stock'}">
                                                                    <span class="badge shadow-sm" style="background-color: #fff9c4; color: #f57f17; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-exclamation-triangle me-1"></i>Poco
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge shadow-sm" style="background-color: #e0e0e0; color: #424242; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-times-circle me-1"></i>Sin stock
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Pestaña Almacén -->
                            <div class="tab-pane fade ${tabActivo == 'almacen' ? 'show active' : ''}" id="almacen" role="tabpanel" aria-labelledby="almacen-tab">
                                <!-- Filtros -->
                                <div class="filtros-container">
                                    <form id="filtroAlmacen" method="get" action="${pageContext.request.contextPath}/administrador/inventario-general" class="row g-2 mb-0" style="margin-bottom: 0 !important;">
                                        <input type="hidden" name="tab" value="almacen"/>
                                        <div class="col-md-4">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                            <input type="text" class="form-control form-control-sm shadow-sm" id="buscarAlmacen" name="busquedaAlmacen" value="${busquedaAlmacen != null ? busquedaAlmacen : ''}" placeholder="Código lote, producto, ubicación..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-info-circle me-1"></i>Estado</label>
                                            <select class="form-select form-select-sm shadow-sm" id="estadoAlmacen" name="filtroAlmacen" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <option value="">Todos</option>
                                                <option value="Activo" ${filtroAlmacen == 'Activo' ? 'selected' : ''}>Activo</option>
                                                <option value="Vencido" ${filtroAlmacen == 'Vencido' ? 'selected' : ''}>Vencido</option>
                                                <option value="Por Vencer" ${filtroAlmacen == 'Por Vencer' ? 'selected' : ''}>Por Vencer</option>
                                            </select>
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <button type="button" class="btn btn-sm btn-primary shadow-sm w-100" id="btnBuscarAlmacen" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-search me-1"></i>Buscar
                                            </button>
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <button type="button" class="btn btn-sm btn-outline-secondary shadow-sm w-100" id="btnLimpiarAlmacen" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                                            </button>
                                        </div>
                                    </form>
                                </div>
                                <div class="table-responsive">
                                    <table id="tablaAlmacen" class="table table-hover align-middle mb-0 inventario-table" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%;">
                                        <thead class="table-light">
                                        <tr>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-tag me-1"></i>Código Lote</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-box me-1"></i>Producto</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-map-marker-alt me-1"></i>Ubicación</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-cubes me-1"></i>Stock</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-calendar-alt me-1"></i>Vencimiento</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-info-circle me-1"></i>Estado</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:choose>
                                            <c:when test="${empty listaAlmacen}">
                                                <tr>
                                                    <td colspan="6" class="text-center py-5 text-muted" style="font-size: 0.85rem;">
                                                        <div class="text-muted">
                                                            <i class="fas fa-inbox fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                            <p class="mb-0">No hay datos de almacén disponibles</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="l" items="${listaAlmacen}">
                                                    <tr class="align-middle">
                                                        <td style="padding: 0.35rem 0.5rem;">
                                                            <span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">${l.codigoLote}</span>
                                                        </td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${l.nombreProducto}</td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${l.nombreUbicacion}</td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${l.stockActual}</td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;"><fmt:formatDate value="${l.fechaVencimiento}" pattern="dd/MM/yyyy"/></td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${l.estado}</td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Pestaña Productores -->
                            <div class="tab-pane fade ${tabActivo == 'productores' ? 'show active' : ''}" id="productores" role="tabpanel" aria-labelledby="productores-tab">
                                <!-- Filtros -->
                                <div class="filtros-container mb-3">
                                    <form id="filtroProductores" method="get" action="${pageContext.request.contextPath}/administrador/inventario-general" class="row g-2 mb-0" style="margin-bottom: 0 !important;">
                                        <input type="hidden" name="tab" value="productores"/>
                                        <div class="col-md-4">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user me-1"></i>Filtrar por Productor</label>
                                            <select class="form-select form-select-sm shadow-sm" id="filtroProductorSelect" name="filtroProductor" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <option value="">Todos los productores</option>
                                                <c:forEach var="prod" items="${listaProductoresUsuarios}">
                                                    <option value="${prod.id}" ${filtroProductor != null && String.valueOf(prod.id).equals(filtroProductor) ? 'selected' : ''}>${prod.nombre}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar Producto</label>
                                            <input type="text" class="form-control form-control-sm shadow-sm" id="buscarProductores" name="busquedaProductores" value="${busquedaProductores != null ? busquedaProductores : ''}" placeholder="SKU, producto, categoría..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <button type="submit" class="btn btn-sm btn-primary shadow-sm w-100" id="btnBuscarProductores" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-search me-1"></i>Buscar
                                            </button>
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <button type="button" class="btn btn-sm btn-outline-secondary shadow-sm w-100" id="btnLimpiarProductores" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                                            </button>
                                        </div>
                                    </form>
                                </div>
                                
                                <!-- Acordeón de Productores -->
                                <div class="accordion" id="accordionProductores">
                                    <c:choose>
                                        <c:when test="${empty inventarioPorProductor}">
                                            <div class="text-center py-5 text-muted">
                                                <i class="fas fa-inbox fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No hay datos de productores disponibles</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="entry" items="${inventarioPorProductor}" varStatus="status">
                                                <c:set var="productorId" value="${entry.key}"/>
                                                <c:set var="datosProductor" value="${entry.value}"/>
                                                <c:set var="productos" value="${datosProductor.productos}"/>
                                                
                                                <div class="accordion-item mb-2" style="border: 1px solid #e9ecef; border-radius: 8px;">
                                                    <h2 class="accordion-header" id="heading${productorId}">
                                                        <button class="accordion-button ${status.index == 0 ? '' : 'collapsed'}" type="button" data-bs-toggle="collapse" data-bs-target="#collapse${productorId}" aria-expanded="${status.index == 0 ? 'true' : 'false'}" aria-controls="collapse${productorId}" style="background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);">
                                                            <div class="d-flex justify-content-between align-items-center w-100 me-3">
                                                                <div class="d-flex align-items-center">
                                                                    <i class="fas fa-user-tie me-2" style="color: #6F4E37;"></i>
                                                                    <strong style="font-size: 0.95rem;">${datosProductor.nombre}</strong>
                                                                </div>
                                                                <div class="d-flex gap-3 align-items-center">
                                                                    <span class="badge bg-info" style="font-size: 0.75rem;">
                                                                        <i class="fas fa-box me-1"></i>${datosProductor.totalProductos} producto${datosProductor.totalProductos != 1 ? 's' : ''}${datosProductor.totalProductos >= 9 ? ' (mostrando 9)' : ''}
                                                                    </span>
                                                                    <span class="badge bg-success" style="font-size: 0.75rem;">
                                                                        <i class="fas fa-cubes me-1"></i>Stock: ${datosProductor.totalStock}
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </button>
                                                    </h2>
                                                    <div id="collapse${productorId}" class="accordion-collapse collapse ${status.index == 0 ? 'show' : ''}" aria-labelledby="heading${productorId}" data-bs-parent="#accordionProductores">
                                                        <div class="accordion-body" style="padding: 1rem;">
                                                            <!-- Tabs internos para Productos, Órdenes y Movimientos -->
                                                            <ul class="nav nav-tabs nav-tabs-sm mb-3" id="tabsProductor${productorId}" role="tablist" style="border-bottom: 2px solid #e9ecef;">
                                                                <li class="nav-item" role="presentation">
                                                                    <button class="nav-link active" id="productos-tab-${productorId}" data-bs-toggle="tab" data-bs-target="#productos-${productorId}" type="button" role="tab" style="font-size: 0.85rem; padding: 0.5rem 1rem;">
                                                                        <i class="fas fa-box me-1"></i>Productos <span class="badge bg-info ms-1">${datosProductor.totalProductos}</span>
                                                                    </button>
                                                                </li>
                                                                <li class="nav-item" role="presentation">
                                                                    <button class="nav-link" id="ordenes-tab-${productorId}" data-bs-toggle="tab" data-bs-target="#ordenes-${productorId}" type="button" role="tab" style="font-size: 0.85rem; padding: 0.5rem 1rem;">
                                                                        <i class="fas fa-shopping-cart me-1"></i>Órdenes de Compra <span class="badge bg-warning ms-1">${datosProductor.totalOrdenes}</span>
                                                                    </button>
                                                                </li>
                                                                <li class="nav-item" role="presentation">
                                                                    <button class="nav-link" id="movimientos-tab-${productorId}" data-bs-toggle="tab" data-bs-target="#movimientos-${productorId}" type="button" role="tab" style="font-size: 0.85rem; padding: 0.5rem 1rem;">
                                                                        <i class="fas fa-exchange-alt me-1"></i>Movimientos <span class="badge bg-success ms-1">${datosProductor.totalMovimientos}</span>
                                                                    </button>
                                                                </li>
                                                            </ul>
                                                            
                                                            <div class="tab-content" id="tabContentProductor${productorId}">
                                                                <!-- Tab Productos -->
                                                                <div class="tab-pane fade show active" id="productos-${productorId}" role="tabpanel">
                                                                    <c:choose>
                                                                        <c:when test="${empty productos}">
                                                                            <div class="text-center py-3 text-muted">
                                                                                <i class="fas fa-box-open fa-2x mb-2" style="opacity: 0.3;"></i>
                                                                                <p class="mb-0">Este productor no tiene productos registrados</p>
                                                                            </div>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <div class="table-responsive">
                                                                                <table id="tablaProductos-${productorId}" class="table table-sm table-hover mb-0 inventario-table" style="font-size: 0.85rem;">
                                                                                    <thead class="table-light">
                                                                                    <tr>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-barcode me-1"></i>SKU</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-box me-1"></i>Producto</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-folder me-1"></i>Categoría</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-cubes me-1"></i>Stock Total</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-dollar-sign me-1"></i>Precio</th>
                                                                                    </tr>
                                                                                    </thead>
                                                                                    <tbody>
                                                                                    <c:forEach var="p" items="${productos}">
                                                                                        <tr>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                <strong style="font-size: 0.85rem;">${p.codigoSku}</strong>
                                                                                            </td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">${p.nombre}</td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                <span class="badge bg-light text-dark">${p.categoriaNombre != null ? p.categoriaNombre : 'Sin categoría'}</span>
                                                                                            </td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                <span class="badge" style="${p.stock > 0 ? 'background-color: #c8e6c9; color: #2e7d32;' : 'background-color: #ffcdd2; color: #c62828;'}">${p.stock}</span>
                                                                                            </td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                S/. <fmt:formatNumber value="${p.precioActual}" minFractionDigits="2"/>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </c:forEach>
                                                                                    </tbody>
                                                                                </table>
                                                                            </div>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                
                                                                <!-- Tab Órdenes de Compra -->
                                                                <div class="tab-pane fade" id="ordenes-${productorId}" role="tabpanel">
                                                                    <c:set var="ordenesCompra" value="${datosProductor.ordenesCompra}"/>
                                                                    <c:choose>
                                                                        <c:when test="${empty ordenesCompra}">
                                                                            <div class="text-center py-3 text-muted">
                                                                                <i class="fas fa-shopping-cart fa-2x mb-2" style="opacity: 0.3;"></i>
                                                                                <p class="mb-0">No hay órdenes de compra registradas</p>
                                                                            </div>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <div class="table-responsive">
                                                                                <table id="tablaOrdenes-${productorId}" class="table table-sm table-hover mb-0 inventario-table" style="font-size: 0.85rem;">
                                                                                    <thead class="table-light">
                                                                                    <tr>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-hashtag me-1"></i>N° Orden</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-box me-1"></i>Producto</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-cubes me-1"></i>Cantidad</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-dollar-sign me-1"></i>Monto</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-user me-1"></i>Logística</th>
                                                                                        <th style="font-size: 0.8rem; padding: 0.4rem 0.5rem;"><i class="fas fa-info-circle me-1"></i>Estado</th>
                                                                                    </tr>
                                                                                    </thead>
                                                                                    <tbody>
                                                                                    <c:forEach var="orden" items="${ordenesCompra}">
                                                                                        <tr>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                <span class="badge" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); color: white; font-size: 0.75rem;">${orden[1]}</span>
                                                                                            </td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">${orden[2]}</td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">${orden[3]} paquetes</td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                S/. <fmt:formatNumber value="${orden[4]}" minFractionDigits="2"/>
                                                                                            </td>
                                                                                            <td style="padding: 0.4rem 0.5rem; font-size: 0.8rem;">${orden[5]}</td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                <c:set var="estadoOrden" value="${orden[6]}"/>
                                                                                                <c:choose>
                                                                                                    <c:when test="${estadoOrden == 'Recibido'}">
                                                                                                        <span class="badge" style="background-color: #b3e5fc; color: #01579b;">Recibido</span>
                                                                                                    </c:when>
                                                                                                    <c:when test="${estadoOrden == 'En Proceso'}">
                                                                                                        <span class="badge" style="background-color: #fff9c4; color: #f57f17;">En Proceso</span>
                                                                                                    </c:when>
                                                                                                    <c:when test="${estadoOrden == 'Rechazado'}">
                                                                                                        <span class="badge" style="background-color: #ffcdd2; color: #c62828;">Rechazado</span>
                                                                                                    </c:when>
                                                                                                    <c:when test="${estadoOrden == 'Aprobado'}">
                                                                                                        <span class="badge" style="background-color: #c8e6c9; color: #2e7d32;">Aprobado</span>
                                                                                                    </c:when>
                                                                                                    <c:when test="${estadoOrden == 'Pendiente'}">
                                                                                                        <span class="badge" style="background-color: #e0e0e0; color: #424242;">Pendiente</span>
                                                                                                    </c:when>
                                                                                                    <c:otherwise>
                                                                                                        <span class="badge" style="background-color: #e0e0e0; color: #424242;">${estadoOrden}</span>
                                                                                                    </c:otherwise>
                                                                                                </c:choose>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </c:forEach>
                                                                                    </tbody>
                                                                                </table>
                                                                            </div>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                
                                                                <!-- Tab Movimientos -->
                                                                <div class="tab-pane fade" id="movimientos-${productorId}" role="tabpanel">
                                                                    <c:set var="movimientosPorProducto" value="${datosProductor.movimientosPorProducto}"/>
                                                                    <c:choose>
                                                                        <c:when test="${empty movimientosPorProducto}">
                                                                            <div class="text-center py-3 text-muted">
                                                                                <i class="fas fa-exchange-alt fa-2x mb-2" style="opacity: 0.3;"></i>
                                                                                <p class="mb-0">No hay movimientos de almacén registrados</p>
                                                                            </div>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <c:forEach var="producto" items="${productos}">
                                                                                <c:set var="movimientosProducto" value="${movimientosPorProducto[producto.idProducto]}"/>
                                                                                <c:if test="${not empty movimientosProducto}">
                                                                                    <div class="card mb-3" style="border: 1px solid #e9ecef;">
                                                                                        <div class="card-header bg-light" style="padding: 0.5rem 0.75rem; font-size: 0.85rem;">
                                                                                            <strong><i class="fas fa-box me-1"></i>${producto.nombre}</strong>
                                                                                            <span class="badge bg-secondary ms-2">${producto.codigoSku}</span>
                                                                                        </div>
                                                                                        <div class="card-body" style="padding: 0.75rem;">
                                                                                            <div class="table-responsive">
                                                                                                <table class="table table-sm table-hover mb-0" style="font-size: 0.8rem;">
                                                                                                    <thead class="table-light">
                                                                                                    <tr>
                                                                                                        <th style="font-size: 0.75rem; padding: 0.3rem 0.4rem;"><i class="fas fa-calendar me-1"></i>Fecha</th>
                                                                                                        <th style="font-size: 0.75rem; padding: 0.3rem 0.4rem;"><i class="fas fa-exchange-alt me-1"></i>Tipo</th>
                                                                                                        <th style="font-size: 0.75rem; padding: 0.3rem 0.4rem;"><i class="fas fa-cubes me-1"></i>Cantidad</th>
                                                                                                        <th style="font-size: 0.75rem; padding: 0.3rem 0.4rem;"><i class="fas fa-barcode me-1"></i>Lote</th>
                                                                                                        <th style="font-size: 0.75rem; padding: 0.3rem 0.4rem;"><i class="fas fa-user me-1"></i>Usuario</th>
                                                                                                        <th style="font-size: 0.75rem; padding: 0.3rem 0.4rem;"><i class="fas fa-info-circle me-1"></i>Motivo</th>
                                                                                                    </tr>
                                                                                                    </thead>
                                                                                                    <tbody>
                                                                                                    <c:forEach var="mov" items="${movimientosProducto}">
                                                                                                        <tr>
                                                                                                            <td style="padding: 0.3rem 0.4rem;">
                                                                                                                <c:set var="fechaMov" value="${mov['fecha']}"/>
                                                                                                                <c:if test="${not empty fechaMov}">
                                                                                                                    <fmt:formatDate value="${fechaMov}" pattern="dd/MM/yyyy HH:mm"/>
                                                                                                                </c:if>
                                                                                                            </td>
                                                                                                            <td style="padding: 0.3rem 0.4rem;">
                                                                                                                <c:set var="tipoMov" value="${mov['tipo']}"/>
                                                                                                                <c:choose>
                                                                                                                    <c:when test="${tipoMov == 'Entrada'}">
                                                                                                                        <span class="badge" style="background-color: #c8e6c9; color: #2e7d32;">Entrada</span>
                                                                                                                    </c:when>
                                                                                                                    <c:when test="${tipoMov == 'Salida'}">
                                                                                                                        <span class="badge" style="background-color: #ffcdd2; color: #c62828;">Salida</span>
                                                                                                                    </c:when>
                                                                                                                    <c:otherwise>
                                                                                                                        <span class="badge" style="background-color: #e0e0e0; color: #424242;">${tipoMov}</span>
                                                                                                                    </c:otherwise>
                                                                                                                </c:choose>
                                                                                                            </td>
                                                                                                            <td style="padding: 0.3rem 0.4rem;">${mov['cantidad']}</td>
                                                                                                            <td style="padding: 0.3rem 0.4rem;">
                                                                                                                <span class="badge bg-info">${mov['codigoLote']}</span>
                                                                                                            </td>
                                                                                                            <td style="padding: 0.3rem 0.4rem; font-size: 0.75rem;">${mov['nombreUsuario']}</td>
                                                                                                            <td style="padding: 0.3rem 0.4rem; font-size: 0.75rem;">
                                                                                                                <c:set var="motivoMov" value="${mov['motivo']}"/>
                                                                                                                ${not empty motivoMov ? motivoMov : 'Sin motivo'}
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </c:forEach>
                                                                                                    </tbody>
                                                                                                </table>
                                                                                            </div>
                                                                                        </div>
                                                                                    </div>
                                                                                </c:if>
                                                                            </c:forEach>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script>
    // Esperar a que jQuery y DataTables estén cargados
    function initInventarioTables() {
        // Verificar que jQuery esté disponible
        if (typeof jQuery === 'undefined' || typeof jQuery.fn.dataTable === 'undefined') {
            // Reintentar después de 100ms
            setTimeout(initInventarioTables, 100);
            return;
        }
        
        // Usar jQuery directamente
        jQuery(document).ready(function($) {
            
            // Variables para almacenar las instancias de DataTables
            var tablaLogistica = null;
            var tablaAlmacen = null;
            var tablaProductores = null;
            
            // Configuración personalizada de DataTables para las 3 tablas
            var tableConfig = {
                responsive: true,
                language: {
                    url: 'https://cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json',
                    search: "Buscar:",
                    info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
                    infoEmpty: "Mostrando 0 a 0 de 0 registros",
                    infoFiltered: "(filtrado de _MAX_ registros totales)",
                    lengthMenu: "",
                    paginate: {
                        first: "",
                        last: "",
                        next: "",
                        previous: ""
                    }
                },
                pageLength: 5,
                lengthChange: false,
                order: [[0, 'asc']],
                dom: 'rt<"row mt-2"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>'
            };
            
            // Función para inicializar tabla de Logística
            function initTablaLogistica() {
                if (!tablaLogistica && $('#tablaLogistica').length > 0) {
                    try {
                        var $table = $('#tablaLogistica');
                        var theadCols = $table.find('thead tr').first().find('th').length;
                        var tbodyRows = $table.find('tbody tr');
                        
                        // Verificar si la tabla tiene datos reales (no solo el mensaje de "sin datos")
                        var hasRealData = false;
                        if (tbodyRows.length > 0) {
                            var firstRow = tbodyRows.first();
                            var firstRowCols = firstRow.find('td').length;
                            
                            // Si tiene colspan, significa que es el mensaje de "sin datos"
                            if (firstRow.find('td[colspan]').length > 0) {
                                hasRealData = false;
                            } else if (theadCols === firstRowCols) {
                                hasRealData = true;
                            } else {
                                console.error('Error: Número de columnas no coincide. thead:', theadCols, 'tbody:', firstRowCols);
                                return;
                            }
                        }
                        
                        // Solo inicializar DataTables si hay datos reales
                        if (hasRealData && theadCols > 0) {
                            tablaLogistica = $table.DataTable(tableConfig);
                        } else {
                            // Si no hay datos, simplemente no inicializar DataTables
                            console.log('Tabla Logística vacía - DataTables no inicializado');
                        }
                    } catch(e) {
                        console.error('Error al inicializar tabla Logística:', e);
                    }
                }
            }
            
            // Función para inicializar tabla de Almacén
            function initTablaAlmacen() {
                if (!tablaAlmacen && $('#tablaAlmacen').length > 0) {
                    try {
                        var $table = $('#tablaAlmacen');
                        var theadCols = $table.find('thead tr').first().find('th').length;
                        var tbodyRows = $table.find('tbody tr');
                        
                        // Verificar si la tabla tiene datos reales (no solo el mensaje de "sin datos")
                        var hasRealData = false;
                        if (tbodyRows.length > 0) {
                            var firstRow = tbodyRows.first();
                            var firstRowCols = firstRow.find('td').length;
                            
                            // Si tiene colspan, significa que es el mensaje de "sin datos"
                            if (firstRow.find('td[colspan]').length > 0) {
                                hasRealData = false;
                            } else if (theadCols === firstRowCols) {
                                hasRealData = true;
                            } else {
                                console.error('Error: Número de columnas no coincide. thead:', theadCols, 'tbody:', firstRowCols);
                                return;
                            }
                        }
                        
                        // Solo inicializar DataTables si hay datos reales
                        if (hasRealData && theadCols > 0) {
                            tablaAlmacen = $table.DataTable(tableConfig);
                        } else {
                            // Si no hay datos, simplemente no inicializar DataTables
                            console.log('Tabla Almacén vacía - DataTables no inicializado');
                        }
                    } catch(e) {
                        console.error('Error al inicializar tabla Almacén:', e);
                    }
                }
            }
            
            // Función para inicializar tabla de Productores
            function initTablaProductores() {
                if (!tablaProductores && $('#tablaProductores').length > 0) {
                    try {
                        tablaProductores = $('#tablaProductores').DataTable(tableConfig);
                    } catch(e) {
                        console.error('Error al inicializar tabla Productores:', e);
                    }
                }
            }
            
            // Inicializar la tabla activa al cargar según el tab activo
            var tabActivo = '${tabActivo != null ? tabActivo : "logistica"}';
            
            // Forzar la activación correcta de la pestaña al cargar
            setTimeout(function() {
                // Remover todas las clases active de las pestañas
                $('#logistica-tab, #almacen-tab, #productores-tab').removeClass('active').attr('aria-selected', 'false');
                $('#logistica, #almacen, #productores').removeClass('show active');
                
                // Activar solo la pestaña correcta
                if (tabActivo === 'logistica') {
                    $('#logistica-tab').addClass('active').attr('aria-selected', 'true');
                    $('#logistica').addClass('show active');
                    initTablaLogistica();
                } else if (tabActivo === 'almacen') {
                    $('#almacen-tab').addClass('active').attr('aria-selected', 'true');
                    $('#almacen').addClass('show active');
                    initTablaAlmacen();
                } else if (tabActivo === 'productores') {
                    $('#productores-tab').addClass('active').attr('aria-selected', 'true');
                    $('#productores').addClass('show active');
                    // NO inicializar tablas internas aquí - se inicializarán cuando se expandan los acordeones
                }
            }, 100);
            
            // Función para inicializar todas las tablas internas de productores
            function initTablasProductores() {
                // Inicializar tablas de productos, órdenes y movimientos para cada productor
                // Solo inicializar tablas que existan, sean elementos <table>, estén visibles y no estén ya inicializadas
                $('table[id^="tablaProductos-"]').each(function() {
                    var $table = $(this);
                    var tableId = $table.attr('id');
                    // Verificar que sea una tabla, esté visible y no esté ya inicializada
                    if ($table.is('table') && $table.is(':visible') && !$table.hasClass('dataTable') && $table.find('tbody tr').length > 0) {
                        try {
                            $table.DataTable(tableConfig);
                        } catch(e) {
                            console.error('Error al inicializar tabla ' + tableId + ':', e);
                        }
                    }
                });
                
                $('table[id^="tablaOrdenes-"]').each(function() {
                    var $table = $(this);
                    var tableId = $table.attr('id');
                    // Verificar que sea una tabla, esté visible y no esté ya inicializada
                    if ($table.is('table') && $table.is(':visible') && !$table.hasClass('dataTable') && $table.find('tbody tr').length > 0) {
                        try {
                            $table.DataTable(tableConfig);
                        } catch(e) {
                            console.error('Error al inicializar tabla ' + tableId + ':', e);
                        }
                    }
                });
            }
            
            // Inicializar tablas internas cuando se expande un acordeón de productor
            $('.accordion-collapse').on('shown.bs.collapse', function() {
                var productorId = $(this).attr('id').replace('collapse', '');
                setTimeout(function() {
                    // Inicializar tabla de productos solo si existe, es visible y tiene filas
                    var tablaProductos = $('#tablaProductos-' + productorId);
                    if (tablaProductos.length > 0 && tablaProductos.is('table') && tablaProductos.is(':visible') && 
                        !tablaProductos.hasClass('dataTable') && tablaProductos.find('tbody tr').length > 0) {
                        try {
                            tablaProductos.DataTable(tableConfig);
                        } catch(e) {
                            console.error('Error al inicializar tabla productos:', e);
                        }
                    }
                    
                    // Inicializar tabla de órdenes solo si existe, es visible y tiene filas
                    var tablaOrdenes = $('#tablaOrdenes-' + productorId);
                    if (tablaOrdenes.length > 0 && tablaOrdenes.is('table') && tablaOrdenes.is(':visible') && 
                        !tablaOrdenes.hasClass('dataTable') && tablaOrdenes.find('tbody tr').length > 0) {
                        try {
                            tablaOrdenes.DataTable(tableConfig);
                        } catch(e) {
                            console.error('Error al inicializar tabla órdenes:', e);
                        }
                    }
                }, 200);
            });
            
            // Inicializar tablas internas cuando se cambia de pestaña dentro de un productor
            $(document).on('shown.bs.tab', '[id^="productos-tab-"], [id^="ordenes-tab-"], [id^="movimientos-tab-"]', function(e) {
                var target = $(e.target).data('bs-target');
                if (!target) return;
                
                var match = target.match(/\d+/);
                if (!match) return;
                
                var productorId = match[0];
                
                setTimeout(function() {
                    if (target.includes('productos-')) {
                        var tabla = $('#tablaProductos-' + productorId);
                        if (tabla.length > 0 && tabla.is('table') && tabla.is(':visible') && 
                            !tabla.hasClass('dataTable') && tabla.find('tbody tr').length > 0) {
                            try {
                                tabla.DataTable(tableConfig);
                            } catch(e) {
                                console.error('Error al inicializar tabla productos:', e);
                            }
                        }
                    } else if (target.includes('ordenes-')) {
                        var tabla = $('#tablaOrdenes-' + productorId);
                        if (tabla.length > 0 && tabla.is('table') && tabla.is(':visible') && 
                            !tabla.hasClass('dataTable') && tabla.find('tbody tr').length > 0) {
                            try {
                                tabla.DataTable(tableConfig);
                            } catch(e) {
                                console.error('Error al inicializar tabla órdenes:', e);
                            }
                        }
                    }
                }, 200);
            });
            
            // Filtros para Logística
            // Asegurar que el formulario preserve el tab al enviar
            $('#filtroLogistica').on('submit', function(e) {
                var tabInput = $(this).find('input[name="tab"]');
                if (tabInput.length === 0) {
                    $(this).append('<input type="hidden" name="tab" value="logistica"/>');
                } else {
                    tabInput.val('logistica');
                }
            });
            
            // Filtro automático en Logística
            $('#estadoLogistica').on('change', function() {
                $('#filtroLogistica').submit();
            });
            
            // Limpiar filtros de logística
            $('#btnLimpiarLogistica').on('click', function() {
                $('#buscarLogistica').val('');
                $('#estadoLogistica').val('');
                window.location.href = '${pageContext.request.contextPath}/administrador/inventario-general?tab=logistica';
            });
            
            // Búsqueda con debounce para logística
            let searchTimeoutLogistica = null;
            $('#buscarLogistica').on('input', function() {
                clearTimeout(searchTimeoutLogistica);
                searchTimeoutLogistica = setTimeout(function() {
                    $('#filtroLogistica').submit();
                }, 500);
            });
            
            // Filtros para Almacén
            // Asegurar que el formulario preserve el tab al enviar
            $('#filtroAlmacen').on('submit', function(e) {
                var tabInput = $(this).find('input[name="tab"]');
                if (tabInput.length === 0) {
                    $(this).append('<input type="hidden" name="tab" value="almacen"/>');
                } else {
                    tabInput.val('almacen');
                }
            });
            
            $('#btnBuscarAlmacen').on('click', function() {
                $('#filtroAlmacen').submit();
            });
            
            $('#btnLimpiarAlmacen').on('click', function() {
                $('#buscarAlmacen').val('');
                $('#estadoAlmacen').val('');
                window.location.href = '${pageContext.request.contextPath}/administrador/inventario-general?tab=almacen';
            });
            
            // Búsqueda con debounce para almacén
            let searchTimeoutAlmacen = null;
            $('#buscarAlmacen').on('input', function() {
                clearTimeout(searchTimeoutAlmacen);
                searchTimeoutAlmacen = setTimeout(function() {
                    $('#filtroAlmacen').submit();
                }, 500);
            });
            
            // Filtro automático por productor
            $('#filtroProductorSelect').on('change', function() {
                // Asegurar que se preserve el tab=productores
                var form = $('#filtroProductores');
                var tabInput = form.find('input[name="tab"]');
                if (tabInput.length === 0) {
                    form.append('<input type="hidden" name="tab" value="productores"/>');
                } else {
                    tabInput.val('productores');
                }
                form.submit();
            });
            
            // Limpiar filtros de productores
            $('#btnLimpiarProductores').on('click', function() {
                $('#filtroProductorSelect').val('');
                $('#buscarProductores').val('');
                window.location.href = '${pageContext.request.contextPath}/administrador/inventario-general?tab=productores';
            });
            
            // Asegurar que el formulario preserve el tab al enviar
            $('#filtroProductores').on('submit', function(e) {
                var tabInput = $(this).find('input[name="tab"]');
                if (tabInput.length === 0) {
                    $(this).append('<input type="hidden" name="tab" value="productores"/>');
                } else {
                    tabInput.val('productores');
                }
            });
            
            // Búsqueda con debounce para productores
            let searchTimeoutProductores = null;
            $('#buscarProductores').on('input', function() {
                clearTimeout(searchTimeoutProductores);
                searchTimeoutProductores = setTimeout(function() {
                    $('#filtroProductores').submit();
                }, 500);
            });
            
            // Inicializar DataTables al cambiar de pestaña principal
            $('button[data-bs-toggle="tab"][data-bs-target^="#logistica"], button[data-bs-toggle="tab"][data-bs-target^="#almacen"], button[data-bs-toggle="tab"][data-bs-target^="#productores"]').on('shown.bs.tab', function (e) {
                var target = $(e.target).data('bs-target');
                
                if (target === '#logistica') {
                    initTablaLogistica();
                    if (tablaLogistica) {
                        setTimeout(function() {
                            tablaLogistica.columns.adjust().responsive.recalc();
                        }, 100);
                    }
                } else if (target === '#almacen') {
                    initTablaAlmacen();
                    if (tablaAlmacen) {
                        setTimeout(function() {
                            tablaAlmacen.columns.adjust().responsive.recalc();
                        }, 100);
                    }
                } else if (target === '#productores') {
                    // NO inicializar tablas internas aquí - se inicializarán cuando se expandan los acordeones
                    // Las tablas se inicializarán automáticamente cuando se expandan los acordeones
                }
            });
        });
    }
    
    // Iniciar cuando el DOM esté listo
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initInventarioTables);
    } else {
        initInventarioTables();
    }
</script>
</body>
</html>
