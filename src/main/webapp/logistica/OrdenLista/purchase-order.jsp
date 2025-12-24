<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.OrdenCompraBean" %>
<%@ page import="com.example.telito.logistica.beans.ProveedorBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Orden de Compra"/>
    </jsp:include>
    <!-- Incluir modales personalizados -->
    <jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />
    <style>
        /* Estilos específicos del módulo: Sidebar con temática café y beige */
        .nav-left-sidebar {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important;
        }
        .nav-link {
            color: #F5DEB3 !important;
        }
        .nav-link:hover, .nav-link.active {
            color: #FFF8DC !important;
            background-color: rgba(245, 222, 179, 0.2) !important;
        }
        .nav-divider {
            color: #F5DEB3 !important;
            border-top-color: rgba(245, 222, 179, 0.4) !important;
        }
        .nav-link::before {
            background: #F5DEB3 !important;
        }
        
        /* Fondo beige claro para todo el contenido principal (header, centro, footer) */
        .dashboard-header {
            background-color: #FFFEF9 !important;
        }
        .dashboard-header .navbar {
            background-color: #FFFEF9 !important;
        }
        .dashboard-wrapper {
            background-color: #FFFEF9 !important;
        }
        .dashboard-content {
            background-color: #FFFEF9 !important;
        }
        .dashboard-main-wrapper {
            background-color: #FFFEF9 !important;
        }
        footer,
        .footer {
            background-color: #FFFEF9 !important;
        }
        body {
            background-color: #FFFEF9 !important;
        }
        
        /* Textos en color marrón */
        .dashboard-header .navbar-brand span {
            color: #6F4E37 !important;
        }
        .dashboard-header .navbar-brand i {
            color: #6F4E37 !important;
        }
        .dashboard-header .navbar-nav .nav-link span {
            color: #6F4E37 !important;
        }
        .dashboard-header .nav-link.dropdown-toggle {
            color: #6F4E37 !important;
        }
        .dashboard-header .nav-link i.fa-bell,
        .dashboard-header .nav-link i[class*="fa-bell"] {
            color: #6F4E37 !important;
        }
        .dashboard-header .nav-link[style*="color: var(--turquoise-dark)"] i,
        .dashboard-header .nav-link i[style*="color: var(--turquoise-dark)"] {
            color: #6F4E37 !important;
        }
        .dashboard-header .navbar-brand i.fa-truck,
        .dashboard-header .navbar-brand i[class*="fa-truck"],
        .dashboard-header .navbar-brand i[style*="color: var(--seafoam)"] {
            color: #6F4E37 !important;
        }
        .pageheader-title {
            color: #6F4E37 !important;
        }
        .pageheader-text {
            color: #6F4E37 !important;
        }
        .page-header h2 {
            color: #6F4E37 !important;
        }
        .page-header p {
            color: #6F4E37 !important;
        }
        .page-header h2 i {
            color: #6F4E37 !important;
        }
        
        /* Estilo para el encabezado de la tabla con temática café */
        .table-card .card-header {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important;
            color: #fff;
            border-radius: 12px 12px 0 0;
            padding: 20px 30px;
            margin: 0;
        }
        .table-card .card-header h5,
        .table-card .card-header small {
            color: white !important;
        }
        
        /* Cards con fondo beige claro y bordes café */
        .card {
            background-color: #FFFEF9 !important;
            border: 2px solid #6F4E37 !important;
        }
        .stat-card {
            background-color: #FFFEF9 !important;
            border: 2px solid #6F4E37 !important;
        }
        .stat-card h3 {
            color: #6F4E37 !important;
        }
        .stat-card p {
            color: #6F4E37 !important;
        }
        /* Estilo para el botón Limpiar igual que en productor - sobrescribir estilos globales */
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
        .btn-outline-secondary:focus {
            color: #fff !important;
            background-color: #6c757d !important;
            border: 1px solid #6c757d !important;
            box-shadow: 0 0 0 0.25rem rgba(108, 117, 125, 0.5) !important;
        }
        
        /* ===================== Estilos para Modal de Enviar por Correo ===================== */
        #sendOrdenesCompraModal.modal { 
            display: none; 
            position: fixed; 
            z-index: 1050; 
            left: 0; 
            top: 0; 
            width: 100%; 
            height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(4px);
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        #sendOrdenesCompraModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #sendOrdenesCompraModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 700px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-30px) scale(0.95);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }
        #sendOrdenesCompraModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important; 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(111, 78, 55, 0.2);
        }
        #sendOrdenesCompraModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #sendOrdenesCompraModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #sendOrdenesCompraModal .modal-close { 
            color: white; 
            font-size: 24px; 
            font-weight: normal; 
            cursor: pointer; 
            opacity: 0.9; 
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        #sendOrdenesCompraModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #sendOrdenesCompraModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #sendOrdenesCompraModal .form-group {
            margin-bottom: 1.25rem;
        }
        #sendOrdenesCompraModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #sendOrdenesCompraModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #sendOrdenesCompraModal .form-group input,
        #sendOrdenesCompraModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #sendOrdenesCompraModal .form-group input:focus,
        #sendOrdenesCompraModal .form-group textarea:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(111, 78, 55, 0.1);
        }
        #sendOrdenesCompraModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #sendOrdenesCompraModal .form-hint i {
            color: #6F4E37;
            margin-top: 2px;
        }
        #sendOrdenesCompraModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #sendOrdenesCompraModal .modal-footer button {
            padding: 12px 28px;
            font-size: 0.95rem;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #sendOrdenesCompraModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #sendOrdenesCompraModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #sendOrdenesCompraModal .modal-footer button[type="submit"] {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(111, 78, 55, 0.3);
        }
        #sendOrdenesCompraModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(111, 78, 55, 0.4);
        }
        @media (max-width: 768px) {
            #sendOrdenesCompraModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #sendOrdenesCompraModal.show {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='OrdenCompra'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <!-- Mensajes de alerta -->
            <c:if test="${not empty sessionScope.mensaje}">
                <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                    ${sessionScope.mensaje}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                </div>
                <c:remove var="mensaje" scope="session"/>
                <c:remove var="tipoMensaje" scope="session"/>
            </c:if>

            <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-file-invoice-dollar me-2"></i>Orden de Compra</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra las órdenes de compra del sistema.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <%
                            String busquedaParam = request.getParameter("busqueda");
                            String proveedorParam = request.getParameter("proveedor");
                            String estadoParam = request.getParameter("estado");
                            StringBuilder urlParams = new StringBuilder();
                            if (busquedaParam != null && !busquedaParam.trim().isEmpty()) {
                                urlParams.append("&busqueda=").append(java.net.URLEncoder.encode(busquedaParam, "UTF-8"));
                            }
                            if (proveedorParam != null && !proveedorParam.trim().isEmpty()) {
                                urlParams.append("&proveedor=").append(java.net.URLEncoder.encode(proveedorParam, "UTF-8"));
                            }
                            if (estadoParam != null && !estadoParam.trim().isEmpty()) {
                                urlParams.append("&estado=").append(java.net.URLEncoder.encode(estadoParam, "UTF-8"));
                            }
                            String urlBase = request.getContextPath() + "/logistica/OrdenCompraReporteServlet?action=exportar" + urlParams.toString();
                            String urlEnviar = request.getContextPath() + "/logistica/OrdenCompraReporteServlet?action=formEnviar" + urlParams.toString();
                        %>
                        <a href="<%= urlBase %>" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #D4A574 0%, #C9A87A 100%); color: white; border: none;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <button type="button" id="openSendOrdenesCompraModalBtn" class="btn btn-sm text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #E8B86D 0%, #D4A574 100%); border: none;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </button>
                        <a href="${pageContext.request.contextPath}/orden-compra?action=crear" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); border: none; color: white; font-weight: 600;">
                            <i class="fas fa-plus me-1"></i>Agregar Orden
                        </a>
                    </div>
                </div>
            </div>

            <%
                // Obtener estadísticas del servlet
                Integer totalOrdenesAttr = (Integer) request.getAttribute("totalOrdenes");
                Integer ordenesPendientesAttr = (Integer) request.getAttribute("ordenesPendientes");
                Integer ordenesAprobadasAttr = (Integer) request.getAttribute("ordenesAprobadas");
                Integer ordenesRechazadasAttr = (Integer) request.getAttribute("ordenesRechazadas");
                Integer ordenesRecibidasAttr = (Integer) request.getAttribute("ordenesRecibidas");
                int totalOrdenes = (totalOrdenesAttr != null) ? totalOrdenesAttr : 0;
                int ordenesPendientes = (ordenesPendientesAttr != null) ? ordenesPendientesAttr : 0;
                int ordenesAprobadas = (ordenesAprobadasAttr != null) ? ordenesAprobadasAttr : 0;
                int ordenesRechazadas = (ordenesRechazadasAttr != null) ? ordenesRechazadasAttr : 0;
                int ordenesRecibidas = (ordenesRecibidasAttr != null) ? ordenesRecibidasAttr : 0;
            %>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="row g-2 mb-3" style="display: flex; flex-wrap: nowrap;">
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 2px solid #6F4E37;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Total de Órdenes</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= totalOrdenes %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 2px solid #6F4E37;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Pendientes</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= ordenesPendientes %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 2px solid #6F4E37;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Aprobadas</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= ordenesAprobadas %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 2px solid #6F4E37;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Rechazadas</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= ordenesRechazadas %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 2px solid #6F4E37;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Recibidas</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= ordenesRecibidas %></p>
                    </div>
                </div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros ===================== -->
            <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px; background-color: #FFFEF9 !important; border: 2px solid #6F4E37 !important;">
                <form action="${pageContext.request.contextPath}/orden-compra" method="GET" id="filterForm">
                    <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                    <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                        <div class="col-xl-4 col-lg-4 col-md-12 col-sm-12">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                            <div class="input-group">
                                <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="N° Orden o producto..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <button class="btn btn-sm shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem; background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); color: white; border: none;">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-xl-3 col-lg-3 col-md-6 col-sm-12">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-truck me-1"></i>Proveedor</label>
                            <select class="form-select form-select-sm shadow-sm" name="proveedor" id="proveedorFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="" ${empty param.proveedor ? 'selected' : ''}>Todos</option>
                                <% ArrayList<ProveedorBean> listaProveedores = (ArrayList<ProveedorBean>) request.getAttribute("listaProveedores");
                                    if(listaProveedores != null){
                                        for(ProveedorBean proveedor : listaProveedores){ 
                                            String proveedorIdStr = String.valueOf(proveedor.getId());
                                            String paramProveedor = request.getParameter("proveedor") != null ? request.getParameter("proveedor") : "";
                                            boolean isSelected = proveedorIdStr.equals(paramProveedor);
                                %>
                                <option value="<%= proveedor.getId() %>" <%= isSelected ? "selected" : "" %>>
                                    <%= proveedor.getNombre() %>
                                </option>
                                <%  }
                                } %>
                            </select>
                        </div>
                        <div class="col-xl-3 col-lg-3 col-md-6 col-sm-12">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                            <select class="form-select form-select-sm shadow-sm" name="estado" id="estadoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                <option value="Pendiente" ${param.estado == 'Pendiente' ? 'selected' : ''}>Pendiente</option>
                                <option value="Aprobado" ${param.estado == 'Aprobado' ? 'selected' : ''}>Aprobado</option>
                                <option value="Rechazado" ${param.estado == 'Rechazado' ? 'selected' : ''}>Rechazado</option>
                                <option value="Recibido" ${param.estado == 'Recibido' ? 'selected' : ''}>Recibido</option>
                            </select>
                        </div>
                        <div class="col-xl-2 col-lg-2 col-md-12 col-sm-12 d-flex align-items-end">
                            <a href="${pageContext.request.contextPath}/orden-compra" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                            </a>
                        </div>
                    </div>
                </form>
            </div>

            <!-- ===================== Card: Tabla de órdenes ===================== -->
            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-file-invoice-dollar me-2"></i>Tabla de Ordenes</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todas las órdenes de compra</small>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">

                            <div class="table-responsive">
                                <table id="purchaseTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                    <thead class="table-light">
                                    <tr>
                                        <th onclick="sortTable(0)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-hashtag me-1"></i>N° de Orden
                                        </th>
                                        <th onclick="sortTable(1)" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-truck me-1"></i>Proveedor
                                        </th>
                                        <th onclick="sortTable(2)" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Producto
                                        </th>
                                        <th onclick="sortTable(3)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-cubes me-1"></i>Cantidad
                                        </th>
                                        <th onclick="sortTable(4)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-user me-1"></i>Personal Responsable
                                        </th>
                                        <th onclick="sortTable(5)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-toggle-on me-1"></i>Estado
                                        </th>
                                        <th onclick="sortTable(6)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-dollar-sign me-1"></i>Monto
                                        </th>
                                        <th class="text-center fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                            <i class="fas fa-cog me-1"></i>Acciones
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<OrdenCompraBean> listaOrdenes = (ArrayList<OrdenCompraBean>) request.getAttribute("listaOrdenes");
                                        
                                        Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                        Integer sizeObj = (Integer) request.getAttribute("size");
                                        int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                        int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                        
                                        if (listaOrdenes != null && !listaOrdenes.isEmpty()) {
                                            for (OrdenCompraBean orden : listaOrdenes) {
                                    %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= orden.getNumeroOrden() %></strong></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getNombreProveedor() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getNombreProducto() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getCantidadPaquetes() %> paquetes</td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getPersonalResponsable() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <% if ("Pendiente".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-clock me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else if ("Aprobado".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-check-circle me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else if ("Rechazado".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-times-circle me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else if ("Recibido".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-inbox me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else { %>
                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-question-circle me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } %>
                                        </td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= orden.getMontoTotal() %></strong></td>
                                        <td class="text-center" style="font-size: 0.85rem; padding: 0.5rem;">
                                            <% if ("Recibido".equals(orden.getEstado())) { %>
                                            <button class="btn btn-sm shadow-sm" onclick="editarOrden('<%= orden.getNumeroOrden() %>')" style="font-size: 0.8rem; padding: 0.35rem 0.6rem; border: none; color: white; background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); transition: all 0.2s ease; white-space: nowrap; font-weight: 600;" onmouseover="this.style.background='linear-gradient(165deg, #8B6F47 0%, #6F4E37 50%, #A0826D 100%)'; this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 8px rgba(111,78,55,0.3)';" onmouseout="this.style.background='linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%)'; this.style.transform='translateY(0)'; this.style.boxShadow='none';">
                                                <i class="fas fa-eye me-1"></i>Ver
                                            </button>
                                            <% } else { %>
                                            <span class="text-muted" style="font-size: 0.75rem;">-</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center py-5">
                                            <div class="text-muted">
                                                <i class="fas fa-file-invoice fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No se encontraron órdenes con los filtros aplicados.</p>
                                                <small>Intenta ajustar los filtros de búsqueda</small>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                </table>
                                
                                <%-- Incluir componente de paginación --%>
                                <%
                                    request.setAttribute("param1Name", "busqueda");
                                    request.setAttribute("param1Value", request.getAttribute("busqueda"));
                                    request.setAttribute("param2Name", "proveedor");
                                    request.setAttribute("param2Value", request.getAttribute("proveedorFiltro"));
                                    request.setAttribute("param3Name", "estado");
                                    request.setAttribute("param3Value", request.getAttribute("estadoFiltro"));
                                %>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<!-- Modal: Ver Detalles de Orden Recibida -->
<div class="modal fade" id="detalleOrdenModal" tabindex="-1" aria-labelledby="detalleOrdenModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
            <div class="modal-header text-white" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important; border-radius: 16px 16px 0 0; padding: 20px 25px; border-bottom: none;">
                <h5 class="modal-title d-flex align-items-center" id="detalleOrdenModalLabel" style="font-weight: 600; font-size: 1.2rem;">
                    <span class="d-flex align-items-center justify-content-center me-3" style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 10px; width: 45px; height: 45px;">
                        <i class="fas fa-box-open" style="font-size: 1.2rem;"></i>
                    </span>
                    Detalles de Orden Recibida
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="opacity: 1; width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.15); display: flex; align-items: center; justify-content: center; border: none; color: white;" onmouseover="this.style.background='rgba(255,255,255,0.25)';" onmouseout="this.style.background='rgba(255,255,255,0.15)';">
                    <i class="fas fa-times" style="color: white; font-size: 18px;"></i>
                </button>
            </div>
            <div class="modal-body" style="padding: 25px; background: #f8f9fa;">
                <div id="loadingDetalle" class="text-center py-5">
                    <div class="spinner-border" style="color: #6F4E37; width: 3rem; height: 3rem;" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-3 text-muted" style="font-size: 0.95rem;">Cargando detalles de la orden...</p>
                </div>
                <div id="detalleOrdenContainer" style="display: none;">
                    <div class="alert" style="background: linear-gradient(165deg, rgba(111,78,55,0.1) 0%, rgba(139,111,71,0.1) 100%); border: 2px solid #6F4E37; border-radius: 12px; padding: 15px 20px; margin-bottom: 20px;">
                        <i class="fas fa-info-circle me-2" style="color: #6F4E37; font-size: 1.1rem;"></i>
                        <strong style="color: #6F4E37;">Orden:</strong> <span id="detalleNumeroOrden" style="color: #495057; font-weight: 600;"></span>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-user me-2" style="color: #6F4E37;"></i>Productor
                                </label>
                                <p id="detalleProductor" class="mb-0" style="font-size: 1rem; font-weight: 500; color: #495057;">-</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-user-tie me-2" style="color: #6F4E37;"></i>Personal Responsable
                                </label>
                                <p id="detallePersonalResponsable" class="mb-0" style="font-size: 1rem; font-weight: 500; color: #495057;">-</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-box me-2" style="color: #6F4E37;"></i>Producto
                                </label>
                                <p id="detalleProducto" class="mb-0" style="font-size: 1rem; font-weight: 500; color: #495057;">-</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-barcode me-2" style="color: #6F4E37;"></i>SKU
                                </label>
                                <p id="detalleSKU" class="mb-0"><span class="badge" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); font-size: 0.9rem; padding: 6px 12px;">-</span></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); text-align: center;">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-cubes me-2" style="color: #6F4E37;"></i>Cantidad
                                </label>
                                <p id="detalleCantidad" class="mb-0" style="font-size: 1.3rem; font-weight: 600; color: #6F4E37;">-</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); text-align: center;">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-dollar-sign me-2" style="color: #6F4E37;"></i>Monto Total
                                </label>
                                <p id="detalleMontoTotal" class="mb-0" style="font-size: 1.3rem; font-weight: 600; color: #6F4E37;">-</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); text-align: center;">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-clipboard-check me-2" style="color: #6F4E37;"></i>Estado
                                </label>
                                <p id="detalleEstado" class="mb-0"><span class="badge" style="font-size: 0.9rem; padding: 6px 12px;">-</span></p>
                            </div>
                        </div>
                    </div>
                    
                    <hr style="border-top: 2px solid #e9ecef; margin: 25px 0;">
                    
                    <h6 class="mb-3" style="color: #6F4E37; font-weight: 600; font-size: 1rem;">
                        <i class="fas fa-boxes me-2"></i>Lote Asignado por el Productor
                    </h6>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-tag me-2" style="color: #6F4E37;"></i>Código de Lote
                                </label>
                                <p id="detalleCodigoLote" class="mb-0" style="font-size: 1.1rem; font-weight: 600; color: #495057;">-</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-calendar-alt me-2" style="color: #6F4E37;"></i>Fecha de Vencimiento
                                </label>
                                <p id="detalleFechaVencimiento" class="mb-0" style="font-size: 1rem; font-weight: 500; color: #495057;">-</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-boxes me-2" style="color: #6F4E37;"></i>Stock Disponible
                                </label>
                                <p id="detalleStockDisponible" class="mb-0" style="font-size: 1.1rem; font-weight: 600; color: #6F4E37;">-</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div style="background: white; padding: 15px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <label class="form-label" style="font-weight: 600; font-size: 0.85rem; color: #6c757d; text-transform: uppercase; margin-bottom: 8px;">
                                    <i class="fas fa-map-marker-alt me-2" style="color: #6F4E37;"></i>Ubicación
                                </label>
                                <p id="detalleUbicacion" class="mb-0" style="font-size: 1rem; font-weight: 500; color: #495057;">-</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="errorDetalle" class="alert alert-warning" style="display: none; border-radius: 12px;">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    No se pudieron cargar los detalles de la orden.
                </div>
            </div>
            <div class="modal-footer d-flex justify-content-between" style="background: white; border-top: 2px solid #e9ecef; padding: 20px 25px; border-radius: 0 0 16px 16px;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="padding: 10px 20px; border-radius: 8px; font-weight: 600;">
                    <i class="fas fa-arrow-left me-2"></i>Volver
                </button>
                <div>
                    <button type="button" class="btn btn-danger me-2" id="btnRechazar" onclick="cambiarEstadoOrden('Rechazado')" style="padding: 10px 20px; border-radius: 8px; font-weight: 600;">
                        <i class="fas fa-times-circle me-2"></i>Rechazar
                    </button>
                    <button type="button" class="btn btn-success" id="btnAprobar" onclick="cambiarEstadoOrden('Aprobado')" style="padding: 10px 20px; border-radius: 8px; font-weight: 600; background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); border: none;">
                        <i class="fas fa-check-circle me-2"></i>Aprobar
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const proveedorFilter = document.getElementById('proveedorFilter');
        const estadoFilter = document.getElementById('estadoFilter');
        
        // Aplicar filtros cuando cambien los selects
        if (proveedorFilter) {
            proveedorFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (estadoFilter) {
            estadoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
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
    });
    // Función para ordenar la tabla
    let sortDirection = {}; // Almacena la dirección de ordenamiento para cada columna
    
    function sortTable(columnIndex) {
        const table = document.getElementById('purchaseTable');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Determinar dirección de ordenamiento
        if (!sortDirection[columnIndex]) {
            sortDirection[columnIndex] = 'asc';
        } else {
            sortDirection[columnIndex] = sortDirection[columnIndex] === 'asc' ? 'desc' : 'asc';
        }
        
        // Ordenar las filas
        rows.sort((a, b) => {
            const aText = a.cells[columnIndex].textContent.trim();
            const bText = b.cells[columnIndex].textContent.trim();
            
            // Intentar comparar como números si es posible
            const aNum = parseFloat(aText.replace(/[^\d.-]/g, ''));
            const bNum = parseFloat(bText.replace(/[^\d.-]/g, ''));
            
            let comparison = 0;
            if (!isNaN(aNum) && !isNaN(bNum)) {
                comparison = aNum - bNum;
            } else {
                // Comparar como texto
                comparison = aText.localeCompare(bText, 'es', { numeric: true, sensitivity: 'base' });
            }
            
            return sortDirection[columnIndex] === 'asc' ? comparison : -comparison;
        });
        
        // Reordenar las filas en el DOM
        rows.forEach(row => tbody.appendChild(row));
        
        // Actualizar indicadores visuales en los encabezados
        const headers = table.querySelectorAll('thead th');
        headers.forEach((header, index) => {
            header.classList.remove('sort-asc', 'sort-desc');
            if (index === columnIndex) {
                header.classList.add(sortDirection[columnIndex] === 'asc' ? 'sort-asc' : 'sort-desc');
            }
        });
    }
    
    // Función para limpiar backdrops múltiples (overlays oscuros)
    function limpiarBackdrops() {
        const backdrops = document.querySelectorAll('.modal-backdrop');
        if (backdrops.length > 1) {
            // Si hay más de un backdrop, eliminar los extras
            for (let i = 1; i < backdrops.length; i++) {
                backdrops[i].remove();
            }
        }
        // Asegurarse de que el body no tenga múltiples clases
        document.body.classList.remove('modal-open');
        if (backdrops.length > 0) {
            document.body.classList.add('modal-open');
        }
    }
    
    // Variable global para la instancia del modal de detalles
    let detalleOrdenModalInstance = null;
    
    // Función para obtener o crear la instancia del modal
    function getDetalleOrdenModal() {
        if (!detalleOrdenModalInstance) {
            const modalElement = document.getElementById('detalleOrdenModal');
            detalleOrdenModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
            
            // Limpiar backdrops cuando se cierre el modal
            modalElement.addEventListener('hidden.bs.modal', function() {
                limpiarBackdrops();
            });
        }
        return detalleOrdenModalInstance;
    }
    
    // Función para ver detalles de orden recibida
    function editarOrden(numeroOrden) {
        console.log('Abriendo detalles de orden:', numeroOrden);
        
        // Mostrar loading y ocultar contenido
        document.getElementById('loadingDetalle').style.display = 'block';
        document.getElementById('detalleOrdenContainer').style.display = 'none';
        document.getElementById('errorDetalle').style.display = 'none';
        
        // Obtener o crear la instancia del modal (reutilizar si ya existe)
        const modal = getDetalleOrdenModal();
        modal.show();
        
        // Extraer el número de orden (ej: "OC005" -> 5)
        const idOrden = numeroOrden.replace(/\D/g, '');
        ordenActualId = idOrden; // Guardar en variable global
        console.log('ID Orden extraído:', idOrden);
        
        // Habilitar botones al abrir el modal
        document.getElementById('btnAprobar').disabled = false;
        document.getElementById('btnRechazar').disabled = false;
        
        // Cargar los detalles de la orden vía AJAX
        fetch('${pageContext.request.contextPath}/orden-compra?action=obtenerDetalle&idOrden=' + idOrden)
            .then(response => response.json())
            .then(data => {
                console.log('Datos recibidos:', data);
                
                document.getElementById('loadingDetalle').style.display = 'none';
                
                if (data.success) {
                    // Llenar los campos del modal con los datos
                    document.getElementById('detalleNumeroOrden').textContent = numeroOrden;
                    document.getElementById('detalleProductor').textContent = data.productor || '-';
                    document.getElementById('detallePersonalResponsable').textContent = data.personalResponsable || '-';
                    document.getElementById('detalleProducto').textContent = data.producto || '-';
                    document.getElementById('detalleSKU').innerHTML = '<span class="badge bg-secondary">' + (data.sku || '-') + '</span>';
                    document.getElementById('detalleCantidad').textContent = (data.cantidad || '-') + ' paquetes';
                    document.getElementById('detalleMontoTotal').textContent = data.montoTotal || '-';
                    
                    // Badge de estado
                    let estadoBadge = '<span class="badge bg-info">' + (data.estado || '-') + '</span>';
                    document.getElementById('detalleEstado').innerHTML = estadoBadge;
                    
                    // Datos del lote
                    document.getElementById('detalleCodigoLote').innerHTML = '<strong>' + (data.codigoLote || '-') + '</strong>';
                    document.getElementById('detalleFechaVencimiento').textContent = data.fechaVencimiento || 'Sin fecha';
                    document.getElementById('detalleStockDisponible').textContent = (data.stockDisponible || '0') + ' unidades';
                    document.getElementById('detalleUbicacion').textContent = data.ubicacion || '-';
                    
                    document.getElementById('detalleOrdenContainer').style.display = 'block';
                } else {
                    document.getElementById('errorDetalle').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error al cargar detalles:', error);
                document.getElementById('loadingDetalle').style.display = 'none';
                document.getElementById('errorDetalle').style.display = 'block';
            });
    }
    
    // Variable global para guardar el ID de la orden actual
    let ordenActualId = null;
    
    // Función para cambiar el estado de la orden (Aprobar o Rechazar)
    function cambiarEstadoOrden(nuevoEstado) {
        if (!ordenActualId) {
            showError('No se ha seleccionado ninguna orden');
            return;
        }
        
        const mensajeConfirm = nuevoEstado === 'Aprobado' 
            ? '¿Está seguro de APROBAR esta orden?' 
            : '¿Está seguro de RECHAZAR esta orden?';
        
        const tituloConfirm = nuevoEstado === 'Aprobado' 
            ? 'Aprobar Orden' 
            : 'Rechazar Orden';
        
        // Cerrar el modal de detalles primero para evitar overlays múltiples
        const detalleModal = getDetalleOrdenModal();
        detalleModal.hide();
        
        // Esperar a que el modal se cierre completamente antes de mostrar el de confirmación
        const detalleModalElement = document.getElementById('detalleOrdenModal');
        detalleModalElement.addEventListener('hidden.bs.modal', function onHidden() {
            detalleModalElement.removeEventListener('hidden.bs.modal', onHidden);
            
            // Ahora mostrar el modal de confirmación
            showConfirm(
                mensajeConfirm,
                function() {
                    console.log('Cambiando estado a:', nuevoEstado, 'para orden:', ordenActualId);
                    
                    // Deshabilitar botones
                    document.getElementById('btnAprobar').disabled = true;
                    document.getElementById('btnRechazar').disabled = true;
                    
                    // Hacer petición para cambiar el estado
                    fetch('${pageContext.request.contextPath}/orden-compra', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'action=cambiarEstado&idOrden=' + ordenActualId + '&nuevoEstado=' + encodeURIComponent(nuevoEstado)
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            showSuccess('Orden ' + (nuevoEstado === 'Aprobado' ? 'aprobada' : 'rechazada') + ' exitosamente');
                            // Recargar la página después de 1 segundo
                            setTimeout(() => location.reload(), 1500);
                        } else {
                            showError('Error: ' + (data.message || 'No se pudo cambiar el estado'));
                            document.getElementById('btnAprobar').disabled = false;
                            document.getElementById('btnRechazar').disabled = false;
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        showError('Error de conexión al cambiar el estado. Por favor, intenta de nuevo.');
                        document.getElementById('btnAprobar').disabled = false;
                        document.getElementById('btnRechazar').disabled = false;
                    });
                },
                tituloConfirm
            );
        }, { once: true });
    }
    
    // ===================== Modal: Enviar Órdenes de Compra por Correo =====================
    document.addEventListener('DOMContentLoaded', function() {
        const sendOrdenesCompraModal = document.getElementById('sendOrdenesCompraModal');
        const openSendOrdenesCompraBtn = document.getElementById('openSendOrdenesCompraModalBtn');
        
        if (!sendOrdenesCompraModal || !openSendOrdenesCompraBtn) {
            console.error('No se encontraron los elementos del modal de Enviar Órdenes de Compra');
            return;
        }
        
        const closeSendOrdenesCompraBtn = sendOrdenesCompraModal.querySelector('.modal-close');
        const cancelSendOrdenesCompraBtn = sendOrdenesCompraModal.querySelector('.modal-cancel');
        
        // Función para abrir el modal
        function abrirModalEnviarOrdenesCompra() {
            // Obtener filtros actuales de la URL
            const urlParams = new URLSearchParams(window.location.search);
            const busqueda = urlParams.get('busqueda') || '';
            const proveedor = urlParams.get('proveedor') || '';
            const estado = urlParams.get('estado') || '';
            
            // Poblar campos ocultos con los filtros
            const hiddenBusqueda = document.getElementById('hiddenBusqueda');
            const hiddenProveedor = document.getElementById('hiddenProveedor');
            const hiddenEstado = document.getElementById('hiddenEstado');
            if (hiddenBusqueda) hiddenBusqueda.value = busqueda;
            if (hiddenProveedor) hiddenProveedor.value = proveedor;
            if (hiddenEstado) hiddenEstado.value = estado;
            
            sendOrdenesCompraModal.classList.add('show');
            sendOrdenesCompraModal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
        
        // Función para cerrar el modal
        function cerrarModalEnviarOrdenesCompra() {
            sendOrdenesCompraModal.classList.remove('show');
            sendOrdenesCompraModal.style.display = 'none';
            document.body.style.overflow = '';
        }
        
        // Event listener para el botón
        openSendOrdenesCompraBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            abrirModalEnviarOrdenesCompra();
        });
        
        if (closeSendOrdenesCompraBtn) {
            closeSendOrdenesCompraBtn.addEventListener('click', cerrarModalEnviarOrdenesCompra);
        }
        
        if (cancelSendOrdenesCompraBtn) {
            cancelSendOrdenesCompraBtn.addEventListener('click', cerrarModalEnviarOrdenesCompra);
        }
        
        // Cerrar al hacer clic fuera del modal
        sendOrdenesCompraModal.addEventListener('click', function(e) {
            if (e.target === sendOrdenesCompraModal) {
                cerrarModalEnviarOrdenesCompra();
            }
        });
        
        // Cerrar con tecla ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && sendOrdenesCompraModal && sendOrdenesCompraModal.classList.contains('show')) {
                cerrarModalEnviarOrdenesCompra();
            }
        });
    });
