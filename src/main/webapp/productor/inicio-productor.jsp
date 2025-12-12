<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.productor.servlets.DashboardProductorServlet.MetricasProductor" %>

<%
    MetricasProductor metricas = (MetricasProductor) request.getAttribute("metricas");
    if (metricas == null) {
        metricas = new MetricasProductor();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inicio - Telito Bodeguero</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --turquoise-dark: #006d77;
            --seafoam: #83c5be;
            --seafoam-light: #edf6f9;
            --white: #ffffff;
            --text-dark: #2b2d42;
            --text-muted: #6c757d;
            --border-color: #e9ecef;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            background-color: var(--seafoam-light);
            color: var(--text-dark);
        }
        .dashboard-main-wrapper { display: flex; min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border-color);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-content { margin-top: 70px; padding: 30px; padding-bottom: 100px !important; }
        .page-header { margin-bottom: 30px; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 10px; }
        .page-header p { color: var(--text-muted); font-size: 1.05rem; }
        .pageheader-title {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #00a896 !important;
        }
        .pageheader-title i {
            color: var(--seafoam);
        }
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
           Tarjetas y Botones (igual a logística y almacenero)
        ====================== */
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
        .sidebar-toggle:hover { color: var(--seafoam); }
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
        .sidebar-overlay.active { opacity: 1; }
        @media (max-width: 992px) {
            .sidebar-toggle { display: inline-block; }
            .nav-left-sidebar { 
                position: fixed; 
                transform: translateX(-100%); 
                transition: transform 0.3s ease;
                z-index: 1000;
            }
            .nav-left-sidebar.open { transform: translateX(0); }
            .sidebar-overlay { display: block; }
            .dashboard-header { left: 0; padding: 0 10px; }
            .dashboard-wrapper { margin-left: 0; width: 100%; }
            .dashboard-content { padding: 20px; }
        }
        
        /* Animación suave para las tarjetas de estadísticas (igual que administrador) */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .stat-card {
            animation: fadeInUp 0.5s ease-out;
        }
        .stat-card:nth-child(1) { animation-delay: 0.1s; }
        .stat-card:nth-child(2) { animation-delay: 0.2s; }
        .stat-card:nth-child(3) { animation-delay: 0.3s; }
        .stat-card:nth-child(4) { animation-delay: 0.4s; }
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
                <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/ProductorServlet?action=inicio">
                    <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                    <span>Telito Bodeguero</span>
                </a>

                <!-- Right actions -->
                <ul class="navbar-nav ms-auto">
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
                        <a class="nav-link active" href="<%= request.getContextPath() %>/ProductorServlet?action=inicio">
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
        <div class="dashboard-content" style="padding-bottom: 100px !important;">
            <div class="row">
                <div class="col-12">
                    <div class="page-header pt-1 pb-1 d-flex justify-content-between align-items-center flex-wrap">
                        <div>
                            <h2 class="pageheader-title mb-0" style="font-size: 1.4rem;"><i class="fas fa-chart-pie me-2"></i>¡Bienvenido, Productor!</h2>
                            <p class="pageheader-text mb-0" style="font-size: 0.85rem;">Resumen de tus productos, lotes y órdenes.</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Primera fila: Productos y Lotes -->
            <div class="row g-2 mb-3">
                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card stat-card shadow-sm border-start border-primary border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Productos Activos</h6>
                                    <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getProductosActivos() %></h2>
                                    <small style="font-size: 0.8rem; color: #4a4a4a;">En tu catálogo</small>
                                </div>
                                <div class="stat-icon text-primary ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                    <i class="fas fa-box"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card stat-card shadow-sm border-start border-success border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Lotes Este Mes</h6>
                                    <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getLotesEsteMes() %></h2>
                                    <small style="font-size: 0.8rem; color: #4a4a4a;">Registrados este mes</small>
                                </div>
                                <div class="stat-icon text-success ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                    <i class="fas fa-boxes"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card stat-card shadow-sm border-start border-info border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Stock Total</h6>
                                    <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getStockTotal() %></h2>
                                    <small style="font-size: 0.8rem; color: #4a4a4a;">Unidades disponibles</small>
                                </div>
                                <div class="stat-icon text-info ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                    <i class="fas fa-warehouse"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card stat-card shadow-sm border-start border-warning border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Lotes Próximos a Vencer</h6>
                                    <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getLotesProximosVencer() %></h2>
                                    <small style="font-size: 0.8rem; color: #4a4a4a;">Próximos 30 días</small>
                                </div>
                                <div class="stat-icon text-warning ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                    <i class="fas fa-calendar-times"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Segunda fila: Órdenes -->
            <div class="row g-2 mb-3">
                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card stat-card shadow-sm border-start border-warning border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Órdenes Pendientes</h6>
                                    <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getOrdenesPendientes() %></h2>
                                    <small style="font-size: 0.8rem; color: #4a4a4a;">Requieren atención</small>
                                </div>
                                <div class="stat-icon text-warning ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                    <i class="fas fa-clock"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card stat-card shadow-sm border-start border-info border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Órdenes en Proceso</h6>
                                    <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getOrdenesEnProceso() %></h2>
                                    <small style="font-size: 0.8rem; color: #4a4a4a;">En preparación</small>
                                </div>
                                <div class="stat-icon text-info ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                    <i class="fas fa-cog"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12 col-12">
                    <div class="card stat-card shadow-sm border-start border-primary border-3" style="transition: transform 0.2s ease, box-shadow 0.2s ease; min-height: auto;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 4px 10px rgba(0,0,0,0.08)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="flex-grow-1">
                                    <h6 class="mb-1 text-uppercase" style="font-size: 0.85rem; font-weight: 600; letter-spacing: 0.3px; color: #4a4a4a;">Total Órdenes</h6>
                                    <h2 class="mb-0 fw-bold" style="font-size: 2.3rem; line-height: 1.1; color: #000000;"><%= metricas.getTotalOrdenes() %></h2>
                                    <small style="font-size: 0.8rem; color: #4a4a4a;">Todas las órdenes</small>
                                </div>
                                <div class="stat-icon text-primary ms-2" style="font-size: 2.2rem; opacity: 0.15; flex-shrink: 0;">
                                    <i class="fas fa-list"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row mt-2 mb-4">
                <div class="col-12">
                    <h5 class="mb-3 pageheader-title" style="font-size: 1.15rem;">
                        <i class="fas fa-bolt text-primary me-2"></i>Accesos rápidos
                    </h5>
                </div>
                <div class="col-lg-3 col-md-6 mb-2">
                    <a href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="mb-1" style="color: #006d77;">
                                <i class="fas fa-shopping-cart" style="font-size: 1.9rem;"></i>
                            </div>
                            <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Mis Productos</h6>
                            <span style="font-size: 0.8rem; color: #4a4a4a;">Ver catálogo</span>
                        </div>
                    </a>
                </div>
                <div class="col-lg-3 col-md-6 mb-2">
                    <a href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="mb-1" style="color: #006d77;">
                                <i class="fas fa-boxes" style="font-size: 1.9rem;"></i>
                            </div>
                            <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Registrar Lotes</h6>
                            <span style="font-size: 0.8rem; color: #4a4a4a;">Nuevo lote</span>
                        </div>
                    </a>
                </div>
                <div class="col-lg-3 col-md-6 mb-2">
                    <a href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="mb-1" style="color: #006d77;">
                                <i class="fas fa-chart-pie" style="font-size: 1.9rem;"></i>
                            </div>
                            <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Órdenes de Compra</h6>
                            <span style="font-size: 0.8rem; color: #4a4a4a;">Gestionar órdenes</span>
                        </div>
                    </a>
                </div>
                <div class="col-lg-3 col-md-6 mb-2">
                    <a href="<%= request.getContextPath() %>/ProductorServlet?action=formActualizarPrecios" class="card quick-link-card shadow-sm text-decoration-none" style="transition: all 0.3s ease; border: none; min-height: auto;" onmouseover="this.style.transform='translateY(-3px)'; this.style.boxShadow='0 6px 12px rgba(0,0,0,0.1)'" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 6px rgba(0,0,0,0.05)'">
                        <div class="card-body text-center p-2" style="padding-top: 0.75rem !important; padding-bottom: 0.75rem !important;">
                            <div class="mb-1" style="color: #006d77;">
                                <i class="fas fa-tags" style="font-size: 1.9rem;"></i>
                            </div>
                            <h6 class="fw-semibold mb-0" style="font-size: 0.95rem; color: #000000;">Actualizar Precios</h6>
                            <span style="font-size: 0.8rem; color: #4a4a4a;">Modificar precios</span>
                        </div>
                    </a>
                </div>
            </div>
            
            <!-- Espacio adicional al final -->
            <div class="row" style="margin-bottom: 80px; padding-bottom: 40px;">
                <div class="col-12"></div>
            </div>

        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

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
</script>
</body>
</html>

