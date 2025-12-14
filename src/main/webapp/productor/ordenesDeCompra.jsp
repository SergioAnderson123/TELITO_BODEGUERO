<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %>
<%--
    JSP: Órdenes de Compra
    Propósito: Mostrar las órdenes de compra del productor con detalles de productos, lotes y destinos.
    Atributos esperados (request):
      - listaOrdenes (ArrayList<OrdenCompra>) - Lista de órdenes de compra
      - totalOrdenes (int) - Total de órdenes
      - ordenesPendientes (int) - Órdenes pendientes
      - ordenesCompletadas (int) - Órdenes completadas
    Navegación: Sidebar con sección "Órdenes de Compra" activa.
--%>

<%
    // Obtener datos del servlet
    List<Object[]> listaOrdenes = (List<Object[]>) request.getAttribute("listaOrdenes");
    if (listaOrdenes == null) {
        listaOrdenes = new ArrayList<>();
    }
    
    // Obtener total de órdenes del servlet (paginación)
    Integer totalOrdenesAttr = (Integer) request.getAttribute("totalRows");
    int totalOrdenes = (totalOrdenesAttr != null) ? totalOrdenesAttr : listaOrdenes.size();
    
    // Obtener estadísticas completas del servlet (calculadas sobre TODAS las órdenes, no solo la página actual)
    Integer ordenesCompletadasAttr = (Integer) request.getAttribute("ordenesCompletadas");
    int ordenesCompletadas = (ordenesCompletadasAttr != null) ? ordenesCompletadasAttr : 0;
    
    Integer ordenesPendientesAttr = (Integer) request.getAttribute("ordenesPendientes");
    int ordenesPendientes = (ordenesPendientesAttr != null) ? ordenesPendientesAttr : 0;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Órdenes de Compra - Telito Bodeguero</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Incluir modales personalizados -->
    <jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />

    <!-- Custom CSS (turquesa/verde agua) -->
    <style>
        /* =====================
           Paleta y tokens
        ====================== */
        :root {
            --turquoise-dark: #006d77;
            --seafoam: #83c5be;
            --seafoam-light: #edf6f9;
            --white: #ffffff;
            --text-dark: #2b2d42;
            --text-muted: #6c757d;
            --border-color: #e9ecef;
        }

        /* =====================
           Layout base
        ====================== */
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            background-color: var(--seafoam-light);
            color: var(--text-dark);
        }
        
        /* =====================
           Contenedores
        ====================== */
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border-color);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-content { margin-top: 70px; padding: 20px; }
        .page-header { margin-bottom: 0.5rem; padding-top: 0.5rem; padding-bottom: 0.5rem; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 0; font-size: 1.4rem; line-height: 1.2; }
        .page-header p { color: var(--text-muted); font-size: 0.85rem; margin-top: 0.2rem; margin-bottom: 0; }
        .pageheader-title {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #00a896 !important;
        }
        .pageheader-title i {
            color: var(--seafoam);
        }

        /* =====================
           Sidebar (igual a logística y almacenero)
        ====================== */
        .nav-left-sidebar {
            width: 250px;
            background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%);
            min-height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            z-index: 1000;
            box-shadow: 3px 0 15px rgba(0,0,0,.12);
        }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
        .nav-link {
            color: rgba(255,255,255,.95) !important;
            padding: 13px 20px;
            border-radius: 10px;
            margin: 6px 15px;
            transition: all .3s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex;
            align-items: center;
            font-weight: 500;
            position: relative;
            overflow: hidden;
        }
        .nav-link::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: #fff;
            transform: scaleY(0);
            transition: transform .3s ease;
            border-radius: 0 4px 4px 0;
        }
        .nav-link:hover, .nav-link.active {
            background-color: rgba(255,255,255,.25);
            color: #fff !important;
            transform: translateX(8px);
            box-shadow: 0 4px 12px rgba(0,0,0,.15);
        }
        .nav-link:hover::before, .nav-link.active::before {
            transform: scaleY(1);
        }
        .nav-link i { margin-right: 12px; width: 22px; font-size: 1.1rem; }
        .nav-divider {
            color: rgba(255,255,255,.95);
            font-weight: 700;
            padding: 18px 20px 8px;
            margin-top: 25px;
            font-size: .8rem;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            border-top: 1px solid rgba(255,255,255,.15);
        }

        /* =====================
           Tarjetas/Tabla/Formularios (igual a logística y almacenero)
        ====================== */
        .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 40px; }
        .stat-card {
            background-color: var(--white);
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }
        .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: var(--text-muted); font-weight: 600; }
        .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: var(--turquoise-dark); }

        /* Card principal */
        .card {
            background-color: var(--white);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            margin-bottom: 40px;
            border: none;
            transition: box-shadow .3s ease;
        }
        .card:hover { box-shadow: 0 8px 24px rgba(0,0,0,.1); }
        .card-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 25px; 
            background: linear-gradient(135deg, #00a896 0%, #83c5be 100%);
            color: white;
            border-radius: 12px 12px 0 0;
            padding: 20px 30px;
            margin: -30px -30px 25px -30px;
            box-shadow: 0 4px 12px rgba(0,168,150,.25);
        }
        .card-header h2, .card-header h5 { margin: 0; color: white; font-weight: 700; }
        .card-body { padding: 0; }

        /* Formularios y Botones */
        form label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--text-dark); }
        form input, form select, form textarea {
            width: 100%; padding: 12px; border: 1.5px solid var(--border-color); border-radius: 8px; box-sizing: border-box; font-size: 1rem;
        }
        button, .btn {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            color: var(--white);
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: transform .2s, box-shadow .2s;
        }
        .btn-secondary { background: #8d99ae; }
        .btn-primary {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            border: none;
            color: #fff;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(0,168,150,.35);
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, #00b8a3 0%, #02a190 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0,168,150,.45);
        }
        .btn-info, a.btn-info, button.btn-info {
            background: linear-gradient(160deg, #17a2b8 0%, #20c997 100%) !important;
            border: none !important;
        }
        .btn-success {
            background: linear-gradient(160deg, #28a745 0%, #20c997 100%);
        }
        .btn-warning {
            background: linear-gradient(160deg, #ffc107 0%, #fd7e14 100%);
            color: #000;
        }
        .btn-danger {
            background: linear-gradient(160deg, #dc3545 0%, #e74c3c 100%);
        }
        button:hover, .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 14px rgba(0, 109, 119, 0.25);
        }

        /* Table card - igual a logística y almacenero */
        .table-card {
            background: var(--white);
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,.06);
            border: none;
            margin-bottom: 30px;
            overflow: hidden;
        }
        .table-card .card-header {
            background: linear-gradient(135deg, #00a896 0%, #83c5be 100%);
            color: #fff;
            border-radius: 12px 12px 0 0;
            padding: 20px 30px;
            margin: 0;
        }
        .table-card .card-header h5, .table-card .card-header small { color: #fff !important; }
        .table-card .card-body {
            padding: 0;
        }
        
        /* Tabla - Estilo igual a gestión de usuarios y mis productos */
        table { 
            width: 100%; 
            border-collapse: collapse; 
            font-size: 0.9rem; 
            margin-bottom: 0 !important; 
            table-layout: auto;
        }
        th, td { 
            padding: 0.4rem 0.5rem; 
            text-align: center; 
            border-bottom: 1px solid var(--border-color); 
            font-size: 0.85rem;
        }
        tbody td {
            padding: 0.35rem 0.5rem;
        }
        thead th { 
            background-color: #f8f9fa; 
            font-weight: 600; 
            color: var(--text-muted); 
            text-transform: uppercase; 
            font-size: 0.85rem; 
            vertical-align: middle;
        }
        tbody tr { 
            vertical-align: middle; 
            transition: all 0.3s ease;
            cursor: pointer;
        }
        tbody tr:hover { 
            background-color: rgba(0, 168, 150, 0.1) !important; 
            transform: scale(1.01);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        tbody tr:hover td {
            color: var(--turquoise-dark);
            font-weight: 500;
        }

        /* Botón Ver Lotes/Editar - Estilo teal/verde agua igual a mis productos */
        .btn-ver-lotes {
            background: linear-gradient(135deg, #20c997 0%, #17a2b8 100%) !important;
            border: none !important;
            color: white !important;
            font-size: 0.8rem !important;
            padding: 0.35rem 0.6rem !important;
            font-weight: 500 !important;
            transition: all 0.2s ease !important;
            border-radius: 6px !important;
        }
        .btn-ver-lotes:hover {
            transform: translateY(-1px) !important;
            box-shadow: 0 4px 8px rgba(32, 201, 151, 0.3) !important;
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%) !important;
        }
        .btn-ver-lotes:focus {
            box-shadow: 0 0 0 0.2rem rgba(32, 201, 151, 0.25) !important;
        }

        /* Badges de estado */
        .badge-pendiente {
            background: linear-gradient(160deg, #ffc107 0%, #fd7e14 100%);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-completada {
            background: linear-gradient(160deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        /* Paginación */
        .pagination .page-link {
            color: var(--turquoise-dark);
            border-color: var(--border-color);
            padding: 10px 15px;
            border-radius: 8px;
            margin: 0 2px;
        }
        .pagination .page-link:hover {
            background-color: var(--seafoam-light);
            border-color: var(--seafoam);
        }
        .pagination .page-item.active .page-link {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            border-color: var(--turquoise-dark);
            color: white;
        }

        /* =====================
           Botón Hamburguesa
        ====================== */
        .sidebar-toggle {
            display: none;
            background: none;
            border: none;
            color: var(--turquoise-dark);
            font-size: 1.5rem;
            padding: 8px 12px;
            cursor: pointer;
            margin-right: 15px;
            transition: color 0.3s ease;
        }
        .sidebar-toggle:hover {
            color: var(--seafoam);
        }
        
        /* Overlay para móvil */
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .sidebar-overlay.active {
            opacity: 1;
        }

        /* Estilos para el header en móvil */
        .navbar-nav .nav-link span {
            white-space: nowrap;
        }
        
        /* =====================
           Responsive
        ====================== */
        @media (max-width: 992px) {
            .sidebar-toggle {
                display: inline-block;
            }
            .nav-left-sidebar { 
                position: fixed; 
                transform: translateX(-100%); 
                transition: transform 0.3s ease;
                z-index: 1000;
            }
            .nav-left-sidebar.open { 
                transform: translateX(0); 
            }
            .sidebar-overlay {
                display: block;
            }
            .dashboard-header { 
                left: 0; 
                padding: 0 10px;
            }
            .dashboard-header .navbar {
                padding: 0;
            }
            .dashboard-header .container-fluid {
                padding: 0 10px;
            }
            .navbar-brand span {
                font-size: 0.9rem;
            }
            /* Ocultar nombre del usuario en móvil, solo mostrar avatar */
            .navbar-nav .nav-link span {
                display: none;
            }
            .navbar-nav .nav-link {
                padding: 8px 12px;
            }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
            .dashboard-content { padding: 20px; }
            .stats-container { grid-template-columns: 1fr; }
            
            /* Asegurar que los botones sean clickeables en móvil */
            .btn,
            button,
            a[href] {
                touch-action: manipulation;
                -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
                cursor: pointer;
            }
        }
        
        @media (max-width: 576px) {
            .navbar-brand span {
                display: none;
            }
            .navbar-brand i {
                margin-right: 0;
            }
        }
        
        /* ===================== Estilos para Modal de Enviar por Correo ===================== */
        #sendOrdenesModal.modal { 
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
        #sendOrdenesModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #sendOrdenesModal .modal-content { 
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
        #sendOrdenesModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #sendOrdenesModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #sendOrdenesModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #sendOrdenesModal .modal-close { 
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
        #sendOrdenesModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #sendOrdenesModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #sendOrdenesModal .form-group {
            margin-bottom: 1.25rem;
        }
        #sendOrdenesModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #sendOrdenesModal .form-group label i {
            color: #00a896;
            font-size: 0.85rem;
        }
        #sendOrdenesModal .form-group input,
        #sendOrdenesModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #sendOrdenesModal .form-group input:focus,
        #sendOrdenesModal .form-group textarea:focus {
            border-color: #00a896;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #sendOrdenesModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #sendOrdenesModal .form-hint i {
            color: #00a896;
            margin-top: 2px;
        }
        #sendOrdenesModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #sendOrdenesModal .modal-footer button {
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
        #sendOrdenesModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #sendOrdenesModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #sendOrdenesModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #sendOrdenesModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,168,150,0.4);
        }
        @media (max-width: 768px) {
            #sendOrdenesModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #sendOrdenesModal.show {
                padding: 10px;
            }
        }
    </style>
</head>
<body>

<div class="dashboard-main-wrapper">
    <!-- ===================== Overlay para móvil ===================== -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>

    <!-- ===================== Header / Topbar ===================== -->
    <div class="dashboard-header">
        <nav class="navbar navbar-expand">
            <div class="container-fluid">
                <!-- Botón Hamburguesa -->
                <button class="sidebar-toggle" id="sidebarToggle" type="button" aria-label="Toggle sidebar">
                    <i class="fas fa-bars"></i>
                </button>
                <!-- Brand -->
                <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                    <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                    <span>Telito Bodeguero</span>
                </a>

                <!-- Right actions -->
                <ul class="navbar-nav ms-auto">
                    <!-- Notificaciones -->
                    <li class="nav-item dropdown me-3">
                        <a class="nav-link position-relative" href="javascript:void(0);" role="button" id="notificacionesDropdown" data-bs-toggle="dropdown" aria-expanded="false" style="padding: 8px 12px;" onclick="event.preventDefault();">
                            <i class="fas fa-bell" style="font-size: 1.3rem; color: var(--turquoise-dark);"></i>
                            <span class="badge-notificacion" id="badgeNotificaciones" style="display: none;">0</span>
                        </a>
                        <div class="dropdown-menu dropdown-menu-end notificaciones-dropdown" aria-labelledby="notificacionesDropdown" style="width: 380px;">
                            <div class="dropdown-header d-flex justify-content-between align-items-center" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; padding: 12px 20px;">
                                <h6 class="mb-0"><i class="fas fa-bell me-2"></i>Notificaciones</h6>
                                <button class="btn btn-sm btn-light" onclick="marcarTodasLeidas()" style="font-size: 0.75rem; padding: 2px 8px;">
                                    <i class="fas fa-check-double me-1"></i>Marcar todas
                                </button>
                            </div>
                            <div id="listaNotificaciones" style="max-height: 400px; overflow-y: auto; overflow-x: hidden;">
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-spinner fa-spin fa-2x mb-2"></i>
                                    <p class="mb-0">Cargando notificaciones...</p>
                                </div>
                            </div>
                            <div class="dropdown-divider m-0"></div>
                            <a class="dropdown-item text-center fw-bold py-2" href="javascript:void(0);" onclick="event.preventDefault(); mostrarModalTodasNotificaciones();" style="color: #00a896 !important;">
                                <i class="fas fa-list me-2"></i>Ver todas las notificaciones
                            </a>
                        </div>
                    </li>
                    
                    <!-- Usuario -->
                    <li class="nav-item dropdown">
                        <%
                            com.example.telito.administrador.beans.Usuario usuarioHeaderOrdenes = 
                                (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                            String nombreCompletoOrdenes = usuarioHeaderOrdenes != null ? 
                                usuarioHeaderOrdenes.getNombres() + " " + usuarioHeaderOrdenes.getApellidos() : "Usuario";
                            String fotoUrlOrdenes = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
                            if (usuarioHeaderOrdenes != null) {
                                String foto = usuarioHeaderOrdenes.getFotoPerfil();
                                if (foto != null && !foto.trim().isEmpty()) {
                                    if (foto.startsWith("http://") || foto.startsWith("https://")) {
                                        fotoUrlOrdenes = foto;
                                    } else {
                                        fotoUrlOrdenes = request.getContextPath() + "/" + foto;
                                    }
                                } else {
                                    fotoUrlOrdenes = usuarioHeaderOrdenes.getFotoPerfilUrl();
                                }
                            }
                        %>
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <img src="<%= fotoUrlOrdenes %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                            <span style="color:#006d77;"><%= nombreCompletoOrdenes %></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="<%= request.getContextPath() %>/perfil"><i class="fas fa-user me-2"></i>Perfil</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesion</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </div>

    <!-- ===================== Sidebar / Navegación ===================== -->
    <div class="nav-left-sidebar">
        <div class="menu-list">
            <nav class="navbar navbar-expand">
                <ul class="navbar-nav flex-column w-100">
                    <li class="nav-divider"><i class="fas fa-bars me-2"></i>Menú</li>
                    <!-- Inicio -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=inicio">
                            <i class="fas fa-home"></i>Inicio
                        </a>
                    </li>
                    <!-- Mis productos -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                            <i class="fas fa-shopping-cart"></i>Mis Productos
                        </a>
                    </li>
                    <!-- Órdenes de Compra -->
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra">
                            <i class="fas fa-chart-pie"></i>Órdenes de Compra
                        </a>
                    </li>
                    <!-- Registrar lotes -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote">
                            <i class="fas fa-boxes"></i>Registrar Lotes
                        </a>
                    </li>
                    <!-- Actualizar precios -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formActualizarPrecios">
                            <i class="fas fa-tags"></i>Actualizar Precios
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>

    <!-- ===================== Contenido principal ===================== -->
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-chart-pie me-2"></i>Órdenes de Compra</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Gestiona y monitorea las órdenes de compra de tus productos.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <a href="<%= request.getContextPath() %>/productor/OrdenCompraReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <button type="button" id="openSendOrdenesModalBtn" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </button>
                    </div>
                </div>
            </div>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="stats-container">
                <div class="stat-card">
                    <h3>Total de Órdenes</h3>
                    <p><%= totalOrdenes %></p>
                </div>
                <div class="stat-card">
                    <h3>Órdenes Pendientes</h3>
                    <p><%= ordenesPendientes %></p>
                </div>
                <div class="stat-card">
                    <h3>Órdenes Completadas</h3>
                    <p><%= ordenesCompletadas %></p>
                </div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros ===================== -->
            <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                    <div class="col-md-4">
                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                        <div class="input-group">
                            <input id="searchInput" type="text" class="form-control form-control-sm shadow-sm" placeholder="Código de orden o producto..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-filter me-1"></i>Estado</label>
                        <select id="statusFilter" class="form-select form-select-sm shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <option value="">Todos los estados</option>
                            <option value="Pendiente">Pendiente</option>
                            <option value="Aprobado">Aprobado</option>
                            <option value="Rechazado">Rechazado</option>
                            <option value="Recibido">Recibido</option>
                            <option value="En Proceso">En Proceso</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <a href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <i class="fas fa-sync-alt me-1"></i>Limpiar
                        </a>
                    </div>
                </div>
            </div>

            <!-- ===================== Card: Tabla de órdenes ===================== -->
            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-chart-pie me-2"></i>Órdenes de Compra</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todas tus órdenes de compra</small>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">
                            <table id="ordenesTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                    <thead class="table-light">
                        <tr>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                <i class="fas fa-hashtag me-1"></i>CÓDIGO DE ORDEN
                            </th>
                            <th class="fw-semibold" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                <i class="fas fa-box me-1"></i>NOMBRE DEL PRODUCTO
                            </th>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                <i class="fas fa-boxes me-1"></i>CANTIDAD DE PAQUETES
                            </th>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                <i class="fas fa-dollar-sign me-1"></i>PRECIO
                            </th>
                            <th class="fw-semibold" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                <i class="fas fa-user me-1"></i>SOLICITANTE DE COMPRA
                            </th>
                            <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                <i class="fas fa-info-circle me-1"></i>ESTADO
                            </th>
                            <th class="fw-semibold" style="width: 9%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                <i class="fas fa-cog me-1"></i>ACCIONES
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                            Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                            Integer sizeObj = (Integer) request.getAttribute("size");
                            int currentPage = (currentPageObj != null) ? currentPageObj : 1;
                            int size = (sizeObj != null) ? sizeObj : 5;
                        %>
                        <% for (Object orden : listaOrdenes) { %>
                            <% Object[] ordenData = (Object[]) orden; %>
                            <tr class="align-middle" data-codigo="<%= ordenData[1] %>" 
                                data-producto="<%= ordenData[2] %>" 
                                data-estado="<%= ordenData[6] %>" 
                                data-destino="<%= ordenData[5] %>"
                                style="padding: 0;">
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= ordenData[1] %></strong></td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= ordenData[2] %></td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= ordenData[3] %> paquetes</td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>S/ <%= String.format("%.2f", (Double) ordenData[4]) %></strong></td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= ordenData[5] %></td>
                                <td>
                                    <% 
                                        String estadoOrden = (String) ordenData[6];
                                        if ("Pendiente".equals(estadoOrden)) { 
                                    %>
                                        <span class="badge-pendiente">
                                            <i class="fas fa-clock me-1"></i>Pendiente
                                        </span>
                                    <% } else if ("Aprobado".equals(estadoOrden)) { %>
                                        <span class="badge" style="background: linear-gradient(160deg, #007bff 0%, #0056b3 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;">
                                            <i class="fas fa-thumbs-up me-1"></i>Aprobado
                                        </span>
                                    <% } else if ("Recibido".equals(estadoOrden)) { %>
                                        <span class="badge-completada" style="cursor: pointer;" onclick="if(typeof cambiarEstado === 'function') { cambiarEstado(<%= ordenData[0] != null ? ordenData[0] : 0 %>, 'En Proceso', this); } else { console.error('cambiarEstado no está definida'); alert('Error: La función cambiarEstado no está disponible'); }" title="Click para cambiar a 'En Proceso'">
                                            <i class="fas fa-check me-1"></i>Recibido
                                        </span>
                                    <% } else if ("En Proceso".equals(estadoOrden)) { %>
                                        <span class="badge" style="background: linear-gradient(160deg, #ffc107 0%, #ff9800 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;">
                                            <i class="fas fa-spinner me-1"></i>En Proceso
                                        </span>
                                    <% } else if ("Rechazado".equals(estadoOrden)) { %>
                                        <span class="badge" style="background: linear-gradient(160deg, #dc3545 0%, #c82333 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;">
                                            <i class="fas fa-times me-1"></i>Rechazado
                                        </span>
                                    <% } else { %>
                                        <span class="badge-completada">
                                            <i class="fas fa-check me-1"></i><%= estadoOrden %>
                                        </span>
                                    <% } %>
                                </td>
                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <% if ("En Proceso".equals(estadoOrden)) { %>
                                        <button type="button" class="btn btn-sm shadow-sm btn-ver-lotes" 
                                                onclick="editarOrden('<%= ordenData[0] %>')"
                                                title="Editar orden">
                                            <i class="fas fa-edit"></i> Editar
                                        </button>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <%-- Incluir componente de paginación --%>
                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Asignar Lote a Orden -->
<div class="modal fade" id="asignarLoteModal" tabindex="-1" aria-labelledby="asignarLoteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content" style="border-radius: 16px; border: none; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
            <div class="modal-header text-white" style="background: linear-gradient(135deg, #00a896 0%, #028f80 100%); border-radius: 16px 16px 0 0; padding: 20px 25px; border-bottom: none;">
                <h5 class="modal-title d-flex align-items-center" id="asignarLoteModalLabel" style="font-weight: 600; font-size: 1.2rem;">
                    <span class="d-flex align-items-center justify-content-center me-3" style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 10px; width: 45px; height: 45px;">
                        <i class="fas fa-boxes" style="font-size: 1.2rem;"></i>
                    </span>
                    Asignar Lote a Orden
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" style="opacity: 1; width: 36px; height: 36px; border-radius: 50%; background: rgba(255,255,255,0.15); display: flex; align-items: center; justify-content: center; border: none; color: white;" onmouseover="this.style.background='rgba(255,255,255,0.25)';" onmouseout="this.style.background='rgba(255,255,255,0.15)';">
                    <i class="fas fa-times" style="color: white; font-size: 18px;"></i>
                </button>
            </div>
            <div class="modal-body" style="padding: 25px; background: #f8f9fa;">
                <div id="loadingLotes" class="text-center py-5">
                    <div class="spinner-border" style="color: #00a896; width: 3rem; height: 3rem;" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-3 text-muted" style="font-size: 0.95rem;">Cargando lotes disponibles...</p>
                </div>
                <div id="tableLotesContainer" style="display: none;">
                    <div class="alert" style="background: linear-gradient(135deg, rgba(0,168,150,0.1) 0%, rgba(2,143,128,0.1) 100%); border: 2px solid #00a896; border-radius: 12px; padding: 15px 20px; margin-bottom: 20px;">
                        <i class="fas fa-info-circle me-2" style="color: #00a896; font-size: 1.1rem;"></i>
                        <strong style="color: #00a896;">Orden:</strong> <span id="modalOrdenNumero" style="color: #495057; font-weight: 600;"></span> | 
                        <strong style="color: #00a896;">Producto:</strong> <span id="modalProductoNombre" style="color: #495057; font-weight: 600;"></span>
                    </div>
                    <div class="table-responsive" style="background: white; border-radius: 12px; padding: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                        <table class="table table-hover mb-0" style="font-size: 0.9rem;">
                            <thead style="background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);">
                                <tr>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; width: 80px; text-align: center;">
                                        <i class="fas fa-check-circle me-1" style="color: #00a896;"></i>Seleccionar
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-barcode me-1" style="color: #00a896;"></i>Código Lote
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-tag me-1" style="color: #00a896;"></i>SKU
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-box me-1" style="color: #00a896;"></i>Producto
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase; text-align: center;">
                                        <i class="fas fa-cubes me-1" style="color: #00a896;"></i>Paquetes
                                    </th>
                                    <th style="padding: 12px; font-weight: 600; font-size: 0.85rem; text-transform: uppercase;">
                                        <i class="fas fa-calendar-alt me-1" style="color: #00a896;"></i>Fecha de Vencimiento
                                    </th>
                                </tr>
                            </thead>
                            <tbody id="tableLotesBody">
                                <!-- Los lotes se cargarán dinámicamente aquí -->
                            </tbody>
                        </table>
                    </div>
                    <div id="noLotesMessage" class="alert alert-warning" style="display: none; border-radius: 12px; margin-top: 15px;">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        No hay lotes disponibles para este producto.
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="background: white; border-top: 2px solid #e9ecef; padding: 20px 25px; border-radius: 0 0 16px 16px;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="padding: 10px 20px; border-radius: 8px; font-weight: 600;">
                    <i class="fas fa-arrow-left me-2"></i>Volver
                </button>
                <button type="button" class="btn btn-primary" id="btnEnviarLote" onclick="asignarLoteAOrden()" style="padding: 10px 20px; border-radius: 8px; font-weight: 600; background: linear-gradient(135deg, #00a896 0%, #028f80 100%); border: none;">
                    <i class="fas fa-paper-plane me-2"></i>Enviar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Funcionalidad de búsqueda y filtros
    const searchInput = document.getElementById('searchInput');
    const statusFilter = document.getElementById('statusFilter');
    const table = document.getElementById('ordenesTable');
    const tbody = table.querySelector('tbody');

    function normalize(text) {
        return (text || '').toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    function applyFilters() {
        const searchTerm = normalize(searchInput.value);
        const status = statusFilter.value;

        const rows = Array.from(tbody.querySelectorAll('tr'));

        rows.forEach(row => {
            const codigo = normalize(row.dataset.codigo);
            const producto = normalize(row.dataset.producto);
            const rowStatus = row.dataset.estado;

            const matchesSearch = !searchTerm || 
                codigo.includes(searchTerm) || 
                producto.includes(searchTerm);
            const matchesStatus = !status || rowStatus === status;

            row.style.display = (matchesSearch && matchesStatus) ? '' : 'none';
        });
    }

    function limpiarFiltros() {
        searchInput.value = '';
        statusFilter.value = '';
        applyFilters();
        // Redirigir para limpiar filtros del servidor también
        window.location.href = '<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra';
    }

    // Event listeners
    searchInput.addEventListener('input', applyFilters);
    statusFilter.addEventListener('change', applyFilters);

    // Variables globales para el modal
    let ordenActualId = null;
    let ordenActualNumero = null;
    let productoActualNombre = null;
    let productoActualId = null;
    let loteSeleccionadoId = null;

    // Función para editar orden (asignar lote)
    function editarOrden(idOrden) {
        // Buscar los datos de la orden en la tabla
        const rows = Array.from(tbody.querySelectorAll('tr'));
        let ordenData = null;
        
        for (let row of rows) {
            const cells = row.querySelectorAll('td');
            if (cells.length > 0) {
                // Buscar por el ID de la orden (necesitamos agregarlo como data-attribute)
                // Por ahora usamos el índice de la fila
                ordenData = {
                    numero: cells[1].textContent.trim(),
                    producto: cells[2].textContent.trim()
                };
                break;
            }
        }
        
        // Guardar datos globales
        ordenActualId = idOrden;
        ordenActualNumero = ordenData ? ordenData.numero : idOrden;
        productoActualNombre = ordenData ? ordenData.producto : 'Producto';
        loteSeleccionadoId = null;
        
        // Actualizar información en el modal
        document.getElementById('modalOrdenNumero').textContent = ordenActualNumero;
        document.getElementById('modalProductoNombre').textContent = productoActualNombre;
        
        // Mostrar loading
        document.getElementById('loadingLotes').style.display = 'block';
        document.getElementById('tableLotesContainer').style.display = 'none';
        
        // Abrir el modal
        const modal = new bootstrap.Modal(document.getElementById('asignarLoteModal'));
        modal.show();
        
        // Cargar los lotes disponibles
        cargarLotesDisponibles(idOrden);
    }
    
    // Función para cargar lotes disponibles
    function cargarLotesDisponibles(idOrden) {
        console.log('=== CARGANDO LOTES ===');
        console.log('ID Orden:', idOrden);
        
        const url = '<%= request.getContextPath() %>/ProductorServlet?action=obtenerLotesParaOrden&idOrden=' + idOrden;
        console.log('URL:', url);
        
        fetch(url)
            .then(response => {
                console.log('Response status:', response.status);
                console.log('Response headers:', response.headers);
                return response.text();
            })
            .then(text => {
                console.log('Response text:', text);
                const data = JSON.parse(text);
                console.log('Data parsed:', data);
                console.log('data.success:', data.success);
                console.log('data.lotes:', data.lotes);
                console.log('data.lotes.length:', data.lotes ? data.lotes.length : 'undefined');
                
                document.getElementById('loadingLotes').style.display = 'none';
                document.getElementById('tableLotesContainer').style.display = 'block';
                
                if (data.success && data.lotes && data.lotes.length > 0) {
                    console.log('✓ Mostrando lotes en tabla...');
                    productoActualId = data.productoId;
                    mostrarLotesEnTabla(data.lotes);
                    document.getElementById('noLotesMessage').style.display = 'none';
                } else {
                    console.log('❌ No hay lotes disponibles o error');
                    document.getElementById('tableLotesBody').innerHTML = '';
                    document.getElementById('noLotesMessage').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('❌ ERROR al cargar lotes:', error);
                document.getElementById('loadingLotes').style.display = 'none';
                showError('Error al cargar los lotes disponibles. Por favor, intenta de nuevo.');
            });
    }
    
    // Función para mostrar lotes en la tabla
    function mostrarLotesEnTabla(lotes) {
        const tbody = document.getElementById('tableLotesBody');
        tbody.innerHTML = '';
        
        console.log('=== MOSTRAR LOTES EN TABLA ===');
        console.log('Total lotes:', lotes.length);
        
        lotes.forEach((lote, index) => {
            console.log('Lote ' + index + ':', lote);
            console.log('  ID:', lote.id);
            console.log('  codigoLote:', lote.codigoLote);
            console.log('  sku:', lote.sku);
            console.log('  producto:', lote.producto);
            console.log('  paquetes:', lote.paquetes);
            console.log('  fechaVencimiento:', lote.fechaVencimiento);
            
            const row = document.createElement('tr');
            row.style.cursor = 'pointer';
            row.onclick = function() {
                seleccionarLote(lote.id, row);
            };
            
            const codigoLoteVal = lote.codigoLote || 'N/A';
            const skuVal = lote.sku || 'N/A';
            const productoVal = lote.producto || 'N/A';
            const paquetesVal = lote.paquetes || 0;
            const fechaVal = lote.fechaVencimiento || '<span class="text-muted">Sin fecha</span>';
            
            console.log('Valores antes de generar HTML:');
            console.log('  codigoLoteVal:', codigoLoteVal);
            console.log('  skuVal:', skuVal);
            console.log('  productoVal:', productoVal);
            console.log('  paquetesVal:', paquetesVal);
            console.log('  fechaVal:', fechaVal);
            
            // Usar concatenación en lugar de template literals
            row.innerHTML = 
                '<td class="text-center">' +
                    '<input type="radio" name="loteSeleccionado" value="' + lote.id + '" class="form-check-input" style="width: 20px; height: 20px;">' +
                '</td>' +
                '<td><strong>' + codigoLoteVal + '</strong></td>' +
                '<td><span class="badge bg-secondary">' + skuVal + '</span></td>' +
                '<td>' + productoVal + '</td>' +
                '<td><span class="badge" style="background: linear-gradient(135deg, #00a896 0%, #028f80 100%); color: white; padding: 6px 14px; border-radius: 20px; font-size: 0.85rem; font-weight: 600;">' + paquetesVal + ' paquetes</span></td>' +
                '<td>' + fechaVal + '</td>';
            
            console.log('HTML generado:', row.innerHTML);
            
            tbody.appendChild(row);
        });
        
        console.log('✓ Tabla renderizada');
    }
    
    // Función para seleccionar un lote
    function seleccionarLote(idLote, row) {
        // Desmarcar todas las filas
        const rows = document.querySelectorAll('#tableLotesBody tr');
        rows.forEach(r => r.classList.remove('table-active'));
        
        // Marcar la fila seleccionada
        row.classList.add('table-active');
        
        // Seleccionar el radio button
        const radio = row.querySelector('input[type="radio"]');
        radio.checked = true;
        
        // Guardar el ID del lote seleccionado
        loteSeleccionadoId = idLote;
    }
    
    // Función para asignar el lote a la orden
    function asignarLoteAOrden() {
        if (!loteSeleccionadoId) {
            showAlert('Por favor, selecciona un lote antes de enviar.', 'Selecciona un lote', 'warning');
            return;
        }
        
        // Deshabilitar el botón
        const btnEnviar = document.getElementById('btnEnviarLote');
        btnEnviar.disabled = true;
        btnEnviar.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Procesando...';
        
        // Enviar la asignación al servidor
        fetch('<%= request.getContextPath() %>/ProductorServlet?action=asignarLoteAOrden', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'idOrden=' + ordenActualId + '&idLote=' + loteSeleccionadoId
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showSuccess('Lote asignado correctamente a la orden');
                // Cerrar el modal
                bootstrap.Modal.getInstance(document.getElementById('asignarLoteModal')).hide();
                // Recargar la página después de 1 segundo
                setTimeout(() => location.reload(), 1500);
            } else {
                showError('Error: ' + (data.message || 'No se pudo asignar el lote'));
                btnEnviar.disabled = false;
                btnEnviar.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Enviar';
            }
        })
        .catch(error => {
            console.error('Error:', error);
            showError('Error de conexión al asignar el lote. Por favor, intenta de nuevo.');
            btnEnviar.disabled = false;
            btnEnviar.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Enviar';
        });
    }

    // Función para cambiar estado de una orden
    function cambiarEstado(idOrden, nuevoEstado, elemento) {
        console.log('🔔 cambiarEstado llamado:', {idOrden, nuevoEstado, elemento});
        
        // Validar parámetros
        if (!idOrden || !nuevoEstado || !elemento) {
            console.error('Parámetros inválidos en cambiarEstado:', {idOrden, nuevoEstado, elemento});
            showError('Error: Parámetros inválidos');
            return;
        }
        
        // Si el estado es "Rechazado", pedir el motivo primero
        if (nuevoEstado === 'Rechazado') {
            console.log('📝 Estado es Rechazado, mostrando modal de motivo');
            // Mostrar modal para pedir el motivo
            const motivoModal = document.getElementById('motivoRechazoModal');
            const motivoInput = document.getElementById('motivoRechazoInput');
            const btnConfirmarRechazo = document.getElementById('btnConfirmarRechazo');
            
            if (!motivoModal || !motivoInput || !btnConfirmarRechazo) {
                showError('Error: No se pudo cargar el modal de rechazo. Por favor, recarga la página.');
                return;
            }
            
            // Limpiar el input
            motivoInput.value = '';
            
            // Mostrar el modal
            const bsModal = new bootstrap.Modal(motivoModal);
            bsModal.show();
            
            // Remover listeners anteriores y agregar uno nuevo
            const newBtn = btnConfirmarRechazo.cloneNode(true);
            btnConfirmarRechazo.parentNode.replaceChild(newBtn, btnConfirmarRechazo);
            
            // Configurar el botón de confirmar
            document.getElementById('btnConfirmarRechazo').onclick = function() {
                const motivo = motivoInput.value.trim();
                if (!motivo) {
                    showError('Por favor, ingresa un motivo para rechazar la orden.');
                    return;
                }
                
                // Cerrar el modal
                bsModal.hide();
                
                // Proceder con el cambio de estado
                procederCambioEstado(idOrden, nuevoEstado, elemento, motivo);
            };
        } else {
            console.log('✅ Estado no es Rechazado, mostrando modal de confirmación para:', nuevoEstado);
            
            // Para otros estados, usar confirmación normal
            // Verificar que showConfirm existe
            if (typeof showConfirm !== 'function') {
                console.error('❌ showConfirm no está definida, usando confirm nativo');
                // Fallback a confirm nativo
                if (confirm('¿Deseas cambiar el estado de esta orden a "' + nuevoEstado + '"?')) {
                    procederCambioEstado(idOrden, nuevoEstado, elemento, '');
                }
                return;
            }
            
            console.log('✅ showConfirm está disponible, llamando...');
            
            // Llamar a showConfirm
            try {
                const result = showConfirm(
                    '¿Deseas cambiar el estado de esta orden a "' + nuevoEstado + '"?',
                    function() {
                        console.log('✅ Usuario confirmó en showConfirm');
                        procederCambioEstado(idOrden, nuevoEstado, elemento, '');
                    },
                    'Cambiar estado de orden'
                );
                console.log('✅ showConfirm retornó:', result);
            } catch (error) {
                console.error('❌ Error al llamar showConfirm:', error);
                // Fallback a confirm nativo
                if (confirm('¿Deseas cambiar el estado de esta orden a "' + nuevoEstado + '"?')) {
                    procederCambioEstado(idOrden, nuevoEstado, elemento, '');
                }
            }
        }
    }
    
    // Función auxiliar para proceder con el cambio de estado
    function procederCambioEstado(idOrden, nuevoEstado, elemento, motivo) {
        // Guardar el estado original para poder restaurarlo en caso de error
        const row = elemento.closest('tr');
        if (!row) {
            showError('Error: No se pudo encontrar la fila de la orden');
            return;
        }
        
        // Las columnas son: 0=Código, 1=Producto, 2=Cantidad, 3=Monto, 4=Solicitante, 5=Estado, 6=Acciones
        const estadoCellOriginal = row.cells[5] ? row.cells[5].innerHTML : '';
        const accionesCellOriginal = row.cells[6] ? row.cells[6].innerHTML : '';
        
        // Mostrar indicador de carga en la celda de estado
        if (row.cells[5]) {
            row.cells[5].innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Procesando...';
        }
        elemento.style.pointerEvents = 'none';
        
        // Construir el body de la petición
        let body = 'idOrden=' + idOrden + '&nuevoEstado=' + encodeURIComponent(nuevoEstado);
        if (motivo) {
            body += '&motivo=' + encodeURIComponent(motivo);
        }
        
        // Hacer petición AJAX
        fetch('<%= request.getContextPath() %>/ProductorServlet?action=cambiarEstadoOrden', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Error HTTP: ' + response.status);
            }
            return response.text();
        })
        .then(text => {
            if (!text || text.trim() === '') {
                throw new Error('La respuesta del servidor está vacía');
            }
            
            let data;
            try {
                data = JSON.parse(text);
            } catch (e) {
                throw new Error('La respuesta del servidor no es JSON válido');
            }
            
            if (!data || typeof data.success === 'undefined') {
                throw new Error('Respuesta del servidor inválida');
            }
            
            if (data.success) {
                // Actualizar el badge con el nuevo estado (columna 5)
                const estadoCell = row.cells[5];
                if (estadoCell) {
                    if (nuevoEstado === 'En Proceso') {
                        estadoCell.innerHTML = '<span class="badge" style="background: linear-gradient(160deg, #ffc107 0%, #ff9800 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;"><i class="fas fa-spinner me-1"></i>En Proceso</span>';
                    } else if (nuevoEstado === 'Rechazado') {
                        estadoCell.innerHTML = '<span class="badge" style="background: linear-gradient(160deg, #dc3545 0%, #c82333 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;"><i class="fas fa-times me-1"></i>Rechazado</span>';
                    } else if (nuevoEstado === 'Recibido') {
                        estadoCell.innerHTML = '<span class="badge-completada"><i class="fas fa-check me-1"></i>Recibido</span>';
                    } else if (nuevoEstado === 'Aprobado') {
                        estadoCell.innerHTML = '<span class="badge" style="background: linear-gradient(160deg, #0d6efd 0%, #0a58ca 100%); color: white; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;"><i class="fas fa-thumbs-up me-1"></i>Aprobado</span>';
                    } else {
                        estadoCell.innerHTML = '<span class="badge">' + nuevoEstado + '</span>';
                    }
                }
                
                // Mostrar el botón de editar solo si el estado es "En Proceso"
                const accionesCell = row.cells[6];
                if (accionesCell) {
                    if (nuevoEstado === 'En Proceso') {
                        accionesCell.innerHTML = '<button type="button" class="btn btn-sm shadow-sm btn-ver-lotes" onclick="editarOrden(\'' + idOrden + '\')" title="Editar orden"><i class="fas fa-edit"></i> Editar</button>';
                    } else {
                        accionesCell.innerHTML = '';
                    }
                }
                
                // Actualizar el atributo data-estado de la fila para los filtros
                if (row) {
                    row.dataset.estado = nuevoEstado;
                }
                
                // Mostrar mensaje de éxito
                showSuccess('Estado cambiado a "' + nuevoEstado + '" correctamente');
                
                // Si es rechazado, recargar la página después de 2 segundos
                if (nuevoEstado === 'Rechazado') {
                    setTimeout(() => location.reload(), 2000);
                }
            } else {
                showError('Error al cambiar el estado: ' + (data.message || 'Error desconocido'));
                // Restaurar todo al estado original
                if (row.cells[5]) row.cells[5].innerHTML = estadoCellOriginal;
                if (row.cells[6]) row.cells[6].innerHTML = accionesCellOriginal;
                elemento.style.pointerEvents = 'auto';
            }
        })
        .catch(error => {
            showError('Error de conexión al cambiar el estado. Por favor, intenta de nuevo.');
            // Restaurar todo al estado original
            if (row.cells[5]) row.cells[5].innerHTML = estadoCellOriginal;
            if (row.cells[6]) row.cells[6].innerHTML = accionesCellOriginal;
            elemento.style.pointerEvents = 'auto';
        });
    }

    // Inicializar filtros
    applyFilters();

    // Recargar página si se vuelve desde el perfil
    if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
        sessionStorage.removeItem('recargarDesdePerfil');
        location.reload();
    }

    // ===================== Control del Sidebar en Móvil =====================
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.querySelector('.nav-left-sidebar');
    const sidebarOverlay = document.getElementById('sidebarOverlay');

    function toggleSidebar() {
        if (sidebar && sidebarOverlay) {
            sidebar.classList.toggle('open');
            sidebarOverlay.classList.toggle('active');
            // Prevenir scroll del body cuando el sidebar está abierto
            if (sidebar.classList.contains('open')) {
                document.body.style.overflow = 'hidden';
            } else {
                document.body.style.overflow = '';
            }
        }
    }

    function closeSidebar() {
        if (sidebar && sidebarOverlay) {
            sidebar.classList.remove('open');
            sidebarOverlay.classList.remove('active');
            document.body.style.overflow = '';
        }
    }

    // Event listeners
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function(e) {
            e.stopPropagation();
            toggleSidebar();
        });
    }

    if (sidebarOverlay) {
        sidebarOverlay.addEventListener('click', closeSidebar);
    }

    // Cerrar sidebar cuando se hace clic en un enlace (solo en móvil)
    if (window.innerWidth <= 992) {
        const sidebarLinks = document.querySelectorAll('.nav-left-sidebar .nav-link');
        sidebarLinks.forEach(link => {
            link.addEventListener('click', function() {
                setTimeout(closeSidebar, 100); // Pequeño delay para permitir la navegación
            });
        });
    }

    // Cerrar sidebar al redimensionar la ventana si pasa a desktop
    window.addEventListener('resize', function() {
        if (window.innerWidth > 992) {
            closeSidebar();
        }
    });
    
    // ===================== Modal: Enviar Órdenes por Correo =====================
    document.addEventListener('DOMContentLoaded', function() {
        const sendOrdenesModal = document.getElementById('sendOrdenesModal');
        const openSendOrdenesBtn = document.getElementById('openSendOrdenesModalBtn');
        
        if (!sendOrdenesModal || !openSendOrdenesBtn) {
            console.error('No se encontraron los elementos del modal de Enviar Órdenes');
            return;
        }
        
        const closeSendOrdenesBtn = sendOrdenesModal.querySelector('.modal-close');
        const cancelSendOrdenesBtn = sendOrdenesModal.querySelector('.modal-cancel');
        
        // Función para abrir el modal
        function abrirModalEnviarOrdenes() {
            // Obtener filtros actuales de la URL (si existen)
            const urlParams = new URLSearchParams(window.location.search);
            const estado = urlParams.get('estado') || '';
            const busqueda = urlParams.get('busqueda') || '';
            
            // Poblar campos ocultos con los filtros
            const hiddenEstado = document.getElementById('hiddenEstado');
            const hiddenBusqueda = document.getElementById('hiddenBusqueda');
            if (hiddenEstado) hiddenEstado.value = estado;
            if (hiddenBusqueda) hiddenBusqueda.value = busqueda;
            
            sendOrdenesModal.classList.add('show');
            sendOrdenesModal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
        
        // Función para cerrar el modal
        function cerrarModalEnviarOrdenes() {
            sendOrdenesModal.classList.remove('show');
            sendOrdenesModal.style.display = 'none';
            document.body.style.overflow = '';
        }
        
        // Event listener para el botón
        openSendOrdenesBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            abrirModalEnviarOrdenes();
        });
        
        if (closeSendOrdenesBtn) {
            closeSendOrdenesBtn.addEventListener('click', cerrarModalEnviarOrdenes);
        }
        
        if (cancelSendOrdenesBtn) {
            cancelSendOrdenesBtn.addEventListener('click', cerrarModalEnviarOrdenes);
        }
        
        // Cerrar al hacer clic fuera del modal
        sendOrdenesModal.addEventListener('click', function(e) {
            if (e.target === sendOrdenesModal) {
                cerrarModalEnviarOrdenes();
            }
        });
        
        // Cerrar con tecla ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && sendOrdenesModal && sendOrdenesModal.classList.contains('show')) {
                cerrarModalEnviarOrdenes();
            }
        });
    });
