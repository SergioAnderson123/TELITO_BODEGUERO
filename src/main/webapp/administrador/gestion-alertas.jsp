<%@ page import="com.example.telito.administrador.beans.AlertaConfig" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Mensajes de éxito o error --%>
<% if (session.getAttribute("successMsg") != null) { %>
<div class="alert alert-success" role="alert">
    <%= session.getAttribute("successMsg") %>
    <% session.removeAttribute("successMsg"); %>
</div>
<% } %>
<% if (session.getAttribute("errorMsg") != null) { %>
<div class="alert alert-danger" role="alert">
    <%= session.getAttribute("errorMsg") %>
    <% session.removeAttribute("errorMsg"); %>
</div>
<% } %>

<% ArrayList<AlertaConfig> listaAlertas = (ArrayList<AlertaConfig>) request.getAttribute("listaAlertas"); %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Alertas – Telito Bodeguero</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body>
<div class="topbar">
    <div class="topbar-brand"><i class="fas fa-warehouse"></i> Telito Bodeguero</div>
    <div class="topbar-actions"><div class="user-avatar">TB</div></div>
</div>

<aside class="sidebar" id="sidebar">
    <div class="sidebar-menu-title">Menu</div>
    <nav>
        <a href="<%= request.getContextPath() %>/inicio"><i class="fas fa-home fa-fw"></i> Pestaña principal</a>
        <a href="<%= request.getContextPath() %>/UsuarioServlet"><i class="fas fa-users fa-fw"></i> Gestión de Usuarios</a>
        <a href="<%= request.getContextPath() %>/ProductoServlet?action=listarInventario"><i class="fas fa-boxes-stacked fa-fw"></i> Inventario General</a>
        <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
        <a href="<%= request.getContextPath() %>/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
        <a href="<%= request.getContextPath() %>/configuracion.jsp" class="active"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
    </nav>
    <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
</aside>

<header class="header" id="header">
    <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
</header>

<main class="content" id="content">
    <div class="page-header mb-4 d-flex justify-content-between align-items-center">
        <div>
            <h2 class="pageheader-title" style="font-weight: 700;">Configuración de Alertas</h2>
            <p class="pageheader-text">Crea y administra las reglas de notificación del sistema.</p>
        </div>
        <div>
            <a href="<%= request.getContextPath() %>/AlertaServlet?action=formCrear" class="btn btn-primary"><i class="fas fa-plus"></i> Crear Nueva Regla</a>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="table-card">
                <div class="card-header">
                    <h5 class="mb-0 fw-semibold">Reglas de Alerta</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                            <tr>
                                <th>Nombre de la Regla</th>
                                <th>Tipo</th>
                                <th>Condición</th>
                                <th>Rol a Notificar</th>
                                <th>Estado</th>
                                <th class="text-end">Acciones</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (listaAlertas != null && !listaAlertas.isEmpty()) { %>
                                <% for (AlertaConfig alerta : listaAlertas) { %>
                                <tr>
                                    <td class="fw-medium"><%= alerta.getNombre() %></td>
                                    <td>
                                        <% if ("STOCK_MINIMO".equals(alerta.getTipoAlerta())) { %>
                                            <span class="badge bg-warning-soft text-warning">Stock Mínimo</span>
                                        <% } else { %>
                                            <span class="badge bg-danger-soft text-danger">Próximo a Vencer</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if ("PROXIMO_A_VENCER".equals(alerta.getTipoAlerta())) { %>
                                            Vence en <strong><%= alerta.getUmbralDias() %></strong> días
                                        <% } else { %>
                                            --
                                        <% } %>
                                        <% if (alerta.getCategoria() != null) { %>
                                            <br><small class="text-muted">Categoría: <%= alerta.getCategoria().getNombre() %></small>
                                        <% } %>
                                    </td>
                                    <td><%= alerta.getRolANotificar().getNombre() %></td>
                                    <td>
                                        <% if (alerta.isActivo()) { %>
                                            <span class="badge bg-success-soft text-success">Activa</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary-soft text-secondary">Inactiva</span>
                                        <% } %>
                                    </td>
                                    <td class="text-end">
                                        <a href="<%= request.getContextPath() %>/AlertaServlet?action=editar&id=<%= alerta.getIdAlertaConfig() %>" class="btn btn-sm btn-outline-primary">Editar</a>
                                        <% if (alerta.isActivo()) { %>
                                            <a href="<%= request.getContextPath() %>/AlertaServlet?action=borrar&id=<%= alerta.getIdAlertaConfig() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Estás seguro de que quieres deshabilitar esta regla?')">Deshabilitar</a>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            <% } else { %>
                                <tr><td colspan="6" class="text-center py-4">No hay reglas de alerta configuradas. ¡Crea la primera!</td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
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
