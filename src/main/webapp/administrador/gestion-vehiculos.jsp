<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Vehículos"/>
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
        
        /* Quitar borde marrón del card de filtros */
        .card.shadow-sm {
            border: 1px solid #dee2e6 !important;
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
        #vehiculoTable tbody tr {
            position: relative;
            z-index: 1;
        }
        
        #vehiculoTable tbody tr:hover {
            z-index: 2;
        }
        
        #vehiculoTable tbody tr.dropdown-open {
            z-index: 1000 !important;
        }
        
        #vehiculoTable td:last-child {
            overflow: visible !important;
            position: relative;
            z-index: 10;
        }
        
        #vehiculoTable td:last-child.dropdown-open {
            z-index: 1001 !important;
        }
        
        #vehiculoTable td:last-child .dropdown {
            position: relative !important;
            display: inline-block !important;
            z-index: 1000;
        }
        
        #vehiculoTable td:last-child .dropdown.dropdown-open {
            z-index: 1002 !important;
        }
        
        #vehiculoTable td:last-child .dropdown-toggle::after {
            display: none;
        }
        
        #vehiculoTable td:last-child .dropdown-menu {
            position: absolute !important;
            right: 0 !important;
            left: auto !important;
            top: 100% !important;
            bottom: auto !important;
            z-index: 99999 !important;
            margin-top: 0.25rem !important;
            margin-bottom: 0 !important;
            min-width: 180px !important;
            display: none;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            transform: none !important;
        }
        
        #vehiculoTable td:last-child .dropdown-menu.show {
            display: block !important;
            position: absolute !important;
        }
        
        /* Eliminar scrollbar vertical no deseado */
        #vehiculoTable tbody {
            overflow: visible !important;
        }
        
        #vehiculoTable {
            overflow: visible !important;
        }
        
        #vehiculoTable tbody tr td {
            overflow: visible !important;
        }
        
        /* Estilos para los encabezados de la tabla (igual que Gestion de Usuarios) */
        /* Estilos para encabezados de tabla - igual que Inventario General */
        #vehiculoTable thead th {
            vertical-align: middle;
        }
        
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
        .table-responsive {
            overflow: visible !important;
        }
        
        .table-card .card-body {
            overflow: visible !important;
        }
        
        .table-card {
            overflow: visible !important;
        }
        
        div[style*="overflow"]:not(.modal):not(.modal-content) {
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
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); 
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
            color: #6F4E37;
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
            border-color: #6F4E37;
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
            color: #6F4E37;
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
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); 
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
            color: #6F4E37;
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
            border-color: #6F4E37;
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
            color: #6F4E37;
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
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
            color: white;
        }
        #sendEmailModal .modal-footer button[type="submit"]:hover {
            background: linear-gradient(135deg, #8B6F47 0%, #A0826D 100%);
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
            border-left: 4px solid #6F4E37;
            background: #e8f5f4;
            color: #6F4E37;
        }
        #sendEmailModal .alert i {
            color: #6F4E37;
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
        
        /* ===================== Estilos para Modal de Editar Vehículo ===================== */
        #editVehiculoModal.modal { 
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
        #editVehiculoModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #editVehiculoModal .modal-content { 
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
        #editVehiculoModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #editVehiculoModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #editVehiculoModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #editVehiculoModal .modal-close { 
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
        #editVehiculoModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #editVehiculoModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 160px);
        }
        #editVehiculoModal .form-group {
            margin-bottom: 1rem;
        }
        #editVehiculoModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #editVehiculoModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #editVehiculoModal .form-group input {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #editVehiculoModal .form-group input:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #editVehiculoModal .form-hint {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #6c757d;
            font-size: 0.8rem;
            margin-top: 6px;
            padding: 8px 12px;
            background: rgba(0,168,150,0.05);
            border-radius: 6px;
        }
        #editVehiculoModal .form-hint i {
            color: #6F4E37;
            flex-shrink: 0;
        }
        #editVehiculoModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #editVehiculoModal .modal-footer button {
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
        #editVehiculoModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #editVehiculoModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #editVehiculoModal .modal-footer button[type="submit"] {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #editVehiculoModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,168,150,0.4);
        }
        @media (max-width: 768px) {
            #editVehiculoModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #editVehiculoModal.show {
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
                                    <a href="${pageContext.request.contextPath}/administrador/VehiculoReporteServlet?action=exportar" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #D4A574 0%, #C9A87A 100%); color: white; border: none;">
                                        <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                                    </a>
                                    <button type="button" id="openSendEmailModalBtn" class="btn btn-sm text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #E8B86D 0%, #D4A574 100%); border: none;">
                                        <i class="fas fa-envelope me-1"></i>Enviar por Correo
                                    </button>
                                    <button type="button" id="openAddVehiculoModalBtn" class="btn btn-sm shadow-sm btn-agregar-vehiculo" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); border: none; color: white; font-weight: 600;">
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
                <div class="row g-2 mb-3">
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Vehículos</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= totalVehiculos %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Con Planes Asignados</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= vehiculosConPlanes %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Sin Planes Asignados</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= vehiculosSinPlanes %></p>
                        </div>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px; border: 1px solid #dee2e6 !important;">
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
                                        <h5 class="mb-0 fw-semibold" style="font-size: 1.25rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Tabla de Vehículos</h5>
                                        <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los vehículos del sistema</small>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body" style="padding: 0.75rem;">
                                <div class="table-responsive">
                                    <table id="vehiculoTable" class="table table-hover align-middle mb-0 datatable-server-side" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                        <thead class="table-light">
                                        <tr>
                                            <th style="width: 3%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-hashtag me-1"></i>N° Vehículo</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-id-card me-1"></i>Placa</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-industry me-1"></i>Marca</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-car me-1"></i>Modelo</th>
                                            <th style="width: 6%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-calendar me-1"></i>Año</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-gas-pump me-1"></i>Combustible</th>
                                            <th style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-barcode me-1"></i>VIN</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-weight me-1"></i>Capacidad</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-wrench me-1"></i>Última Revisión</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-shield-alt me-1"></i>Venc. SOAT</th>
                                            <th class="fw-semibold text-success" style="width: 9%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;"><i class="fas fa-cog me-1"></i>Acciones</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="vehiculo" items="${listaVehiculos}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <span class="badge" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); color: white; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        VEH<fmt:formatNumber value="${vehiculo.idVehiculo}" pattern="000"/>
                                                    </span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <span class="text-dark" style="font-size: 0.85rem;">
                                                        ${vehiculo.placa}
                                                    </span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty vehiculo.marca}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${vehiculo.marca}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty vehiculo.modelo}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${vehiculo.modelo}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty vehiculo.año}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${vehiculo.año}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty vehiculo.tipoCombustible}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${vehiculo.tipoCombustible}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty vehiculo.numeroSerieVin}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${vehiculo.numeroSerieVin}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <span class="text-dark" style="font-size: 0.85rem;">
                                                        ${vehiculo.capacidadKg} kg
                                                    </span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty vehiculo.fechaUltimaRevision}">
                                                            <%
                                                                com.example.telito.administrador.beans.Vehiculo veh = (com.example.telito.administrador.beans.Vehiculo) pageContext.getAttribute("vehiculo");
                                                                if (veh != null && veh.getFechaUltimaRevision() != null) {
                                                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                                                    String fechaFormateada = sdf.format(veh.getFechaUltimaRevision());
                                                                    out.print("<span class='text-dark' style='font-size: 0.85rem;'>" + fechaFormateada + "</span>");
                                                                } else {
                                                                    out.print("<span class='text-muted' style='font-size: 0.85rem;'>-</span>");
                                                                }
                                                            %>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty vehiculo.fechaVencimientoSoat}">
                                                            <%
                                                                com.example.telito.administrador.beans.Vehiculo veh2 = (com.example.telito.administrador.beans.Vehiculo) pageContext.getAttribute("vehiculo");
                                                                if (veh2 != null && veh2.getFechaVencimientoSoat() != null) {
                                                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                                                    String fechaFormateada = sdf.format(veh2.getFechaVencimientoSoat());
                                                                    // Verificar si está próxima a vencer (30 días)
                                                                    java.util.Date hoy = new java.util.Date();
                                                                    long diffInMillies = veh2.getFechaVencimientoSoat().getTime() - hoy.getTime();
                                                                    long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
                                                                    
                                                                    if (diffInDays < 0) {
                                                                        // Ya venció - badge rojo
                                                                        out.print("<span class='badge shadow-sm' style='background-color: #ffcdd2; color: #c62828; font-size: 0.8rem; padding: 0.3rem 0.6rem;'><i class='fas fa-exclamation-triangle me-1'></i>" + fechaFormateada + "</span>");
                                                                    } else {
                                                                        // Válida - badge verde
                                                                        out.print("<span class='badge shadow-sm' style='background-color: #c8e6c9; color: #2e7d32; font-size: 0.8rem; padding: 0.3rem 0.6rem;'><i class='fas fa-check-circle me-1'></i>" + fechaFormateada + "</span>");
                                                                    }
                                                                } else {
                                                                    out.print("<span class='text-muted' style='font-size: 0.85rem;'>-</span>");
                                                                }
                                                            %>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <div class="dropdown d-inline-block">
                                                        <button class="btn btn-sm btn-outline-success shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <ul class="dropdown-menu dropdown-menu-end shadow-lg">
                                                            <li>
                                                                <a class="dropdown-item text-primary" href="#" onclick="event.preventDefault(); editarVehiculo(${vehiculo.idVehiculo});">
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