</script>

<!-- ===================== Modal: Enviar Órdenes por Correo ===================== -->
<div id="sendOrdenesModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte de Órdenes por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/productor/OrdenCompraReporteServlet" id="formEnviarOrdenes">
            <input type="hidden" name="action" value="enviar">
            <input type="hidden" name="estado" id="hiddenEstado" value="">
            <input type="hidden" name="busqueda" id="hiddenBusqueda" value="">
            
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
                           value="Reporte de Órdenes de Compra - Productor - TELITO BODEGUERO" 
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
                    <strong>Nota:</strong> El archivo Excel se generará con los mismos filtros que tienes aplicados en la tabla de órdenes. 
                    Incluirá todas las columnas (Número, Producto, Cantidad, Estado, Fecha, etc.) y tendrá filtros automáticos habilitados.
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

<!-- Estilos y JavaScript para Notificaciones -->
<style>
    .badge-notificacion {
        position: absolute;
        top: -2px;
        right: -2px;
        background: #dc3545;
        color: white;
        font-size: 10px;
        font-weight: 700;
        padding: 2px 5px;
        border-radius: 10px;
        min-width: 18px;
        height: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        line-height: 1;
        animation: pulse-badge 2s infinite;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        border: 2px solid white;
    }
    
    @keyframes pulse-badge {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
    }
    
    .notificaciones-dropdown {
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        border: none;
        border-radius: 12px;
        overflow: visible;
    }
    
    #listaNotificaciones {
        scrollbar-width: thin;
        scrollbar-color: rgba(0, 168, 150, 0.3) transparent;
    }
    
    #listaNotificaciones::-webkit-scrollbar {
        width: 6px;
    }
    
    #listaNotificaciones::-webkit-scrollbar-track {
        background: transparent;
    }
    
    #listaNotificaciones::-webkit-scrollbar-thumb {
        background-color: rgba(0, 168, 150, 0.3);
        border-radius: 10px;
    }
    
    #listaNotificaciones::-webkit-scrollbar-thumb:hover {
        background-color: rgba(0, 168, 150, 0.5);
    }
    
    .notificacion-item {
        padding: 12px 20px;
        border-bottom: 1px solid #eee;
        transition: all 0.3s ease;
        cursor: pointer;
        background: white;
    }
    
    .notificacion-item:hover {
        background: #f8f9fa;
    }
    
    .notificacion-item.no-leida {
        background: #e8f4f8;
        border-left: 4px solid var(--turquoise-dark);
    }
    
    .notificacion-item.no-leida:hover {
        background: #d4ecf5;
    }
    
    .notificacion-icon {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.2rem;
        flex-shrink: 0;
    }
    
    .notificacion-icon.CRITICAL { background: #fee; color: #dc3545; }
    .notificacion-icon.WARNING { background: #fff3cd; color: #ffc107; }
    .notificacion-icon.INFO { background: #d1ecf1; color: #0dcaf0; }
    
    .notificacion-contenido {
        flex: 1;
        min-width: 0;
    }
    
    .notificacion-titulo {
        font-weight: 600;
        font-size: 0.9rem;
        color: #212529 !important;
        margin-bottom: 4px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        line-height: 1.3;
    }
    
    .notificacion-mensaje {
        font-size: 0.8rem;
        color: #495057 !important;
        margin-bottom: 4px;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        line-height: 1.4;
    }
    
    .notificacion-tiempo {
        font-size: 0.7rem;
        color: #6c757d !important;
    }
</style>

<script>
// ===================== Sistema de Notificaciones =====================
document.addEventListener('DOMContentLoaded', function() {
    cargarContadorNotificaciones();
    cargarNotificacionesRecientes();
    setInterval(function() {
        cargarContadorNotificaciones();
        cargarNotificacionesRecientes();
    }, 120000);
});

function cargarContadorNotificaciones() {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=contador', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const contador = data.datos.contador || 0;
            const badge = document.getElementById('badgeNotificaciones');
            if (badge) {
                if (contador > 0) {
                    badge.textContent = contador > 99 ? '99+' : contador;
                    badge.style.display = 'block';
                } else {
                    badge.style.display = 'none';
                }
            }
        }
    })
    .catch(error => console.error('Error al cargar contador:', error));
}

