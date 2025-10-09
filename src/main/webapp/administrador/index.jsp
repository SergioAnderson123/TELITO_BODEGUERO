<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Inicio – Telito Bodeguero</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
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
          <a href="<%= request.getContextPath() %>/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
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
        <div class="page-header">
          <h2 class="pageheader-title" style="font-weight: 700;">¡Bienvenido, Administrador!</h2>
          <p class="pageheader-text">Resumen general del sistema y accesos rápidos.</p>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12">
        <div class="card stat-card border-success">
          <div class="card-body"><div class="d-flex justify-content-between align-items-center"><div><h5 class="text-muted">Usuarios registrados</h5><h2 class="mb-0 fw-bold"><%= request.getAttribute("totalUsuarios") %></h2></div><div class="stat-icon"><i class="fas fa-users"></i></div></div></div>
        </div>
      </div>
      <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12">
        <div class="card stat-card border-danger">
          <div class="card-body"><div class="d-flex justify-content-between align-items-center"><div><h5 class="text-muted">Usuarios baneados</h5><h2 class="mb-0 fw-bold"><%= request.getAttribute("usuariosBaneados") %></h2></div><div class="stat-icon"><i class="fas fa-user-slash"></i></div></div></div>
        </div>
      </div>
      <div class="col-xl-4 col-lg-6 col-md-6 col-sm-12 col-12">
        <div class="card stat-card border-warning">
          <div class="card-body"><div class="d-flex justify-content-between align-items-center"><div><h5 class="text-muted">Alertas abiertas</h5><h2 class="mb-0 fw-bold"><%= session.getAttribute("alertasAbiertas") != null ? session.getAttribute("alertasAbiertas") : "0" %></h2></div><div class="stat-icon"><i class="fas fa-exclamation-triangle"></i></div></div></div>
        </div>
      </div>
    </div>

    <div class="row mt-4">
      <div class="col-12"><h3 class="mb-3" style="font-weight: 700;">Accesos rápidos</h3></div>
      <div class="col-lg-3 col-md-6 mb-4"><a href="<%= request.getContextPath() %>/reportes-globales.jsp" class="card quick-link-card"><i class="fas fa-chart-pie"></i><h5>Reportes globales</h5><span>KPIs y tableros</span></a></div>
      <div class="col-lg-3 col-md-6 mb-4"><a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp" class="card quick-link-card"><i class="fas fa-user-shield"></i><h5>Roles y permisos</h5><span>Asignación y políticas</span></a></div>
      <div class="col-lg-3 col-md-6 mb-4"><a href="<%= request.getContextPath() %>/administrador/configuracion.jsp" class="card quick-link-card"><i class="fas fa-cogs"></i><h5>Configuración</h5><span>Sistema y plantillas</span></a></div>
      <div class="col-lg-3 col-md-6 mb-4"><a href="#" class="card quick-link-card"><i class="fas fa-chart-line"></i><h5>Reportes globales</h5><span>Indicadores y métricas</span></a></div>
    </div>

    <div class="row mt-2">
      <div class="col-12">
        <button class="btn btn-primary" onclick="location.href='<%= request.getContextPath() %>/UsuarioServlet?action=formCrear'"><i class="fas fa-user-plus me-2"></i> Crear usuario</button>
        <button class="btn btn-secondary" onclick="location.href='#'"><i class="fas fa-chart-line me-2"></i> Ver reportes</button>
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