<!-- ===================== Modal: Editar Vehículo ===================== -->
<div id="editVehiculoModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-truck-loading"></i> Editar Vehículo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="${pageContext.request.contextPath}/administrador/VehiculoServlet" id="formEditarVehiculo">
            <input type="hidden" name="action" value="actualizar">
            <input type="hidden" name="id" id="editIdVehiculo">
            <div class="modal-body">
                <div class="form-group">
                    <label for="editPlaca">
                        <i class="fas fa-id-card"></i>
                        Placa <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="placa" 
                           id="editPlaca" 
                           placeholder="Ej: ABC-123" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la placa del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editMarca">
                        <i class="fas fa-industry"></i>
                        Marca
                    </label>
                    <input type="text" 
                           name="marca" 
                           id="editMarca" 
                           placeholder="Ej: Toyota, Nissan">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la marca del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editModelo">
                        <i class="fas fa-car"></i>
                        Modelo
                    </label>
                    <input type="text" 
                           name="modelo" 
                           id="editModelo" 
                           placeholder="Ej: Hiace, Urvan">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el modelo del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editCapacidadKg">
                        <i class="fas fa-weight"></i>
                        Capacidad (Kg) <span class="text-danger">*</span>
                    </label>
                    <input type="number" 
                           name="capacidadKg" 
                           id="editCapacidadKg" 
                           placeholder="Ej: 1500" 
                           min="0" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la capacidad máxima en kilogramos</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editAño">
                        <i class="fas fa-calendar"></i>
                        Año del Vehículo <span class="text-danger">*</span>
                    </label>
                    <input type="number" 
                           name="año" 
                           id="editAño" 
                           placeholder="Ej: 2020" 
                           min="1900"
                           max="2100"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el año de fabricación del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editTipoCombustible">
                        <i class="fas fa-gas-pump"></i>
                        Tipo de Combustible <span class="text-danger">*</span>
                    </label>
                    <select name="tipoCombustible" 
                            id="editTipoCombustible" 
                            required>
                        <option value="">Seleccione un tipo</option>
                        <option value="Gasolina">Gasolina</option>
                        <option value="Diesel">Diesel</option>
                        <option value="GLP">GLP</option>
                        <option value="Eléctrico">Eléctrico</option>
                        <option value="Híbrido">Híbrido</option>
                    </select>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el tipo de combustible del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editNumeroSerieVin">
                        <i class="fas fa-barcode"></i>
                        Número de Serie/VIN <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="numeroSerieVin" 
                           id="editNumeroSerieVin" 
                           placeholder="Ej: 1HGBH41JXMN109186" 
                           maxlength="50"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el número de serie o VIN del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editFechaUltimaRevision">
                        <i class="fas fa-wrench"></i>
                        Fecha de Última Revisión Técnica <span class="text-danger">*</span>
                    </label>
                    <input type="date" 
                           name="fechaUltimaRevision" 
                           id="editFechaUltimaRevision" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la fecha de la última revisión técnica</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editFechaVencimientoSoat">
                        <i class="fas fa-shield-alt"></i>
                        Fecha de Vencimiento de SOAT/Seguro <span class="text-danger">*</span>
                    </label>
                    <input type="date" 
                           name="fechaVencimientoSoat" 
                           id="editFechaVencimientoSoat" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la fecha de vencimiento del SOAT o seguro</span>
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
                    Guardar cambios
                </button>
            </div>
        </form>
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
                
                <div class="form-group">
                    <label for="modalAño">
                        <i class="fas fa-calendar"></i>
                        Año del Vehículo <span class="text-danger">*</span>
                    </label>
                    <input type="number" 
                           name="año" 
                           id="modalAño" 
                           placeholder="Ej: 2020" 
                           min="1900"
                           max="2100"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el año de fabricación del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalTipoCombustible">
                        <i class="fas fa-gas-pump"></i>
                        Tipo de Combustible <span class="text-danger">*</span>
                    </label>
                    <select name="tipoCombustible" 
                            id="modalTipoCombustible" 
                            required>
                        <option value="">Seleccione un tipo</option>
                        <option value="Gasolina">Gasolina</option>
                        <option value="Diesel">Diesel</option>
                        <option value="GLP">GLP</option>
                        <option value="Eléctrico">Eléctrico</option>
                        <option value="Híbrido">Híbrido</option>
                    </select>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el tipo de combustible del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalNumeroSerieVin">
                        <i class="fas fa-barcode"></i>
                        Número de Serie/VIN <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="numeroSerieVin" 
                           id="modalNumeroSerieVin" 
                           placeholder="Ej: 1HGBH41JXMN109186" 
                           maxlength="50"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el número de serie o VIN del vehículo</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalFechaUltimaRevision">
                        <i class="fas fa-wrench"></i>
                        Fecha de Última Revisión Técnica <span class="text-danger">*</span>
                    </label>
                    <input type="date" 
                           name="fechaUltimaRevision" 
                           id="modalFechaUltimaRevision" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la fecha de la última revisión técnica</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalFechaVencimientoSoat">
                        <i class="fas fa-shield-alt"></i>
                        Fecha de Vencimiento de SOAT/Seguro <span class="text-danger">*</span>
                    </label>
                    <input type="date" 
                           name="fechaVencimientoSoat" 
                           id="modalFechaVencimientoSoat" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la fecha de vencimiento del SOAT o seguro</span>
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
    // Función para ajustar el posicionamiento de los dropdowns
    function ajustarDropdowns() {
        document.querySelectorAll('#vehiculoTable td:last-child .dropdown').forEach(function(dropdown) {
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
                button.addEventListener('click', function(e) {
                    setTimeout(function() {
                        posicionarDropdown();
                    }, 10);
                });
                
                // Ajustar posición al hacer scroll o redimensionar
                let scrollTimeout;
                function ajustarEnScroll() {
                    clearTimeout(scrollTimeout);
                    scrollTimeout = setTimeout(function() {
                        if (menu.classList.contains('show')) {
                            posicionarDropdown();
                        }
                    }, 10);
                }
                
                window.addEventListener('scroll', ajustarEnScroll, true);
                window.addEventListener('resize', ajustarEnScroll);
            }
        });
    }
    
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        // Ajustar dropdowns después de que la página cargue
        ajustarDropdowns();
        
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
                document.getElementById('modalAño').value = '';
                document.getElementById('modalTipoCombustible').value = '';
                document.getElementById('modalNumeroSerieVin').value = '';
                document.getElementById('modalFechaUltimaRevision').value = '';
                document.getElementById('modalFechaVencimientoSoat').value = '';
                
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
            if (event.key === 'Escape' && editVehiculoModal && editVehiculoModal.classList.contains('show')) {
                cerrarModalEditarVehiculo();
            }
        });
        
        // ===================== Manejo del Modal de Editar Vehículo =====================
        const editVehiculoModal = document.getElementById('editVehiculoModal');
        const closeEditVehiculoModalBtn = document.querySelector('#editVehiculoModal .modal-close');
        const cancelEditVehiculoModalBtn = document.querySelector('#editVehiculoModal .modal-cancel');
        
        // Función para abrir el modal de edición
        function abrirModalEditarVehiculo() {
            if (editVehiculoModal) {
                editVehiculoModal.classList.add('show');
                editVehiculoModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        }
        
        // Función para cerrar el modal de edición
        function cerrarModalEditarVehiculo() {
            if (editVehiculoModal) {
                editVehiculoModal.classList.remove('show');
                editVehiculoModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Función global para editar vehículo
        window.editarVehiculo = function(idVehiculo) {
            const editVehiculoModal = document.getElementById('editVehiculoModal');
            const originalModalBodyContent = editVehiculoModal.querySelector('.modal-body').innerHTML;
            
            // Mostrar loading overlay
            const modalBody = editVehiculoModal.querySelector('.modal-body');
            if (modalBody) {
                modalBody.innerHTML = '<div class="text-center py-5"><i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: #6F4E37;"></i><p>Cargando datos del vehículo...</p></div>';
            }
            
            abrirModalEditarVehiculo();
            
            fetch('${pageContext.request.contextPath}/administrador/VehiculoServlet?action=obtenerVehiculoJson&id=' + idVehiculo, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            })
            .then(response => {
                if (!response.ok) {
                    return response.json().then(errorData => {
                        throw new Error(errorData.mensaje || 'Error al cargar los datos del vehículo');
                    });
                }
                return response.json();
            })
            .then(data => {
                // Verificar si hay un error en la respuesta
                if (data.exito === false) {
                    throw new Error(data.mensaje || 'Error al cargar los datos del vehículo');
                }
                
                // Restore original form HTML
                modalBody.innerHTML = originalModalBodyContent;
                
                // Populate form fields
                document.getElementById('editIdVehiculo').value = data.idVehiculo;
                document.getElementById('editPlaca').value = data.placa || '';
                document.getElementById('editMarca').value = data.marca || '';
                document.getElementById('editModelo').value = data.modelo || '';
                document.getElementById('editCapacidadKg').value = data.capacidadKg || '';
                document.getElementById('editAño').value = data.año || '';
                document.getElementById('editTipoCombustible').value = data.tipoCombustible || '';
                document.getElementById('editNumeroSerieVin').value = data.numeroSerieVin || '';
                
                // Formatear fechas para el input date (YYYY-MM-DD)
                if (data.fechaUltimaRevision) {
                    try {
                        if (typeof data.fechaUltimaRevision === 'string' && data.fechaUltimaRevision.match(/^\d{4}-\d{2}-\d{2}/)) {
                            document.getElementById('editFechaUltimaRevision').value = data.fechaUltimaRevision.substring(0, 10);
                        } else {
                            const fecha = new Date(data.fechaUltimaRevision);
                            if (!isNaN(fecha.getTime())) {
                                const fechaFormateada = fecha.toISOString().split('T')[0];
                                document.getElementById('editFechaUltimaRevision').value = fechaFormateada;
                            } else {
                                document.getElementById('editFechaUltimaRevision').value = '';
                            }
                        }
                    } catch (e) {
                        document.getElementById('editFechaUltimaRevision').value = '';
                    }
                } else {
                    document.getElementById('editFechaUltimaRevision').value = '';
                }
                
                if (data.fechaVencimientoSoat) {
                    try {
                        if (typeof data.fechaVencimientoSoat === 'string' && data.fechaVencimientoSoat.match(/^\d{4}-\d{2}-\d{2}/)) {
                            document.getElementById('editFechaVencimientoSoat').value = data.fechaVencimientoSoat.substring(0, 10);
                        } else {
                            const fecha = new Date(data.fechaVencimientoSoat);
                            if (!isNaN(fecha.getTime())) {
                                const fechaFormateada = fecha.toISOString().split('T')[0];
                                document.getElementById('editFechaVencimientoSoat').value = fechaFormateada;
                            } else {
                                document.getElementById('editFechaVencimientoSoat').value = '';
                            }
                        }
                    } catch (e) {
                        document.getElementById('editFechaVencimientoSoat').value = '';
                    }
                } else {
                    document.getElementById('editFechaVencimientoSoat').value = '';
                }
            })
            .catch(error => {
                console.error('Error al cargar vehículo:', error);
                cerrarModalEditarVehiculo();
                alert('Error al cargar los datos del vehículo: ' + (error.message || 'Por favor, intenta nuevamente.'));
            });
        };
        
        // Event listeners para cerrar el modal
        if (closeEditVehiculoModalBtn) {
            closeEditVehiculoModalBtn.addEventListener('click', cerrarModalEditarVehiculo);
        }
        
        if (cancelEditVehiculoModalBtn) {
            cancelEditVehiculoModalBtn.addEventListener('click', cerrarModalEditarVehiculo);
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (editVehiculoModal) {
            editVehiculoModal.addEventListener('click', function(event) {
                if (event.target === editVehiculoModal) {
                    cerrarModalEditarVehiculo();
                }
            });
        }
        
        // Usar delegación de eventos en el modal para capturar el submit del formulario
        if (editVehiculoModal) {
            editVehiculoModal.addEventListener('submit', function(event) {
                // Verificar que el evento venga del formulario de edición
                const form = event.target;
                if (form && form.id === 'formEditarVehiculo') {
                    event.preventDefault();
                    event.stopPropagation();
                    
                    console.log('Formulario de edición detectado - previniendo envío normal');
                    
                    // Validar que los campos requeridos estén presentes
                    const id = document.getElementById('editIdVehiculo');
                    const placa = document.getElementById('editPlaca');
                    const capacidadKg = document.getElementById('editCapacidadKg');
                    
                    if (!id || !id.value || id.value.trim() === '') {
                        alert('Error: El ID del vehículo no está presente. Por favor, cierra el modal y vuelve a intentar.');
                        return;
                    }
                    
                    if (!placa || !placa.value || placa.value.trim() === '') {
                        alert('La placa es requerida.');
                        return;
                    }
                    
                    if (!capacidadKg || !capacidadKg.value || capacidadKg.value.trim() === '') {
                        alert('La capacidad es requerida.');
                        return;
                    }
                    
                    const capacidadNum = parseInt(capacidadKg.value);
                    if (isNaN(capacidadNum) || capacidadNum <= 0) {
                        alert('La capacidad debe ser un número mayor a 0.');
                        return;
                    }
                    
                    const formData = new FormData(form);
                    // Asegurar que el parámetro action esté en el FormData
                    if (!formData.has('action')) {
                        formData.append('action', 'actualizar');
                    }
                    
                    // Log para depuración
                    console.log('Enviando datos del formulario:');
                    for (let [key, value] of formData.entries()) {
                        console.log(key + ':', value);
                    }
                    
                    const url = form.action;
                    console.log('URL:', url);
                    
                    fetch(url, {
                        method: 'POST',
                        headers: {
                            'Accept': 'application/json'
                        },
                        body: formData
                    })
                    .then(response => {
                        console.log('Respuesta recibida:', response.status, response.statusText);
                        // Verificar el Content-Type de la respuesta
                        const contentType = response.headers.get('content-type');
                        const isJson = contentType && contentType.includes('application/json');
                        
                        // Verificar si la respuesta es exitosa
                        if (!response.ok) {
                            // Si la respuesta no es exitosa, intentar leer el mensaje de error
                            if (isJson) {
                                return response.json().then(data => {
                                    throw new Error(data.mensaje || 'Error al procesar la solicitud.');
                                });
                            } else {
                                // Si no es JSON, leer como texto
                                return response.text().then(text => {
                                    console.error('Respuesta no JSON:', text);
                                    throw new Error('Error del servidor: ' + response.status + ' ' + response.statusText);
                                });
                            }
                        }
                        
                        // Si es exitosa, verificar que sea JSON
                        if (isJson) {
                            return response.json();
                        } else {
                            throw new Error('El servidor no devolvió una respuesta JSON válida.');
                        }
                    })
                    .then(data => {
                        console.log('Datos recibidos:', data);
                        if (data.exito) {
                            alert(data.mensaje || 'Vehículo actualizado exitosamente.');
                            cerrarModalEditarVehiculo();
                            location.reload();
                        } else {
                            alert(data.mensaje || 'Error al actualizar el vehículo.');
                        }
                    })
                    .catch(error => {
                        console.error('Error al enviar formulario de edición:', error);
                        console.error('Detalles del error:', {
                            message: error.message,
                            stack: error.stack,
                            name: error.name
                        });
                        // Mostrar el mensaje de error específico si está disponible
                        const mensajeError = error.message || 'Error de conexión con el servidor. Por favor, verifica la consola del navegador para más detalles.';
                        alert(mensajeError);
                    });
                }
            }, true); // Usar capture phase para asegurar que se capture antes
        }
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

