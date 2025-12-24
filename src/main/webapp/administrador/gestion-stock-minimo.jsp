<%--
  Created by IntelliJ IDEA.
  User: Sergio
  Date: 21/10/2025
  Time: 17:17
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Stock Mínimo"/>
    </jsp:include>
    <style>
        /* Estilo para el botón Limpiar */
        .btn-outline-secondary {
            color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-color: transparent !important;
            background-image: none !important;
        }
        .btn-outline-secondary:hover {
            color: #fff !important;
            background-color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-image: none !important;
        }
        
        /* Estilos para el header del modal - siempre con el color del sidebar */
        #modalHeader {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important;
            color: #ffffff !important;
        }
        
        #modalHeader .modal-title {
            color: #ffffff !important;
        }
        
        #modalHeader .btn-close {
            filter: invert(1) grayscale(100%) brightness(200%);
        }
        
        /* Estilos mejorados para el dropdown de acciones */
        #stockMinimoTable tbody tr {
            position: relative;
            z-index: 1;
        }
        
        #stockMinimoTable tbody tr:hover {
            z-index: 2;
        }
        
        #stockMinimoTable tbody tr.dropdown-open {
            z-index: 1000 !important;
        }
        
        #stockMinimoTable td:last-child {
            overflow: visible !important;
            position: relative;
            z-index: 10;
        }
        
        #stockMinimoTable td:last-child.dropdown-open {
            z-index: 1001 !important;
        }
        
        #stockMinimoTable td:last-child .dropdown {
            position: relative !important;
            display: inline-block !important;
            z-index: 1000;
        }
        
        #stockMinimoTable td:last-child .dropdown.dropdown-open {
            z-index: 1002 !important;
        }
        
        #stockMinimoTable td:last-child .dropdown-toggle::after {
            display: none;
        }
        
        #stockMinimoTable td:last-child .dropdown-menu {
            position: absolute !important;
            right: 0 !important;
            left: auto !important;
            top: 100% !important;
            bottom: auto !important;
            z-index: 999999 !important;
            margin-top: 0.25rem !important;
            margin-bottom: 0 !important;
            min-width: 180px !important;
            display: none;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            transform: none !important;
            border-radius: 8px !important;
            font-size: 0.9rem !important;
            padding: 0.5rem 0 !important;
            background-color: #ffffff !important;
        }
        
        #stockMinimoTable td:last-child .dropdown-menu.show {
            display: block !important;
            position: absolute !important;
        }
        
        #stockMinimoTable tbody {
            overflow: visible !important;
        }
        
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .dropdown-item {
            border-radius: 4px;
            margin: 2px 8px;
            padding: 0.5rem 0.75rem !important;
            transition: all 0.2s ease;
        }
        
        .dropdown-item i {
            width: 20px;
            text-align: center;
        }
        
        .dropdown-item:hover {
            transform: translateX(3px);
            background-color: #f8f9fa;
        }
        
        .dropdown-item.text-primary:hover {
            background-color: #e3f2fd;
            color: #1976d2 !important;
        }
        
        .dropdown-item.text-danger:hover {
            background-color: #ffebee;
            color: #dc3545 !important;
        }
        
        /* Estilos uniformes para la tabla - igual que Gestión de Inventario (Logística) */
        #stockMinimoTable thead th {
            position: relative;
            user-select: none;
            background-color: #f8f9fa !important; /* Color gris plomo de Bootstrap table-light */
            font-weight: 700 !important;
            color: #000000 !important; /* Color negro */
            text-transform: uppercase;
            font-size: 0.85rem;
            text-align: center;
        }
        
        #stockMinimoTable thead th:not(:last-child) {
            cursor: pointer;
        }
        
        #stockMinimoTable thead th:not(:last-child):hover {
            background-color: var(--seafoam) !important;
        }
        
        /* Eliminar flechas de ordenamiento */
        #stockMinimoTable thead th::after,
        #stockMinimoTable thead th::before {
            content: none !important;
            display: none !important;
        }
        
        /* Centrar contenido de todas las celdas (excepto Acciones) */
        #stockMinimoTable tbody td:not(:last-child) {
            text-align: center !important;
        }
        
        /* Asegurar que la paginación tenga z-index bajo para no interferir con dropdowns */
        .dataTables_wrapper .dataTables_paginate {
            position: relative;
            z-index: 1 !important;
        }
        
        /* Estilos para paginación - igual que Gestión de Usuarios (verde agua) */
        .dataTables_wrapper .dataTables_paginate .paginate_button {
            padding: 10px 15px;
            margin: 0 2px;
            border: 1px solid var(--border-color, #dee2e6);
            border-radius: 8px;
            transition: all 0.3s ease;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button a {
            color: #6F4E37;
            text-decoration: none;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button:hover {
            background-color: #e0f2f1 !important;
            border-color: #6F4E37 !important;
            transform: translateY(-2px);
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button:hover a {
            color: #6F4E37 !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.current {
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%) !important;
            border-color: #6F4E37 !important;
            color: #fff !important;
            box-shadow: 0 4px 8px rgba(0,168,150,.35);
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.current a {
            color: #fff !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
            transform: translateY(-2px);
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover {
            background-color: transparent !important;
            border-color: var(--border-color, #dee2e6) !important;
            transform: none;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.disabled a {
            color: #6c757d !important;
        }
        
        /* Solo iconos para botones anterior/siguiente */
        .dataTables_wrapper .dataTables_paginate .paginate_button.previous a,
        .dataTables_wrapper .dataTables_paginate .paginate_button.next a {
            font-size: 0 !important;
            line-height: 0 !important;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.previous a::before {
            content: "\f053";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            font-size: 0.875rem;
            display: inline-block;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.next a::after {
            content: "\f054";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            font-size: 0.875rem;
            display: inline-block;
        }
        
        .dataTables_wrapper .dataTables_paginate .paginate_button.first a,
        .dataTables_wrapper .dataTables_paginate .paginate_button.last a {
            font-size: 0 !important;
            line-height: 0 !important;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Configuracion'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid px-4">
                <div class="page-header mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-triangle-exclamation me-2"></i>Gestión de Stock Mínimo</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Configura los umbrales de stock.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <a href="${pageContext.request.contextPath}/StockMinimoReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <a href="${pageContext.request.contextPath}/StockMinimoReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </a>
                        <button type="button" class="btn btn-sm shadow-sm" data-bs-toggle="modal" data-bs-target="#modalStockMinimo" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                            <i class="fas fa-plus me-1"></i>Nueva Configuración
                        </button>
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

                <%
                    // Obtener estadísticas del servlet
                    Integer totalConfiguracionesAttr = (Integer) request.getAttribute("totalConfiguraciones");
                    Integer configuracionesProductosActivosAttr = (Integer) request.getAttribute("configuracionesProductosActivos");
                    Integer configuracionesProductosInactivosAttr = (Integer) request.getAttribute("configuracionesProductosInactivos");
                    int totalConfiguraciones = (totalConfiguracionesAttr != null) ? totalConfiguracionesAttr : 0;
                    int configuracionesProductosActivos = (configuracionesProductosActivosAttr != null) ? configuracionesProductosActivosAttr : 0;
                    int configuracionesProductosInactivos = (configuracionesProductosInactivosAttr != null) ? configuracionesProductosInactivosAttr : 0;
                %>

                <!-- ===================== Tarjetas de estadísticas ===================== -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Configuraciones</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= totalConfiguraciones %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Productos Activos</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= configuracionesProductosActivos %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Productos Inactivos</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= configuracionesProductosInactivos %></p>
                        </div>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                    <form action="${pageContext.request.contextPath}/StockMinimoServlet" method="GET" id="filterForm">
                        <input type="hidden" name="action" value="listar">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-xl-5 col-lg-5 col-md-12 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Nombre o SKU del producto..." value="${busqueda != null ? busqueda : ''}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado de Producto</label>
                                <select class="form-select form-select-sm shadow-sm" name="estadoProducto" id="estadoProductoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="" ${(estadoProductoFiltro == null || estadoProductoFiltro.isEmpty()) ? 'selected' : ''}>Todos</option>
                                    <option value="1" ${"1".equals(estadoProductoFiltro) ? 'selected' : ''}>Activo</option>
                                    <option value="0" ${"0".equals(estadoProductoFiltro) ? 'selected' : ''}>Inactivo</option>
                                </select>
                            </div>
                            <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6 d-flex align-items-end">
                                <a href="${pageContext.request.contextPath}/StockMinimoServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-sync-alt me-1"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Tabla de configuraciones -->
                <div class="table-card shadow-sm">
                    <div class="card-header">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h5 class="mb-0 fw-semibold"><i class="fas fa-list me-2"></i>Configuraciones de Stock Mínimo</h5>
                                <small class="text-white" style="opacity: 1;">Gestiona los umbrales de stock para cada producto</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                            <table id="stockMinimoTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%;">
                                <thead class="table-light">
                                <tr>
                                    <th class="fw-semibold" style="font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center; cursor: pointer;"><i class="fas fa-barcode me-1"></i>SKU</th>
                                    <th class="fw-semibold" style="font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center; cursor: pointer;"><i class="fas fa-box me-1"></i>Producto</th>
                                    <th class="fw-semibold" style="font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center; cursor: pointer;"><i class="fas fa-warehouse me-1"></i>Umbral Lote (Prod.)</th>
                                    <th class="fw-semibold" style="font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center; cursor: pointer;"><i class="fas fa-chart-line me-1"></i>Umbral Total (Logis.)</th>
                                    <th class="fw-semibold" style="font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center; cursor: pointer;"><i class="fas fa-toggle-on me-1"></i>Estado de Producto</th>
                                    <th class="fw-semibold" style="font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center; cursor: pointer;"><i class="fas fa-calendar me-1"></i>Última Actualización</th>
                                    <th class="text-end fw-semibold text-success" style="width: 120px; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: default;"><i class="fas fa-cog me-1"></i>Acciones</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="config" items="${listaStockMinimo}">
                                    <tr>
                                        <td style="padding: 0.35rem 0.5rem; text-align: center; font-size: 0.85rem; color: #000; font-weight: 500;">${config.producto.codigoSku}</td>
                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem; text-align: center;">${config.producto.nombre}</td>
                                        <td style="padding: 0.35rem 0.5rem; text-align: center; font-size: 0.85rem;">${config.stockMinimoLote} paquetes</td>
                                        <td style="padding: 0.35rem 0.5rem; text-align: center; font-size: 0.85rem;">${config.stockMinimoProducto} paquetes</td>
                                        <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                            <c:choose>
                                                <c:when test="${config.producto.activo}">
                                                    <span class="badge shadow-sm" style="background-color: #c8e6c9; color: #2e7d32; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-check-circle me-1"></i>Activo
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge shadow-sm" style="background-color: #f8d7da; color: #721c24; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-times-circle me-1"></i>Inactivo
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem; text-align: center;"><small class="text-muted">${config.fechaActualizacion}</small></td>
                                        <td class="text-end" style="padding: 0.35rem 0.5rem; position: relative;">
                                            <div class="dropdown" style="position: relative;">
                                                <button class="btn btn-sm btn-outline-secondary shadow-sm" type="button" onclick="toggleDropdown(this)" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;">
                                                    <i class="fas fa-ellipsis-v"></i>
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end" id="dropdown-${config.idStockMinimo}" style="display: none; position: absolute; right: 0; top: 100%; z-index: 999999; min-width: 180px; margin-top: 0.25rem; background-color: #ffffff;">
                                                    <li><a class="dropdown-item" href="#" 
                                                           data-id="${config.idStockMinimo}"
                                                           data-productoid="${config.producto.idProducto}"
                                                           data-nombre="${fn:escapeXml(config.producto.nombre)}"
                                                           data-stockminimolote="${config.stockMinimoLote}"
                                                           data-stockcriticolote="${config.stockMinimoLote}"
                                                           data-stockminimoproducto="${config.stockMinimoProducto}"
                                                           data-stockcriticoproducto="${config.stockMinimoProducto}"
                                                           data-activo="${config.activo}"
                                                           onclick="editarDesdeDropdown(this); return false;"><i class="fas fa-edit me-2"></i>Editar</a></li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<!-- Incluir modales de confirmación -->
<jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />

<!-- Modal para agregar/editar configuración -->
<div class="modal fade" id="modalStockMinimo" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header" id="modalHeader">
                <h5 class="modal-title" id="modalTitle">Nueva Configuración de Stock</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="formStockMinimo" action="${pageContext.request.contextPath}/StockMinimoServlet" method="post">
                <div class="modal-body">
                    <input type="hidden" id="idStockMinimo" name="idStockMinimo">
                    <input type="hidden" id="action" name="action" value="crear">

                    <div class="mb-4" id="productoSelectContainer">
                        <label for="productoId" class="form-label fw-bold">Producto</label>
                        <select class="form-select" id="productoId" name="productoId" required>
                            <option value="">Selecciona un producto</option>
                            <c:forEach var="producto" items="${listaProductos}">
                                <option value="${producto.idProducto}">${producto.nombre} (${producto.codigoSku})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-4" id="productoDisplayContainer" style="display: none;">
                        <label class="form-label fw-bold">Producto</label>
                        <input type="text" class="form-control" id="productoDisplay" readonly style="background-color: #f8f9fa;">
                        <input type="hidden" id="productoIdHidden" name="productoId">
                    </div>

                    <!-- Cards Visuales (Idea 2) -->
                    <div class="row g-3">
                        <!-- Card: Vista Almacén -->
                        <div class="col-md-6">
                            <div class="card border-info">
                                <div class="card-header bg-info text-white">
                                    <h6 class="mb-0"><i class="fas fa-warehouse me-2"></i>VISTA ALMACÉN</h6>
                                    <small>Por Lote Individual</small>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="stockMinimoLote" class="form-label">Umbral de Stock:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockMinimoLote" 
                                                   name="stockMinimoLote" min="0" required placeholder="Ej: 10">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Umbral para determinar Poco Stock / En Stock</div>
                                    </div>
                                    <input type="hidden" id="stockCriticoLote" name="stockCriticoLote" value="0">
                                    <div class="alert alert-light mb-0">
                                        <small><strong>Aplica a:</strong> Cada lote por separado</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Card: Vista Logística -->
                        <div class="col-md-6">
                            <div class="card border-primary">
                                <div class="card-header bg-primary text-white">
                                    <h6 class="mb-0"><i class="fas fa-chart-line me-2"></i>VISTA LOGÍSTICA</h6>
                                    <small>Producto Agrupado</small>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="stockMinimoProducto" class="form-label">Umbral de Stock:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockMinimoProducto" 
                                                   name="stockMinimoProducto" min="0" required placeholder="Ej: 50">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Umbral para determinar Poco Stock / En Stock</div>
                                    </div>
                                    <input type="hidden" id="stockCriticoProducto" name="stockCriticoProducto" value="0">
                                    <div class="alert alert-light mb-0">
                                        <small><strong>Aplica a:</strong> Suma total del producto</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <input type="hidden" id="activo" name="activo" value="true">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>


<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script>
    // Inicializar DataTables
    $(document).ready(function() {
        var table = $('#stockMinimoTable').DataTable({
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
            responsive: true,
            dom: 'rt<"row mt-2"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>'
        });
        
        // Función para ajustar el posicionamiento de los dropdowns
        function ajustarDropdowns() {
            document.querySelectorAll('#stockMinimoTable td:last-child .dropdown').forEach(function(dropdown) {
                const button = dropdown.querySelector('button[data-bs-toggle="dropdown"]');
                const menu = dropdown.querySelector('.dropdown-menu');
                
                if (button && menu) {
                    // Función para posicionar el dropdown
                    function posicionarDropdown() {
                        if (menu.classList.contains('show')) {
                            // Agregar clases para aumentar z-index
                            const tr = button.closest('tr');
                            const td = button.closest('td');
                            if (tr) tr.classList.add('dropdown-open');
                            if (td) td.classList.add('dropdown-open');
                            dropdown.classList.add('dropdown-open');
                            
                            menu.style.position = 'absolute';
                            menu.style.right = '0';
                            menu.style.left = 'auto';
                            menu.style.top = '100%';
                            menu.style.bottom = 'auto';
                            menu.style.transform = 'none';
                            menu.style.zIndex = '99999';
                            menu.style.marginTop = '0.25rem';
                            menu.style.marginBottom = '0';
                            menu.removeAttribute('data-bs-popper');
                        } else {
                            // Remover clases cuando se cierra
                            const tr = button.closest('tr');
                            const td = button.closest('td');
                            if (tr) tr.classList.remove('dropdown-open');
                            if (td) td.classList.remove('dropdown-open');
                            dropdown.classList.remove('dropdown-open');
                        }
                    }
                    
                    // Ajustar cuando el dropdown se muestra
                    button.addEventListener('shown.bs.dropdown', function() {
                        posicionarDropdown();
                    });
                    
                    // Ajustar cuando el dropdown se oculta
                    button.addEventListener('hidden.bs.dropdown', function() {
                        posicionarDropdown();
                    });
                    
                    // Ajustar después de un pequeño delay para asegurar que Bootstrap haya aplicado sus estilos
                    setTimeout(function() {
                        posicionarDropdown();
                    }, 10);
                }
            });
        }
        
        // Reinicializar dropdowns después de que DataTables renderice la tabla
        table.on('draw', function() {
            ajustarDropdowns();
        });
        
        // Inicializar dropdowns al cargar la página
        ajustarDropdowns();
    });
</script>
<script>
    // Función para mostrar/ocultar el dropdown
    function toggleDropdown(button) {
        // Cerrar todos los otros dropdowns
        document.querySelectorAll('.dropdown-menu').forEach(function(menu) {
            if (menu !== button.nextElementSibling) {
                menu.style.display = 'none';
            }
        });
        
        // Toggle del dropdown actual
        const menu = button.nextElementSibling;
        if (menu && menu.classList.contains('dropdown-menu')) {
            if (menu.style.display === 'none' || menu.style.display === '') {
                menu.style.display = 'block';
                
                // Verificar si hay espacio suficiente abajo, si no, mostrar arriba
                const rect = button.getBoundingClientRect();
                const menuHeight = menu.offsetHeight || 100; // Altura estimada del menú
                const spaceBelow = window.innerHeight - rect.bottom;
                const spaceAbove = rect.top;
                
                // Mostrar abajo (comportamiento normal) pero con z-index alto para estar por encima de la paginación
                menu.style.top = '100%';
                menu.style.bottom = 'auto';
                menu.style.marginTop = '0.25rem';
                menu.style.marginBottom = '0';
                menu.style.zIndex = '999999';
            } else {
                menu.style.display = 'none';
            }
        }
    }
    
    // Cerrar dropdowns al hacer clic fuera
    document.addEventListener('click', function(event) {
        if (!event.target.closest('.dropdown')) {
            document.querySelectorAll('.dropdown-menu').forEach(function(menu) {
                menu.style.display = 'none';
            });
        }
    });
    
    function editarConfiguracion(id, productoId, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo) {
        document.getElementById('modalTitle').textContent = 'Editar Configuración de Stock';
        document.getElementById('idStockMinimo').value = id;
        document.getElementById('action').value = 'actualizar';
        document.getElementById('stockMinimoLote').value = stockMinimoLote;
        // El stock crítico de lote se establece automáticamente igual al mínimo (solo un umbral)
        document.getElementById('stockCriticoLote').value = stockMinimoLote;
        document.getElementById('stockMinimoProducto').value = stockMinimoProducto;
        // El stock crítico de producto se establece automáticamente igual al mínimo (solo un umbral)
        document.getElementById('stockCriticoProducto').value = stockMinimoProducto;
        document.getElementById('activo').value = 'true'; // Siempre activo
        
        // Ocultar el select y mostrar el nombre del producto como texto de solo lectura
        document.getElementById('productoSelectContainer').style.display = 'none';
        document.getElementById('productoDisplayContainer').style.display = 'block';
        document.getElementById('productoDisplay').value = nombre;
        document.getElementById('productoIdHidden').value = productoId;

        // Mostrar el modal
        var modal = new bootstrap.Modal(document.getElementById('modalStockMinimo'));
        modal.show();
    }

    function editarConfiguracionFromButton(btn) {
        const id = parseInt(btn.dataset.id);
        const productoId = parseInt(btn.dataset.productoid || 0);
        const nombre = btn.dataset.nombre;
        const stockMinimoLote = parseInt(btn.dataset.stockminimolote);
        const stockCriticoLote = parseInt(btn.dataset.stockcriticolote);
        const stockMinimoProducto = parseInt(btn.dataset.stockminimoproducto);
        const stockCriticoProducto = parseInt(btn.dataset.stockcriticoproducto);
        const activo = String(btn.dataset.activo) === 'true';
        editarConfiguracion(id, productoId, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo);
    }
    
    function editarConfiguracionDirecta(id, productoId, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo) {
        editarConfiguracion(id, productoId, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo);
    }
    
    function editarDesdeDropdown(element) {
        const id = parseInt(element.dataset.id);
        const productoId = parseInt(element.dataset.productoid);
        const nombre = element.dataset.nombre;
        const stockMinimoLote = parseInt(element.dataset.stockminimolote);
        const stockCriticoLote = parseInt(element.dataset.stockcriticolote);
        const stockMinimoProducto = parseInt(element.dataset.stockminimoproducto);
        const stockCriticoProducto = parseInt(element.dataset.stockcriticoproducto);
        const activo = element.dataset.activo === 'true';
        
        editarConfiguracion(id, productoId, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo);
    }

    function eliminarConfiguracion(id) {
        showConfirm(
            '¿Estás seguro de que deseas eliminar esta configuración?',
            function() {
                var form = document.createElement('form');
                form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/StockMinimoServlet';

            var actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'eliminar';

            var idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'idStockMinimo';
            idInput.value = id;

            form.appendChild(actionInput);
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
            },
            'Confirmar eliminación'
        );
    }


    // Limpiar formulario al cerrar modal
    document.getElementById('modalStockMinimo').addEventListener('hidden.bs.modal', function () {
        document.getElementById('formStockMinimo').reset();
        document.getElementById('modalTitle').textContent = 'Nueva Configuración de Stock';
        document.getElementById('action').value = 'crear';
        // Mostrar el select y ocultar el display cuando se crea nueva configuración
        document.getElementById('productoSelectContainer').style.display = 'block';
        document.getElementById('productoDisplayContainer').style.display = 'none';
        document.getElementById('productoId').disabled = false;
        // Asegurar que activo siempre sea true
        document.getElementById('activo').value = 'true';
    });

    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const estadoProductoFilter = document.getElementById('estadoProductoFilter');
        
        // Variable para el timeout del debounce
        let searchTimeout = null;
        
        // Aplicar filtros automáticamente mientras se escribe en el campo de búsqueda (con debounce)
        if (searchInput && filterForm) {
            searchInput.addEventListener('input', function(e) {
                // Limpiar el timeout anterior
                if (searchTimeout) {
                    clearTimeout(searchTimeout);
                }
                
                // Esperar 500ms después de que el usuario deje de escribir antes de enviar
                searchTimeout = setTimeout(function() {
                    filterForm.submit();
                }, 500);
            });
            
            // Aplicar filtros al presionar Enter en el campo de búsqueda (inmediato)
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    // Cancelar el timeout si existe
                    if (searchTimeout) {
                        clearTimeout(searchTimeout);
                    }
                    filterForm.submit();
                }
            });
        }
        
        // Aplicar filtros cuando cambien los selects
        if (estadoProductoFilter && filterForm) {
            estadoProductoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
    });
</script>
</body>
</html>