function cargarNotificacionesRecientes() {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=recientes', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const notifs = data.datos.notificaciones || [];
            mostrarNotificaciones(notifs);
        }
    })
    .catch(error => {
        console.error('Error al cargar notificaciones:', error);
        const lista = document.getElementById('listaNotificaciones');
        if (lista) {
            lista.innerHTML = '<div class="text-center py-4 text-danger"><i class="fas fa-exclamation-triangle fa-2x mb-2"></i><p class="mb-0">Error al cargar notificaciones</p></div>';
        }
    });
}

function mostrarNotificaciones(notificaciones) {
    const lista = document.getElementById('listaNotificaciones');
    if (!lista) return;
    
    if (notificaciones.length === 0) {
        lista.innerHTML = '<div class="text-center py-4 text-muted"><i class="fas fa-bell-slash fa-2x mb-2"></i><p class="mb-0">No tienes notificaciones nuevas</p></div>';
        return;
    }
    
    const htmlArray = notificaciones.map(notif => {
        const iconoTipo = obtenerIconoTipo(notif.tipo || notif.tipoNotificacion);
        const tiempoRelativo = obtenerTiempoRelativo(notif.fechaCreacion);
        const idNotif = notif.id || notif.idNotificacion;
        const nivelPrioridad = notif.nivel || notif.nivelPrioridad;
        
        return '<div class="notificacion-item no-leida" onclick="verNotificacion(' + idNotif + ', \'' + (notif.urlAccion || '') + '\')">' +
                '<div class="d-flex gap-3">' +
                    '<div class="notificacion-icon ' + nivelPrioridad + '">' +
                        '<i class="' + iconoTipo + '"></i>' +
                    '</div>' +
                    '<div class="notificacion-contenido">' +
                        '<div class="notificacion-titulo">' + notif.titulo + '</div>' +
                        '<div class="notificacion-mensaje">' + notif.mensaje + '</div>' +
                        '<div class="notificacion-tiempo"><i class="far fa-clock me-1"></i>' + tiempoRelativo + '</div>' +
                    '</div>' +
                    '<div class="text-primary"><i class="fas fa-circle" style="font-size: 8px;"></i></div>' +
                '</div>' +
            '</div>';
    });
    
    lista.innerHTML = htmlArray.join('');
}

