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
            color: #00a896 !important;
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
        .nav-tabs-sm .nav-link {
            font-size: 0.85rem;
            padding: 0.5rem 1rem;
            border: none;
            border-bottom: 2px solid transparent;
            color: #6c757d;
            transition: all 0.3s ease;
        }
        
        .nav-tabs-sm .nav-link:hover {
            color: #00a896;
            border-bottom-color: rgba(0, 168, 150, 0.3);
        }
        
        .nav-tabs-sm .nav-link.active {
            color: #00a896;
            background: transparent;
            border-bottom-color: #00a896;
            font-weight: 600;
        }
        
        .nav-tabs-sm {
            border-bottom: 2px solid #e9ecef;
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
                                <button class="nav-link active" id="logistica-tab" data-bs-toggle="tab" data-bs-target="#logistica" type="button" role="tab" aria-controls="logistica" aria-selected="true">
                                    <i class="fas fa-truck-fast me-2"></i>Logística
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="almacen-tab" data-bs-toggle="tab" data-bs-target="#almacen" type="button" role="tab" aria-controls="almacen" aria-selected="false">
                                    <i class="fas fa-warehouse me-2"></i>Almacén
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="productores-tab" data-bs-toggle="tab" data-bs-target="#productores" type="button" role="tab" aria-controls="productores" aria-selected="false">
                                    <i class="fas fa-seedling me-2"></i>Productores
                                </button>
                            </li>
                        </ul>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <div class="tab-content" id="inventarioTabsContent">
                            <!-- Pestaña Logística -->
                            <div class="tab-pane fade show active" id="logistica" role="tabpanel" aria-labelledby="logistica-tab">
                                <!-- Filtros -->
                                <div class="filtros-container">
                                    <form id="filtroLogistica" class="row g-2 mb-0" style="margin-bottom: 0 !important;">
                                        <div class="col-md-4">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                            <input type="text" class="form-control form-control-sm shadow-sm" id="buscarLogistica" placeholder="SKU, producto..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-info-circle me-1"></i>Estado</label>
                                            <select class="form-select form-select-sm shadow-sm" id="estadoLogistica" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <option value="">Todos</option>
                                                <option value="En Stock">En Stock</option>
                                                <option value="Poco Stock">Poco Stock</option>
                                                <option value="Sin Stock">Sin Stock</option>
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
                                                            <span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">${it.codigoSKU}</span>
                                                        </td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${it.nombreProducto}</td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${it.paquetesDisponibles}</td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">S/. <fmt:formatNumber value="${it.precioPorPaquete}" minFractionDigits="2"/></td>
                                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">S/. <fmt:formatNumber value="${it.costoPorUnidad}" minFractionDigits="2"/></td>
                                                        <td style="padding: 0.35rem 0.5rem;">
                                                            <c:choose>
                                                                <c:when test="${it.estadoStock == 'En Stock'}">
                                                                    <span class="badge bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-check-circle me-1"></i>En stock
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${it.estadoStock == 'Poco Stock'}">
                                                                    <span class="badge bg-warning text-dark shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-exclamation-triangle me-1"></i>Poco
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
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
                            <div class="tab-pane fade" id="almacen" role="tabpanel" aria-labelledby="almacen-tab">
                                <!-- Filtros -->
                                <div class="filtros-container">
                                    <form id="filtroAlmacen" class="row g-2 mb-0" style="margin-bottom: 0 !important;">
                                        <div class="col-md-4">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                            <input type="text" class="form-control form-control-sm shadow-sm" id="buscarAlmacen" placeholder="Código lote, producto, ubicación..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-info-circle me-1"></i>Estado</label>
                                            <select class="form-select form-select-sm shadow-sm" id="estadoAlmacen" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <option value="">Todos</option>
                                                <option value="Activo">Activo</option>
                                                <option value="Vencido">Vencido</option>
                                                <option value="Por Vencer">Por Vencer</option>
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
                            <div class="tab-pane fade" id="productores" role="tabpanel" aria-labelledby="productores-tab">
                                <!-- Filtros -->
                                <div class="filtros-container mb-3">
                                    <form id="filtroProductores" method="get" action="${pageContext.request.contextPath}/administrador/inventario-general" class="row g-2 mb-0" style="margin-bottom: 0 !important;">
                                        <input type="hidden" name="tab" value="productores"/>
                                        <div class="col-md-4">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user me-1"></i>Filtrar por Productor</label>
                                            <select class="form-select form-select-sm shadow-sm" id="filtroProductorSelect" name="filtroProductor" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <option value="">Todos los productores</option>
                                                <c:forEach var="prod" items="${listaProductoresUsuarios}">
                                                    <option value="${prod.id}" ${filtroProductor != null && filtroProductor == prod.id ? 'selected' : ''}>${prod.nombre}</option>
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
                                                                    <i class="fas fa-user-tie me-2" style="color: #00a896;"></i>
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
                                                                                <table class="table table-sm table-hover mb-0" style="font-size: 0.85rem;">
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
                                                                                                <span class="badge bg-secondary" style="font-size: 0.75rem;">${p.codigoSku}</span>
                                                                                            </td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">${p.nombre}</td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                <span class="badge bg-light text-dark">${p.categoriaNombre != null ? p.categoriaNombre : 'Sin categoría'}</span>
                                                                                            </td>
                                                                                            <td style="padding: 0.4rem 0.5rem;">
                                                                                                <span class="badge ${p.stock > 0 ? 'bg-success' : 'bg-danger'}">${p.stock}</span>
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
                                                                                <table class="table table-sm table-hover mb-0" style="font-size: 0.85rem;">
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
                                                                                                <span class="badge" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; font-size: 0.75rem;">${orden[1]}</span>
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
                                                                                                        <span class="badge bg-info">Recibido</span>
                                                                                                    </c:when>
                                                                                                    <c:when test="${estadoOrden == 'En Proceso'}">
                                                                                                        <span class="badge bg-warning text-dark">En Proceso</span>
                                                                                                    </c:when>
                                                                                                    <c:when test="${estadoOrden == 'Rechazado'}">
                                                                                                        <span class="badge bg-danger">Rechazado</span>
                                                                                                    </c:when>
                                                                                                    <c:otherwise>
                                                                                                        <span class="badge bg-secondary">${estadoOrden}</span>
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
                                                                                                                        <span class="badge bg-success">Entrada</span>
                                                                                                                    </c:when>
                                                                                                                    <c:when test="${tipoMov == 'Salida'}">
                                                                                                                        <span class="badge bg-danger">Salida</span>
                                                                                                                    </c:when>
                                                                                                                    <c:otherwise>
                                                                                                                        <span class="badge bg-secondary">${tipoMov}</span>
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
                        tablaLogistica = $('#tablaLogistica').DataTable(tableConfig);
                    } catch(e) {
                        console.error('Error al inicializar tabla Logística:', e);
                    }
                }
            }
            
            // Función para inicializar tabla de Almacén
            function initTablaAlmacen() {
                if (!tablaAlmacen && $('#tablaAlmacen').length > 0) {
                    try {
                        tablaAlmacen = $('#tablaAlmacen').DataTable(tableConfig);
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
            
            // Inicializar la tabla activa al cargar
            if ($('#logistica').hasClass('active')) {
                initTablaLogistica();
            }
            
            // Filtros para Logística
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
            $('#btnBuscarAlmacen').on('click', function() {
                if (!tablaAlmacen) initTablaAlmacen();
                if (tablaAlmacen) {
                    var busqueda = $('#buscarAlmacen').val();
                    var estado = $('#estadoAlmacen').val();
                    
                    tablaAlmacen.column(0).search(busqueda, false, false);
                    tablaAlmacen.column(1).search(busqueda, false, false);
                    tablaAlmacen.column(2).search(busqueda, false, false);
                    tablaAlmacen.column(5).search(estado, false, false);
                    tablaAlmacen.draw();
                }
            });
            
            $('#btnLimpiarAlmacen').on('click', function() {
                if (!tablaAlmacen) initTablaAlmacen();
                if (tablaAlmacen) {
                    $('#buscarAlmacen').val('');
                    $('#estadoAlmacen').val('');
                    tablaAlmacen.search('').columns().search('').draw();
                }
            });
            
            // Filtro automático por productor
            $('#filtroProductorSelect').on('change', function() {
                $('#filtroProductores').submit();
            });
            
            // Limpiar filtros de productores
            $('#btnLimpiarProductores').on('click', function() {
                $('#filtroProductorSelect').val('');
                $('#buscarProductores').val('');
                window.location.href = '${pageContext.request.contextPath}/administrador/inventario-general?tab=productores';
            });
            
            // Búsqueda con debounce para productores
            let searchTimeoutProductores = null;
            $('#buscarProductores').on('input', function() {
                clearTimeout(searchTimeoutProductores);
                searchTimeoutProductores = setTimeout(function() {
                    $('#filtroProductores').submit();
                }, 500);
            });
            
            // Inicializar DataTables al cambiar de pestaña
            $('button[data-bs-toggle="tab"]').on('shown.bs.tab', function (e) {
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
                    initTablaProductores();
                    if (tablaProductores) {
                        setTimeout(function() {
                            tablaProductores.columns.adjust().responsive.recalc();
                        }, 100);
                    }
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
