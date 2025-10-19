<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.Rol" %>

<jsp:useBean id="listaRoles" class="java.util.ArrayList" scope="request" />

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Crear Usuario – Telito Bodeguero</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Crear un nuevo usuario en el sistema - Telito Bodeguero">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/administrador/assets/css/style.css">

    <style>
        .form-card {
            border: none;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border-radius: 12px;
        }
        .form-card .card-body { padding: 2rem; }
        .form-label { font-weight: 500; color: #374151; margin-bottom: 0.5rem; }
        .form-control, .form-select {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 0.75rem 1rem;
            transition: all 0.2s ease;
        }
        .form-control:focus, .form-select:focus {
            border-color: #36a39a;
            box-shadow: 0 0 0 3px rgba(54, 163, 154, 0.1);
        }
        .btn-primary {
            background: linear-gradient(160deg, #006d77 0%, #36a39a 100%);
            border: none;
            border-radius: 8px;
            padding: 0.75rem 2rem;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(54, 163, 154, 0.3);
        }
        .btn-light {
            border: 1px solid #d1d5db;
            border-radius: 8px;
            padding: 0.75rem 2rem;
            font-weight: 500;
        }
        .field-hint { font-size: 0.875rem; color: #6b7280; margin-top: 0.25rem; }
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
        <a href="<%= request.getContextPath() %>/inicio"><i class="fas fa-home fa-fw"></i> Pestaña principal</a>
        <a href="<%= request.getContextPath() %>/UsuarioServlet" class="active"><i class="fas fa-users fa-fw"></i> Gestión de Usuarios</a>
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
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb breadcrumb-custom">
            <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/inicio">Pestaña principal</a></li>
            <li class="breadcrumb-item"><a href="<%= request.getContextPath() %>/UsuarioServlet">Gestión de Usuarios</a></li>
            <li class="breadcrumb-item active" aria-current="page">Crear Usuario</li>
        </ol>
    </nav>

    <div class="page-header mb-4">
        <h1 class="pageheader-title" style="font-weight: 700;">
            <i class="fas fa-user-plus me-2"></i>Crear Nuevo Usuario
        </h1>
        <p class="pageheader-text">Complete el formulario para añadir un nuevo usuario al sistema.</p>
    </div>

    <div class="row">
        <div class="col-xl-8 col-lg-10 col-md-12 mx-auto">
            <div class="form-card">
                <div class="card-body">
                    <form action="<%= request.getContextPath() %>/UsuarioServlet?action=guardar" method="POST" id="userForm">

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="nombres" class="form-label">Nombres <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="nombres" name="nombres" required placeholder="Ingrese los nombres">
                                <div class="field-hint">Nombre legal del usuario</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="apellidos" class="form-label">Apellidos <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="apellidos" name="apellidos" required placeholder="Ingrese los apellidos">
                                <div class="field-hint">Apellidos completos</div>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label for="email" class="form-label">Correo electrónico <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="email" name="email" required placeholder="usuario@ejemplo.com">
                            <div class="field-hint">Dirección de correo única para el sistema</div>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Contraseña <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="password" name="password" required placeholder="Ingrese una contraseña segura">
                            <div class="field-hint">La contraseña debe tener al menos 8 caracteres</div>
                        </div>

                        <div class="mb-3">
                            <label for="rol_id" class="form-label">Rol del sistema <span class="text-danger">*</span></label>
                            <select id="rol_id" name="rol_id" class="form-select" required>
                                <option value="" selected disabled>Seleccionar rol...</option>
                                <%
                                    ArrayList<Rol> roles = (ArrayList<Rol>) request.getAttribute("listaRoles");
                                    if (roles != null) {
                                        for (Rol rol : roles) {
                                %>
                                    <option value="<%= rol.getIdRol() %>"><%= rol.getNombre() %></option>
                                <%
                                        }
                                    }
                                %>
                            </select>
                            <div class="field-hint">Define los permisos y acceso del usuario</div>
                        </div>

                        <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                            <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-light me-2">
                                <i class="fas fa-times me-1"></i> Cancelar
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-1"></i> Crear Usuario
                            </button>
                        </div>
                    </form>
                </div>
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

        const form = document.getElementById('userForm');
        form.addEventListener('submit', (e) => {
            if (!confirm('¿Está seguro de que desea crear este nuevo usuario?')) {
                e.preventDefault();
            }
        });
    });
</script>
</body>
</html>