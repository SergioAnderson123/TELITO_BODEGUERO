<%@ page import="com.example.telito.administrador.beans.Producto" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% ArrayList<Producto> listaProductos = (ArrayList<Producto>) request.getAttribute("lista"); %>

<!doctype html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Gestión de Stock – Telito Bodeguero</title>
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
          <a href="<%= request.getContextPath() %>/administrador/reportes-globales.jsp"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
          <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp" class="active"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>

  <main class="content" id="content">
      <div class="page-header mb-4">
        <h2 class="pageheader-title"><i class="fas fa-triangle-exclamation me-2"></i>Configurar Stock Mínimo</h2>
        <p class="pageheader-text">Define el umbral de stock para generar alertas de inventario.</p>
      </div>

      <div class="row">
          <div class="col-12">
              <div class="table-card shadow-sm">
                  <div class="card-header">
                      <div class="d-flex justify-content-between align-items-center">
                          <div>
                              <h5 class="mb-0 fw-semibold"><i class="fas fa-list me-2"></i>Stock Mínimo por Producto</h5>
                              <small class="text-white-50">Configura los umbrales de stock mínimo</small>
                          </div>
                      </div>
                  </div>
                  <div class="card-body">
                      <form action="<%= request.getContextPath() %>/ProductoServlet?action=guardarStock" method="POST">
                          <div class="table-responsive">
                              <table class="table table-hover align-middle mb-0">
                                  <thead class="table-light">
                                      <tr>
                                          <th><i class="fas fa-barcode me-1"></i>SKU</th>
                                          <th><i class="fas fa-box me-1"></i>Nombre del Producto</th>
                                          <th style="width: 200px;"><i class="fas fa-exclamation-triangle me-1"></i>Stock Mínimo</th>
                                      </tr>
                                  </thead>
                                  <tbody>
                                  <% if (listaProductos != null && !listaProductos.isEmpty()) { %>
                                      <% for (Producto producto : listaProductos) { %>
                                      <tr>
                                          <td><%= producto.getCodigoSku() %></td>
                                          <td><%= producto.getNombre() %></td>
                                          <td>
                                              <input type="hidden" name="productoId" value="<%= producto.getIdProducto() %>">
                                              <input type="number" class="form-control form-control-sm shadow-sm stock-input"
                                                     name="stockMinimo_<%= producto.getIdProducto() %>"
                                                     value="<%= producto.getStockMinimo() %>"
                                                     min="0">
                                          </td>
                                      </tr>
                                      <% } %>
                                  <% } else { %>
                                      <tr><td colspan="3" class="text-center">No hay productos para mostrar.</td></tr>
                                  <% } %>
                                  </tbody>
                              </table>
                          </div>
                          <div class="d-flex justify-content-end mt-4 pt-3 border-top">
                              <button type="submit" class="btn btn-primary shadow-sm px-4">
                                  <i class="fas fa-save me-2"></i>Guardar Todos los Cambios
                              </button>
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
