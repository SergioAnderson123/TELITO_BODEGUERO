<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Acceso a Roles – Telito Bodeguero</title>
  
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
          <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp" class="active"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
          <a href="<%= request.getContextPath() %>/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
          <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>
    
  <main class="content" id="content">
    <section class="content-box">
      <h1 class="page-title"><i class="fas fa-user-shield"></i> Acceso a Roles</h1>
      <p class="page-subtitle">Selecciona la interfaz a la que deseas acceder.</p>

      <div class="menu-grid">
        <a class="menu-card" href="#">
          <div class="menu-card-icon icon-almacen"><i class="fas fa-warehouse"></i></div>
          <div class="menu-card-title">Almacén</div>
        </a>

        <a class="menu-card" href="#">
          <div class="menu-card-icon icon-logistica"><i class="fas fa-truck"></i></div>
          <div class="menu-card-title">Logística</div>
        </a>

        <a class="menu-card" href="#">
          <div class="menu-card-icon icon-productor"><i class="fas fa-seedling"></i></div>
          <div class="menu-card-title">Productor</div>
        </a>
      </div>

    </section>
  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      const sidebarToggle = document.getElementById('sidebar-toggle');
      const sidebar = document.getElementById('sidebar');
      const content = document.getElementById('content');
      const header = document.getElementById('header');

      if (sidebarToggle && sidebar && content && header) {
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