function obtenerIconoTipo(tipo) {
    const iconos = {
        'STOCK_CRITICO': 'fas fa-exclamation-triangle',
        'STOCK_MINIMO': 'fas fa-box-open',
        'VENCIMIENTO_7_DIAS': 'fas fa-calendar-times',
        'VENCIMIENTO_3_DIAS': 'fas fa-bell',
        'LOTE_VENCIDO': 'fas fa-times-circle',
        'INCIDENCIA_REPORTADA': 'fas fa-exclamation-circle',
        'AJUSTE_INVENTARIO': 'fas fa-exchange-alt',
        'ENTRADA_REGISTRADA': 'fas fa-arrow-down',
        'ORDEN_COMPRA_CREADA': 'fas fa-shopping-cart',
        'ORDEN_LISTA': 'fas fa-check-circle',
        'PLAN_TRANSPORTE_CREADO': 'fas fa-truck',
        'PEDIDO_RECHAZADO': 'fas fa-times',
        'PEDIDO_COMPLETADO': 'fas fa-check',
        'ORDEN_CONFIRMADA': 'fas fa-check-circle',
        'ORDEN_RECHAZADA': 'fas fa-times-circle',
        'ORDEN_LISTA_PRODUCTOR': 'fas fa-check',
        'PRODUCTO_NUEVO': 'fas fa-plus-circle',
        'USUARIO_CREADO': 'fas fa-user-plus',
        'ALERTA_CONFIGURADA': 'fas fa-cog',
        'SISTEMA_ACTUALIZADO': 'fas fa-info-circle'
    };
    return iconos[tipo] || 'fas fa-bell';
}

