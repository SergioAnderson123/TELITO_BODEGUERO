<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.productor.beans.Producto" %>
<%@ page import="com.example.telito.productor.beans.Categoria" %>
<%@ page import="java.util.ArrayList" %>
<%--
    JSP: Mis Productos
    Propósito: Mostrar el inventario del productor, estadísticas y utilidades de filtrado/ordenado.
    Atributos esperados (request):
      - listaProductos (ArrayList<Producto>)
      - totalProductos (int), fueraDeStock (int), totalCategorias (int)
    Navegación: Sidebar con sección "Mis Productos" activa.
--%>
<jsp:useBean id="listaProductos" scope="request" type="java.util.ArrayList<com.example.telito.productor.beans.Producto>" />

<%
    int totalProductos = (request.getAttribute("totalProductos") != null) ? (int) request.getAttribute("totalProductos") : 0;
    int fueraDeStock = (request.getAttribute("fueraDeStock") != null) ? (int) request.getAttribute("fueraDeStock") : 0;
    int totalCategorias = (request.getAttribute("totalCategorias") != null) ? (int) request.getAttribute("totalCategorias") : 0;
    ArrayList<Categoria> todasLasCategorias = (ArrayList<Categoria>) request.getAttribute("todasLasCategorias");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Productos - Telito Bodeguero</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

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
           Contenedores (match registrarLotes)
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
        #openModalBtn { background: linear-gradient(135deg, #00a896 0%, #028f80 100%); border: none; }
        
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
        
        /* Botón Agregar Producto */
        .btn-agregar-producto {
            transition: all 0.3s ease;
        }
        .btn-agregar-producto:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(40, 167, 69, 0.4) !important;
        }

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
        button:hover { transform: translateY(-2px); box-shadow: 0 6px 14px rgba(0, 109, 119, 0.25); }

        /* Tabla - Estilo igual a gestión de usuarios */
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

        /* Botón Ver Lotes - Estilo teal/verde agua */
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
           Modal personalizado (solo para addProductModal)
        ====================== */
        #addProductModal.modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); }
        #addProductModal .modal-content { background-color: var(--white); margin: 5% auto; padding: 20px; border: none; width: 60%; max-width: 700px; max-height: 90vh; overflow-y: auto; border-radius: 12px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); animation: slide-down 0.3s ease-out; }
        @keyframes slide-down { from { transform: translateY(-30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        #addProductModal .modal-header { display: flex; justify-content: space-between; align-items: center; background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); padding: 15px 20px; margin: -20px -20px 15px -20px; border-radius: 12px 12px 0 0; }
        #addProductModal .modal-header h2 { margin: 0; color: white; }
        #addProductModal .modal-close { color: white; font-size: 28px; font-weight: bold; cursor: pointer; opacity: 0.9; }
        #addProductModal .modal-close:hover { opacity: 1; }
        #addProductModal .modal-footer { display: flex; justify-content: flex-end; gap: 15px; padding-top: 15px; margin-top: 15px; border-top: 1px solid var(--border-color); }
        
        /* Asegurar que los modales Bootstrap tengan z-index correcto */
        #resumenLotesProductoModal {
            z-index: 1055;
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
            .modal-content { width: 92%; margin: 15% auto; }
            
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
                    <li class="nav-item dropdown">
                        <%
                            com.example.telito.administrador.beans.Usuario usuarioHeaderMisProd = 
                                (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                            String nombreCompletoMisProd = usuarioHeaderMisProd != null ? 
                                usuarioHeaderMisProd.getNombres() + " " + usuarioHeaderMisProd.getApellidos() : "Usuario";
                            String fotoUrlMisProd = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
                            if (usuarioHeaderMisProd != null) {
                                String foto = usuarioHeaderMisProd.getFotoPerfil();
                                if (foto != null && !foto.trim().isEmpty()) {
                                    if (foto.startsWith("http://") || foto.startsWith("https://")) {
                                        fotoUrlMisProd = foto;
                                    } else {
                                        fotoUrlMisProd = request.getContextPath() + "/" + foto;
                                    }
                                } else {
                                    fotoUrlMisProd = usuarioHeaderMisProd.getFotoPerfilUrl();
                                }
                            }
                        %>
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <img src="<%= fotoUrlMisProd %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                            <span style="color:#006d77;"><%= nombreCompletoMisProd %></span>
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
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                            <i class="fas fa-shopping-cart"></i>Mis Productos
                        </a>
                    </li>
                    <!-- Órdenes de Compra -->
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra">
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
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-shopping-cart me-2"></i>Mis Productos</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Vista general de tu inventario y herramientas de gestión.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <button id="openModalBtn" class="btn btn-sm shadow-sm btn-agregar-producto" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                            <i class="fas fa-plus me-1"></i>Agregar Producto
                        </button>
                        <a href="<%= request.getContextPath() %>/productor/ProductoReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-file-excel me-1"></i>Exportar Productos
                        </a>
                        <a href="<%= request.getContextPath() %>/productor/ProductoReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-envelope me-1"></i>Enviar Productos
                        </a>
                    </div>
                </div>
            </div>

            <!-- ===================== Mensaje de resultado (éxito/error) ===================== -->
            <%
                String alertType = (String) request.getAttribute("alertType");
                String alertMessage = (String) request.getAttribute("alertMessage");
                if (alertType != null && alertMessage != null) {
            %>
            <div class="alert alert-<%= alertType %> alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem; border-radius: 6px;">
                <i class="fas <%= "success".equals(alertType) ? "fa-check-circle" : "fa-exclamation-triangle" %> me-2"></i>
                <%= alertMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
            </div>
            <%
                }
                // Mensajes de sesión para reportes
                String mensaje = (String) session.getAttribute("mensaje");
                String tipoMensaje = (String) session.getAttribute("tipoMensaje");
                if (mensaje != null) {
            %>
            <div class="alert alert-<%= tipoMensaje != null ? tipoMensaje : "info" %> alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem; border-radius: 6px;">
                <i class="fas <%= "success".equals(tipoMensaje) ? "fa-check-circle" : "info".equals(tipoMensaje) ? "fa-info-circle" : "fa-exclamation-triangle" %> me-2"></i>
                <%= mensaje %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
            </div>
            <%
                    session.removeAttribute("mensaje");
                    session.removeAttribute("tipoMensaje");
                }
            %>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="stats-container">
                <div class="stat-card"><h3>Total de Productos</h3><p><%= totalProductos %></p></div>
                <div class="stat-card"><h3>Fuera de Stock</h3><p><%= fueraDeStock %></p></div>
                <div class="stat-card"><h3>Categorías Activas</h3><p><%= totalCategorias %></p></div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros de productos ===================== -->
            <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                    <div class="col-md-4">
                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                        <div class="input-group">
                            <input id="searchInput" type="text" class="form-control form-control-sm shadow-sm" placeholder="Nombre o SKU..." style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-tags me-1"></i>Categoría</label>
                        <select id="categoryFilter" class="form-select form-select-sm shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <option value="">Todas las categorías</option>
                            <% if (todasLasCategorias != null) { for (Categoria categoria : todasLasCategorias) { %>
                                <option value="<%= categoria.getNombre() %>"><%= categoria.getNombre() %></option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-sort-amount-down me-1"></i>Precio</label>
                        <select id="priceOrder" class="form-select form-select-sm shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <option value="">Todos los precios</option>
                            <option value="asc">Menor a Mayor</option>
                            <option value="desc">Mayor a Menor</option>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex align-items-end">
                        <a href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <i class="fas fa-sync-alt me-1"></i>Limpiar
                        </a>
                    </div>
                </div>
            </div>

    <!-- ===================== Card: Inventario actual (tabla) ===================== -->
    <div class="row">
        <div class="col-12">
            <div class="table-card shadow-sm">
                <div class="card-header" style="padding: 0.5rem 0.75rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-boxes me-2"></i>Inventario Actual</h5>
                            <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos tus productos</small>
                        </div>
                    </div>
                </div>
        <div class="card-body" style="padding: 0.75rem;">
            <table id="productsTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                <thead class="table-light">
                <tr>
                    <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                        <i class="fas fa-barcode me-1"></i>SKU
                    </th>
                    <th class="fw-semibold" style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                        <i class="fas fa-box me-1"></i>NOMBRE
                    </th>
                    <th class="fw-semibold" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                        <i class="fas fa-folder me-1"></i>CATEGORÍA
                    </th>
                    <th class="fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                        <i class="fas fa-dollar-sign me-1"></i>PRECIO
                    </th>
                    <th class="fw-semibold" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                        <i class="fas fa-boxes me-1"></i>LOTES
                    </th>
                    <th class="fw-semibold" style="width: 13%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                        <i class="fas fa-cog me-1"></i>ACCIONES
                    </th>
                </tr>
                </thead>
                <tbody>
                <% 
                    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                    Integer sizeObj = (Integer) request.getAttribute("size");
                    int currentPage = (currentPageObj != null) ? currentPageObj : 1;
                    int size = (sizeObj != null) ? sizeObj : 10;
                    int i = (currentPage - 1) * size + 1;
                %>
                <% for (Producto p : listaProductos) { %>
                <tr class="align-middle" data-category="<%= p.getCategoria().getNombre() %>" data-price="<%= String.format(java.util.Locale.US, "%.2f", p.getPrecioActual()) %>" data-sku="<%= p.getCodigoSKU() %>" data-name="<%= p.getNombre() %>" style="padding: 0;">
                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= p.getCodigoSKU() %></td>
                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= p.getNombre() %></td>
                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= p.getCategoria().getNombre() %></td>
                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">S/ <%= String.format("%.2f", p.getPrecioActual()) %></td>
                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <% int lotes = p.getNumeroLotes(); %>
                        <span class="badge <%= (lotes > 0) ? "bg-success" : "bg-danger" %> shadow-sm me-2" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;"><%= lotes %></span>
                        <% if (lotes > 0) { %>
                            <button type="button" 
                                    class="btn btn-sm shadow-sm btn-ver-lotes" 
                                    onclick="mostrarResumenLotesProducto(<%= p.getIdProducto() %>, '<%= p.getNombre() %>')"
                                    title="Ver detalles de lotes">
                                <i class="fas fa-eye"></i> Ver
                            </button>
                        <% } %>
                    </td>
                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <button type="button" class="btn btn-sm shadow-sm"
                                style="background-color: #ff6b6b; color: white; border: none; font-size: 0.8rem; padding: 0.35rem 0.6rem; border-radius: 6px; transition: all 0.2s ease;"
                                onclick="confirmarEliminacion(<%= p.getIdProducto() %>, '<%= p.getNombre() %>')"
                                title="Eliminar producto"
                                onmouseover="this.style.backgroundColor='#ff5252'; this.style.transform='translateY(-1px)';"
                                onmouseout="this.style.backgroundColor='#ff6b6b'; this.style.transform='translateY(0)';">
                            <i class="fas fa-trash me-1"></i>Borrar
                        </button>
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

    <!-- Cierre del contenedor principal -->
    </div>

<!-- ===================== Modal: Agregar Producto ===================== -->
<div id="addProductModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2>Agregar Nuevo Producto</h2>
            <span class="modal-close">&times;</span>
        </div>
        <form method="POST" action="<%= request.getContextPath() %>/ProductorServlet?action=crearProducto" id="formAgregarProducto">
            <div style="display: flex; gap: 15px;">
                <div style="flex: 1;"><label for="productName">Nombre del producto</label><input type="text" name="productName" id="productName" required></div>
                <div style="flex: 1;"><label for="productCategory">Categoría</label>
                    <select name="productCategory" id="productCategory" required>
                        <option value="">Seleccionar...</option>
                        <% if (todasLasCategorias != null) { %>
                            <% for (Categoria categoria : todasLasCategorias) { %>
                                <option value="<%= categoria.getIdCategoria() %>"><%= categoria.getNombre() %></option>
                            <% } %>
                        <% } %>
                    </select>
                </div>
            </div>
            <div style="display: flex; gap: 15px; margin-top: 10px;">
                <div style="flex: 1;">
                    <label for="productSKUDisplay">SKU (generado automáticamente)</label>
                    <input type="text" id="productSKUDisplay" readonly style="background-color: #f0f0f0; cursor: not-allowed;" placeholder="Cargando...">
                    <small style="color: var(--text-muted); display: block; margin-top: 3px; font-size: 0.85rem;">
                        <i class="fas fa-info-circle"></i> El SKU se genera automáticamente
                    </small>
                </div>
                <div style="flex: 1;"><label for="productPrice">Precio por Paquete (S/)</label><input type="number" name="productPrice" id="productPrice" step="0.01" required></div>
            </div>
            <div style="display: flex; gap: 15px; margin-top: 10px;">
                <div style="flex: 1;">
                    <label for="productUnits">Unidades por Paquete</label>
                    <input type="number" name="productUnits" id="productUnits" min="1" value="1" required>
                    <small style="color: var(--text-muted); display: block; margin-top: 3px; font-size: 0.85rem;">
                        <i class="fas fa-box"></i> Ej: Si vende cerveza en cajas de 12, ingrese 12
                    </small>
                </div>
                <div style="flex: 1;"></div>
            </div>
            <div style="margin-top: 10px;"><label for="productDescription">Descripción</label><textarea name="productDescription" id="productDescription" rows="2"></textarea></div>
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">Cancelar</button>
                <button type="submit" id="btnGuardarProducto">Guardar Producto</button>
            </div>
        </form>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    const modal = document.getElementById('addProductModal');
    const openBtn = document.getElementById('openModalBtn');
    const closeBtn = document.querySelector('.modal-close');
    const cancelBtn = document.querySelector('.modal-cancel');
    const skuDisplay = document.getElementById('productSKUDisplay');

    // Función para cargar el siguiente SKU disponible
    function cargarNuevoSKU() {
        skuDisplay.value = 'Cargando...';
        skuDisplay.style.color = '#999';
        
        const contextPath = '<%= request.getContextPath() %>';
        fetch(contextPath + '/ProductorServlet?action=obtenerNuevoSKU')
            .then(response => response.json())
            .then(data => {
                if (data.sku) {
                    skuDisplay.value = data.sku;
                    skuDisplay.style.color = '#28a745'; // Color verde para indicar éxito
                    skuDisplay.style.fontWeight = 'bold';
                } else {
                    skuDisplay.value = 'Error al generar SKU';
                    skuDisplay.style.color = '#dc3545';
                }
            })
            .catch(error => {
                console.error('Error al obtener SKU:', error);
                skuDisplay.value = 'Error de conexión';
                skuDisplay.style.color = '#dc3545';
            });
    }

    // Al abrir el modal, cargar el nuevo SKU
    openBtn.onclick = function() { 
        modal.style.display = "block";
        cargarNuevoSKU(); // Cargar el SKU automáticamente
        // Limpiar solo los campos editables (no borrar las opciones del select)
        document.getElementById('productName').value = '';
        document.getElementById('productCategory').selectedIndex = 0; // Volver a "Seleccionar..."
        document.getElementById('productDescription').value = '';
        document.getElementById('productPrice').value = '';
        document.getElementById('productUnits').value = '1';
    }
    
    closeBtn.onclick = function() { modal.style.display = "none"; }
    cancelBtn.onclick = function() { modal.style.display = "none"; }
    window.onclick = function(event) { if (event.target == modal) { modal.style.display = "none"; } }

    // Búsqueda, filtro por categoría y orden de precio (en cliente)
    const searchInput = document.getElementById('searchInput');
    const categoryFilter = document.getElementById('categoryFilter');
    const priceOrder = document.getElementById('priceOrder');
    const table = document.getElementById('productsTable');
    const tbody = table.querySelector('tbody');

    function normalize(text){
        return (text || '').toString().toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    }

    function applyFilters() {
        const term = normalize(searchInput.value);
        const category = categoryFilter.value;

        const rows = Array.from(tbody.querySelectorAll('tr'));

        rows.forEach(row => {
            const name = normalize(row.dataset.name);
            const sku = normalize(row.dataset.sku);
            const rowCategory = row.dataset.category;

            const matchesSearch = !term || name.includes(term) || sku.includes(term);
            const matchesCategory = !category || rowCategory === category;

            row.style.display = (matchesSearch && matchesCategory) ? '' : 'none';
        });

        applySort();
    }

    function applySort() {
        const order = priceOrder.value;
        if (!order) return; // no ordenar

        const rows = Array.from(tbody.querySelectorAll('tr'))
            .filter(r => r.style.display !== 'none');

        rows.sort((a, b) => {
            const pa = parseFloat(a.dataset.price || '0');
            const pb = parseFloat(b.dataset.price || '0');
            return order === 'asc' ? pa - pb : pb - pa;
        });

        // Reinsertar en el nuevo orden, manteniendo ocultos sin moverlos
        rows.forEach(r => tbody.appendChild(r));
    }

    // Event listeners para búsqueda y filtros
    searchInput.addEventListener('input', applyFilters);
    categoryFilter.addEventListener('change', applyFilters);
    priceOrder.addEventListener('change', () => { applySort(); });
    
    // Botón de búsqueda
    const searchButton = document.querySelector('.btn-primary.shadow-sm');
    if (searchButton) {
        searchButton.addEventListener('click', function(e) {
            e.preventDefault();
            applyFilters();
        });
    }

    // Inicializar
    applyFilters();

    // Variables globales para los modales
    let productoAEliminarId = null;
    let productoAEliminarNombre = null;
    
    // ===================== Función para confirmar eliminación de producto =====================
    function confirmarEliminacion(idProducto, nombreProducto) {
        productoAEliminarId = idProducto;
        productoAEliminarNombre = nombreProducto;
        
        // Actualizar el mensaje del modal de confirmación
        document.getElementById('nombreProductoEliminar').textContent = nombreProducto;
        
        // Mostrar el modal de confirmación
        const confirmModal = new bootstrap.Modal(document.getElementById('confirmarEliminacionModal'));
        confirmModal.show();
    }
    
    // Función para proceder con la eliminación
    function procederEliminacion() {
        if (productoAEliminarId && productoAEliminarNombre) {
            // Cerrar el modal de confirmación
            const confirmModal = bootstrap.Modal.getInstance(document.getElementById('confirmarEliminacionModal'));
            confirmModal.hide();
            
            // Crear y enviar el formulario
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '<%= request.getContextPath() %>/ProductorServlet';
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'desactivarProducto';
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'idProducto';
            idInput.value = productoAEliminarId;
            form.appendChild(actionInput);
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
        }
    }
    
    // Verificar si hay mensaje de éxito en la sesión y mostrar modal de éxito
    <%
        String mensajeExito = (String) session.getAttribute("mensaje");
        String tipoMensajeExito = (String) session.getAttribute("tipoMensaje");
        boolean mostrarModalExito = mensajeExito != null && "success".equals(tipoMensajeExito) && mensajeExito.contains("eliminado");
        if (mostrarModalExito) {
            // Limpiar mensaje de sesión antes de mostrar el modal
            session.removeAttribute("mensaje");
            session.removeAttribute("tipoMensaje");
    %>
    document.addEventListener('DOMContentLoaded', function() {
        const successModal = new bootstrap.Modal(document.getElementById('productoEliminadoExitoModal'));
        successModal.show();
    });
    <% } %>

    // Recargar página si se vuelve desde el perfil
    if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
        sessionStorage.removeItem('recargarDesdePerfil');
        location.reload();
    }
    
    // Instancia global del modal para reutilizar
    let resumenLotesModalInstance = null;
    
    function getResumenLotesModal() {
        const modalElement = document.getElementById('resumenLotesProductoModal');
        
        // Siempre crear nueva instancia o obtener la existente
        resumenLotesModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        
        // Limpiar backdrops cuando se cierre el modal (una sola vez)
        if (!modalElement.hasAttribute('data-backdrop-listener')) {
            modalElement.setAttribute('data-backdrop-listener', 'true');
            modalElement.addEventListener('hidden.bs.modal', function() {
                limpiarBackdropsResumen();
            });
        }
        
        return resumenLotesModalInstance;
    }
    
    function limpiarBackdropsResumen() {
        // Esperar un poco para que Bootstrap termine de procesar
        setTimeout(function() {
            const backdrops = document.querySelectorAll('.modal-backdrop');
            // Eliminar todos los backdrops excepto si hay un modal abierto
            if (backdrops.length > 0) {
                const modalsAbiertos = document.querySelectorAll('.modal.show');
                if (modalsAbiertos.length === 0) {
                    // No hay modales abiertos, eliminar todos los backdrops
                    backdrops.forEach(backdrop => backdrop.remove());
                    document.body.classList.remove('modal-open');
                    document.body.style.overflow = '';
                    document.body.style.paddingRight = '';
                } else if (backdrops.length > 1) {
                    // Hay múltiples backdrops pero solo un modal, eliminar extras
                    for (let i = 1; i < backdrops.length; i++) {
                        backdrops[i].remove();
                    }
                }
            }
        }, 150);
    }
    
    // Función para mostrar resumen de lotes de un producto
    function mostrarResumenLotesProducto(productoId, nombreProducto) {
        // Limpiar cualquier estado previo del modal
        const modalElement = document.getElementById('resumenLotesProductoModal');
        
        // Cerrar modal si está abierto
        const existingModal = bootstrap.Modal.getInstance(modalElement);
        if (existingModal) {
            existingModal.hide();
        }
        
        // Limpiar backdrops previos
        const backdrops = document.querySelectorAll('.modal-backdrop');
        backdrops.forEach(backdrop => backdrop.remove());
        document.body.classList.remove('modal-open');
        document.body.style.overflow = '';
        document.body.style.paddingRight = '';
        
        // Actualizar título del modal
        document.getElementById('modalProductoNombreResumen').textContent = 'Producto: ' + nombreProducto;
        
        // Mostrar loading y ocultar contenido
        document.getElementById('loadingResumenProducto').style.display = 'block';
        document.getElementById('contenidoResumenProducto').style.display = 'none';
        document.getElementById('sinLotesProducto').style.display = 'none';
        
        // Limpiar tabla
        document.getElementById('tablaResumenLotesProducto').innerHTML = '';
        
        // Abrir modal usando instancia reutilizable después de un pequeño delay
        setTimeout(function() {
            const modal = getResumenLotesModal();
            modal.show();
        }, 50);
        
        // Cargar datos via AJAX
        fetch('<%= request.getContextPath() %>/ProductorServlet?action=obtenerResumenLotesProducto&productoId=' + productoId)
            .then(response => response.json())
            .then(data => {
                document.getElementById('loadingResumenProducto').style.display = 'none';
                
                if (data.success && data.lotes && data.lotes.length > 0) {
                    document.getElementById('contenidoResumenProducto').style.display = 'block';
                    document.getElementById('sinLotesProducto').style.display = 'none';
                    
                    const tbody = document.getElementById('tablaResumenLotesProducto');
                    tbody.innerHTML = '';
                    
                    data.lotes.forEach(lote => {
                        const row = document.createElement('tr');
                        const fechaVencimiento = lote.fechaVencimiento || 'Sin fecha';
                        
                        // Convertir a números explícitamente
                        const paquetesInicial = parseInt(lote.paquetesInicial) || 0;
                        const paquetesRestante = parseInt(lote.paquetesRestante) || 0;
                        const stockInicial = parseInt(lote.stockInicial) || 0;
                        const stockRestante = parseInt(lote.stockRestante) || 0;
                        
                        // Calcular porcentaje usado basado en unidades (más preciso)
                        let porcentajeUsado = 0;
                        if (stockInicial > 0) {
                            const unidadesUsadas = stockInicial - stockRestante;
                            porcentajeUsado = (unidadesUsadas / stockInicial * 100).toFixed(1);
                        }
                        
                        // Determinar el color del badge según el porcentaje
                        let badgeClass = 'badge bg-secondary';
                        if (parseFloat(porcentajeUsado) === 0) {
                            badgeClass = 'badge bg-success';
                        } else if (parseFloat(porcentajeUsado) < 50) {
                            badgeClass = 'badge bg-info';
                        } else if (parseFloat(porcentajeUsado) < 90) {
                            badgeClass = 'badge bg-warning text-dark';
                        } else {
                            badgeClass = 'badge bg-danger';
                        }
                        
                        row.innerHTML = 
                            '<td><strong>' + lote.codigoLote + '</strong></td>' +
                            '<td>' + paquetesInicial + ' paquetes<br><small class="text-muted">(' + stockInicial.toLocaleString() + ' unidades)</small></td>' +
                            '<td>' + paquetesRestante + ' paquetes<br><small class="text-muted">(' + stockRestante.toLocaleString() + ' unidades)</small></td>' +
                            '<td><span class="' + badgeClass + '">' + porcentajeUsado + '% usado</span></td>' +
                            '<td>' + fechaVencimiento + '</td>';
                        tbody.appendChild(row);
                    });
                } else {
                    document.getElementById('contenidoResumenProducto').style.display = 'block';
                    document.getElementById('sinLotesProducto').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error al cargar resumen de lotes:', error);
                document.getElementById('loadingResumenProducto').style.display = 'none';
                document.getElementById('contenidoResumenProducto').style.display = 'block';
                document.getElementById('sinLotesProducto').innerHTML = 
                    '<div class="alert alert-danger">Error al cargar el resumen de lotes. Por favor, intenta de nuevo.</div>';
            });
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
</script>

<!-- Modal para mostrar resumen de lotes de un producto -->
<div class="modal fade" id="resumenLotesProductoModal" tabindex="-1" aria-labelledby="resumenLotesProductoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="resumenLotesProductoModalLabel">
                    <i class="fas fa-boxes me-2"></i>Resumen de Lotes del Producto
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <h6 class="mb-3" id="modalProductoNombreResumen"></h6>
                <div id="loadingResumenProducto" class="text-center py-3">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                </div>
                <div id="contenidoResumenProducto" style="display: none;">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm">
                            <thead class="table-light">
                                <tr>
                                    <th>Código Lote</th>
                                    <th>Cantidad Inicial</th>
                                    <th>Cantidad Restante</th>
                                    <th>% Usado</th>
                                    <th>Fecha Vencimiento</th>
                                </tr>
                            </thead>
                            <tbody id="tablaResumenLotesProducto">
                            </tbody>
                        </table>
                    </div>
                    <div id="sinLotesProducto" class="alert alert-info" style="display: none;">
                        No hay lotes registrados para este producto.
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- ===================== Modal: Confirmar Eliminación de Producto ===================== -->
<div class="modal fade" id="confirmarEliminacionModal" tabindex="-1" aria-labelledby="confirmarEliminacionModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius: 15px; overflow: hidden;">
            <div class="modal-header bg-danger text-white" style="border-bottom: none; padding: 20px 25px;">
                <h5 class="modal-title d-flex align-items-center" id="confirmarEliminacionModalLabel">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    Confirmar Eliminación
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" style="padding: 25px;">
                <p class="mb-3" style="font-size: 1.1rem;">
                    ¿Estás seguro de que quieres eliminar el producto <strong id="nombreProductoEliminar"></strong>?
                </p>
                <p class="text-muted mb-0" style="font-size: 0.95rem;">
                    <i class="fas fa-info-circle me-2"></i>Esta acción no se puede deshacer.
                </p>
            </div>
            <div class="modal-footer" style="border-top: none; padding: 20px 25px;">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" style="padding: 8px 20px; border-radius: 8px;">
                    <i class="fas fa-times me-2"></i>Cancelar
                </button>
                <button type="button" class="btn btn-danger" onclick="procederEliminacion()" style="padding: 8px 20px; border-radius: 8px;">
                    <i class="fas fa-trash me-2"></i>Eliminar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ===================== Modal: Producto Eliminado Exitosamente ===================== -->
<div class="modal fade" id="productoEliminadoExitoModal" tabindex="-1" aria-labelledby="productoEliminadoExitoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content" style="border-radius: 15px; overflow: hidden; border: none;">
            <div class="modal-header bg-success text-white d-flex align-items-center justify-content-center" style="border-bottom: none; padding: 20px;">
                <div class="d-flex align-items-center">
                    <div class="rounded-circle bg-white d-flex align-items-center justify-content-center me-3" style="width: 40px; height: 40px;">
                        <i class="fas fa-check text-success" style="font-size: 1.5rem;"></i>
                    </div>
                    <h5 class="modal-title mb-0" id="productoEliminadoExitoModalLabel">¡Éxito!</h5>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center" style="padding: 25px;">
                <p class="mb-0" style="font-size: 1rem; color: #2b2d42;">
                    Producto eliminado correctamente
                </p>
            </div>
            <div class="modal-footer d-flex justify-content-center" style="border-top: none; padding: 20px 25px;">
                <button type="button" class="btn btn-success d-flex align-items-center" data-bs-dismiss="modal" style="padding: 8px 25px; border-radius: 8px;">
                    <i class="fas fa-check me-2"></i>Aceptar
                </button>
            </div>
        </div>
    </div>
</div>

</body>
</html>