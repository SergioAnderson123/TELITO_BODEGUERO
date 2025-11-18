<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.productor.servlets.DashboardProductorServlet.MetricasProductor" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    MetricasProductor metricas = (MetricasProductor) request.getAttribute("metricas");
    if (metricas == null) {
        metricas = new MetricasProductor();
    }
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Telito Bodeguero</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --turquoise-dark: #006d77;
            --seafoam: #83c5be;
            --seafoam-light: #edf6f9;
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
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, #055e68 100%);
            min-height: 100vh;
            position: fixed; left: 0; top: 0; z-index: 1000;
            box-shadow: 2px 0 10px rgba(0,0,0,0.1);
        }
        .dashboard-wrapper { margin-left: 250px; width: calc(100% - 250px); min-height: 100vh; }
        .dashboard-header {
            background-color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            position: fixed; top: 0; right: 0; left: 250px; z-index: 999;
            height: 70px; border-bottom: 1px solid var(--border);
        }
        .dashboard-content { margin-top: 70px; padding: 30px; }
        .nav-link {
            color: rgba(255,255,255,0.9) !important;
            padding: 12px 20px; border-radius: 8px; margin: 5px 15px;
            transition: all 0.3s ease; display: flex; align-items: center;
        }
        .nav-link:hover, .nav-link.active { background-color: rgba(255,255,255,0.18); color: #fff !important; transform: translateX(5px); }
        .nav-link i { margin-right: 10px; width: 20px; }
        .nav-divider { color: rgba(255,255,255,0.8); font-weight: 600; padding: 15px 20px 5px; margin-top: 20px; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 1px; }
        .navbar-brand { font-weight: 700; color: var(--turquoise-dark); }
        .card { border: none; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.08); transition: transform 0.3s ease; }
        .card:hover { transform: translateY(-2px); }
        .page-header { margin-bottom: 30px; }
        .page-header h2 { color: var(--turquoise-dark); font-weight: 700; margin-bottom: 10px; }
        .page-header p { color: var(--text-muted); font-size: 1.05rem; }
        .stat-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            min-height: auto;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.08) !important;
        }
        .stat-icon {
            font-size: 2.2rem;
            opacity: 0.15;
            flex-shrink: 0;
        }
        .quick-link-card {
            transition: transform 0.2s ease;
        }
        .quick-link-card:hover {
            transform: translateY(-3px);
        }
        /* Botón Hamburguesa */
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
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <!-- Overlay para móvil -->
    <div class="sidebar-overlay" id="sidebarOverlay"></div>
    
    <!-- Sidebar -->
    <div class="nav-left-sidebar">
        <div class="menu-list">
            <nav class="navbar navbar-expand">
                <ul class="navbar-nav flex-column w-100">
                    <li class="nav-divider"><i class="fas fa-bars me-2"></i>Menú</li>
                    <li class="nav-item">
                        <a class="nav-link active" href="<%= request.getContextPath() %>/productor/DashboardProductorServlet">
                            <i class="fas fa-chart-line"></i>Dashboard
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos">
                            <i class="fas fa-shopping-cart"></i>Mis Productos
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra">
                            <i class="fas fa-chart-pie"></i>Órdenes de Compra
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote">
                            <i class="fas fa-boxes"></i>Registrar Lotes
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<%= request.getContextPath() %>/ProductorServlet?action=formActualizarPrecios">
                            <i class="fas fa-tags"></i>Actualizar Precios
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>

    <!-- Header -->
    <div class="dashboard-header">
        <nav class="navbar navbar-expand-lg navbar-light bg-white">
            <div class="container-fluid">
                <!-- Botón Hamburguesa -->
                <button class="sidebar-toggle" id="sidebarToggle" type="button" aria-label="Toggle sidebar">
                    <i class="fas fa-bars"></i>
                </button>
                <!-- Brand -->
                <a class="navbar-brand d-flex align-items-center" href="<%= request.getContextPath() %>/productor/DashboardProductorServlet">
                    <i class="fas fa-store me-2" style="color: var(--seafoam);"></i>
                    <span>Telito Bodeguero</span>
                </a>
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
                            <li><a class="dropdown-item text-danger" href="<%= request.getContextPath() %>/logout"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </nav>
    </div>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header pt-1 pb-1 d-flex justify-content-between align-items-center flex-wrap">
                            <div>
                                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem;">
                                    <i class="fas fa-chart-pie me-2"></i>Dashboard del Productor
                                </h2>
                                <p class="pageheader-text mb-0" style="font-size: 0.85rem;">
                                    Resumen de tus productos, lotes y órdenes.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Alertas -->
                <% if (metricas.getLotesProximosVencer() > 0) { %>
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <strong>Atención:</strong> Tienes <%= metricas.getLotesProximosVencer() %> lote(s) que vencen en los próximos 30 días.
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <!-- Primera fila: Productos y Lotes -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-primary border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Productos Activos</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getProductosActivos() %></h2>
                                        <small class="text-muted">En tu catálogo</small>
                                    </div>
                                    <div class="stat-icon text-primary ms-2">
                                        <i class="fas fa-box"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-success border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Lotes Este Mes</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getLotesEsteMes() %></h2>
                                        <small class="text-muted">Registrados este mes</small>
                                    </div>
                                    <div class="stat-icon text-success ms-2">
                                        <i class="fas fa-boxes"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-info border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Stock Total</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getStockTotal() %></h2>
                                        <small class="text-muted">Unidades disponibles</small>
                                    </div>
                                    <div class="stat-icon text-info ms-2">
                                        <i class="fas fa-warehouse"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-warning border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Lotes Próximos a Vencer</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getLotesProximosVencer() %></h2>
                                        <small class="text-muted">Próximos 30 días</small>
                                    </div>
                                    <div class="stat-icon text-warning ms-2">
                                        <i class="fas fa-calendar-times"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Segunda fila: Órdenes -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-warning border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Órdenes Pendientes</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getOrdenesPendientes() %></h2>
                                        <small class="text-muted">Requieren atención</small>
                                    </div>
                                    <div class="stat-icon text-warning ms-2">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-info border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Órdenes en Proceso</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getOrdenesEnProceso() %></h2>
                                        <small class="text-muted">En preparación</small>
                                    </div>
                                    <div class="stat-icon text-info ms-2">
                                        <i class="fas fa-cog"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12">
                        <div class="card stat-card shadow-sm border-start border-primary border-3">
                            <div class="card-body p-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div class="flex-grow-1">
                                        <h6 class="text-muted mb-1 text-uppercase">Total Órdenes</h6>
                                        <h2 class="mb-0 fw-bold text-dark"><%= metricas.getTotalOrdenes() %></h2>
                                        <small class="text-muted">Todas las órdenes</small>
                                    </div>
                                    <div class="stat-icon text-primary ms-2">
                                        <i class="fas fa-list"></i>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Accesos rápidos -->
                <div class="row mt-2">
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-white">
                                <h5 class="mb-0"><i class="fas fa-bolt me-2"></i>Accesos Rápidos</h5>
                            </div>
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/ProductorServlet?action=listarProductos" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-shopping-cart" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Mis Productos</h6>
                                                <span class="text-muted small">Ver catálogo</span>
                                            </div>
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/ProductorServlet?action=formRegistrarLote" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-boxes" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Registrar Lotes</h6>
                                                <span class="text-muted small">Nuevo lote</span>
                                            </div>
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/ProductorServlet?action=ordenesCompra" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-chart-pie" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Órdenes de Compra</h6>
                                                <span class="text-muted small">Gestionar órdenes</span>
                                            </div>
                                        </a>
                                    </div>
                                    <div class="col-lg-3 col-md-6">
                                        <a href="<%= request.getContextPath() %>/ProductorServlet?action=formActualizarPrecios" class="card quick-link-card shadow-sm text-decoration-none">
                                            <div class="card-body text-center p-3">
                                                <div class="mb-2" style="color: #006d77;"><i class="fas fa-tags" style="font-size: 2rem;"></i></div>
                                                <h6 class="text-dark fw-semibold mb-0">Actualizar Precios</h6>
                                                <span class="text-muted small">Modificar precios</span>
                                            </div>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Toggle sidebar en móvil
    document.addEventListener('DOMContentLoaded', function() {
        const sidebarToggle = document.getElementById('sidebarToggle');
        const sidebar = document.querySelector('.nav-left-sidebar');
        const overlay = document.getElementById('sidebarOverlay');
        
        if (sidebarToggle && sidebar && overlay) {
            sidebarToggle.addEventListener('click', function() {
                sidebar.classList.toggle('open');
                overlay.classList.toggle('active');
            });
            
            overlay.addEventListener('click', function() {
                sidebar.classList.remove('open');
                overlay.classList.remove('active');
            });
        }
    });
</script>
</body>
</html>

