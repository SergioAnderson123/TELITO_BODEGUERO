<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.webbappadministrador.beans.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% 
    ArrayList<Usuario> listaUsuarios = (ArrayList<Usuario>) request.getAttribute("lista"); 
    String busqueda = (String) request.getAttribute("busqueda");
    String rolFiltro = (String) request.getAttribute("rolFiltro");
    String estadoFiltro = (String) request.getAttribute("estadoFiltro");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) {
        session.removeAttribute("successMsg");
    }

    // Parámetros de ordenamiento actuales
    String currentSortBy = (String) request.getAttribute("sortBy");
    String currentSortOrder = (String) request.getAttribute("sortOrder");
%>

<%! // BLOQUE DE DECLARACIÓN JSP PARA MÉTODOS AUXILIARES
    // Función auxiliar para generar URLs de ordenamiento
    public String getSortUrl(jakarta.servlet.http.HttpServletRequest request, String sortByColumn, String currentSortBy, String currentSortOrder, String busqueda, String rolFiltro, String estadoFiltro) {
        String newSortOrder = "asc";
        if (sortByColumn.equals(currentSortBy)) {
            newSortOrder = (currentSortOrder != null && currentSortOrder.equalsIgnoreCase("asc")) ? "desc" : "asc";
        }
        String baseUrl = request.getContextPath() + "/UsuarioServlet?action=listar";
        if (busqueda != null && !busqueda.isEmpty()) baseUrl += "&busqueda=" + busqueda;
        if (rolFiltro != null && !rolFiltro.isEmpty()) baseUrl += "&rol=" + rolFiltro;
        if (estadoFiltro != null && !estadoFiltro.isEmpty()) baseUrl += "&estado=" + estadoFiltro;
        baseUrl += "&sortBy=" + sortByColumn + "&sortOrder=" + newSortOrder;
        return baseUrl;
    }

    // Función auxiliar para mostrar el icono de ordenamiento
    public String getSortIcon(String sortByColumn, String currentSortBy, String currentSortOrder) {
        if (sortByColumn.equals(currentSortBy)) {
            return (currentSortOrder != null && currentSortOrder.equalsIgnoreCase("asc")) ? "<i class=\"fas fa-sort-up ms-1\"></i>" : "<i class=\"fas fa-sort-down ms-1\"></i>";
        }
        return "<i class=\"fas fa-sort ms-1\"></i>"; // Icono por defecto para no ordenado
    }
