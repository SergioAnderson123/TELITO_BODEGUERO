<%@ page import="com.example.webbappadministrador.beans.AlertaConfig" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    AlertaConfig alerta = (AlertaConfig) request.getAttribute("alerta");
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Regla de Alerta – Telito Bodeguero</title>
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
        <a href="<%= request.getContextPath() %>/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
        <a href="<%= request.getContextPath() %>/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
        <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp" class="active"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
    </nav>
    <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
</aside>

<header class="header" id="header">
    <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
</header>

<main class="content" id="content">
    <div class="page-header mb-4">
        <h2 class="pageheader-title" style="font-weight: 700;">Editar Regla de Alerta</h2>
        <p class="pageheader-text">Modifica las condiciones de la notificación automática.</p>
    </div>

    <div class="row">
        <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
            <div class="form-card">
                <div class="card-body">
                    <form action="<%= request.getContextPath() %>/AlertaServlet?action=actualizar" method="POST">
                        <input type="hidden" name="id_alerta_config" value="<%= alerta.getIdAlertaConfig() %>">

                        <div class="mb-3">
                            <label for="nombre" class="form-label">Nombre de la Regla</label>
                            <input type="text" class="form-control" id="nombre" name="nombre" value="<%= alerta.getNombre() %>" required>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="tipo_alerta" class="form-label">Tipo de Alerta</label>
                                <select id="tipo_alerta" name="tipo_alerta" class="form-select" required>
                                    <option value="STOCK_MINIMO" <%= "STOCK_MINIMO".equals(alerta.getTipoAlerta()) ? "selected" : "" %>>Stock Mínimo</option>
                                    <option value="PROXIMO_A_VENCER" <%= "PROXIMO_A_VENCER".equals(alerta.getTipoAlerta()) ? "selected" : "" %>>Próximo a Vencer</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3" id="umbral-container">
                                <label for="umbral_dias" class="form-label">Umbral de Días</label>
                                <input type="number" class="form-control" id="umbral_dias" name="umbral_dias" value="<%= alerta.getUmbralDias() != null ? alerta.getUmbralDias() : "" %>">
                                <small class="form-text text-muted">Activar alerta cuando falten X días para vencer.</small>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="categoria_id" class="form-label">Categoría (Opcional)</label>
                                <select id="categoria_id" name="categoria_id" class="form-select">
                                    <option value="">Todas las categorías</option>
                                    <option value="1" <%= (alerta.getCategoria() != null && alerta.getCategoria().getIdCategoria() == 1) ? "selected" : "" %>>Bebidas</option>
                                    <option value="2" <%= (alerta.getCategoria() != null && alerta.getCategoria().getIdCategoria() == 2) ? "selected" : "" %>>Lácteos</option>
                                    <option value="3" <%= (alerta.getCategoria() != null && alerta.getCategoria().getIdCategoria() == 3) ? "selected" : "" %>>Abarrotes</option>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="rol_a_notificar_id" class="form-label">Rol a Notificar</label>
                                <select id="rol_a_notificar_id" name="rol_a_notificar_id" class="form-select" required>
                                    <option value="1" <%= (alerta.getRolANotificar().getIdRol() == 1) ? "selected" : "" %>>Administrador</option>
                                    <option value="2" <%= (alerta.getRolANotificar().getIdRol() == 2) ? "selected" : "" %>>Logística</option>
                                    <option value="3" <%= (alerta.getRolANotificar().getIdRol() == 3) ? "selected" : "" %>>Productor</option>
                                    <option value="4" <%= (alerta.getRolANotificar().getIdRol() == 4) ? "selected" : "" %>>Almacén</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-check mt-4">
                            <input class="form-check-input" type="checkbox" id="activo" name="activo" value="true" <%= alerta.isActivo() ? "checked" : "" %>>
                            <label class="form-check-label" for="activo">
                                Regla Activa
                            </label>
                        </div>

                        <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                            <a href="<%= request.getContextPath() %>/AlertaServlet" class="btn btn-light me-2">Cancelar</a>
                            <button type="submit" class="btn btn-primary">Guardar Cambios</button>
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

        const tipoAlertaSelect = document.getElementById('tipo_alerta');
        const umbralContainer = document.getElementById('umbral-container');
        const umbralInput = document.getElementById('umbral_dias');

        function toggleUmbralField() {
            if (tipoAlertaSelect.value === 'PROXIMO_A_VENCER') {
                umbralContainer.style.display = 'block';
                umbralInput.required = true;
            } else {
                umbralContainer.style.display = 'none';
                umbralInput.required = false;
            }
        }

        tipoAlertaSelect.addEventListener('change', toggleUmbralField);
        
        toggleUmbralField();
    });
</script>
</body>
</html>
