<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Configuración – Telito Bodeguero</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/administrador/assets/css/style.css">
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
          <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp" class="active"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>

  <main class="content" id="content">
    <section class="content-box">
      <h1 class="page-title"><i class="fas fa-cogs"></i> Configuración del Sistema</h1>
      <p class="page-subtitle">Selecciona el área de configuración que deseas administrar.</p>

      <div class="menu-grid">
        <a class="menu-card" href="<%= request.getContextPath() %>/ProductoServlet?action=listarStock">
          <div class="menu-card-icon icon-alert"><i class="fas fa-triangle-exclamation"></i></div>
          <div>
            <div class="menu-card-title">Configurar Stock Mínimo</div>
            <div class="menu-card-desc">Define umbrales y notificaciones para el stock.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/AlertaServlet">
          <div class="menu-card-icon icon-notification"><i class="fas fa-bell"></i></div>
           <div>
            <div class="menu-card-title">Gestión de Alertas</div>
            <div class="menu-card-desc">Crea y administra las reglas de notificación del sistema.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/PlantillaServlet">
          <div class="menu-card-icon icon-security"><i class="fas fa-file-excel"></i></div>
           <div>
            <div class="menu-card-title">Gestión de Plantillas</div>
            <div class="menu-card-desc">Administra las plantillas para la carga masiva de datos.</div>
          </div>
        </a>

      </div>
    </section>
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
