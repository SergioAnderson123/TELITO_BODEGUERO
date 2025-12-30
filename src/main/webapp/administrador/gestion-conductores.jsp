<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Conductores"/>
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
        
        /* Estilos para el botón Agregar Conductor */
        .btn-agregar-conductor {
            transition: all 0.3s ease;
        }
        
        .btn-agregar-conductor:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(40, 167, 69, 0.4) !important;
        }
        
        /* Eliminar scroll horizontal de la tabla */
        #conductorTable {
            width: 100% !important;
            max-width: 100% !important;
        }
        
        #conductorTable th,
        #conductorTable td {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        /* Estilos para encabezados de tabla - igual que Inventario General */
        #conductorTable thead th {
            vertical-align: middle;
        }
        
        /* Permitir que el dropdown sea visible en la columna de acciones */
        #conductorTable tbody tr {
            position: relative;
            z-index: 1;
        }
        
        #conductorTable tbody tr:hover {
            z-index: 2;
        }
        
        #conductorTable tbody tr.dropdown-open {
            z-index: 1000 !important;
        }
        
        #conductorTable td:last-child {
            overflow: visible !important;
            position: relative;
            z-index: 10;
        }
        
        #conductorTable td:last-child.dropdown-open {
            z-index: 1001 !important;
        }
        
        #conductorTable td:last-child .dropdown {
            position: relative !important;
            display: inline-block !important;
            z-index: 1000;
        }
        
        #conductorTable td:last-child .dropdown.dropdown-open {
            z-index: 1002 !important;
        }
        
        #conductorTable td:last-child .dropdown-toggle::after {
            display: none;
        }
        
        #conductorTable td:last-child .dropdown-menu {
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
        
        #conductorTable td:last-child .dropdown-menu.show {
            display: block !important;
            position: absolute !important;
        }
        
        /* Eliminar scrollbar vertical no deseado */
        #conductorTable tbody {
            overflow: visible !important;
        }
        
        #conductorTable {
            overflow: visible !important;
        }
        
        #conductorTable tbody tr td {
            overflow: visible !important;
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
        
        /* ===================== Estilos para Modal de Agregar Conductor ===================== */
        #addConductorModal.modal { 
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
        #addConductorModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #addConductorModal .modal-content { 
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
        #addConductorModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #addConductorModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #addConductorModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #addConductorModal .modal-close { 
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
        #addConductorModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #addConductorModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 160px);
        }
        #addConductorModal .form-group {
            margin-bottom: 1.25rem;
        }
        #addConductorModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #addConductorModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #addConductorModal .form-group input {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
            box-sizing: border-box;
        }
        #addConductorModal .form-group input:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #addConductorModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #addConductorModal .form-hint i {
            color: #6F4E37;
            margin-top: 2px;
        }
        #addConductorModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #addConductorModal .modal-footer button {
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
        #addConductorModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #addConductorModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #addConductorModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(40,167,69,0.3);
        }
        #addConductorModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(40,167,69,0.4);
        }
        @media (max-width: 768px) {
            #addConductorModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #addConductorModal.show {
                padding: 10px;
            }
        }
        
        /* ===================== Estilos para Modal de Editar Conductor ===================== */
        #editConductorModal.modal { 
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
        #editConductorModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #editConductorModal .modal-content { 
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
        #editConductorModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #editConductorModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #editConductorModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #editConductorModal .modal-close { 
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
        #editConductorModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #editConductorModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 160px);
        }
        #editConductorModal .form-group {
            margin-bottom: 1rem;
        }
        #editConductorModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #editConductorModal .form-group label i {
            color: #6F4E37;
            font-size: 0.85rem;
        }
        #editConductorModal .form-group input {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #editConductorModal .form-group input:focus {
            border-color: #6F4E37;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #editConductorModal .form-hint {
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
        #editConductorModal .form-hint i {
            color: #6F4E37;
            flex-shrink: 0;
        }
        #editConductorModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #editConductorModal .modal-footer button {
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
        #editConductorModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #editConductorModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #editConductorModal .modal-footer button[type="submit"] {
            background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #editConductorModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,168,150,0.4);
        }
        @media (max-width: 768px) {
            #editConductorModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #editConductorModal.show {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/header_admin.jsp"/>
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Conductores"/>
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
                                    <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-user-tie me-2"></i>Gestión de Conductores</h2>
                                    <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra los conductores del sistema de transporte.</p>
                                </div>
                                <div class="d-flex gap-2 flex-wrap">
                                    <a href="${pageContext.request.contextPath}/administrador/ConductorReporteServlet?action=exportar" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #D4A574 0%, #C9A87A 100%); color: white; border: none;">
                                        <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                                    </a>
                                    <button type="button" id="openSendEmailModalBtn" class="btn btn-sm text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #E8B86D 0%, #D4A574 100%); border: none;">
                                        <i class="fas fa-envelope me-1"></i>Enviar por Correo
                                    </button>
                                    <button type="button" id="openAddConductorModalBtn" class="btn btn-sm shadow-sm btn-agregar-conductor" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); border: none; color: white; font-weight: 600;">
                                        <i class="fas fa-plus me-1"></i>Agregar Conductor
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%
                    // Obtener estadísticas del servlet
                    Integer totalConductoresAttr = (Integer) request.getAttribute("totalConductores");
                    Integer conductoresConPlanesAttr = (Integer) request.getAttribute("conductoresConPlanes");
                    Integer conductoresSinPlanesAttr = (Integer) request.getAttribute("conductoresSinPlanes");
                    int totalConductores = (totalConductoresAttr != null) ? totalConductoresAttr : 0;
                    int conductoresConPlanes = (conductoresConPlanesAttr != null) ? conductoresConPlanesAttr : 0;
                    int conductoresSinPlanes = (conductoresSinPlanesAttr != null) ? conductoresSinPlanesAttr : 0;
                %>

                <!-- ===================== Tarjetas de estadísticas ===================== -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Conductores</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= totalConductores %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Con Planes Asignados</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= conductoresConPlanes %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05); border: 1px solid #dee2e6;">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Sin Planes Asignados</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #6F4E37;"><%= conductoresSinPlanes %></p>
                        </div>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px; border: 1px solid #dee2e6 !important;">
                    <form action="${pageContext.request.contextPath}/administrador/ConductorServlet" method="GET" id="filterForm">
                        <input type="hidden" name="action" value="listar">
                        <input type="hidden" name="size" value="${size != null ? size : 5}">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Nombre o licencia..." value="${busqueda != null ? busqueda : ''}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-id-badge me-1"></i>DNI</label>
                                <input type="text" class="form-control form-control-sm shadow-sm" name="dni" id="dniInput" placeholder="Buscar por DNI..." value="${param.dni != null ? param.dni : ''}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            </div>
                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar-alt me-1"></i>Vencimiento</label>
                                <input type="date" class="form-control form-control-sm shadow-sm" name="fechaVencimiento" id="fechaVencimientoInput" value="${param.fechaVencimiento != null ? param.fechaVencimiento : ''}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            </div>
                            <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12 d-flex align-items-end">
                                <a href="${pageContext.request.contextPath}/administrador/ConductorServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
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

                <!-- ===================== Card: Tabla de conductores ===================== -->
                <div class="row">
                    <div class="col-12">
                        <div class="table-card shadow-sm">
                            <div class="card-header" style="padding: 0.5rem 0.75rem;">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <h5 class="mb-0 fw-semibold" style="font-size: 1.25rem; line-height: 1.2;"><i class="fas fa-user-tie me-2"></i>Tabla de Conductores</h5>
                                        <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los conductores del sistema</small>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body" style="padding: 0.75rem;">
                                <div class="table-responsive">
                                    <table id="conductorTable" class="table table-hover align-middle mb-0 datatable-server-side" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                        <thead class="table-light">
                                        <tr>
                                            <th style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-hashtag me-1"></i>N° Conductor</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-user me-1"></i>Nombre Completo</th>
                                            <th style="width: 8%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-id-badge me-1"></i>DNI</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-phone me-1"></i>Teléfono</th>
                                            <th style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-envelope me-1"></i>Email</th>
                                            <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-id-card me-1"></i>Licencia</th>
                                            <th style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;" class="fw-semibold"><i class="fas fa-calendar-alt me-1"></i>Vencimiento</th>
                                            <th class="fw-semibold text-success" style="width: 6%; font-size: 0.85rem; padding: 0.4rem 0.5rem; text-align: center;"><i class="fas fa-cog me-1"></i>Acciones</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="conductor" items="${listaConductores}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <span class="badge" style="background: linear-gradient(165deg, #6F4E37 0%, #8B6F47 50%, #A0826D 100%); color: white; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        CON<fmt:formatNumber value="${conductor.idConductor}" pattern="000"/>
                                                    </span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <div class="d-flex align-items-center justify-content-center">
                                                        <div class="avatar-wrapper me-2">
                                                            <div class="rounded-circle bg-success text-white d-flex align-items-center justify-content-center shadow-sm" 
                                                                 style="width: 38px; height: 38px; font-weight: 600; font-size: 0.9rem; border: 2px solid #e9ecef;">
                                                                ${fn:substring(conductor.nombreCompleto, 0, 1)}
                                                            </div>
                                                        </div>
                                                        <span class="fw-semibold text-dark" style="font-size: 0.9rem; line-height: 1.2;">${conductor.nombreCompleto}</span>
                                                    </div>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty conductor.dni}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${conductor.dni}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty conductor.telefono}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${conductor.telefono}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty conductor.email}">
                                                            <span class="text-dark" style="font-size: 0.85rem;">${conductor.email}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted" style="font-size: 0.85rem;">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <span class="text-dark" style="font-size: 0.85rem;">
                                                        ${conductor.licencia}
                                                    </span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; text-align: center;">
                                                    <c:choose>
                                                        <c:when test="${not empty conductor.fechaVencimientoLicencia}">
                                                            <%
                                                                // Obtener la fecha del conductor
                                                                com.example.telito.administrador.beans.Conductor cond = (com.example.telito.administrador.beans.Conductor) pageContext.getAttribute("conductor");
                                                                if (cond != null && cond.getFechaVencimientoLicencia() != null) {
                                                                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                                                                    String fechaFormateada = sdf.format(cond.getFechaVencimientoLicencia());
                                                                    // Verificar si está próxima a vencer (30 días)
                                                                    java.util.Date hoy = new java.util.Date();
                                                                    long diffInMillies = cond.getFechaVencimientoLicencia().getTime() - hoy.getTime();
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
                                                                <a class="dropdown-item text-primary" href="#" onclick="event.preventDefault(); editarConductor(${conductor.idConductor});">
                                                                    <i class="fas fa-edit"></i> Editar
                                                                </a>
                                                            </li>
                                                            <li><hr class="dropdown-divider"></li>
                                                            <li>
                                                                <a class="dropdown-item text-danger" href="#" data-id="${conductor.idConductor}" data-nombre="${conductor.nombreCompleto}" onclick="confirmarEliminacion(this.dataset.id, this.dataset.nombre)">
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

<!-- Modal de Agregar Conductor -->
<div id="addConductorModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-user-plus"></i> Agregar Nuevo Conductor</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="${pageContext.request.contextPath}/administrador/ConductorServlet" id="formAgregarConductor">
            <input type="hidden" name="action" value="guardar">
            
            <div class="modal-body">
                <div class="form-group">
                    <label for="modalNombreCompleto">
                        <i class="fas fa-user"></i>
                        Nombre Completo <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="nombreCompleto" 
                           id="modalNombreCompleto" 
                           placeholder="Ej: Juan Pérez García" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el nombre completo del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalLicencia">
                        <i class="fas fa-id-card"></i>
                        Número de Licencia <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="licencia" 
                           id="modalLicencia" 
                           placeholder="Ej: A001, B002" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el número de licencia del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalTipoLicencia">
                        <i class="fas fa-certificate"></i>
                        Tipo de Licencia <span class="text-danger">*</span>
                    </label>
                    <select name="tipoLicencia" 
                            id="modalTipoLicencia" 
                            required>
                        <option value="">Seleccione un tipo</option>
                        <option value="A">A - Motocicletas</option>
                        <option value="B">B - Vehículos particulares</option>
                        <option value="C">C - Vehículos de carga</option>
                        <option value="D">D - Transporte público</option>
                        <option value="E">E - Transporte de carga pesada</option>
                    </select>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el tipo de licencia del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalFechaVencimientoLicencia">
                        <i class="fas fa-calendar-alt"></i>
                        Fecha de Vencimiento de Licencia <span class="text-danger">*</span>
                    </label>
                    <input type="date" 
                           name="fechaVencimientoLicencia" 
                           id="modalFechaVencimientoLicencia" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la fecha de vencimiento de la licencia</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalDni">
                        <i class="fas fa-id-badge"></i>
                        DNI <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="dni" 
                           id="modalDni" 
                           placeholder="Ej: 12345678" 
                           maxlength="20"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el DNI del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalTelefono">
                        <i class="fas fa-phone"></i>
                        Teléfono <span class="text-danger">*</span>
                    </label>
                    <input type="tel" 
                           name="telefono" 
                           id="modalTelefono" 
                           placeholder="Ej: 987654321" 
                           maxlength="20"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el número de teléfono del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalEmail">
                        <i class="fas fa-envelope"></i>
                        Email <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email" 
                           id="modalEmail" 
                           placeholder="Ej: conductor@ejemplo.com"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el correo electrónico del conductor</span>
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
                    Guardar Conductor
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== Modal: Editar Conductor ===================== -->
<div id="editConductorModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-user-edit"></i> Editar Conductor</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="${pageContext.request.contextPath}/administrador/ConductorServlet" id="formEditarConductor">
            <input type="hidden" name="action" value="actualizar">
            <input type="hidden" name="id" id="editIdConductor">
            <div class="modal-body">
                <div class="form-group">
                    <label for="editNombreCompleto">
                        <i class="fas fa-user"></i>
                        Nombre Completo <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="nombreCompleto" 
                           id="editNombreCompleto" 
                           placeholder="Ej: Juan Pérez García" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el nombre completo del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editLicencia">
                        <i class="fas fa-id-card"></i>
                        Número de Licencia <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="licencia" 
                           id="editLicencia" 
                           placeholder="Ej: A001, B002" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el número de licencia del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editTipoLicencia">
                        <i class="fas fa-certificate"></i>
                        Tipo de Licencia <span class="text-danger">*</span>
                    </label>
                    <select name="tipoLicencia" 
                            id="editTipoLicencia" 
                            required>
                        <option value="">Seleccione un tipo</option>
                        <option value="A">A - Motocicletas</option>
                        <option value="B">B - Vehículos particulares</option>
                        <option value="C">C - Vehículos de carga</option>
                        <option value="D">D - Transporte público</option>
                        <option value="E">E - Transporte de carga pesada</option>
                    </select>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el tipo de licencia del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editFechaVencimientoLicencia">
                        <i class="fas fa-calendar-alt"></i>
                        Fecha de Vencimiento de Licencia <span class="text-danger">*</span>
                    </label>
                    <input type="date" 
                           name="fechaVencimientoLicencia" 
                           id="editFechaVencimientoLicencia" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa la fecha de vencimiento de la licencia</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editDni">
                        <i class="fas fa-id-badge"></i>
                        DNI <span class="text-danger">*</span>
                    </label>
                    <input type="text" 
                           name="dni" 
                           id="editDni" 
                           placeholder="Ej: 12345678" 
                           maxlength="20"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el DNI del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editTelefono">
                        <i class="fas fa-phone"></i>
                        Teléfono <span class="text-danger">*</span>
                    </label>
                    <input type="tel" 
                           name="telefono" 
                           id="editTelefono" 
                           placeholder="Ej: 987654321" 
                           maxlength="20"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el número de teléfono del conductor</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="editEmail">
                        <i class="fas fa-envelope"></i>
                        Email
                    </label>
                    <input type="email" 
                           name="email" 
                           id="editEmail" 
                           placeholder="Ej: conductor@ejemplo.com">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el correo electrónico del conductor (opcional)</span>
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
        
        <form method="POST" action="${pageContext.request.contextPath}/administrador/ConductorReporteServlet" id="formEnviarCorreo">
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
                           value="Reporte de Conductores - TELITO BODEGUERO" 
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
                    <strong>Nota:</strong> El archivo Excel se generará con todos los conductores del sistema. 
                    Incluirá todas las columnas (Nombre Completo, Licencia) y tendrá filtros automáticos habilitados.
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

<script>
    // Función para ajustar el posicionamiento de los dropdowns
    function ajustarDropdowns() {
        document.querySelectorAll('#conductorTable td:last-child .dropdown').forEach(function(dropdown) {
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
        const dniInput = document.getElementById('dniInput');
        const fechaVencimientoInput = document.getElementById('fechaVencimientoInput');
        
        // Aplicar filtros al presionar Enter en el campo de búsqueda
        if (searchInput && filterForm) {
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    filterForm.submit();
                }
            });
        }
        
        // Aplicar filtros al presionar Enter en el campo de DNI
        if (dniInput && filterForm) {
            dniInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    filterForm.submit();
                }
            });
        }
        
        // Aplicar filtros al cambiar la fecha de vencimiento
        if (fechaVencimientoInput && filterForm) {
            fechaVencimientoInput.addEventListener('change', function() {
                filterForm.submit();
            });
        }
    });

    function confirmarEliminacion(id, nombre) {
        showConfirm(
            '¿Estás seguro de eliminar al conductor "' + nombre + '"? Esta acción no se puede deshacer.',
            function() {
                window.location.href = '${pageContext.request.contextPath}/administrador/ConductorServlet?action=eliminar&id=' + id;
            },
            'Confirmar eliminación'
        );
    }
    
    // ===================== Manejo del Modal de Agregar Conductor =====================
    document.addEventListener('DOMContentLoaded', function() {
        const addConductorModal = document.getElementById('addConductorModal');
        const openAddConductorModalBtn = document.getElementById('openAddConductorModalBtn');
        const closeAddConductorModalBtn = document.querySelector('#addConductorModal .modal-close');
        const cancelAddConductorModalBtn = document.querySelector('#addConductorModal .modal-cancel');
        
        // Función para abrir el modal de agregar conductor
        function abrirModalAgregarConductor() {
            if (addConductorModal) {
                // Limpiar formulario
                document.getElementById('modalNombreCompleto').value = '';
                document.getElementById('modalLicencia').value = '';
                document.getElementById('modalTipoLicencia').value = '';
                document.getElementById('modalFechaVencimientoLicencia').value = '';
                document.getElementById('modalDni').value = '';
                document.getElementById('modalTelefono').value = '';
                document.getElementById('modalEmail').value = '';
                
                addConductorModal.classList.add('show');
                addConductorModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            } else {
                console.error('Modal addConductorModal no encontrado');
            }
        }
        
        // Función para cerrar el modal de agregar conductor
        function cerrarModalAgregarConductor() {
            if (addConductorModal) {
                addConductorModal.classList.remove('show');
                addConductorModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Event listeners para el modal de agregar conductor
        if (openAddConductorModalBtn) {
            openAddConductorModalBtn.addEventListener('click', function(e) {
                e.preventDefault();
                abrirModalAgregarConductor();
            });
        } else {
            console.error('Botón openAddConductorModalBtn no encontrado');
        }
        
        if (closeAddConductorModalBtn) {
            closeAddConductorModalBtn.addEventListener('click', cerrarModalAgregarConductor);
        }
        
        if (cancelAddConductorModalBtn) {
            cancelAddConductorModalBtn.addEventListener('click', cerrarModalAgregarConductor);
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (addConductorModal) {
            addConductorModal.addEventListener('click', function(event) {
                if (event.target === addConductorModal) {
                    cerrarModalAgregarConductor();
                }
            });
        }
        
        // Cerrar modal con la tecla ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && addConductorModal && addConductorModal.classList.contains('show')) {
                cerrarModalAgregarConductor();
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
                document.getElementById('modalAsunto').value = 'Reporte de Conductores - TELITO BODEGUERO';
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
            if (event.key === 'Escape' && editConductorModal && editConductorModal.classList.contains('show')) {
                cerrarModalEditarConductor();
            }
        });
        
        // ===================== Manejo del Modal de Editar Conductor =====================
        const editConductorModal = document.getElementById('editConductorModal');
        const closeEditConductorModalBtn = document.querySelector('#editConductorModal .modal-close');
        const cancelEditConductorModalBtn = document.querySelector('#editConductorModal .modal-cancel');
        
        // Función para abrir el modal de edición
        function abrirModalEditarConductor() {
            if (editConductorModal) {
                editConductorModal.classList.add('show');
                editConductorModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        }
        
        // Función para cerrar el modal de edición
        function cerrarModalEditarConductor() {
            if (editConductorModal) {
                editConductorModal.classList.remove('show');
                editConductorModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Función global para editar conductor
        window.editarConductor = function(idConductor) {
            const editConductorModal = document.getElementById('editConductorModal');
            const originalModalBodyContent = editConductorModal.querySelector('.modal-body').innerHTML;
            
            // Mostrar loading overlay
            const modalBody = editConductorModal.querySelector('.modal-body');
            if (modalBody) {
                modalBody.innerHTML = '<div class="text-center py-5"><i class="fas fa-spinner fa-spin fa-2x mb-3" style="color: #6F4E37;"></i><p>Cargando datos del conductor...</p></div>';
            }
            
            abrirModalEditarConductor();
            
            fetch('${pageContext.request.contextPath}/administrador/ConductorServlet?action=obtenerConductorJson&id=' + idConductor, {
                method: 'GET',
                headers: { 'Content-Type': 'application/json' }
            })
            .then(response => {
                if (!response.ok) {
                    return response.json().then(errorData => {
                        throw new Error(errorData.mensaje || 'Error al cargar los datos del conductor');
                    });
                }
                return response.json();
            })
            .then(data => {
                // Verificar si hay un error en la respuesta
                if (data.exito === false) {
                    throw new Error(data.mensaje || 'Error al cargar los datos del conductor');
                }
                
                // Restore original form HTML
                modalBody.innerHTML = originalModalBodyContent;
                
                // Populate form fields
                document.getElementById('editIdConductor').value = data.idConductor || '';
                document.getElementById('editNombreCompleto').value = data.nombreCompleto || '';
                document.getElementById('editLicencia').value = data.licencia || '';
                document.getElementById('editTipoLicencia').value = data.tipoLicencia || '';
                
                // Formatear fecha para el input date (YYYY-MM-DD)
                if (data.fechaVencimientoLicencia) {
                    try {
                        // Si viene como string en formato YYYY-MM-DD, usarlo directamente
                        if (typeof data.fechaVencimientoLicencia === 'string' && data.fechaVencimientoLicencia.match(/^\d{4}-\d{2}-\d{2}/)) {
                            document.getElementById('editFechaVencimientoLicencia').value = data.fechaVencimientoLicencia.substring(0, 10);
                        } else {
                            // Si viene como objeto Date o timestamp
                            const fecha = new Date(data.fechaVencimientoLicencia);
                            if (!isNaN(fecha.getTime())) {
                                const fechaFormateada = fecha.toISOString().split('T')[0];
                                document.getElementById('editFechaVencimientoLicencia').value = fechaFormateada;
                            } else {
                                document.getElementById('editFechaVencimientoLicencia').value = '';
                            }
                        }
                    } catch (e) {
                        console.error('Error al formatear fecha:', e);
                        document.getElementById('editFechaVencimientoLicencia').value = '';
                    }
                } else {
                    document.getElementById('editFechaVencimientoLicencia').value = '';
                }
                
                document.getElementById('editDni').value = data.dni || '';
                document.getElementById('editTelefono').value = data.telefono || '';
                document.getElementById('editEmail').value = data.email || '';
            })
            .catch(error => {
                console.error('Error al cargar conductor:', error);
                cerrarModalEditarConductor();
                alert('Error al cargar los datos del conductor: ' + (error.message || 'Por favor, intenta nuevamente.'));
            });
        };
        
        // Event listeners para cerrar el modal
        if (closeEditConductorModalBtn) {
            closeEditConductorModalBtn.addEventListener('click', cerrarModalEditarConductor);
        }
        
        if (cancelEditConductorModalBtn) {
            cancelEditConductorModalBtn.addEventListener('click', cerrarModalEditarConductor);
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (editConductorModal) {
            editConductorModal.addEventListener('click', function(event) {
                if (event.target === editConductorModal) {
                    cerrarModalEditarConductor();
                }
            });
        }
        
        // Usar delegación de eventos en el modal para capturar el submit del formulario
        if (editConductorModal) {
            editConductorModal.addEventListener('submit', function(event) {
                // Verificar que el evento venga del formulario de edición
                const form = event.target;
                if (form && form.id === 'formEditarConductor') {
                    event.preventDefault();
                    event.stopPropagation();
                    
                    console.log('Formulario de edición detectado - previniendo envío normal');
                    
                    // Validar que los campos requeridos estén presentes
                    const id = document.getElementById('editIdConductor');
                    const nombreCompleto = document.getElementById('editNombreCompleto');
                    const licencia = document.getElementById('editLicencia');
                    
                    if (!id || !id.value || id.value.trim() === '') {
                        alert('Error: El ID del conductor no está presente. Por favor, cierra el modal y vuelve a intentar.');
                        return;
                    }
                    
                    if (!nombreCompleto || !nombreCompleto.value || nombreCompleto.value.trim() === '') {
                        alert('El nombre completo es requerido.');
                        return;
                    }
                    
                    if (!licencia || !licencia.value || licencia.value.trim() === '') {
                        alert('El número de licencia es requerido.');
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
                            alert(data.mensaje || 'Conductor actualizado exitosamente.');
                            cerrarModalEditarConductor();
                            location.reload();
                        } else {
                            alert(data.mensaje || 'Error al actualizar el conductor.');
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
</script>

<!-- Bootstrap JS ya está incluido en footer.jsp -->
</body>
</html>

