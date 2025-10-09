<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Reportes Globales – Telito Bodeguero</title>
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
          <a href="<%= request.getContextPath() %>/reportes-globales.jsp" class="active"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
          <a href="<%= request.getContextPath() %>/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>

  <main class="content" id="content">
    <section class="content-box">
      <h1 class="page-title"><i class="fas fa-chart-pie"></i> Reportes Globales</h1>
      <p class="page-subtitle">Elige el tablero de indicadores que deseas visualizar.</p>

      <div class="menu-grid">
        <a class="menu-card" href="<%= request.getContextPath() %>/reportes?action=logistica">
          <div class="menu-card-icon icon-logistica"><i class="fas fa-chart-line"></i></div>
          <div>
            <div class="menu-card-title">Reporte Logística</div>
            <div class="menu-card-desc">Movimientos, distribución y transporte.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/reportes?action=productor">
          <div class="menu-card-icon icon-productor"><i class="fas fa-seedling"></i></div>
           <div>
            <div class="menu-card-title">Reporte Productor</div>
            <div class="menu-card-desc">Producción, lotes, costos y caducidad.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/reportes?action=almacen">
          <div class="menu-card-icon icon-almacen"><i class="fas fa-warehouse"></i></div>
           <div>
            <div class="menu-card-title">Reporte Almacén</div>
            <div class="menu-card-desc">Stock, entradas, salidas y ajustes.</div>
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
