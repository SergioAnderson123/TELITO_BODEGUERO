<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% Usuario usuario = (Usuario) request.getAttribute("usuario"); %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Usuario – Telito Bodeguero</title>
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
          <a href="<%= request.getContextPath() %>/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
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
        <h2 class="pageheader-title" style="font-weight: 700;">Editar Usuario</h2>
        <p class="pageheader-text">Modifica la información del usuario.</p>
      </div>

      <div class="row">
          <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
              <div class="form-card">
                  <div class="card-body">
                      <form action="<%= request.getContextPath() %>/UsuarioServlet?action=actualizar" method="POST">
                          <input type="hidden" name="id_usuario" value="<%= usuario.getIdUsuario() %>">

                          <div class="row">
                              <div class="col-md-6 mb-3">
                                  <label for="nombres" class="form-label">Nombres</label>
                                  <input type="text" class="form-control" id="nombres" name="nombres" value="<%= usuario.getNombres() %>">
                              </div>
                              <div class="col-md-6 mb-3">
                                  <label for="apellidos" class="form-label">Apellidos</label>
                                  <input type="text" class="form-control" id="apellidos" name="apellidos" value="<%= usuario.getApellidos() %>">
                              </div>
                          </div>

                          <div class="mb-3">
                              <label for="email" class="form-label">Correo electrónico</label>
                              <input type="email" class="form-control" id="email" name="email" value="<%= usuario.getEmail() %>">
                          </div>

                          <div class="mb-3">
                              <label for="rol" class="form-label">Rol</label>
                              <select id="rol" name="rol_id" class="form-select">
                                  <option value="1" <%= (usuario.getRol().getIdRol() == 1) ? "selected" : "" %>>Administrador</option>
                                  <option value="2" <%= (usuario.getRol().getIdRol() == 2) ? "selected" : "" %>>Logística</option>
                                  <option value="3" <%= (usuario.getRol().getIdRol() == 3) ? "selected" : "" %>>Productor</option>
                                  <option value="4" <%= (usuario.getRol().getIdRol() == 4) ? "selected" : "" %>>Almacén</option>
                              </select>
                          </div>

                          <div class="form-check mt-4">
                              <input class="form-check-input" type="checkbox" id="activo" name="activo" value="true" <%= usuario.isActivo() ? "checked" : "" %>>
                              <label class="form-check-label" for="activo">
                                  Usuario Activo
                              </label>
                              <small class="form-text text-muted d-block">
                                  Desmarcar esta casilla deshabilita el acceso del usuario al sistema.
                              </small>
                          </div>

                          <div class="mt-4 pt-3 border-top d-flex justify-content-end">
                              <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-light me-2">Cancelar</a>
                              <button type="submit" class="btn btn-primary">Guardar cambios</button>
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