function obtenerTiempoRelativo(fechaStr) {
    let fecha;
    if (typeof fechaStr === 'number') {
        fecha = new Date(fechaStr);
    } else if (typeof fechaStr === 'string') {
        fecha = new Date(fechaStr);
    } else {
        return 'Reciente';
    }
    
    if (isNaN(fecha.getTime())) {
        return 'Reciente';
    }
    
    const ahora = new Date();
    const diffMs = ahora - fecha;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);
    
    if (diffMins < 1) return 'Ahora mismo';
    if (diffMins < 60) return 'Hace ' + diffMins + ' min';
    if (diffHours < 24) return 'Hace ' + diffHours + ' h';
    if (diffDays < 7) return 'Hace ' + diffDays + ' días';
    return fecha.toLocaleDateString('es-ES', { day: '2-digit', month: 'short' });
}

function verNotificacion(id, url) {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarLeida&id=' + id, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            if (url && url.trim() !== '') {
                window.location.href = url;
            } else {
                cargarNotificacionesRecientes();
            }
        }
    })
    .catch(error => console.error('Error al marcar como leída:', error));
}

function marcarTodasLeidas() {
    const dropdown = document.getElementById('notificacionesDropdown');
    if (dropdown) {
        const bsDropdown = bootstrap.Dropdown.getInstance(dropdown);
        if (bsDropdown) bsDropdown.hide();
    }
    
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarTodasLeidas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            cargarNotificacionesRecientes();
            mostrarToast('success', 'Todas las notificaciones marcadas como leídas', 'fas fa-check-circle');
        } else {
            mostrarToast('danger', 'Error al marcar notificaciones', 'fas fa-exclamation-triangle');
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
        mostrarToast('danger', 'Error de conexión con el servidor', 'fas fa-exclamation-triangle');
    });
}

