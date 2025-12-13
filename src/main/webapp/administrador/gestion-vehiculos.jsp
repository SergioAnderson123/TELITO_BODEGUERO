<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Vehículos"/>
    </jsp:include>
    <style>
        /* Estilos para stat-cards */
        .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 40px; }
        .stat-card {
            background-color: #ffffff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }
        .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: #6c757d; font-weight: 600; }
        .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: #00a896; }
        @media (max-width: 768px) {
            .stats-container { grid-template-columns: 1fr; }
        }
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
    </style>
    <style>
        /* Estilos mejorados para el dropdown de acciones */
        .dropdown-menu {
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            border: 1px solid rgba(0, 0, 0, 0.08) !important;
            border-radius: 8px !important;
            min-width: 180px !important;
            font-size: 0.9rem !important;
            padding: 0.5rem 0 !important;
            animation: fadeInDown 0.2s ease-out;
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
        
        /* Mejora del botón de acciones */
        .btn-outline-success:hover {
            transform: scale(1.05);
        }
        
        /* Estilos para el botón Agregar Vehículo */
        .btn-agregar-vehiculo {
            transition: all 0.3s ease;
        }
        
        .btn-agregar-vehiculo:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(40, 167, 69, 0.4) !important;
        }
        
        /* Eliminar scroll horizontal de la tabla */
        #vehiculoTable {
            width: 100% !important;
            max-width: 100% !important;
        }
        
        #vehiculoTable th,
        #vehiculoTable td {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        /* Permitir que el dropdown sea visible en la columna de acciones */
        #vehiculoTable td:last-child {
            overflow: visible !important;
            position: relative;
        }
        
        #vehiculoTable td:last-child .dropdown {
            position: static;
        }
        
        #vehiculoTable td:last-child .dropdown-menu {
            position: absolute !important;
            right: 0 !important;
            left: auto !important;
            z-index: 1050 !important;
            transform: none !important;
        }
        
        /* Eliminar scrollbar vertical no deseado */
        .card-body {
            overflow: visible !important;
        }
        
        /* Eliminar scrollbars de DataTables */
        .dataTables_wrapper {
            overflow: visible !important;
        }
        
        .dataTables_wrapper .dataTables_scroll {
            overflow: visible !important;
        }
        
        .dataTables_wrapper .dataTables_scrollBody {
            overflow: visible !important;
        }
        
        /* Contenedor de la tabla sin scrollbars */
        div[style*="overflow"] {
            overflow: visible !important;
        }
        
        /* Asegurar que el contenedor no corte el dropdown pero sin scrollbars */
        .table-responsive {
            overflow: visible !important;
        }
        
        /* ===================== Estilos para Modal de Agregar Vehículo ===================== */
        #addVehiculoModal.modal { 
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
        #addVehiculoModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #addVehiculoModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 600px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        #addVehiculoModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #addVehiculoModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #addVehiculoModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #addVehiculoModal .modal-close { 
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
        #addVehiculoModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #addVehiculoModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 160px);
        }
        #addVehiculoModal .form-group {
            margin-bottom: 1.25rem;
        }
        #addVehiculoModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #addVehiculoModal .form-group label i {
            color: #00a896;
            font-size: 0.85rem;
        }
        #addVehiculoModal .form-group input {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
            box-sizing: border-box;
        }
        #addVehiculoModal .form-group input:focus {
            border-color: #00a896;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #addVehiculoModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #addVehiculoModal .form-hint i {
            color: #00a896;
            margin-top: 2px;
        }
        #addVehiculoModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #addVehiculoModal .modal-footer button {
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
        #addVehiculoModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #addVehiculoModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #addVehiculoModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(40,167,69,0.3);
        }
        #addVehiculoModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(40,167,69,0.4);
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
        @media (max-width: 768px) {
            #addVehiculoModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #addVehiculoModal.show {
                padding: 10px;
            }
        }
        
        /* ===================== Estilos para Modal de Enviar por Correo ===================== */
        #sendEmailModal.modal { 
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
        #sendEmailModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #sendEmailModal .modal-content { 
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
        #sendEmailModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #sendEmailModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #sendEmailModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #sendEmailModal .modal-close { 
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
        #sendEmailModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #sendEmailModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #sendEmailModal .form-group {
            margin-bottom: 1.25rem;
        }
        #sendEmailModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #sendEmailModal .form-group label i {
            color: #00a896;
            font-size: 0.85rem;
        }
        #sendEmailModal .form-group input,
        #sendEmailModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
            box-sizing: border-box;
        }
        #sendEmailModal .form-group input:focus,
        #sendEmailModal .form-group textarea:focus {
            border-color: #00a896;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #sendEmailModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #sendEmailModal .form-hint i {
            color: #00a896;
            margin-top: 2px;
        }
        #sendEmailModal .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            padding: 20px 25px;
            border-top: 1px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #sendEmailModal .modal-footer button {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #sendEmailModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            color: white;
        }
        #sendEmailModal .modal-footer button[type="submit"]:hover {
            background: linear-gradient(135deg, #028f80 0%, #02796b 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #sendEmailModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #sendEmailModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
        }
        #sendEmailModal .alert {
            margin-top: 1rem;
            padding: 12px 16px;
            border-radius: 8px;
            border-left: 4px solid #00a896;
            background: #e8f5f4;
            color: #006d77;
        }
        #sendEmailModal .alert i {
            color: #00a896;
        }
        @media (max-width: 768px) {
            #sendEmailModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #sendEmailModal.show {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/header_admin.jsp"/>
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Vehiculos"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <!-- Encabezado -->
                <div class="row">
                    <div class="col-12">
                        <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Gestión de Vehículos</h2>
                                    <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra los vehículos del sistema de transporte.</p>
                                </div>
                                <div class="d-flex gap-2 flex-wrap">
                                    <a href="${pageContext.request.contextPath}/administrador/VehiculoReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                        <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                                    </a>
                                    <button type="button" id="openSendEmailModalBtn" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                        <i class="fas fa-envelope me-1"></i>Enviar por Correo
                                    </button>
                                    <button type="button" id="openAddVehiculoModalBtn" class="btn btn-sm shadow-sm btn-agregar-vehiculo" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                                        <i class="fas fa-plus me-1"></i>Agregar Vehículo
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%
                    // Obtener estadísticas del servlet
                    Integer totalVehiculosAttr = (Integer) request.getAttribute("totalVehiculos");
                    Integer vehiculosConPlanesAttr = (Integer) request.getAttribute("vehiculosConPlanes");
                    Integer vehiculosSinPlanesAttr = (Integer) request.getAttribute("vehiculosSinPlanes");
                    int totalVehiculos = (totalVehiculosAttr != null) ? totalVehiculosAttr : 0;
                    int vehiculosConPlanes = (vehiculosConPlanesAttr != null) ? vehiculosConPlanesAttr : 0;
                    int vehiculosSinPlanes = (vehiculosSinPlanesAttr != null) ? vehiculosSinPlanesAttr : 0;
                %>

                <!-- ===================== Tarjetas de estadísticas ===================== -->
                <div class="stats-container">
                    <div class="stat-card">
                        <h3>Total de Vehículos</h3>
                        <p><%= totalVehiculos %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Con Planes Asignados</h3>
                        <p><%= vehiculosConPlanes %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Sin Planes Asignados</h3>
                        <p><%= vehiculosSinPlanes %></p>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                    <form action="${pageContext.request.contextPath}/administrador/VehiculoServlet" method="GET" id="filterForm">
                        <input type="hidden" name="action" value="listar">
                        <input type="hidden" name="size" value="${size != null ? size : 5}">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-xl-6 col-lg-6 col-md-12 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Placa, marca o modelo..." value="${busqueda != null ? busqueda : ''}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-xl-6 col-lg-6 col-md-12 col-sm-12 d-flex align-items-end">
                                <a href="${pageContext.request.contextPath}/administrador/VehiculoServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-sync-alt me-1"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Mensajes de alerta -->
                <c:if test="${not empty sessionScope.mensaje}">
                    <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert">
                        ${sessionScope.mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="mensaje" scope="session"/>
                    <c:remove var="tipoMensaje" scope="session"/>
                </c:if>

                <!-- ===================== Card: Tabla de vehículos ===================== -->
                <div class="row">
                    <div class="col-12">
                        <div class="table-card shadow-sm">
                            <div class="card-header" style="padding: 0.5rem 0.75rem;">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Tabla de Vehículos</h5>
                                        <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los vehículos del sistema</small>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body" style="padding: 0.75rem;">
                                <div class="table-responsive">
                                    <table id="vehiculoTable" class="table table-hover align-middle mb-0 datatable-server-side" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                        <thead class="table-light">
                                        <tr>
                                            <th style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">#</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-id-card me-1"></i>Placa</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-industry me-1"></i>Marca</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-car me-1"></i>Modelo</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-weight me-1"></i>Capacidad (Kg)</th>
                                            <th class="text-end fw-semibold text-success" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-cog me-1"></i>Acciones</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <%
                                            Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                            Integer sizeObj = (Integer) request.getAttribute("size");
                                            int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                            int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                            int contador = (currentPageInt - 1) * sizeInt + 1;
                                        %>
                                        <c:forEach var="vehiculo" items="${listaVehiculos}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td class="text-muted" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= contador++ %></td>
                                                <td style="padding: 0.35rem 0.5rem;">
                                                    <span class="badge bg-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-id-card me-1"></i>${vehiculo.placa}
                                                    </span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;" class="fw-semibold">${vehiculo.marca}</td>
                                                <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;" class="fw-semibold">${vehiculo.modelo}</td>
                                                <td style="padding: 0.35rem 0.5rem;">
                                                    <span class="badge bg-info-subtle text-info border border-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-weight me-1"></i>${vehiculo.capacidadKg} kg
                                                    </span>
                                                </td>
                                                <td class="text-end" style="padding: 0.35rem 0.5rem;">
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-outline-success shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <ul class="dropdown-menu dropdown-menu-end shadow-lg">
                                                            <li>
                                                                <a class="dropdown-item text-primary" href="${pageContext.request.contextPath}/administrador/VehiculoServlet?action=editar&id=${vehiculo.idVehiculo}">
                                                                    <i class="fas fa-edit"></i> Editar
                                                                </a>
                                                            </li>
                                                            <li><hr class="dropdown-divider"></li>
                                                            <li>
                                                                <a class="dropdown-item text-danger" href="#" data-id="${vehiculo.idVehiculo}" data-placa="${vehiculo.placa}" onclick="confirmarEliminacion(this.dataset.id, this.dataset.placa)">
                                                                    <i class="fas fa-trash-alt"></i> Eliminar
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <%-- Incluir componente de paginación --%>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <jsp:include page="/administrador/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<!-- Modal de Enviar por Correo -->
<div id="sendEmailModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="${pageContext.request.contextPath}/administrador/VehiculoReporteServlet" id="formEnviarCorreo">
            <input type="hidden" name="action" value="enviar">
            <input type="hidden" name="busqueda" id="modalBusqueda" value="">
            
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
                           value="Reporte de Vehículos - TELITO BODEGUERO" 
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
                
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <strong>Nota:</strong> El archivo Excel se generará con todos los vehículos del sistema. 
                    Incluirá todas las columnas (Placa, Marca, Modelo, Capacidad) y tendrá filtros automáticos habilitados.
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

<!-- Modal de Agregar Vehículo -->
<div id="addVehiculoModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-truck"></i> Agregar Nuevo Vehículo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="${pageContext.request.contextPath}/administrador/VehiculoServlet" id="formAgregarVehiculo">
            <input type="hidden" name="action" value="guardar">
            
            <div class="modal-body">
                <div class="form-group">
                    <label for="modalPlaca">
                        <i class="fas fa-id-card"></i>
                        Placa <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="placa" 
                           id="modalPlaca" 
                           placeholder="Ej: ABC123" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la placa del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalMarca">
                        <i class="fas fa-industry"></i>
                        Marca
                    </label>
                    <input type="text" 
                           name="marca" 
                           id="modalMarca" 
                           placeholder="Ej: Toyota, Nissan">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la marca del vehículo (opcional)</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalModelo">
                        <i class="fas fa-car"></i>
                        Modelo
                    </label>
                    <input type="text" 
                           name="modelo" 
                           id="modalModelo" 
                           placeholder="Ej: Hiace, NV350">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el modelo del vehículo (opcional)</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalCapacidadKg">
                        <i class="fas fa-weight"></i>
                        Capacidad (Kg) <span class="text-danger">*</span>
                    </label>
                    <input type="number" 
                           name="capacidadKg" 
                           id="modalCapacidadKg" 
                           placeholder="Ej: 2500" 
                           min="0"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la capacidad máxima en kilogramos</span>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-save"></i>
                    Guardar Vehículo
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        
        // Aplicar filtros al presionar Enter en el campo de búsqueda
        if (searchInput && filterForm) {
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    filterForm.submit();
                }
            });
        }
        
        // ===================== Manejo del Modal de Agregar Vehículo =====================
        const addVehiculoModal = document.getElementById('addVehiculoModal');
        const openAddVehiculoModalBtn = document.getElementById('openAddVehiculoModalBtn');
        const closeAddVehiculoModalBtn = document.querySelector('#addVehiculoModal .modal-close');
        const cancelAddVehiculoModalBtn = document.querySelector('#addVehiculoModal .modal-cancel');
        
        // Función para abrir el modal de agregar vehículo
        function abrirModalAgregarVehiculo() {
            if (addVehiculoModal) {
                // Limpiar formulario
                document.getElementById('modalPlaca').value = '';
                document.getElementById('modalMarca').value = '';
                document.getElementById('modalModelo').value = '';
                document.getElementById('modalCapacidadKg').value = '';
                
                addVehiculoModal.classList.add('show');
                addVehiculoModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            } else {
                console.error('Modal addVehiculoModal no encontrado');
            }
        }
        
        // Función para cerrar el modal de agregar vehículo
        function cerrarModalAgregarVehiculo() {
            if (addVehiculoModal) {
                addVehiculoModal.classList.remove('show');
                addVehiculoModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Event listeners para el modal de agregar vehículo
        if (openAddVehiculoModalBtn) {
            openAddVehiculoModalBtn.addEventListener('click', function(e) {
                e.preventDefault();
                abrirModalAgregarVehiculo();
            });
        } else {
            console.error('Botón openAddVehiculoModalBtn no encontrado');
        }
        
        if (closeAddVehiculoModalBtn) {
            closeAddVehiculoModalBtn.addEventListener('click', cerrarModalAgregarVehiculo);
        }
        
        if (cancelAddVehiculoModalBtn) {
            cancelAddVehiculoModalBtn.addEventListener('click', cerrarModalAgregarVehiculo);
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (addVehiculoModal) {
            addVehiculoModal.addEventListener('click', function(event) {
                if (event.target === addVehiculoModal) {
                    cerrarModalAgregarVehiculo();
                }
            });
        }
        
        // Cerrar modal con la tecla ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && addVehiculoModal && addVehiculoModal.classList.contains('show')) {
                cerrarModalAgregarVehiculo();
            }
        });
        
        // ===================== Manejo del Modal de Enviar por Correo =====================
        const sendEmailModal = document.getElementById('sendEmailModal');
        const openSendEmailModalBtn = document.getElementById('openSendEmailModalBtn');
        const closeSendEmailModalBtn = document.querySelector('#sendEmailModal .modal-close');
        const cancelSendEmailModalBtn = document.querySelector('#sendEmailModal .modal-cancel');
        
        // Función para obtener los filtros actuales de la URL
        function obtenerFiltrosActuales() {
            const urlParams = new URLSearchParams(window.location.search);
            const busqueda = urlParams.get('busqueda') || '';
            return { busqueda };
        }
        
        // Función para abrir el modal de enviar correo
        function abrirModalEnviarCorreo() {
            if (sendEmailModal) {
                const filtros = obtenerFiltrosActuales();
                
                // Actualizar campos hidden del formulario
                const busquedaInput = document.getElementById('modalBusqueda');
                if (busquedaInput) busquedaInput.value = filtros.busqueda;
                
                // Limpiar formulario
                document.getElementById('modalEmailDestino').value = '';
                document.getElementById('modalAsunto').value = 'Reporte de Vehículos - TELITO BODEGUERO';
                document.getElementById('modalMensaje').value = '';
                
                sendEmailModal.classList.add('show');
                sendEmailModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            } else {
                console.error('Modal sendEmailModal no encontrado');
            }
        }
        
        // Función para cerrar el modal de enviar correo
        function cerrarModalEnviarCorreo() {
            if (sendEmailModal) {
                sendEmailModal.classList.remove('show');
                sendEmailModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Event listeners para el modal de enviar correo
        if (openSendEmailModalBtn) {
            openSendEmailModalBtn.addEventListener('click', function(e) {
                e.preventDefault();
                abrirModalEnviarCorreo();
            });
        } else {
            console.error('Botón openSendEmailModalBtn no encontrado');
        }
        
        if (closeSendEmailModalBtn) {
            closeSendEmailModalBtn.addEventListener('click', cerrarModalEnviarCorreo);
        }
        
        if (cancelSendEmailModalBtn) {
            cancelSendEmailModalBtn.addEventListener('click', cerrarModalEnviarCorreo);
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (sendEmailModal) {
            sendEmailModal.addEventListener('click', function(event) {
                if (event.target === sendEmailModal) {
                    cerrarModalEnviarCorreo();
                }
            });
        }
        
        // Cerrar modal con la tecla ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && sendEmailModal && sendEmailModal.classList.contains('show')) {
                cerrarModalEnviarCorreo();
            }
        });
    });

    function confirmarEliminacion(id, placa) {
        showConfirm(
            '¿Estás seguro de eliminar el vehículo con placa "' + placa + '"? Esta acción no se puede deshacer.',
            function() {
                window.location.href = '${pageContext.request.contextPath}/administrador/VehiculoServlet?action=eliminar&id=' + id;
            },
            'Confirmar eliminación'
        );
    }
</script>

<!-- Bootstrap JS ya está incluido en footer.jsp -->
</body>
</html>

