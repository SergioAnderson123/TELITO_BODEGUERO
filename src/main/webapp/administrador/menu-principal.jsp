<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Inicio"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Inicio'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
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
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>