function mostrarToast(tipo, mensaje, icono) {
    const toastDiv = document.createElement('div');
    toastDiv.className = 'position-fixed top-0 end-0 p-3';
    toastDiv.style.zIndex = '9999';
    toastDiv.style.marginTop = '70px';
    
    const colorMap = {
        'success': '#28a745',
        'danger': '#dc3545',
        'warning': '#ffc107',
        'info': '#17a2b8'
    };
    
    toastDiv.innerHTML = 
        '<div class="toast show" role="alert" style="min-width: 300px; border-left: 4px solid ' + (colorMap[tipo] || '#333') + ';">' +
            '<div class="toast-header" style="background: ' + (colorMap[tipo] || '#333') + '; color: white;">' +
                '<i class="' + (icono || 'fas fa-info-circle') + ' me-2"></i>' +
                '<strong class="me-auto">Notificación</strong>' +
                '<button type="button" class="btn-close btn-close-white" data-bs-dismiss="toast"></button>' +
            '</div>' +
            '<div class="toast-body" style="font-size: 0.95rem;">' +
                mensaje +
            '</div>' +
        '</div>';
    
    document.body.appendChild(toastDiv);
    
    setTimeout(function() {
        toastDiv.querySelector('.toast').classList.remove('show');
        setTimeout(function() { toastDiv.remove(); }, 300);
    }, 3000);
}

// ===================== Sistema de Notificaciones =====================
let ultimaActualizacion = Date.now();
let modalNotificacionesMostrado = false;

// Cargar notificaciones al inicio
document.addEventListener('DOMContentLoaded', function() {
    cargarContadorNotificaciones();
    cargarNotificacionesRecientes();
    
    // Auto-refresh cada 5 segundos (5000ms)
    setInterval(function() {
        cargarContadorNotificaciones();
        cargarNotificacionesRecientes();
    }, 5000);
});

// Cargar contador de notificaciones no leídas
function cargarContadorNotificaciones() {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=contador', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const contador = data.datos.contador || 0;
            const badge = document.getElementById('badgeNotificaciones');
            if (badge) {
                if (contador > 0) {
                    badge.textContent = contador > 99 ? '99+' : contador;
                    badge.style.display = 'block';
                } else {
                    badge.style.display = 'none';
                }
            }
        }
    })
    .catch(error => console.error('Error al cargar contador:', error));
}

