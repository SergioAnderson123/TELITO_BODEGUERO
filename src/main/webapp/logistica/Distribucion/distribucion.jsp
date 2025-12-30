<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.PlanTransporteBean" %>
<%@ page import="com.example.telito.logistica.beans.ConductorBean" %>
<%@ page import="com.example.telito.logistica.beans.LoteBean" %>
<%@ page import="com.example.telito.logistica.beans.VehiculoBean" %>
<%@ page import="com.example.telito.logistica.beans.DistritoBean" %>
<%@ page import="com.example.telito.logistica.beans.ProveedorBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Distribucion y Transporte"/>
    </jsp:include>
    <!-- Select2 CSS para mejorar el dropdown de búsqueda -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />
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
            border: 1px solid #dee2e6 !important;
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
        #sendDistribucionModal.modal { 
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
        #sendDistribucionModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #sendDistribucionModal .modal-content { 
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
        #sendDistribucionModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important; 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(111, 78, 55, 0.2);
        }
        #sendDistribucionModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #sendDistribucionModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #sendDistribucionModal .modal-close { 
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
        #sendDistribucionModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #sendDistribucionModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #sendDistribucionModal .form-group {
            margin-bottom: 1.25rem;
        }
        #sendDistribucionModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #sendDistribucionModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #sendDistribucionModal .form-group input,
        #sendDistribucionModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #sendDistribucionModal .form-group input:focus,
        #sendDistribucionModal .form-group textarea:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(111, 78, 55, 0.1);
        }
        #sendDistribucionModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #sendDistribucionModal .form-hint i {
            color: #6F4E37;
            margin-top: 2px;
        }
        #sendDistribucionModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #sendDistribucionModal .modal-footer button {
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
        #sendDistribucionModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #sendDistribucionModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #sendDistribucionModal .modal-footer button[type="submit"] {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(111, 78, 55, 0.3);
        }
        #sendDistribucionModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(111, 78, 55, 0.4);
        }
        @media (max-width: 768px) {
            #sendDistribucionModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #sendDistribucionModal.show {
                padding: 10px;
            }
        }
        
        /* ===================== Estilos para Modal de Agregar Plan ===================== */
        #agregarPlanModal.modal { 
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
        #agregarPlanModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #agregarPlanModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 800px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        #agregarPlanModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important; 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(111, 78, 55, 0.2);
        }
        #agregarPlanModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #agregarPlanModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #agregarPlanModal .modal-close-plan { 
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
        #agregarPlanModal .modal-close-plan:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #agregarPlanModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #agregarPlanModal .form-group {
            margin-bottom: 1.25rem;
        }
        #agregarPlanModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #agregarPlanModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #agregarPlanModal .form-group input,
        #agregarPlanModal .form-group select,
        #agregarPlanModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #agregarPlanModal .form-group input:focus,
        #agregarPlanModal .form-group select:focus,
        #agregarPlanModal .form-group textarea:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(111, 78, 55, 0.1);
        }
        
        /* ===================== Estilos para Select2 en el modal ===================== */
        #agregarPlanModal .select2-container {
            width: 100% !important;
        }
        #agregarPlanModal .select2-selection--single {
            height: auto !important;
            min-height: 48px;
            border: 2px solid #e9ecef !important;
            border-radius: 8px !important;
            padding: 10px 14px !important;
            background: white !important;
            transition: all 0.3s ease !important;
        }
        #agregarPlanModal .select2-selection--single:focus,
        #agregarPlanModal .select2-container--open .select2-selection--single {
            border-color: #6F4E37 !important;
            box-shadow: 0 0 0 3px rgba(111, 78, 55, 0.1) !important;
        }
        #agregarPlanModal .select2-selection__rendered {
            padding: 0 !important;
            line-height: 1.5 !important;
            color: #2b2d42 !important;
            font-size: 0.95rem !important;
        }
        #agregarPlanModal .select2-selection__arrow {
            height: 100% !important;
            right: 12px !important;
        }
        #agregarPlanModal .select2-selection__arrow b {
            border-color: #6c757d transparent transparent transparent !important;
            border-width: 6px 5px 0 5px !important;
        }
        #agregarPlanModal .select2-container--open .select2-selection__arrow b {
            border-color: transparent transparent #6c757d transparent !important;
            border-width: 0 5px 6px 5px !important;
        }
        #agregarPlanModal .select2-dropdown {
            border: 2px solid #e9ecef !important;
            border-radius: 8px !important;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15) !important;
            z-index: 9999 !important;
            margin-top: 4px !important;
        }
        #agregarPlanModal .select2-search--dropdown {
            padding: 12px !important;
            background: #f8f9fa !important;
            border-bottom: 2px solid #e9ecef !important;
        }
        #agregarPlanModal .select2-search--dropdown .select2-search__field {
            border: 2px solid #e9ecef !important;
            border-radius: 6px !important;
            padding: 8px 12px !important;
            font-size: 0.9rem !important;
            transition: all 0.3s ease !important;
        }
        #agregarPlanModal .select2-search--dropdown .select2-search__field:focus {
            border-color: #6F4E37 !important;
            box-shadow: 0 0 0 3px rgba(111, 78, 55, 0.1) !important;
            outline: none !important;
        }
        #agregarPlanModal .select2-results {
            max-height: 250px !important;
            overflow-y: auto !important;
        }
        #agregarPlanModal .select2-results__option {
            padding: 12px 14px !important;
            font-size: 0.95rem !important;
            color: #2b2d42 !important;
            transition: all 0.2s ease !important;
        }
        #agregarPlanModal .select2-results__option--highlighted {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important;
            color: #ffffff !important;
        }
        #agregarPlanModal .select2-results__option--highlighted * {
            color: #ffffff !important;
        }
        #agregarPlanModal .select2-results__option[aria-selected="true"] {
            background-color: rgba(111, 78, 55, 0.1) !important;
            color: #6F4E37 !important;
            font-weight: 600 !important;
        }
        /* Asegurar que el texto sea visible en todos los estados */
        #agregarPlanModal .select2-results__option:hover {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%) !important;
            color: #ffffff !important;
        }
        #agregarPlanModal .select2-results__option:hover * {
            color: #ffffff !important;
        }
        /* Scrollbar personalizado para el dropdown */
        #agregarPlanModal .select2-results::-webkit-scrollbar {
            width: 8px;
        }
        #agregarPlanModal .select2-results::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }
        #agregarPlanModal .select2-results::-webkit-scrollbar-thumb {
            background: #6F4E37;
            border-radius: 4px;
        }
        #agregarPlanModal .select2-results::-webkit-scrollbar-thumb:hover {
            background: #8B6F47;
        }
        /* Ocultar campo de búsqueda en el dropdown de distrito */
        #agregarPlanModal .distrito-select + .select2-container .select2-search--dropdown {
            display: none !important;
        }
        #agregarPlanModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #agregarPlanModal .form-hint i {
            color: #6F4E37;
            margin-top: 2px;
        }
        #agregarPlanModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #agregarPlanModal .modal-footer button {
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
        #agregarPlanModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #agregarPlanModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #agregarPlanModal .modal-footer button[type="submit"] {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(111, 78, 55, 0.3);
        }
        #agregarPlanModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(111, 78, 55, 0.4);
        }
        @media (max-width: 768px) {
            #agregarPlanModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #agregarPlanModal.show {
                padding: 10px;
            }
        }
        /* Estilos para stat-cards */
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Distribucion'/>
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
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Planes de Transporte</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Seguimiento de entregas y análisis de rutas.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <%
                            String busquedaParam = request.getParameter("busqueda");
                            String conductorParam = request.getParameter("conductor");
                            String estadoParam = request.getParameter("estado");
                            String fechaDesdeParam = request.getParameter("fecha_desde");
                            String fechaHastaParam = request.getParameter("fecha_hasta");
                            StringBuilder urlParams = new StringBuilder();
                            if (busquedaParam != null && !busquedaParam.trim().isEmpty()) {
                                urlParams.append("&busqueda=").append(java.net.URLEncoder.encode(busquedaParam, "UTF-8"));
                            }
                            if (conductorParam != null && !conductorParam.trim().isEmpty()) {
                                urlParams.append("&conductor=").append(java.net.URLEncoder.encode(conductorParam, "UTF-8"));
                            }
                            if (estadoParam != null && !estadoParam.trim().isEmpty()) {
                                urlParams.append("&estado=").append(java.net.URLEncoder.encode(estadoParam, "UTF-8"));
                            }
                            if (fechaDesdeParam != null && !fechaDesdeParam.trim().isEmpty()) {
                                urlParams.append("&fecha_desde=").append(java.net.URLEncoder.encode(fechaDesdeParam, "UTF-8"));
                            }
                            if (fechaHastaParam != null && !fechaHastaParam.trim().isEmpty()) {
                                urlParams.append("&fecha_hasta=").append(java.net.URLEncoder.encode(fechaHastaParam, "UTF-8"));
                            }
                            String urlBase = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=exportar" + urlParams.toString();
                            String urlEnviar = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=formEnviar" + urlParams.toString();
                        %>
                        <a href="<%= urlBase %>" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #D4A574 0%, #C9A87A 100%); color: white; border: none;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <button type="button" id="openSendDistribucionModalBtn" class="btn btn-sm text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #E8B86D 0%, #D4A574 100%); border: none;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </button>
                        <button type="button" id="openAgregarPlanModalBtn" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); border: none; color: white; font-weight: 600;">
                            <i class="fas fa-plus me-1"></i>Agregar Plan
                        </button>
                    </div>
                </div>
            </div>

            <%
                // Obtener estadísticas del servlet
                Integer totalPlanesAttr = (Integer) request.getAttribute("totalPlanes");
                Integer planesEnRutaAttr = (Integer) request.getAttribute("planesEnRuta");
                Integer planesEntregadosAttr = (Integer) request.getAttribute("planesEntregados");
                Integer planesCanceladosAttr = (Integer) request.getAttribute("planesCancelados");
                Integer planesSalidaAttr = (Integer) request.getAttribute("planesSalida");
                Integer planesPendientesAttr = (Integer) request.getAttribute("planesPendientes");
                int totalPlanes = (totalPlanesAttr != null) ? totalPlanesAttr : 0;
                int planesEnRuta = (planesEnRutaAttr != null) ? planesEnRutaAttr : 0;
                int planesEntregados = (planesEntregadosAttr != null) ? planesEntregadosAttr : 0;
                int planesCancelados = (planesCanceladosAttr != null) ? planesCanceladosAttr : 0;
                int planesSalida = (planesSalidaAttr != null) ? planesSalidaAttr : 0;
                int planesPendientes = (planesPendientesAttr != null) ? planesPendientesAttr : 0;
            %>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="row g-2 mb-3" style="display: flex; flex-wrap: nowrap;">
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Total de Planes</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= totalPlanes %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Pendiente</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= planesPendientes %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Salida</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= planesSalida %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">En Ruta</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= planesEnRuta %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Entregados</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= planesEntregados %></p>
                    </div>
                </div>
                <div class="col" style="flex: 1 1 0%; min-width: 0;">
                    <div class="stat-card" style="background-color: #FFFEF9; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                        <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6F4E37; font-weight: 600;">Cancelado</h3>
                        <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= planesCancelados %></p>
                    </div>
                </div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros ===================== -->
            <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px; background-color: #FFFEF9 !important; border: 1px solid #dee2e6 !important;">
                <form action="${pageContext.request.contextPath}/planes-transporte" method="GET" id="filterForm">
                    <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                    <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                        <div class="col-md-2">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                            <div class="input-group">
                                <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="N° Viaje, Placa, Lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <button class="btn btn-sm shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem; background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); color: white; border: none;">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user me-1"></i>Conductor</label>
                            <select class="form-select form-select-sm shadow-sm" name="conductor" id="conductorFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="" ${empty param.conductor ? 'selected' : ''}>Todos</option>
                                <% ArrayList<ConductorBean> listaConductores = (ArrayList<ConductorBean>) request.getAttribute("listaConductores");
                                    if(listaConductores != null){
                                        for(ConductorBean conductor : listaConductores){ 
                                            String conductorIdStr = String.valueOf(conductor.getId());
                                            String paramConductor = request.getParameter("conductor") != null ? request.getParameter("conductor") : "";
                                            boolean isSelected = conductorIdStr.equals(paramConductor);
                                %>
                                <option value="<%= conductor.getId() %>" <%= isSelected ? "selected" : "" %>>
                                    <%= conductor.getNombreCompleto() %>
                                </option>
                                <%  }
                                } %>
                            </select>
                        </div>
                        <div class="col-xl-2 col-lg-3 col-md-6 col-sm-12">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                            <select class="form-select form-select-sm shadow-sm" name="estado" id="estadoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                <option value="Pendiente" ${param.estado == 'Pendiente' ? 'selected' : ''}>Pendiente</option>
                                <option value="Salida" ${param.estado == 'Salida' ? 'selected' : ''}>Salida</option>
                                <option value="En Ruta" ${param.estado == 'En Ruta' ? 'selected' : ''}>En Ruta</option>
                                <option value="Entregado" ${param.estado == 'Entregado' ? 'selected' : ''}>Entregado</option>
                                <option value="Cancelado" ${param.estado == 'Cancelado' ? 'selected' : ''}>Cancelado</option>
                            </select>
                        </div>
                        <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Desde</label>
                            <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_desde" id="fechaDesdeFilter" value="${param.fecha_desde}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        </div>
                        <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Hasta</label>
                            <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_hasta" id="fechaHastaFilter" value="${param.fecha_hasta}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <a href="${pageContext.request.contextPath}/planes-transporte" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                            </a>
                        </div>
                    </div>
                </form>
            </div>

            <!-- ===================== Card: Tabla de planes de transporte ===================== -->
            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.25rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Tabla de Transportes</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los planes de transporte</small>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">

                            <div class="table-responsive">
                                <table id="distribucionTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                    <thead class="table-light">
                                    <tr>
                                        <th onclick="sortTable(0)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-hashtag me-1"></i>N° de Viaje
                                        </th>
                                        <th onclick="sortTable(1)" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Producto
                                        </th>
                                        <th onclick="sortTable(2)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-barcode me-1"></i>Lote
                                        </th>
                                        <th onclick="sortTable(3)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-toggle-on me-1"></i>Estado
                                        </th>
                                        <th onclick="sortTable(4)" style="width: 13%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-user me-1"></i>Conductor
                                        </th>
                                        <th onclick="sortTable(5)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-car me-1"></i>Placa
                                        </th>
                                        <th onclick="sortTable(6)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-calendar me-1"></i>Fecha de Entrega
                                        </th>
                                        <th onclick="sortTable(7)" style="width: 14%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer; text-align: center;" class="fw-semibold">
                                            <i class="fas fa-map-marker-alt me-1"></i>Destino
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<PlanTransporteBean> listaPlanes = (ArrayList<PlanTransporteBean>) request.getAttribute("listaPlanes");
                                        
                                        Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                        Integer sizeObj = (Integer) request.getAttribute("size");
                                        int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                        int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                        
                                        if (listaPlanes != null && !listaPlanes.isEmpty()) {
                                            for (PlanTransporteBean plan : listaPlanes) {
                                    %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;"><strong><%= plan.getNumeroViaje() %></strong></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;"><%= plan.getNombreProducto() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;"><%= plan.getCodigoLote() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;">
                                            <% if ("Entregado".equals(plan.getEstado())) { %>
                                            <span class="badge shadow-sm" style="background-color: #c8e6c9; color: #2e7d32; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-check-circle me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("En Ruta".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-truck me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("Pendiente".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-clock me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("Salida".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-arrow-right me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("Cancelado".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-times-circle me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else { %>
                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-question-circle me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } %>
                                        </td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;"><%= plan.getNombreConductor() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;"><%= plan.getPlacaVehiculo() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;"><%= plan.getFechaEntrega() != null ? plan.getFechaEntrega() : "-" %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem; text-align: center;"><%= plan.getNombreDestino() != null ? plan.getNombreDestino() : "-" %></td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center py-5">
                                            <div class="text-muted">
                                                <i class="fas fa-road fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No se encontraron planes con los filtros aplicados.</p>
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
                                    request.setAttribute("param2Name", "conductor");
                                    request.setAttribute("param2Value", request.getAttribute("conductorFiltro"));
                                    request.setAttribute("param3Name", "estado");
                                    request.setAttribute("param3Value", request.getAttribute("estadoFiltro"));
                                    request.setAttribute("param4Name", "fecha_desde");
                                    request.setAttribute("param4Value", request.getAttribute("fechaDesdeFiltro"));
                                    request.setAttribute("param5Name", "fecha_hasta");
                                    request.setAttribute("param5Value", request.getAttribute("fechaHastaFiltro"));
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const conductorFilter = document.getElementById('conductorFilter');
        const estadoFilter = document.getElementById('estadoFilter');
        const fechaDesdeFilter = document.getElementById('fechaDesdeFilter');
        const fechaHastaFilter = document.getElementById('fechaHastaFilter');
        
        // Aplicar filtros cuando cambien los selects
        if (conductorFilter) {
            conductorFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (estadoFilter) {
            estadoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        // Aplicar filtros cuando cambien las fechas
        if (fechaDesdeFilter) {
            fechaDesdeFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (fechaHastaFilter) {
            fechaHastaFilter.addEventListener('change', function() {
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
        const table = document.getElementById('distribucionTable');
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
    
    // ===================== Modal: Enviar Distribución y Transporte por Correo =====================
    document.addEventListener('DOMContentLoaded', function() {
        const sendDistribucionModal = document.getElementById('sendDistribucionModal');
        const openSendDistribucionBtn = document.getElementById('openSendDistribucionModalBtn');
        
        if (!sendDistribucionModal || !openSendDistribucionBtn) {
            console.error('No se encontraron los elementos del modal de Enviar Distribución');
            return;
        }
        
        const closeSendDistribucionBtn = sendDistribucionModal.querySelector('.modal-close');
        const cancelSendDistribucionBtn = sendDistribucionModal.querySelector('.modal-cancel');
        
        // Función para abrir el modal
        function abrirModalEnviarDistribucion() {
            // Obtener filtros actuales de la URL
            const urlParams = new URLSearchParams(window.location.search);
            const busqueda = urlParams.get('busqueda') || '';
            const conductor = urlParams.get('conductor') || '';
            const estado = urlParams.get('estado') || '';
            const fechaDesde = urlParams.get('fecha_desde') || '';
            const fechaHasta = urlParams.get('fecha_hasta') || '';
            
            // Poblar campos ocultos con los filtros
            const hiddenBusqueda = document.getElementById('hiddenBusqueda');
            const hiddenConductor = document.getElementById('hiddenConductor');
            const hiddenEstado = document.getElementById('hiddenEstado');
            const hiddenFechaDesde = document.getElementById('hiddenFechaDesde');
            const hiddenFechaHasta = document.getElementById('hiddenFechaHasta');
            if (hiddenBusqueda) hiddenBusqueda.value = busqueda;
            if (hiddenConductor) hiddenConductor.value = conductor;
            if (hiddenEstado) hiddenEstado.value = estado;
            if (hiddenFechaDesde) hiddenFechaDesde.value = fechaDesde;
            if (hiddenFechaHasta) hiddenFechaHasta.value = fechaHasta;
            
            sendDistribucionModal.classList.add('show');
            sendDistribucionModal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
        
        // Función para cerrar el modal
        function cerrarModalEnviarDistribucion() {
            sendDistribucionModal.classList.remove('show');
            sendDistribucionModal.style.display = 'none';
            document.body.style.overflow = '';
        }
        
        // Event listener para el botón
        openSendDistribucionBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            abrirModalEnviarDistribucion();
        });
        
        if (closeSendDistribucionBtn) {
            closeSendDistribucionBtn.addEventListener('click', cerrarModalEnviarDistribucion);
        }
        
        if (cancelSendDistribucionBtn) {
            cancelSendDistribucionBtn.addEventListener('click', cerrarModalEnviarDistribucion);
        }
        
        // Cerrar al hacer clic fuera del modal
        sendDistribucionModal.addEventListener('click', function(e) {
            if (e.target === sendDistribucionModal) {
                cerrarModalEnviarDistribucion();
            }
        });
        
        // Cerrar con tecla ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && sendDistribucionModal && sendDistribucionModal.classList.contains('show')) {
                cerrarModalEnviarDistribucion();
            }
        });
    });
    
    // ===================== Modal: Agregar Plan de Transporte =====================
    document.addEventListener('DOMContentLoaded', function() {
        const agregarPlanModal = document.getElementById('agregarPlanModal');
        const openAgregarPlanBtn = document.getElementById('openAgregarPlanModalBtn');
        
        if (!agregarPlanModal || !openAgregarPlanBtn) {
            console.error('No se encontraron los elementos del modal de Agregar Plan');
            return;
        }
        
        const closeAgregarPlanBtn = agregarPlanModal.querySelector('.modal-close-plan');
        const cancelAgregarPlanBtn = agregarPlanModal.querySelector('.modal-cancel-plan');
        
        // Función para abrir el modal
        function abrirModalAgregarPlan() {
            agregarPlanModal.classList.add('show');
            agregarPlanModal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            
            // Inicializar Select2 en los dropdowns después de abrir el modal
            setTimeout(function() {
                inicializarSelect2Lote();
                inicializarSelect2Distrito();
            }, 100);
        }
        
        // Función para inicializar Select2 en el dropdown de lotes
        function inicializarSelect2Lote() {
            const selectLote = $('#modalLote');
            if (selectLote.length && !selectLote.hasClass('select2-hidden-accessible')) {
                selectLote.select2({
                    theme: 'bootstrap-5',
                    placeholder: {
                        id: '',
                        text: 'Seleccione un lote...'
                    },
                    allowClear: true,
                    dropdownParent: $('#agregarPlanModal'),
                    width: '100%',
                    language: {
                        noResults: function() {
                            return "No se encontraron lotes";
                        },
                        searching: function() {
                            return "Buscando...";
                        }
                    }
                });
                
                // Evento para actualizar cantidad máxima cuando se selecciona un lote
                selectLote.on('select2:select', function(e) {
                    actualizarInfoLoteModal();
                });
                
                // Evento para limpiar cuando se deselecciona
                selectLote.on('select2:clear', function(e) {
                    actualizarInfoLoteModal();
                });
            }
        }
        
        // Función para actualizar información del lote seleccionado en el modal
        function actualizarInfoLoteModal() {
            const select = document.getElementById('modalLote');
            const option = select.options[select.selectedIndex];
            const cantidadInput = document.getElementById('modalCantidadPaquetes');
            const maxPaquetesSpan = document.getElementById('maxPaquetesModal');
            const infoLote = document.getElementById('infoLoteModal');
            
            if (option && option.value) {
                const paquetesDisponibles = parseInt(option.getAttribute('data-paquetes')) || 0;
                const stockActual = parseInt(option.getAttribute('data-stock')) || 0;
                const unidadesPorPaquete = parseInt(option.getAttribute('data-unidades-paquete')) || 1;
                
                cantidadInput.max = paquetesDisponibles;
                maxPaquetesSpan.textContent = paquetesDisponibles;
                cantidadInput.placeholder = 'Máximo ' + paquetesDisponibles + ' paquetes';
                infoLote.innerHTML = '<i class="fas fa-info-circle"></i> Stock disponible: ' + stockActual + ' unidades (' + paquetesDisponibles + ' paquetes)';
            } else {
                cantidadInput.max = '';
                cantidadInput.value = '';
                maxPaquetesSpan.textContent = '-';
                cantidadInput.placeholder = 'Ingrese la cantidad de paquetes';
                infoLote.innerHTML = '<i class="fas fa-info-circle"></i> Selecciona el producto y lote que será transportado';
            }
        }
        
        // Función para inicializar Select2 en el dropdown de distrito (sin búsqueda)
        function inicializarSelect2Distrito() {
            const selectDistrito = $('#modalDestino');
            if (selectDistrito.length && !selectDistrito.hasClass('select2-hidden-accessible')) {
                selectDistrito.select2({
                    theme: 'bootstrap-5',
                    placeholder: {
                        id: '',
                        text: 'Seleccione un destino...'
                    },
                    allowClear: true,
                    dropdownParent: $('#agregarPlanModal'),
                    width: '100%',
                    minimumResultsForSearch: Infinity, // Desactiva la búsqueda
                    language: {
                        noResults: function() {
                            return "No se encontraron destinos";
                        }
                    }
                });
            }
        }
        
        // ===================== Cargar lotes por productor =====================
        const modalProductor = document.getElementById('modalProductor');
        const modalLote = document.getElementById('modalLote');
        
        // Función para cerrar el modal
        function cerrarModalAgregarPlan() {
            // Destruir Select2 antes de cerrar
            const selectLote = $('#modalLote');
            if (selectLote.length && selectLote.hasClass('select2-hidden-accessible')) {
                selectLote.select2('destroy');
            }
            
            const selectDistrito = $('#modalDestino');
            if (selectDistrito.length && selectDistrito.hasClass('select2-hidden-accessible')) {
                selectDistrito.select2('destroy');
            }
            
            agregarPlanModal.classList.remove('show');
            agregarPlanModal.style.display = 'none';
            document.body.style.overflow = '';
            
            // Limpiar formulario al cerrar
            const formAgregarPlan = document.getElementById('formAgregarPlan');
            if (formAgregarPlan) {
                formAgregarPlan.reset();
            }
        }
        
        // Event listener para el botón
        openAgregarPlanBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            abrirModalAgregarPlan();
        });
        
        if (closeAgregarPlanBtn) {
            closeAgregarPlanBtn.addEventListener('click', cerrarModalAgregarPlan);
        }
        
        if (cancelAgregarPlanBtn) {
            cancelAgregarPlanBtn.addEventListener('click', cerrarModalAgregarPlan);
        }
        
        // Cerrar al hacer clic fuera del modal
        agregarPlanModal.addEventListener('click', function(e) {
            if (e.target === agregarPlanModal) {
                cerrarModalAgregarPlan();
            }
        });
        
        // Cerrar con tecla ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && agregarPlanModal && agregarPlanModal.classList.contains('show')) {
                cerrarModalAgregarPlan();
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

<!-- ===================== Modal: Agregar Plan de Transporte ===================== -->
<div id="agregarPlanModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-plus"></i> Generar Nuevo Plan de Transporte</h2>
            <span class="modal-close-plan">&times;</span>
        </div>
        
        <form method="POST" action="${pageContext.request.contextPath}/planes-transporte" id="formAgregarPlan">
            <input type="hidden" name="action" value="guardar">
            
            <div class="modal-body">
                <div class="form-group">
                    <label for="modalLote">
                        <i class="fas fa-box"></i>
                        Producto y Lote a Transportar <span class="text-danger">*</span>
                    </label>
                    <select class="form-control lote-select" id="modalLote" name="lote_id" required>
                        <option value="" selected disabled>Seleccione un lote...</option>
                        <%
                            ArrayList<LoteBean> lotesModal = (ArrayList<LoteBean>) request.getAttribute("listaLotes");
                            System.out.println("=== DEBUG JSP: Lotes en request ===");
                            System.out.println("lotesModal es null? " + (lotesModal == null));
                            
                            // FALLBACK: Si el servlet no cargó los lotes, cargarlos directamente aquí
                            if (lotesModal == null || lotesModal.isEmpty()) {
                                System.out.println("⚠️ listaLotes es NULL o vacío - Cargando directamente desde DAO");
                                try {
                                    com.example.telito.logistica.daos.LoteDao loteDao = new com.example.telito.logistica.daos.LoteDao();
                                    lotesModal = loteDao.listarLotesDisponibles();
                                    System.out.println("✓ Lotes cargados directamente: " + (lotesModal != null ? lotesModal.size() : 0));
                                    if (lotesModal != null) {
                                        for (LoteBean l : lotesModal) {
                                            System.out.println("  - Lote: ID=" + l.getId() + ", Producto=" + l.getNombreProducto() + ", Codigo=" + l.getCodigoLote());
                                        }
                                    }
                                } catch (Exception e) {
                                    System.err.println("❌ Error al cargar lotes en JSP: " + e.getMessage());
                                    e.printStackTrace();
                                }
                            } else {
                                System.out.println("✓ Lotes cargados desde servlet: " + lotesModal.size());
                            }
                            
                            if (lotesModal != null && !lotesModal.isEmpty()) {
                                System.out.println("Total de lotes a mostrar: " + lotesModal.size());
                                for (LoteBean lote : lotesModal) { %>
                        <option value="<%= lote.getId() %>" 
                                data-stock="<%= lote.getStockActual() %>"
                                data-unidades-paquete="<%= lote.getUnidadesPorPaquete() %>"
                                data-paquetes="<%= lote.getPaquetesDisponibles() %>">
                            <%= lote.getNombreProducto() %> (<%= lote.getCodigoLote() %>) - <%= lote.getPaquetesDisponibles() %> paquetes disponibles
                        </option>
                        <%     }
                            } else {
                                System.out.println("⚠️ No hay lotes disponibles para mostrar");
                            } %>
                    </select>
                    <div class="form-hint" id="infoLoteModal">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el producto y lote que será transportado</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalCantidadPaquetes">
                        <i class="fas fa-boxes"></i>
                        Cantidad de Paquetes a Transportar <span class="text-danger">*</span>
                    </label>
                    <input type="number" class="form-control" id="modalCantidadPaquetes" name="cantidad_paquetes" 
                           min="1" max="" required placeholder="Ingrese la cantidad de paquetes">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingrese la cantidad de paquetes a transportar (máximo: <span id="maxPaquetesModal">-</span> paquetes)</span>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalConductor">
                                <i class="fas fa-user"></i>
                                Conductor Asignado <span class="text-danger">*</span>
                            </label>
                            <select class="form-control" id="modalConductor" name="conductor_id" required>
                                <option value="" selected disabled>Seleccione un conductor...</option>
                                <%
                                    ArrayList<ConductorBean> conductoresModal = (ArrayList<ConductorBean>) request.getAttribute("listaConductores");
                                    if (conductoresModal != null) {
                                        for (ConductorBean conductor : conductoresModal) { %>
                                <option value="<%= conductor.getId() %>"><%= conductor.getNombreCompleto() %></option>
                                <%     }
                                } %>
                            </select>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalVehiculo">
                                <i class="fas fa-truck"></i>
                                Vehículo Asignado <span class="text-danger">*</span>
                            </label>
                            <select class="form-control" id="modalVehiculo" name="vehiculo_id" required>
                                <option value="" selected disabled>Seleccione un vehículo...</option>
                                <%
                                    ArrayList<VehiculoBean> vehiculosModal = (ArrayList<VehiculoBean>) request.getAttribute("listaVehiculos");
                                    if (vehiculosModal != null) {
                                        for (VehiculoBean vehiculo : vehiculosModal) { %>
                                <option value="<%= vehiculo.getId() %>"><%= vehiculo.getPlaca() %></option>
                                <%     }
                                } %>
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalFechaEntrega">
                                <i class="fas fa-calendar-alt"></i>
                                Fecha de Entrega Programada <span class="text-danger">*</span>
                            </label>
                            <input type="date" class="form-control" id="modalFechaEntrega" name="fecha_entrega" required>
                            <div class="form-hint">
                                <i class="fas fa-info-circle"></i>
                                <span>Fecha estimada de entrega del producto</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalDestino">
                                <i class="fas fa-map-marker-alt"></i>
                                Destino (Distrito) <span class="text-danger">*</span>
                            </label>
                            <select class="form-control distrito-select" id="modalDestino" name="distrito_id" required>
                                <option value="" selected disabled>Seleccione un destino...</option>
                                <%
                                    ArrayList<DistritoBean> distritosModal = (ArrayList<DistritoBean>) request.getAttribute("listaDistritos");
                                    if (distritosModal != null) {
                                        for (DistritoBean distrito : distritosModal) { %>
                                <option value="<%= distrito.getId() %>"><%= distrito.getNombre() %></option>
                                <%     }
                                } %>
                            </select>
                        </div>
                    </div>
                </div>
                
                <div class="alert alert-info" style="background: rgba(13,202,240,0.1); border-left: 4px solid #0dcaf0; border-radius: 8px; padding: 12px 15px; margin-top: 15px; font-size: 0.9rem;">
                    <i class="fas fa-info-circle me-2" style="color: #0dcaf0;"></i>
                    <strong>Importante:</strong> Asegúrate de verificar la disponibilidad del conductor y vehículo para la fecha seleccionada.
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel-plan">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-save"></i>
                    Guardar Plan
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== Modal: Enviar Distribución y Transporte por Correo ===================== -->
<div id="sendDistribucionModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte de Distribución y Transporte por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/logistica/DistribucionTransporteReporteServlet" id="formEnviarDistribucion">
            <input type="hidden" name="action" value="enviar">
            <input type="hidden" name="busqueda" id="hiddenBusqueda" value="">
            <input type="hidden" name="conductor" id="hiddenConductor" value="">
            <input type="hidden" name="estado" id="hiddenEstado" value="">
            <input type="hidden" name="fecha_desde" id="hiddenFechaDesde" value="">
            <input type="hidden" name="fecha_hasta" id="hiddenFechaHasta" value="">
            
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
                           value="Reporte de Distribución y Transporte - Logística - TELITO BODEGUERO" 
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
                    <strong>Nota:</strong> El archivo Excel se generará con los mismos filtros que tienes aplicados en la tabla de distribución y transporte. 
                    Incluirá todas las columnas (Número Plan, Conductor, Vehículo, Destino, Estado, Fecha, etc.) y tendrá filtros automáticos habilitados.
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

<!-- jQuery y Select2 JS para mejorar el dropdown de búsqueda -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

</body>
</html>