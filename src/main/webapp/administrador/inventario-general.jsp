<%@ page import="com.example.telito.administrador.beans.Producto" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% ArrayList<Producto> listaProductos = (ArrayList<Producto>) request.getAttribute("lista"); %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Inventario General"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Inventario'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
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
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
