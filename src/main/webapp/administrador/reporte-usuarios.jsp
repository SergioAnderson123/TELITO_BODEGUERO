<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.dtos.UsuariosPorRolDto" %>

<jsp:useBean id="reporteUsuarios" class="java.util.ArrayList" scope="request" />

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Usuarios por Rol – Telito Bodeguero</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Reporte estadístico de usuarios agrupados por rol">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/administrador/assets/css/style.css">

    <style>
        .report-card {
            border: none;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border-radius: 12px;
            margin-bottom: 2rem;
        }
        .report-card .card-body { padding: 2rem; }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }
        .stat-number {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        .table-custom {
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .table-custom thead th {
            background: linear-gradient(135deg, #36a39a 0%, #006d77 100%);
            color: white;
            border: none;
            font-weight: 600;
            padding: 1rem;
        }
        .table-custom tbody td {
            padding: 1rem;
            border-color: #f1f5f9;
        }
        .badge-custom {
            padding: 0.5rem 1rem;
            border-radius: 20px;
            font-weight: 500;
        }
        .breadcrumb-custom .breadcrumb-item.active { color: #36a39a; font-weight: 500; }
    </style>
</head>
<body>
<div class="topbar">
    <div class="topbar-brand"><i class="fas fa-warehouse"></i> Telito Bodeguero</div>
    <div class="topbar-actions">
        <a href="<%= request.getContextPath() %>/AlertaServlet?action=listar" class="notification-bell" aria-label="Notificaciones">
            <i class="fas fa-bell"></i>
        </a>
        <div class="user-avatar">TB</div>
    </div>
</div>

<aside class="sidebar" id="sidebar">
    <div class="sidebar-menu-title">Menu</div>
    <nav aria-label="Navegación principal">
        <a href="<%= request.getContextPath() %>/administrador/menu-principal.jsp"><i class="fas fa-home fa-fw"></i> Pestaña principal</a>
        <a href="<%= request.getContextPath() %>/UsuarioServlet"><i class="fas fa-users fa-fw"></i> Gestión de Usuarios</a>
        <a href="<%= request.getContextPath() %>/ProductoServlet?action=listarInventario"><i class="fas fa-boxes-stacked fa-fw"></i> Inventario General</a>
        <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
        <a href="<%= request.getContextPath() %>/ReporteServlet?tipo=general" class="active"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
        <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
    </nav>
    <div class="sidebar-footer"><a href="<%= request.getContextPath() %>/LogoutServlet"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
</aside>

<header class="header" id="header">
    <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
</header>

<main class="content" id="content">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb breadcrumb-custom">
            <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/administrador/menu-principal.jsp">Pestaña principal</a></li>
            <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/ReporteServlet?tipo=general">Reportes Globales</a></li>
            <li class="breadcrumb-item active" aria-current="page">Usuarios por Rol</li>
        </ol>
    </nav>

    <div class="page-header mb-4">
        <h1 class="pageheader-title" style="font-weight: 700;">
            <i class="fas fa-chart-bar me-2"></i>Reporte de Usuarios por Rol
        </h1>
        <p class="pageheader-text">Estadísticas detalladas de usuarios agrupados por rol en el sistema.</p>
    </div>

    <!-- Tarjetas de estadísticas generales -->
    <div class="row mb-4">
        <%
            ArrayList<UsuariosPorRolDto> usuarios = (ArrayList<UsuariosPorRolDto>) request.getAttribute("reporteUsuarios");
            int totalUsuarios = 0;
            int totalActivos = 0;
            int totalInactivos = 0;
            
            if (usuarios != null) {
                for (UsuariosPorRolDto dto : usuarios) {
                    totalUsuarios += dto.getCantidadUsuarios();
                    totalActivos += dto.getUsuariosActivos();
                    totalInactivos += dto.getUsuariosInactivos();
                }
            }
        %>
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-number"><%= totalUsuarios %></div>
                <div class="stat-label">Total de Usuarios</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-number"><%= totalActivos %></div>
                <div class="stat-label">Usuarios Activos</div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card">
                <div class="stat-number"><%= totalInactivos %></div>
                <div class="stat-label">Usuarios Inactivos</div>
            </div>
        </div>
    </div>

    <!-- Tabla de reporte detallado -->
    <div class="report-card">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="mb-0"><i class="fas fa-table me-2"></i>Detalle por Rol</h3>
                <div>
                    <a href="<%= request.getContextPath() %>/ReporteServlet?tipo=general" class="btn btn-outline-primary me-2">
                        <i class="fas fa-arrow-left me-1"></i> Volver
                    </a>
                    <button class="btn btn-primary" onclick="window.print()">
                        <i class="fas fa-print me-1"></i> Imprimir
                    </button>
                </div>
            </div>

            <div class="table-responsive">
                <table class="table table-custom">
                    <thead>
                        <tr>
                            <th><i class="fas fa-user-tag me-2"></i>Rol</th>
                            <th><i class="fas fa-users me-2"></i>Total Usuarios</th>
                            <th><i class="fas fa-user-check me-2"></i>Activos</th>
                            <th><i class="fas fa-user-times me-2"></i>Inactivos</th>
                            <th><i class="fas fa-percentage me-2"></i>% Activos</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (usuarios != null && !usuarios.isEmpty()) {
                                for (UsuariosPorRolDto dto : usuarios) {
                                    double porcentajeActivos = dto.getCantidadUsuarios() > 0 ? 
                                        (double) dto.getUsuariosActivos() / dto.getCantidadUsuarios() * 100 : 0;
                        %>
                        <tr>
                            <td>
                                <span class="badge badge-custom bg-primary">
                                    <%= dto.getNombreRol() != null ? dto.getNombreRol() : "Sin Rol" %>
                                </span>
                            </td>
                            <td><strong><%= dto.getCantidadUsuarios() %></strong></td>
                            <td>
                                <span class="badge bg-success">
                                    <%= dto.getUsuariosActivos() %>
                                </span>
                            </td>
                            <td>
                                <span class="badge bg-danger">
                                    <%= dto.getUsuariosInactivos() %>
                                </span>
                            </td>
                            <td>
                                <div class="progress" style="height: 20px;">
                                    <div class="progress-bar bg-success" role="progressbar" 
                                         style="width: <%= porcentajeActivos %>%" 
                                         aria-valuenow="<%= porcentajeActivos %>" 
                                         aria-valuemin="0" aria-valuemax="100">
                                        <%= String.format("%.1f", porcentajeActivos) %>%
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="5" class="text-center text-muted">
                                <i class="fas fa-info-circle me-2"></i>No hay datos disponibles
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const sidebarToggle = document.getElementById('sidebar-toggle');
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => {
                document.getElementById('sidebar').classList.toggle('hidden');
                document.getElementById('content').classList.toggle('full-width');
                document.getElementById('header').classList.toggle('full-width');
            });
        }
    });
</script>
</body>
</html>