%>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Usuarios – Telito Bodeguero</title>
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
          <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#" onclick="event.preventDefault(); document.getElementById('logout-form').submit();"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>

  <main class="content" id="content">
    <% if (successMsg != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <%= successMsg %>
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    <% } %>

      <div class="page-header mb-4">
        <h2 class="pageheader-title" style="font-weight: 700;">Gestión de Usuarios</h2>
        <p class="pageheader-text">Administra los usuarios del sistema.</p>
      </div>

      <div class="row">
          <div class="col-12">
              <div class="table-card">
                  <div class="card-header">
                      <div class="d-flex justify-content-between align-items-center">
                          <h5 class="mb-0 fw-semibold">Lista de Usuarios</h5>
                          <div>
                              <a href="<%= request.getContextPath() %>/UsuarioServlet?action=formCrear" class="btn btn-sm btn-primary">
                                  <i class="fas fa-plus me-2"></i>Agregar Usuario
                              </a>
                          </div>
                      </div>
                  </div>
                  <div class="card-body">
                      <form action="<%= request.getContextPath() %>/UsuarioServlet" method="GET">
                          <input type="hidden" name="action" value="listar">
                          <div class="row mb-3">
                              <div class="col-md-4">
                                  <input type="text" class="form-control form-control-sm" name="busqueda" placeholder="Buscar por nombre, correo..." value="<%= busqueda != null ? busqueda : "" %>">
                              </div>
                              <div class="col-md-2">
                                  <select class="form-select form-select-sm" name="rol">
                                      <option value="" <%= (rolFiltro == null || rolFiltro.isEmpty()) ? "selected" : "" %>>Todos los Roles</option>
                                      <option value="1" <%= "1".equals(rolFiltro) ? "selected" : "" %>>Administrador</option>
                                      <option value="2" <%= "2".equals(rolFiltro) ? "selected" : "" %>>Logística</option>
                                      <option value="3" <%= "3".equals(rolFiltro) ? "selected" : "" %>>Productor</option>
                                      <option value="4" <%= "4".equals(rolFiltro) ? "selected" : "" %>>Almacén</option>
                                  </select>
                              </div>
                              <div class="col-md-2">
                                  <select class="form-select form-select-sm" name="estado">
                                      <option value="" <%= (estadoFiltro == null || estadoFiltro.isEmpty()) ? "selected" : "" %>>Todos los Estados</option>
                                      <option value="1" <%= "1".equals(estadoFiltro) ? "selected" : "" %>>Activo</option>
                                      <option value="0" <%= "0".equals(estadoFiltro) ? "selected" : "" %>>Inactivo</option>
                                  </select>
                              </div>
                              <div class="col-md-2"><button type="submit" class="btn btn-sm btn-primary w-100">Buscar</button></div>
                              <div class="col-md-2"><a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-sm btn-light w-100"><i class="fas fa-sync-alt me-2"></i>Limpiar</a></div>
                          </div>
                      </form>

                      <div class="table-responsive">
                          <table id="userTable" class="table table-hover align-middle">
                              <thead>
                                  <tr>
                                      <th>#</th>
                                      <th>
                                          <a href="<%= getSortUrl(request, "usuario", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro) %>" class="text-decoration-none text-dark">
                                              Usuario<%= getSortIcon("usuario", currentSortBy, currentSortOrder) %>
                                          </a>
                                      </th>
                                      <th>
                                          <a href="<%= getSortUrl(request, "correo", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro) %>" class="text-decoration-none text-dark">
                                              Correo<%= getSortIcon("correo", currentSortBy, currentSortOrder) %>
                                          </a>
                                      </th>
                                      <th>
                                          <a href="<%= getSortUrl(request, "rol", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro) %>" class="text-decoration-none text-dark">
                                              Rol<%= getSortIcon("rol", currentSortBy, currentSortOrder) %>
                                          </a>
                                      </th>
                                      <th>
                                          <a href="<%= getSortUrl(request, "estado", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro) %>" class="text-decoration-none text-dark">
                                              Estado<%= getSortIcon("estado", currentSortBy, currentSortOrder) %>
                                          </a>
                                      </th>
                                      <th class="text-end">Acciones</th>
                                  </tr>
                              </thead>
                              <tbody>
                              <% if (listaUsuarios != null && !listaUsuarios.isEmpty()) { %>
                                  <% for (Usuario usuario : listaUsuarios) { 
                                      String roleName = usuario.getRol().getNombre();
                                      String badgeClass = "text-bg-secondary"; // Default color
                                      switch (roleName) {
                                          case "Administrador":
                                              badgeClass = "text-bg-primary";
                                              break;
                                          case "Logística":
                                              badgeClass = "text-bg-info";
                                              break;
                                          case "Productor":
                                              badgeClass = "text-bg-success";
                                              break;
                                          case "Almacén":
                                              badgeClass = "text-bg-warning";
                                              break;
                                      }
                                  %>
                                  <tr>
                                      <td><%= usuario.getIdUsuario() %></td>
                                      <td>
                                          <div class="d-flex align-items-center">
                                              <img src="https://ui-avatars.com/api/?name=<%= usuario.getNombres() %>+<%= usuario.getApellidos() %>&background=667eea&color=fff" alt="Avatar" class="rounded-circle me-3" width="40" height="40">
                                              <div><h6 class="mb-0 fw-semibold"><%= usuario.getNombres() %> <%= usuario.getApellidos() %></h6></div>
                                          </div>
                                      </td>
                                      <td><%= usuario.getEmail() %></td>
                                      <td><span class="badge <%= badgeClass %>"><%= roleName %></span></td>
                                      <td>
                                          <% if (usuario.isActivo()) { %><span class="badge text-bg-success">Activo</span><% } else { %><span class="badge text-bg-secondary">Inactivo</span><% } %>
                                      </td>
                                      <td class="text-end">
                                          <div class="dropdown">
                                              <button class="btn btn-sm btn-light" type="button" data-bs-toggle="dropdown"><i class="fas fa-ellipsis-h"></i></button>
                                              <ul class="dropdown-menu dropdown-menu-end">
                                                  <li><a class="dropdown-item" href="<%= request.getContextPath() %>/UsuarioServlet?action=editar&id=<%= usuario.getIdUsuario() %>"><i class="fas fa-edit me-2"></i>Editar</a></li>
                                                  <li><a class="dropdown-item text-danger" href="<%= request.getContextPath() %>/UsuarioServlet?action=borrar&id=<%= usuario.getIdUsuario() %>" onclick="return confirm('¿Estás seguro?');"><i class="fas fa-trash me-2"></i>Eliminar</a></li>
                                              </ul>
                                          </div>
                                      </td>
                                  </tr>
                                  <% } %>
                              <% } else { %>
                                  <tr><td colspan="6" class="text-center py-4">No se encontraron usuarios con los filtros aplicados.</td></tr>
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
