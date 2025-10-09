<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Crear Usuario – Telito Bodeguero</title>
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
          <a href="<%= request.getContextPath() %>/UsuarioServlet" class="active"><i class="fas fa-users fa-fw"></i> Gestión de Usuarios</a>
          <a href="<%= request.getContextPath() %>/ProductoServlet?action=listarInventario"><i class="fas fa-boxes-stacked fa-fw"></i> Inventario General</a>
          <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
          <a href="<%= request.getContextPath() %>/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
          <a href="<%= request.getContextPath() %>/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>

  <main class="content" id="content">
      <div class="page-header mb-4">
        <h2 class="pageheader-title" style="font-weight: 700;">Crear Nuevo Usuario</h2>
        <p class="pageheader-text">Complete los datos para registrar un nuevo usuario en el sistema.</p>
      </div>

      <div class="row">
          <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
              <div class="form-card">
                  <div class="card-body">
                      <form action="<%= request.getContextPath() %>/UsuarioServlet?action=guardar" method="POST" autocomplete="off">
                          <div class="row">
                              <div class="col-md-6 mb-3">
                                  <label for="nombres" class="form-label">Nombres</label>
                                  <input type="text" class="form-control" id="nombres" name="nombres" placeholder="Ej: Juan" required>
                              </div>
                              <div class="col-md-6 mb-3">
                                  <label for="apellidos" class="form-label">Apellidos</label>
                                  <input type="text" class="form-control" id="apellidos" name="apellidos" placeholder="Ej: Pérez" required>
                              </div>
                          </div>

                          <div class="mb-3">
                              <label for="email" class="form-label">Correo electrónico</label>
                              <input type="email" class="form-control" id="email" name="email" placeholder="Ej: juan.perez@example.com" required>
                          </div>

                          <div class="mb-3">
                              <label for="password" class="form-label">Contraseña</label>
                              <input type="password" class="form-control" id="password" name="password" placeholder="********" required>
                          </div>

                          <div class="mb-3">
                              <label for="rol" class="form-label">Rol</label>
                              <select id="rol" name="rol_id" class="form-select" required>
                                  <option value="" disabled selected>Selecciona un rol</option>
                                  <option value="1">Administrador</option>
                                  <option value="2">Logística</option>
                                  <option value="3">Productor</option>
                                  <option value="4">Almacén</option>
                              </select>
                          </div>

                          <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                              <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-light me-2">Cancelar</a>
                              <button type="submit" class="btn btn-primary">Crear Usuario</button>
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
    });
  </script>
</body>
</html>