</script>

<style>
    thead th {
        position: relative;
        user-select: none;
    }
    thead th:hover {
        background-color: rgba(111, 78, 55, 0.1) !important;
    }
    thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: #6F4E37;
    }
    thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: #6F4E37;
    }
</style>

<!-- ===================== Modal: Enviar Órdenes de Compra por Correo ===================== -->
<div id="sendOrdenesCompraModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte de Órdenes de Compra por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/logistica/OrdenCompraReporteServlet" id="formEnviarOrdenesCompra">
            <input type="hidden" name="action" value="enviar">
            <input type="hidden" name="busqueda" id="hiddenBusqueda" value="">
            <input type="hidden" name="proveedor" id="hiddenProveedor" value="">
            <input type="hidden" name="estado" id="hiddenEstado" value="">
            
            <div class="modal-body">
                <div class="form-group">
                    <label for="modalEmailDestino">
                        <i class="fas fa-envelope"></i>
                        Email de Destino <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email_destino" 
                           id="modalEmailDestino" 
                           placeholder="correo@ejemplo.com" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el correo electrónico donde deseas recibir el reporte.</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalAsunto">
                        <i class="fas fa-tag"></i>
                        Asunto del Correo
                    </label>
                    <input type="text" 
                           name="asunto" 
                           id="modalAsunto" 
                           value="Reporte de Órdenes de Compra - Logística - TELITO BODEGUERO" 
                           placeholder="Asunto del correo">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Si no especificas un asunto, se usará uno por defecto.</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalMensaje">
                        <i class="fas fa-comment"></i>
                        Mensaje Adicional (Opcional)
                    </label>
                    <textarea name="mensaje" 
                              id="modalMensaje" 
                              rows="4" 
                              placeholder="Escribe un mensaje personalizado que aparecerá en el correo..."></textarea>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Puedes agregar un mensaje personalizado que aparecerá en el cuerpo del correo.</span>
                    </div>
                </div>
                
                <div class="alert alert-warning" style="background: rgba(255,193,7,0.1); border-left: 4px solid #ffc107; border-radius: 8px; padding: 12px 15px; margin-top: 15px; font-size: 0.9rem;">
                    <i class="fas fa-exclamation-triangle me-2" style="color: #ffc107;"></i>
                    <strong>Nota:</strong> El archivo Excel se generará con los mismos filtros que tienes aplicados en la tabla de órdenes de compra. 
                    Incluirá todas las columnas (Número, Proveedor, Producto, Cantidad, Monto Total, Estado, etc.) y tendrá filtros automáticos habilitados.
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-paper-plane"></i>
                    Enviar Reporte
                </button>
            </div>
        </form>
    </div>
</div>

</body>
</html>