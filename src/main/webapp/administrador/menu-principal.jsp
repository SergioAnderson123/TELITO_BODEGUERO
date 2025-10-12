<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Inicio – Telito Bodeguero</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/administrador/assets/css/style.css">

    <style>
        /* Paleta de colores del diseño de referencia */
        :root {
            --primary-accent: #36a39a;
            --page-bg: #f4f7f9;
            --card-bg: #ffffff;
            --border-color: #e9ecef;
            --text-dark: #343a40;
            --text-muted-light: #6c757d;
        }

        /* Aplicamos el fondo a la sección de contenido, no a todo el body */
        /* para no interferir con el sidebar */
        main.content {
            background-color: var(--page-bg);
        }

        /* Solo cambiamos el color de fondo y el borde del topbar */
        .topbar {
            background-color: var(--card-bg);
            border-bottom: 1px solid var(--border-color);
        }

        .pageheader-title {
            font-weight: 600;
            color: var(--text-dark);
        }

        .pageheader-text {
            color: var(--text-muted-light);
        }

        /* Estilo general para las tarjetas (esto es seguro y no rompe el layout) */
        .card {
            border: 1px solid var(--border-color);
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border-radius: 0.5rem;
        }

        .stat-card .card-body {
            padding: 1.5rem;
        }
        .stat-card .stat-icon {
            font-size: 2.5rem;
            opacity: 0.7;
        }

        .quick-link-card {
            background-color: var(--card-bg);
            text-decoration: none;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .quick-link-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 16px rgba(0,0,0,0.08);
        }
        .quick-link-card .card-body {
            padding: 1.5rem;
        }
        .quick-link-card i {
            color: var(--primary-accent);
        }

        /* Estilos para los botones */
        .btn-primary {
            background-color: var(--primary-accent);
            border-color: var(--primary-accent);
            font-weight: 500;
        }
        .btn-primary:hover {
            background-color: #2b847c;
            border-color: #2b847c;
        }

        .btn-light {
            background-color: #e9ecef;
            border-color: #ced4da;
            color: #495057;
            font-weight: 500;
        }
        .btn-light:hover {
            background-color: #d6dbdf;
            border-color: #b6bec4;
        }
    </style>
</head>
<body>
<div class="topbar">
    <div class="topbar-brand"><i class="fas fa-warehouse"></i> Telito Bodeguero</div>
    <div class="topbar-actions">
        <a href="<%= request.getContextPath() %>/AlertaServlet?action=listar" class="notification-bell">
            <i class="fas fa-bell"></i>
            <%
                Integer alertasAbiertas = (Integer) session.getAttribute("alertasAbiertas");
                if (alertasAbiertas != null && alertasAbiertas > 0) {
            %>
            <span class="notification-badge"><%= alertasAbiertas %></span>
            <%
                }
            %>
        </a>
        <div class="user-avatar">TB</div>
    </div>
</div>

<aside class="sidebar" id="sidebar">
    <div class="sidebar-menu-title">Menu</div>
    <nav>
        <a href="<%= request.getContextPath() %>/inicio" class="active"><i class="fas fa-home fa-fw"></i> Pestaña principal</a>
        <a href="<%= request.getContextPath() %>/UsuarioServlet"><i class="fas fa-users fa-fw"></i> Gestión de Usuarios</a>
        <a href="<%= request.getContextPath() %>/ProductoServlet?action=listarInventario"><i class="fas fa-boxes-stacked fa-fw"></i> Inventario General</a>
        <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
        <a href="<%= request.getContextPath() %>/administrador/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
        <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
    </nav>
    <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
</aside>

<header class="header" id="header">
    <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
</header>

<main class="content" id="content">
    <div class="row">
        <div class="col-12">
            <div class="page-header pt-3">
                <h2 class="pageheader-title"><i class="fas fa-chart-pie me-2"></i>¡Bienvenido, Administrador!</h2>
                <p class="pageheader-text">Resumen general del sistema y accesos rápidos.</p>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12 mb-4">
            <div class="card stat-card">
                <div class="card-body"><div class="d-flex justify-content-between align-items-center"><div><h5 class="text-muted">Usuarios registrados</h5><h2 class="mb-0 fw-bold"><%= request.getAttribute("totalUsuarios") %></h2></div><div class="stat-icon text-success"><i class="fas fa-users"></i></div></div></div>
            </div>
        </div>
        <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12 mb-4">
            <div class="card stat-card">
                <div class="card-body"><div class="d-flex justify-content-between align-items-center"><div><h5 class="text-muted">Usuarios baneados</h5><h2 class="mb-0 fw-bold"><%= request.getAttribute("usuariosBaneados") %></h2></div><div class="stat-icon text-danger"><i class="fas fa-user-slash"></i></div></div></div>
            </div>
        </div>
        <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12 mb-4">
            <div class="card stat-card">
                <div class="card-body"><div class="d-flex justify-content-between align-items-center"><div><h5 class="text-muted">Alertas abiertas</h5><h2 class="mb-0 fw-bold"><%= session.getAttribute("alertasAbiertas") != null ? session.getAttribute("alertasAbiertas") : "0" %></h2></div><div class="stat-icon text-warning"><i class="fas fa-exclamation-triangle"></i></div></div></div>
            </div>
        </div>
    </div>

    <div class="row mt-4">
        <div class="col-12"><h3 class="mb-3 pageheader-title">Accesos rápidos</h3></div>
        <div class="col-lg-3 col-md-6 mb-4"><a href="<%= request.getContextPath() %>/administrador/reportes-globales.jsp" class="card quick-link-card"><div class="card-body text-center"><i class="fas fa-chart-pie fs-1 mb-3"></i><h5 class="text-dark">Reportes globales</h5><span class="text-muted small">KPIs y tableros</span></div></a></div>
        <div class="col-lg-3 col-md-6 mb-4"><a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp" class="card quick-link-card"><div class="card-body text-center"><i class="fas fa-user-shield fs-1 mb-3"></i><h5 class="text-dark">Roles y permisos</h5><span class="text-muted small">Asignación y políticas</span></div></a></div>
        <div class="col-lg-3 col-md-6 mb-4"><a href="<%= request.getContextPath() %>/administrador/configuracion.jsp" class="card quick-link-card"><div class="card-body text-center"><i class="fas fa-cogs fs-1 mb-3"></i><h5 class="text-dark">Configuración</h5><span class="text-muted small">Sistema y plantillas</span></div></a></div>
        <div class="col-lg-3 col-md-6 mb-4"><a href="#" class="card quick-link-card"><div class="card-body text-center"><i class="fas fa-chart-line fs-1 mb-3"></i><h5 class="text-dark">Reportes globales</h5><span class="text-muted small">Indicadores y métricas</span></div></a></div>
    </div>

    <div class="row mt-3">
        <div class="col-12">
            <button class="btn btn-primary" onclick="location.href='<%= request.getContextPath() %>/UsuarioServlet?action=formCrear'"><i class="fas fa-user-plus me-2"></i> Crear usuario</button>
            <button class="btn btn-light" onclick="location.href='<%= request.getContextPath() %>/administrador/reportes-globales.jsp'"><i class="fas fa-eye me-2"></i> Ver reportes</button>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const sidebar = document.getElementById('sidebar');
        const content = document.getElementById('content');
        const header = document.getElementById('header');
        const sidebarToggle = document.getElementById('sidebar-toggle');
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => {
                sidebar.classList.toggle('hidden');
                content.classList.toggle('full-width');
                header.classList.toggle('full-width');
            });
        }
    });
</script>
</body>
</html>