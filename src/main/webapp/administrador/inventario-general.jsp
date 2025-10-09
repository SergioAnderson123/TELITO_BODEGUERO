<%@ page import="com.example.telito.administrador.beans.Producto" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% ArrayList<Producto> listaProductos = (ArrayList<Producto>) request.getAttribute("lista"); %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Inventario General – Telito Bodeguero</title>
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
          <a href="<%= request.getContextPath() %>/ProductoServlet?action=listarInventario" class="active"><i class="fas fa-boxes-stacked fa-fw"></i> Inventario General</a>
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
      <div class="page-header mb-4">
        <h2 class="pageheader-title" style="font-weight: 700;">Inventario General</h2>
        <p class="pageheader-text">Vista de supervisión de todos los productos del sistema.</p>
      </div>

      <div class="row">
          <div class="col-12">
              <div class="table-card">
                  <div class="card-header">
                      <h5 class="mb-0 fw-semibold">Lista de Productos</h5>
                  </div>
                  <div class="card-body">
                      <div class="table-responsive">
                          <table class="table table-hover align-middle">
                              <thead>
                                  <tr>
                                      <th>#</th>
                                      <th>SKU</th>
                                      <th>Nombre</th>
                                      <th>Descripción</th>
                                      <th>Precio</th>
                                      <th>Stock</th>
                                      <th>Stock Mín.</th>
                                      <th>Uds/Paq.</th>
                                      <th>ID Prod.</th>
                                      <th>ID Cat.</th>
                                  </tr>
                              </thead>
                              <tbody>
                              <% if (listaProductos != null && !listaProductos.isEmpty()) { %>
                                  <% for (Producto producto : listaProductos) { %>
                                  <tr>
                                      <td><%= producto.getIdProducto() %></td>
                                      <td><%= producto.getCodigoSku() %></td>
                                      <td><%= producto.getNombre() %></td>
                                      <td><%= producto.getDescripcion() %></td>
                                      <td>S/ <%= String.format("%.2f", producto.getPrecioActual()) %></td>
                                      <td><%= producto.getStock() %></td>
                                      <td><%= producto.getStockMinimo() %></td>
                                      <td><%= producto.getUnidadesPorPaquete() %></td>
                                      <td><%= producto.getProductorId() %></td>
                                      <td><%= producto.getCategoriaId() %></td>
                                  </tr>
                                  <% } %>
                              <% } else { %>
                                  <tr><td colspan="10" class="text-center py-4">No hay productos para mostrar.</td></tr>
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