// Cargar notificaciones recientes
function cargarNotificacionesRecientes() {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=recientes', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const notifs = data.datos.notificaciones || [];
            mostrarNotificaciones(notifs);
            
            // Mostrar modal automáticamente si hay notificaciones nuevas
            if (notifs.length > 0) {
                mostrarModalNotificaciones(notifs);
            }
        } else {
            document.getElementById('listaNotificaciones').innerHTML = 
                '<div class="text-center py-4 text-warning">' +
                    '<i class="fas fa-exclamation-triangle fa-2x mb-2"></i>' +
                    '<p class="mb-0">' + (data.mensaje || 'Error al cargar notificaciones') + '</p>' +
                '</div>';
        }
    })
    .catch(error => {
        console.error('Error al cargar notificaciones:', error);
        document.getElementById('listaNotificaciones').innerHTML = 
            '<div class="text-center py-4 text-danger">' +
                '<i class="fas fa-exclamation-triangle fa-2x mb-2"></i>' +
                '<p class="mb-0">Error al cargar notificaciones</p>' +
            '</div>';
    });
}

// Mostrar notificaciones en el dropdown
function mostrarNotificaciones(notificaciones) {
    const lista = document.getElementById('listaNotificaciones');
    
    if (notificaciones.length === 0) {
        lista.innerHTML = '<div class="text-center py-4 text-muted">' +
            '<i class="fas fa-bell-slash fa-2x mb-2"></i>' +
            '<p class="mb-0">No tienes notificaciones nuevas</p>' +
        '</div>';
        return;
    }
    
    const htmlArray = notificaciones.map(notif => {
        const iconoTipo = obtenerIconoTipo(notif.tipo || notif.tipoNotificacion);
        const tiempoRelativo = obtenerTiempoRelativo(notif.fechaCreacion);
        const idNotif = notif.id || notif.idNotificacion;
        const nivelPrioridad = notif.nivel || notif.nivelPrioridad;
        const ordenCompraId = notif.ordenCompraId || '';
        const tipoNotif = notif.tipo || notif.tipoNotificacion || '';
        
        return '<div class="notificacion-item no-leida" onclick="verNotificacion(' + idNotif + ', \'' + (notif.urlAccion || '') + '\', ' + (ordenCompraId || 'null') + ', \'' + tipoNotif + '\')">' +
                '<div class="d-flex gap-3">' +
                    '<div class="notificacion-icon ' + nivelPrioridad + '">' +
                        '<i class="' + iconoTipo + '"></i>' +
                    '</div>' +
                    '<div class="notificacion-contenido">' +
                        '<div class="notificacion-titulo">' + notif.titulo + '</div>' +
                        '<div class="notificacion-mensaje">' + notif.mensaje + '</div>' +
                        '<div class="notificacion-tiempo">' +
                            '<i class="far fa-clock me-1"></i>' + tiempoRelativo +
                        '</div>' +
                    '</div>' +
                    '<div class="text-primary"><i class="fas fa-circle" style="font-size: 8px;"></i></div>' +
                '</div>' +
            '</div>';
    });
    
    lista.innerHTML = htmlArray.join('');
}

// Obtener icono según tipo de notificación
function obtenerIconoTipo(tipo) {
    const iconos = {
        'STOCK_CRITICO': 'fas fa-exclamation-triangle',
        'STOCK_MINIMO': 'fas fa-box-open',
        'VENCIMIENTO_7_DIAS': 'fas fa-calendar-times',
        'VENCIMIENTO_3_DIAS': 'fas fa-bell',
        'LOTE_VENCIDO': 'fas fa-times-circle',
        'INCIDENCIA_REPORTADA': 'fas fa-exclamation-circle',
        'AJUSTE_INVENTARIO': 'fas fa-exchange-alt',
        'ENTRADA_REGISTRADA': 'fas fa-arrow-down',
        'ORDEN_COMPRA_CREADA': 'fas fa-shopping-cart',
        'ORDEN_LISTA': 'fas fa-check-circle',
        'PLAN_TRANSPORTE_CREADO': 'fas fa-truck',
        'PEDIDO_RECHAZADO': 'fas fa-times',
        'PEDIDO_COMPLETADO': 'fas fa-check',
        'ORDEN_CONFIRMADA': 'fas fa-check-circle',
        'ORDEN_RECHAZADA': 'fas fa-times-circle',
        'ORDEN_LISTA_PRODUCTOR': 'fas fa-check',
        'PRODUCTO_NUEVO': 'fas fa-plus-circle',
        'USUARIO_CREADO': 'fas fa-user-plus',
        'ALERTA_CONFIGURADA': 'fas fa-cog',
        'SISTEMA_ACTUALIZADO': 'fas fa-info-circle'
    };
    return iconos[tipo] || 'fas fa-bell';
}

// Obtener tiempo relativo
function obtenerTiempoRelativo(fechaStr) {
    let fecha;
    if (typeof fechaStr === 'number') {
        fecha = new Date(fechaStr);
    } else if (typeof fechaStr === 'string') {
        fecha = new Date(fechaStr);
    } else {
        return 'Reciente';
    }
    
    if (isNaN(fecha.getTime())) {
        return 'Reciente';
    }
    
    const ahora = new Date();
    const diffMs = ahora - fecha;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);
    
    if (diffMins < 1) return 'Ahora mismo';
    if (diffMins < 60) return 'Hace ' + diffMins + ' min';
    if (diffHours < 24) return 'Hace ' + diffHours + ' h';
    if (diffDays < 7) return 'Hace ' + diffDays + ' días';
    return fecha.toLocaleDateString('es-ES', { day: '2-digit', month: 'short' });
}

// Ver notificación (marcar como leída y redirigir)
function verNotificacion(id, url, ordenCompraId, tipoNotificacion) {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarLeida&id=' + id, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            // Si es una notificación de orden de compra, redirigir a la página de órdenes
            // Si es una notificación relacionada con órdenes de compra, redirigir a la página de órdenes
            if (tipoNotificacion && (tipoNotificacion.includes('ORDEN_COMPRA') || tipoNotificacion.includes('ORDEN_RECHAZADA') || tipoNotificacion.includes('ORDEN_CONFIRMADA') || tipoNotificacion.includes('ORDEN_LISTA'))) {
                window.location.href = '<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra';
            } else if (url && url.trim() !== '') {
                const contextPath = '<%= request.getContextPath() %>';
                const finalUrl = url.startsWith('/') ? contextPath + url : url;
                window.location.href = finalUrl;
            } else {
                cargarNotificacionesRecientes();
            }
        }
    })
    .catch(error => console.error('Error al marcar como leída:', error));
}

// Marcar todas como leídas
function marcarTodasLeidas() {
    const dropdown = document.getElementById('notificacionesDropdown');
    if (dropdown) {
        const bsDropdown = bootstrap.Dropdown.getInstance(dropdown);
        if (bsDropdown) bsDropdown.hide();
    }
    
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarTodasLeidas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            cargarNotificacionesRecientes();
            mostrarToast('success', 'Todas las notificaciones marcadas como leídas', 'fas fa-check-circle');
        } else {
            mostrarToast('danger', 'Error al marcar notificaciones', 'fas fa-exclamation-triangle');
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
        mostrarToast('danger', 'Error de conexión con el servidor', 'fas fa-exclamation-triangle');
    });
}

// Mostrar modal de notificaciones automáticamente
function mostrarModalNotificaciones(notificaciones) {
    if (notificaciones.length === 0 || modalNotificacionesMostrado) {
        return;
    }
    
    const primeraNotificacion = notificaciones[0];
    const iconoTipo = obtenerIconoTipo(primeraNotificacion.tipo || primeraNotificacion.tipoNotificacion);
    const tiempoRelativo = obtenerTiempoRelativo(primeraNotificacion.fechaCreacion);
    const nivelPrioridad = primeraNotificacion.nivel || primeraNotificacion.nivelPrioridad;
    
    document.getElementById('modalNotificacionIcono').className = 'notificacion-icon-modal ' + nivelPrioridad;
    document.getElementById('modalNotificacionIcono').innerHTML = '<i class="' + iconoTipo + '"></i>';
    document.getElementById('modalNotificacionTitulo').textContent = primeraNotificacion.titulo;
    document.getElementById('modalNotificacionMensaje').textContent = primeraNotificacion.mensaje;
    document.getElementById('modalNotificacionTiempo').innerHTML = '<i class="far fa-clock me-1"></i>' + tiempoRelativo;
    
    document.getElementById('modalNotificacion').setAttribute('data-notificacion-id', primeraNotificacion.id || primeraNotificacion.idNotificacion);
    document.getElementById('modalNotificacion').setAttribute('data-notificacion-url', primeraNotificacion.urlAccion || '');
    document.getElementById('modalNotificacion').setAttribute('data-orden-compra-id', primeraNotificacion.ordenCompraId || '');
    document.getElementById('modalNotificacion').setAttribute('data-tipo-notificacion', primeraNotificacion.tipo || primeraNotificacion.tipoNotificacion || '');
    
    const modal = new bootstrap.Modal(document.getElementById('modalNotificacion'));
    modal.show();
    
    modalNotificacionesMostrado = true;
    
    const notifId = primeraNotificacion.id || primeraNotificacion.idNotificacion;
    if (notifId) {
        fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarLeida&id=' + notifId, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
        .then(response => response.json())
        .then(data => {
            if (data.exito) {
                cargarContadorNotificaciones();
            }
        })
        .catch(error => console.error('Error al marcar como leída:', error));
    }
}

// Función para ir a la acción de la notificación
function irANotificacion() {
    const modal = document.getElementById('modalNotificacion');
    const url = modal.getAttribute('data-notificacion-url');
    const tipoNotificacion = modal.getAttribute('data-tipo-notificacion');
    const modalInstance = bootstrap.Modal.getInstance(modal);
    modalInstance.hide();
    
    // Si es una notificación relacionada con órdenes de compra, redirigir a la página de órdenes
    if (tipoNotificacion && (tipoNotificacion.includes('ORDEN_COMPRA') || tipoNotificacion.includes('ORDEN_RECHAZADA') || tipoNotificacion.includes('ORDEN_CONFIRMADA') || tipoNotificacion.includes('ORDEN_LISTA'))) {
        window.location.href = '<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra';
    } else if (url && url.trim() !== '') {
        const contextPath = '<%= request.getContextPath() %>';
        const finalUrl = url.startsWith('/') ? contextPath + url : url;
        window.location.href = finalUrl;
    }
}

