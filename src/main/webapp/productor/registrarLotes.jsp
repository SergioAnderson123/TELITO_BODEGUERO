<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.productor.beans.Producto" %>
<%@ page import="java.util.ArrayList" %>
<%--
    JSP: Registrar Lotes
    Propósito: Permite registrar nuevos lotes asociados a un producto.
    Atributos esperados (request):
      - alertType (String: success/danger) y alertMessage (String) para mensajes de resultado
      - form_* (opcionales) para repoblar campos cuando hay error: form_skuProducto, form_cantidadStock, form_fechaCaducidad
    Navegación: Sidebar con sección "Registrar Lotes" activa.
    Notas: El código de lote se genera automáticamente en formato L--0001, L--0002, etc. El distrito se asigna por defecto.
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Registrar Lotes - Telito Bodeguero</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Custom CSS -->
    <style>
        :root {
            --turquoise-dark: #00a896; /* oscuro */
            --seafoam: #83c5be;        /* verde agua */
            --seafoam-light: #edf6f9;  /* fondo claro */
            --text-dark: #2b2d42;
            --text-muted: #6c757d;
            --border: #e9ecef;
        }
        body {
            background-color: var(--seafoam-light);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
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
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border);
        }
        .dashboard-content { margin-top: 70px; padding: 20px; }
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
        .user-avatar-md { width: 40px; height: 40px; }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
        .navbar-brand img { height: 35px; }
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
        .btn-secondary { background: #8d99ae; border: none; }
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
        .btn-info {
            background: linear-gradient(160deg, #17a2b8 0%, #20c997 100%);
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
        .form-control, .form-select { border-radius: 8px; border: 2px solid var(--border); padding: 8px 12px; transition: all 0.3s ease; font-size: 0.9rem; }
        .form-control:focus, .form-select:focus { border-color: var(--seafoam); box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.35); }
        .form-label { font-weight: 600; color: var(--text-dark); margin-bottom: 4px; font-size: 0.9rem; }
        .form-text { color: var(--text-muted); font-size: 0.75rem; margin-top: 2px; }
        .invalid-feedback { font-size: 0.875rem; }
        .page-header { margin-bottom: 15px; }
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
        .section-title { color: var(--turquoise-dark); font-weight: 600; font-size: 0.95rem; margin-bottom: 12px; padding-bottom: 6px; border-bottom: 2px solid var(--border); }
        .footer { background-color: #fff; border-top: 1px solid var(--border); margin-top: 50px; padding: 20px 0; }
        .footer-links a { color: var(--text-muted); text-decoration: none; margin: 0 10px; }
        .footer-links a:hover { color: var(--turquoise-dark); }

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

        /* Responsive sidebar */
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
            .dashboard-header { left: 0; }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
        }
        
        /* ===================== Estilos para Modal de Enviar Lotes por Correo ===================== */
        #sendLotesModal.modal { 
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
        #sendLotesModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #sendLotesModal .modal-content { 
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
        #sendLotesModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #sendLotesModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #sendLotesModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #sendLotesModal .modal-close { 
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
        #sendLotesModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #sendLotesModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #sendLotesModal .form-group {
            margin-bottom: 1.25rem;
        }
        #sendLotesModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #sendLotesModal .form-group label i {
            color: #00a896;
            font-size: 0.85rem;
        }
        #sendLotesModal .form-group input,
        #sendLotesModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #sendLotesModal .form-group input:focus,
        #sendLotesModal .form-group textarea:focus {
            border-color: #00a896;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #sendLotesModal .form-hint {
            margin-top: 6px;
            font-size: 0.8rem;
            color: #6c757d;
            display: flex;
            align-items: flex-start;
            gap: 6px;
        }
        #sendLotesModal .form-hint i {
            color: #00a896;
            margin-top: 2px;
        }
        #sendLotesModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #sendLotesModal .modal-footer button {
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
        #sendLotesModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #sendLotesModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #sendLotesModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #sendLotesModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,168,150,0.4);
        }
        @media (max-width: 768px) {
            #sendLotesModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #sendLotesModal.show {
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
                        
                        <li class="nav-item dropdown">
                            <%
                                com.example.telito.administrador.beans.Usuario usuarioHeader = 
                                    (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
                                String nombreCompleto = usuarioHeader != null ? 
                                    usuarioHeader.getNombres() + " " + usuarioHeader.getApellidos() : "Usuario";
                                String fotoUrl = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
                                if (usuarioHeader != null) {
                                    String foto = usuarioHeader.getFotoPerfil();
                                    if (foto != null && !foto.trim().isEmpty()) {
                                        if (foto.startsWith("http://") || foto.startsWith("https://")) {
                                            fotoUrl = foto;
                                        } else {
                                            fotoUrl = request.getContextPath() + "/" + foto;
                                        }
                                    } else {
                                        fotoUrl = usuarioHeader.getFotoPerfilUrl();
                                    }
                                }
                            %>
                            <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                                <img src="<%= fotoUrl %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                                <span style="color:#006d77;"><%= nombreCompleto %></span>
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
                            <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra">
                                <i class="fas fa-chart-pie"></i>Órdenes de Compra
                            </a>
                        </li>
                        <!-- Registrar lotes -->
                        <li class="nav-item">
                            <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote">
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
                <!-- Page Header -->
                <div class="page-header d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-boxes me-2"></i>Registrar Lotes</h2>
                        <p class="text-muted mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Registra los nuevos lotes de productos distribuidos en diferentes ubicaciones.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <div class="d-flex gap-2 flex-wrap">
                            <a href="<%= request.getContextPath() %>/productor/LoteReporteServlet?action=exportar" class="btn btn-sm btn-success text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-file-excel me-1"></i>Exportar Lotes
                            </a>
                            <button type="button" id="openSendLotesModalBtn" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-envelope me-1"></i>Enviar Lotes
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Mini pantalla de error para fecha inválida -->
                <div id="fechaErrorAlert" class="alert alert-danger d-none" role="alert" style="border-radius: 10px;">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    La fecha de caducidad no puede ser anterior a hoy.
                </div>

                <!-- Mensaje de resultado de registro de lote -->
                <%
                    String alertType = (String) request.getAttribute("alertType");
                    String alertMessage = (String) request.getAttribute("alertMessage");
                    if (alertType != null && alertMessage != null) {
                %>
                <div class="alert alert-<%= alertType %>" role="alert" style="border-radius: 10px;">
                    <i class="fas <%= "success".equals(alertType) ? "fa-check-circle" : "fa-exclamation-triangle" %> me-2"></i>
                    <%= alertMessage %>
                </div>
                <%
                    }
                %>
        
                <!-- ===================== Card: Formulario de Registro de Lotes ===================== -->
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0"><i class="fas fa-clipboard-list me-2"></i>Formulario de Registro de Lotes</h5>
                            </div>
                            <div class="card-body" style="padding: 20px;">
                                <form id="registrarLoteForm" class="needs-validation" novalidate method="POST" action="<%= request.getContextPath() %>/ProductorServlet">
                                    <input type="hidden" name="action" value="registrarLote">
                                    
                                    <div class="row">
                                        <div class="col-md-6">
                                            <h6 class="section-title">
                                                <i class="fas fa-info-circle me-2"></i>Información del Producto y Lote
                                            </h6>
                                            
                                            <!-- SKU del producto: al salir del campo se autocompleta el nombre vía fetch JSON -->
                                            <div class="mb-2">
                                                <label for="skuProducto" class="form-label">SKU del Producto</label>
                                                <input type="text" class="form-control" id="skuProducto" name="skuProducto" placeholder="Ej: BOD-0001" required value="<%= request.getAttribute("form_skuProducto") != null ? request.getAttribute("form_skuProducto") : "" %>">
                                                <div class="form-text">
                                                    <i class="fas fa-info-circle me-1"></i>Ingresa el SKU para cargar el nombre del producto.
                                                </div>
                                                <div class="invalid-feedback">Por favor, ingresa un SKU válido.</div>
                                            </div>
                                            
                                            <!-- Nombre de producto autocompletado (solo lectura) -->
                                            <div class="mb-2">
                                                <label for="nombreProducto" class="form-label">Nombre del Producto</label>
                                                <input type="text" class="form-control" id="nombreProducto" placeholder="Se completará automáticamente" readonly>
                                            </div>
                                            
                                            <!-- Código de lote (generado automáticamente) -->
                                            <div class="mb-2">
                                                <label for="codigoLote" class="form-label">Código de Lote (generado automáticamente)</label>
                                                <input type="text" class="form-control" id="codigoLote" name="codigoLote" readonly style="background-color: #f0f0f0; cursor: not-allowed; font-weight: bold; color: #28a745; font-size: 0.9rem;" placeholder="Cargando...">
                                                <small class="form-text text-muted">
                                                    <i class="fas fa-info-circle"></i> El código de lote se genera automáticamente (ej: L--0031)
                                                </small>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-6">
                                            <h6 class="section-title">
                                                <i class="fas fa-warehouse me-2"></i>Detalles de Stock y Ubicación
                                            </h6>
                                            
                                            <!-- Cantidad de paquetes. El stock real se calcula automáticamente multiplicando por unidades_por_paquete -->
                                            <div class="mb-2">
                                                <label for="cantidadStock" class="form-label">Cantidad de Paquetes/Cajas</label>
                                                <input type="number" class="form-control" id="cantidadStock" name="cantidadStock" min="1" placeholder="Ej: 10 (cajas)" required value="<%= request.getAttribute("form_cantidadStock") != null ? request.getAttribute("form_cantidadStock") : "" %>">
                                                <small class="form-text text-muted">
                                                    <i class="fas fa-info-circle"></i> El stock total se calculará automáticamente multiplicando por las unidades por paquete del producto
                                                </small>
                                                <div class="invalid-feedback">Ingresa una cantidad válida.</div>
                                            </div>
                                            
                                            <!-- Selección de distrito/ubicación -->
                                            <div class="mb-2">
                                                <label for="fechaCaducidad" class="form-label">Fecha de Caducidad (Opcional)</label>
                                                <input type="date" class="form-control" id="fechaCaducidad" name="fechaCaducidad" value="<%= request.getAttribute("form_fechaCaducidad") != null ? request.getAttribute("form_fechaCaducidad") : "" %>">
                                                <div class="form-text">
                                                    <i class="fas fa-calendar me-1"></i>Deja vacío si el producto no tiene fecha de caducidad.
                                                </div>
                                            </div>
                                            
                                            <!-- Costo de producción -->
                                            <div class="mb-2">
                                                <label for="costoProduccion" class="form-label">Costo de Producción por Unidad (Opcional)</label>
                                                <div class="input-group">
                                                    <span class="input-group-text" style="font-size: 0.9rem; padding: 8px 12px;">S/</span>
                                                    <input type="number" class="form-control" id="costoProduccion" name="costoProduccion" 
                                                           step="0.01" min="0" placeholder="Ej: 2.50" 
                                                           value="<%= request.getAttribute("form_costoProduccion") != null ? request.getAttribute("form_costoProduccion") : "" %>">
                                                </div>
                                                <small class="form-text text-muted">
                                                    <i class="fas fa-info-circle"></i> Costo de producción por unidad del lote.
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="d-flex justify-content-end mt-3">
                                        <button type="button" class="btn btn-secondary me-3" style="padding: 8px 16px; font-size: 0.9rem;" onclick="limpiarFormulario()">
                                            <i class="fas fa-eraser me-1"></i>Limpiar
                                        </button>
                                        <span id="tooltipSubmitWrapper" data-bs-toggle="tooltip" data-bs-placement="top" title="">
                                            <button id="submitRegistrarLote" class="btn btn-primary" type="submit" style="padding: 8px 16px; font-size: 0.9rem;">
                                                <i class="fas fa-save me-1"></i>Registrar Lote
                                            </button>
                                        </span>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
    
    <!-- ===================== Bootstrap JS ===================== -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- ===================== Scripts de la vista ===================== -->
    <!-- Validación, autocompletado por SKU (fetch JSON), manejo de tooltip y bloqueo de submit -->
    <script>
        // Validación de Bootstrap (se mantiene igual)
        (function() {
            'use strict'
            var forms = document.querySelectorAll('.needs-validation')
            Array.prototype.slice.call(forms)
                .forEach(function(form) {
                    form.addEventListener('submit', function(event) {
                        if (!form.checkValidity()) {
                            event.preventDefault()
                            event.stopPropagation()
                        }
                        form.classList.add('was-validated')
                    }, false)
                })
        })();

        // Event listener para buscar el producto cuando se sale del campo SKU
        document.getElementById('skuProducto').addEventListener('blur', function() {
            const sku = this.value.trim();
            if (sku) {
                // Llamamos a la nueva función que se conecta al Servlet
                buscarProductoPorSKU_ajax(sku);
            }
        });

        // VVV --- FUNCIÓN ROBUSTA PARA BUSCAR POR SKU --- VVV
        function buscarProductoPorSKU_ajax(sku) {
            const campoNombre = document.getElementById('nombreProducto');
            const skuSanitizado = (sku || '').trim();
            if (!skuSanitizado) {
                campoNombre.value = '';
                return;
            }

            const url = '<%= request.getContextPath() %>' + '/ProductorServlet?action=buscarProductoPorSkuJson&sku=' + encodeURIComponent(skuSanitizado);

            fetch(url, { headers: { 'Accept': 'application/json' } })
                .then(resp => {
                    if (!resp.ok) throw new Error('HTTP ' + resp.status);
                    return resp.json();
                })
                .then(data => {
                    const nombre = (data && typeof data.nombre === 'string') ? data.nombre : '';
                    if (nombre) {
                        campoNombre.value = nombre;
                        campoNombre.style.backgroundColor = '#d4edda';
                        setTimeout(() => { campoNombre.style.backgroundColor = ''; }, 1500);
                    } else {
                        campoNombre.value = 'Producto no encontrado';
                        campoNombre.style.backgroundColor = '#f8d7da';
                        setTimeout(() => { campoNombre.value = ''; campoNombre.style.backgroundColor = ''; }, 1500);
                    }
                })
                .catch(error => {
                    console.error('Error en la búsqueda:', error);
                    campoNombre.value = 'Error al buscar';
                    campoNombre.style.backgroundColor = '#f8d7da';
                    setTimeout(() => { campoNombre.value = ''; campoNombre.style.backgroundColor = ''; }, 1500);
                });
        }

        // Función para limpiar el formulario
        function limpiarFormulario() {
            document.getElementById('registrarLoteForm').reset();
            document.getElementById('registrarLoteForm').classList.remove('was-validated');
            cargarCodigoLote(); // Cargar un nuevo código de lote
        }

        // Cargar código de lote automático al cargar la página
        function cargarCodigoLote() {
            const codigoLoteInput = document.getElementById('codigoLote');
            codigoLoteInput.value = 'Cargando...';
            codigoLoteInput.style.color = '#999';
            
            const contextPath = '<%= request.getContextPath() %>';
            fetch(contextPath + '/ProductorServlet?action=obtenerNuevoCodigoLote')
                .then(response => response.json())
                .then(data => {
                    if (data.codigo) {
                        codigoLoteInput.value = data.codigo;
                        codigoLoteInput.style.color = '#28a745';
                    } else {
                        codigoLoteInput.value = 'Error al generar código';
                        codigoLoteInput.style.color = '#dc3545';
                    }
                })
                .catch(error => {
                    console.error('Error al obtener código de lote:', error);
                    codigoLoteInput.value = 'Error de conexión';
                    codigoLoteInput.style.color = '#dc3545';
                });
        }
        
        // Cargar código al iniciar la página
        cargarCodigoLote();

        // Si hay mensaje de éxito, recargar nuevo código de lote
        <% if ("success".equals(alertType)) { %>
        setTimeout(function() {
            cargarCodigoLote();
        }, 500);
        <% } %>

        // Validación de fecha de caducidad (se mantiene igual)
        const fechaCaducidadInput = document.getElementById('fechaCaducidad');
        const submitBtn = document.getElementById('submitRegistrarLote');
        const tooltipWrapper = document.getElementById('tooltipSubmitWrapper');

        function toDateOnly(d) {
            const copy = new Date(d.getTime());
            copy.setHours(0,0,0,0);
            return copy;
        }

        function validarFechaCaducidad() {
            // Campo opcional: vacío => válido
            if (!fechaCaducidadInput.value) {
                fechaCaducidadInput.setCustomValidity('');
                ocultarErrorFecha();
                submitBtn.disabled = false;
                if (tooltipWrapper) { tooltipWrapper.setAttribute('title', ''); }
                if (tooltipWrapper && bootstrap.Tooltip.getInstance(tooltipWrapper)) { bootstrap.Tooltip.getInstance(tooltipWrapper).setContent({'.tooltip-inner': ''}); }
                return true;
            }

            const fechaCad = toDateOnly(new Date(fechaCaducidadInput.value));
            const hoy = toDateOnly(new Date());

            // Debe ser estrictamente futura
            if (fechaCad <= hoy) {
                fechaCaducidadInput.setCustomValidity('La fecha de caducidad debe ser futura.');
                mostrarErrorFecha();
                submitBtn.disabled = true;
                if (tooltipWrapper) { tooltipWrapper.setAttribute('title', 'La fecha de caducidad debe ser futura'); }
                if (tooltipWrapper && bootstrap.Tooltip.getInstance(tooltipWrapper)) { bootstrap.Tooltip.getInstance(tooltipWrapper).setContent({'.tooltip-inner': 'La fecha de caducidad debe ser futura'}); }
                return false;
            } else {
                fechaCaducidadInput.setCustomValidity('');
                ocultarErrorFecha();
                submitBtn.disabled = false;
                if (tooltipWrapper) { tooltipWrapper.setAttribute('title', ''); }
                if (tooltipWrapper && bootstrap.Tooltip.getInstance(tooltipWrapper)) { bootstrap.Tooltip.getInstance(tooltipWrapper).setContent({'.tooltip-inner': ''}); }
                return true;
            }
        }

        fechaCaducidadInput.addEventListener('change', validarFechaCaducidad);

        // Mostrar/ocultar mini pantalla de error
        function mostrarErrorFecha() {
            const alerta = document.getElementById('fechaErrorAlert');
            alerta.classList.remove('d-none');
        }

        function ocultarErrorFecha() {
            const alerta = document.getElementById('fechaErrorAlert');
            alerta.classList.add('d-none');
        }

        // Bloquear envío si la fecha es inválida y mostrar alerta
        document.getElementById('registrarLoteForm').addEventListener('submit', function(event) {
            if (!validarFechaCaducidad()) {
                event.preventDefault();
                event.stopPropagation();
            }
        });

        // Estado inicial del botón al cargar
        validarFechaCaducidad();

        // Inicializar tooltips de la página (incluido el del botón)
        (function initTooltips(){
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
            tooltipTriggerList.forEach(function (tooltipTriggerEl) {
                if (!bootstrap.Tooltip.getInstance(tooltipTriggerEl)) {
                    new bootstrap.Tooltip(tooltipTriggerEl);
                }
            })
        })();

        // Recargar página si se vuelve desde el perfil
        if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
            sessionStorage.removeItem('recargarDesdePerfil');
            location.reload();
        }
    </script>

    <script>
        // ===================== Control del Sidebar en Móvil =====================
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebar = document.querySelector('.nav-left-sidebar');
        const sidebarOverlay = document.getElementById('sidebarOverlay');

        function toggleSidebar() {
            if (sidebar && sidebarOverlay) {
                sidebar.classList.toggle('open');
                sidebarOverlay.classList.toggle('active');
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

        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', function(e) {
                e.stopPropagation();
                toggleSidebar();
            });
        }

        if (sidebarOverlay) {
            sidebarOverlay.addEventListener('click', closeSidebar);
        }

        if (window.innerWidth <= 992) {
            const sidebarLinks = document.querySelectorAll('.nav-left-sidebar .nav-link');
            sidebarLinks.forEach(link => {
                link.addEventListener('click', function() {
                    setTimeout(closeSidebar, 100);
                });
            });
        }

        window.addEventListener('resize', function() {
            if (window.innerWidth > 992) {
                closeSidebar();
            }
        });
        
        // ===================== Modal: Enviar Lotes por Correo =====================
        document.addEventListener('DOMContentLoaded', function() {
            const sendLotesModal = document.getElementById('sendLotesModal');
            const openSendLotesBtn = document.getElementById('openSendLotesModalBtn');
            
            if (!sendLotesModal || !openSendLotesBtn) {
                console.error('No se encontraron los elementos del modal de Enviar Lotes');
                return;
            }
            
            const closeSendLotesBtn = sendLotesModal.querySelector('.modal-close');
            const cancelSendLotesBtn = sendLotesModal.querySelector('.modal-cancel');
            
            // Función para abrir el modal
            function abrirModalEnviarLotes() {
                // Obtener filtros actuales de la URL (si existen)
                const urlParams = new URLSearchParams(window.location.search);
                const producto = urlParams.get('producto') || '';
                const distrito = urlParams.get('distrito') || '';
                
                // Poblar campos ocultos con los filtros
                const hiddenProducto = document.getElementById('hiddenProducto');
                const hiddenDistrito = document.getElementById('hiddenDistrito');
                if (hiddenProducto) hiddenProducto.value = producto;
                if (hiddenDistrito) hiddenDistrito.value = distrito;
                
                sendLotesModal.classList.add('show');
                sendLotesModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
            
            // Función para cerrar el modal
            function cerrarModalEnviarLotes() {
                sendLotesModal.classList.remove('show');
                sendLotesModal.style.display = 'none';
                document.body.style.overflow = '';
            }
            
            // Event listener para el botón
            openSendLotesBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                abrirModalEnviarLotes();
            });
            
            if (closeSendLotesBtn) {
                closeSendLotesBtn.addEventListener('click', cerrarModalEnviarLotes);
            }
            
            if (cancelSendLotesBtn) {
                cancelSendLotesBtn.addEventListener('click', cerrarModalEnviarLotes);
            }
            
            // Cerrar al hacer clic fuera del modal
            sendLotesModal.addEventListener('click', function(e) {
                if (e.target === sendLotesModal) {
                    cerrarModalEnviarLotes();
                }
            });
            
            // Cerrar con tecla ESC
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && sendLotesModal && sendLotesModal.classList.contains('show')) {
                    cerrarModalEnviarLotes();
                }
            });
        });
    </script>

<!-- ===================== Modal: Enviar Lotes por Correo ===================== -->
<div id="sendLotesModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte de Lotes por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/productor/LoteReporteServlet" id="formEnviarLotes">
            <input type="hidden" name="action" value="enviar">
            <input type="hidden" name="producto" id="hiddenProducto" value="">
            <input type="hidden" name="distrito" id="hiddenDistrito" value="">
            
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
                           value="Reporte de Lotes - Productor - TELITO BODEGUERO" 
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
                    <strong>Nota:</strong> El archivo Excel se generará con los mismos filtros que tienes aplicados en la tabla de lotes. 
                    Incluirá todas las columnas (Código, Producto, Cantidad, Fecha de Vencimiento, etc.) y tendrá filtros automáticos habilitados.
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

<!-- Estilos para Notificaciones -->
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
        border-left: 4px solid #00a896;
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

<script>
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
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
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
        }
    })
    .catch(error => {
        console.error('Error al marcar todas como leídas:', error);
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

</body>
</html>