// Cargar y mostrar todas las notificaciones en el modal grande
function mostrarModalTodasNotificaciones() {
    const dropdown = document.getElementById('notificacionesDropdown');
    if (dropdown) {
        const bsDropdown = bootstrap.Dropdown.getInstance(dropdown);
        if (bsDropdown) bsDropdown.hide();
    }
    
    document.getElementById('listaTodasNotificaciones').innerHTML = 
        '<div class="text-center py-5">' +
            '<i class="fas fa-spinner fa-spin fa-2x mb-3 text-muted"></i>' +
            '<p class="text-muted">Cargando notificaciones...</p>' +
        '</div>';
    
    const modal = new bootstrap.Modal(document.getElementById('modalTodasNotificaciones'));
    modal.show();
    
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=todas', {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            const notifs = data.datos.notificaciones || [];
            mostrarTodasNotificaciones(notifs);
        } else {
            document.getElementById('listaTodasNotificaciones').innerHTML = 
                '<div class="text-center py-5 text-danger">' +
                    '<i class="fas fa-exclamation-triangle fa-2x mb-3"></i>' +
                    '<p>' + (data.mensaje || 'Error al cargar notificaciones') + '</p>' +
                '</div>';
        }
    })
    .catch(error => {
        console.error('Error al cargar todas las notificaciones:', error);
        document.getElementById('listaTodasNotificaciones').innerHTML = 
            '<div class="text-center py-5 text-danger">' +
                '<i class="fas fa-exclamation-triangle fa-2x mb-3"></i>' +
                '<p>Error al cargar notificaciones</p>' +
            '</div>';
    });
}

// Mostrar todas las notificaciones en el modal grande
function mostrarTodasNotificaciones(notificaciones) {
    const lista = document.getElementById('listaTodasNotificaciones');
    
    if (notificaciones.length === 0) {
        lista.innerHTML = '<div class="text-center py-5 text-muted">' +
            '<i class="fas fa-bell-slash fa-3x mb-3"></i>' +
            '<h5 class="mb-2">No tienes notificaciones</h5>' +
            '<p class="mb-0">No hay notificaciones para mostrar</p>' +
        '</div>';
        return;
    }
    
    const htmlArray = notificaciones.map(notif => {
        const iconoTipo = obtenerIconoTipo(notif.tipo || notif.tipoNotificacion);
        const tiempoRelativo = obtenerTiempoRelativo(notif.fechaCreacion);
        const idNotif = notif.id || notif.idNotificacion;
        const nivelPrioridad = notif.nivel || notif.nivelPrioridad;
        const esLeida = notif.leida || false;
        const claseLeida = esLeida ? '' : 'no-leida';
        const ordenCompraId = notif.ordenCompraId || '';
        const tipoNotif = notif.tipo || notif.tipoNotificacion || '';
        
        return '<div class="notificacion-item-grande ' + claseLeida + '" onclick="verNotificacion(' + idNotif + ', \'' + (notif.urlAccion || '') + '\', ' + (ordenCompraId || 'null') + ', \'' + tipoNotif + '\')">' +
                '<div class="d-flex gap-3 align-items-start">' +
                    '<div class="notificacion-icon-grande ' + nivelPrioridad + '">' +
                        '<i class="' + iconoTipo + '"></i>' +
                    '</div>' +
                    '<div class="notificacion-contenido-grande flex-grow-1">' +
                        '<div class="d-flex justify-content-between align-items-start mb-2">' +
                            '<div class="notificacion-titulo-grande">' + notif.titulo + '</div>' +
                            (!esLeida ? '<span class="badge bg-primary rounded-pill" style="font-size: 0.7rem;">Nueva</span>' : '') +
                        '</div>' +
                        '<div class="notificacion-mensaje-grande">' + notif.mensaje + '</div>' +
                        '<div class="notificacion-tiempo-grande mt-2">' +
                            '<i class="far fa-clock me-1"></i>' + tiempoRelativo +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';
    });
    
    lista.innerHTML = htmlArray.join('');
    
    const contador = notificaciones.filter(n => !(n.leida || false)).length;
    const contadorEl = document.getElementById('contadorModalNotificaciones');
    if (contadorEl) {
        contadorEl.textContent = contador > 0 ? contador + ' no leída' + (contador > 1 ? 's' : '') : 'Todas leídas';
    }
}

// Marcar todas como leídas desde el modal
function marcarTodasLeidasDesdeModal() {
    fetch('<%= request.getContextPath() %>/NotificacionServlet?action=marcarTodasLeidas', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' }
    })
    .then(response => response.json())
    .then(data => {
        if (data.exito) {
            cargarContadorNotificaciones();
            mostrarModalTodasNotificaciones();
            mostrarToast('success', 'Todas las notificaciones marcadas como leídas', 'fas fa-check-circle');
        } else {
            mostrarToast('danger', 'Error al marcar notificaciones', 'fas fa-exclamation-triangle');
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
        mostrarToast('danger', 'Error de conexión con el servidor', 'fas fa-exclamation-triangle');
    });
}
</script>

<!-- Modal de Notificaciones -->
<div class="modal fade" id="modalNotificacion" tabindex="-1" aria-labelledby="modalNotificacionLabel" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.2);">
            <div class="modal-header" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; border-radius: 15px 15px 0 0; border: none; padding: 20px;">
                <h5 class="modal-title" id="modalNotificacionLabel" style="font-weight: 600;">
                    <i class="fas fa-bell me-2"></i>Nueva Notificación
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 30px;">
                <div class="d-flex align-items-start gap-4">
                    <div id="modalNotificacionIcono" class="notificacion-icon-modal" style="flex-shrink: 0;">
                        <i class="fas fa-bell"></i>
                    </div>
                    <div style="flex: 1;">
                        <h6 id="modalNotificacionTitulo" style="font-weight: 600; color: #212529; margin-bottom: 10px; font-size: 1.1rem;"></h6>
                        <p id="modalNotificacionMensaje" style="color: #495057; margin-bottom: 15px; line-height: 1.6; font-size: 0.95rem;"></p>
                        <div id="modalNotificacionTiempo" style="color: #6c757d; font-size: 0.85rem;">
                            <i class="far fa-clock me-1"></i>Reciente
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #e9ecef; padding: 20px; border-radius: 0 0 15px 15px;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius: 8px; padding: 8px 20px;">
                    <i class="fas fa-times me-2"></i>Cerrar
                </button>
                <button type="button" class="btn btn-primary" onclick="irANotificacion()" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); border: none; border-radius: 8px; padding: 8px 20px;">
                    <i class="fas fa-arrow-right me-2"></i>Ver Detalles
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal Grande para Todas las Notificaciones -->
<div class="modal fade" id="modalTodasNotificaciones" tabindex="-1" aria-labelledby="modalTodasNotificacionesLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content" style="border-radius: 15px; border: none; box-shadow: 0 10px 40px rgba(0,0,0,0.2);">
            <div class="modal-header" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; border-radius: 15px 15px 0 0; border: none; padding: 20px;">
                <h5 class="modal-title" id="modalTodasNotificacionesLabel" style="font-weight: 600;">
                    <i class="fas fa-bell me-2"></i>Todas las Notificaciones
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 0;">
                <div class="d-flex justify-content-between align-items-center p-3 border-bottom" style="background: #f8f9fa;">
                    <button class="btn btn-sm" onclick="marcarTodasLeidasDesdeModal()" style="background: linear-gradient(165deg, #00a896 0%, #028f80 50%, #02796b 100%); color: white; border: none; border-radius: 8px; padding: 6px 15px;">
                        <i class="fas fa-check-double me-1"></i>Marcar todas como leídas
                    </button>
                    <span class="text-muted" id="contadorModalNotificaciones"></span>
                </div>
                <div id="listaTodasNotificaciones" style="max-height: 500px; overflow-y: auto; overflow-x: hidden;">
                    <div class="text-center py-5">
                        <i class="fas fa-spinner fa-spin fa-2x mb-3 text-muted"></i>
                        <p class="text-muted">Cargando notificaciones...</p>
                    </div>
                </div>
            </div>
            <div class="modal-footer" style="border-top: 1px solid #e9ecef; padding: 15px 20px; border-radius: 0 0 15px 15px;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="border-radius: 8px; padding: 8px 20px;">
                    <i class="fas fa-times me-2"></i>Cerrar
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .notificacion-icon-modal {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        flex-shrink: 0;
    }
    
    .notificacion-icon-modal.CRITICAL {
        background: #fee;
        color: #dc3545;
    }
    
    .notificacion-icon-modal.WARNING {
        background: #fff3cd;
        color: #ffc107;
    }
    
    .notificacion-icon-modal.INFO {
        background: #d1ecf1;
        color: #0dcaf0;
    }
    
    #modalNotificacion .modal-content {
        animation: slideDown 0.3s ease-out;
    }
    
    @keyframes slideDown {
        from {
            transform: translateY(-50px);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }
    
    .notificacion-item-grande {
        padding: 20px;
        border-bottom: 1px solid #e9ecef;
        transition: all 0.3s ease;
        cursor: pointer;
        background: white;
        border-left: 4px solid transparent;
    }
    
    .notificacion-item-grande:hover {
        background: #f8f9fa;
        border-left-color: #00a896;
    }
    
    .notificacion-item-grande.no-leida {
        background: #e8f4f8;
        border-left-color: #00a896;
    }
    
    .notificacion-icon-grande {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.3rem;
        flex-shrink: 0;
    }
    
    .notificacion-icon-grande.CRITICAL {
        background: #fee;
        color: #dc3545;
    }
    
    .notificacion-icon-grande.WARNING {
        background: #fff3cd;
        color: #ffc107;
    }
    
    .notificacion-icon-grande.INFO {
        background: #d1ecf1;
        color: #0dcaf0;
    }
    
    .notificacion-titulo-grande {
        font-weight: 600;
        font-size: 1rem;
        color: #212529;
        margin-bottom: 8px;
    }
    
    .notificacion-mensaje-grande {
        font-size: 0.9rem;
        color: #495057;
        line-height: 1.5;
        margin-bottom: 8px;
    }
    
    .notificacion-tiempo-grande {
        font-size: 0.8rem;
        color: #6c757d;
    }
</style>

</body>
</html>
