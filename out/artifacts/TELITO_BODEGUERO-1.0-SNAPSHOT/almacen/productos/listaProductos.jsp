<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.Producto" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    ArrayList<Producto> listaProductos = (ArrayList<Producto>) request.getAttribute("listaProductos");
    if (listaProductos == null) listaProductos = new ArrayList<>();
    String busqueda = (String) request.getAttribute("busqueda");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Productos"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Productos"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header mb-4">
                            <h2><i class="fas fa-boxes-stacked me-2"></i>Productos</h2>
                            <p class="text-muted">Consulta de productos disponibles en el sistema (solo lectura).</p>
                        </div>
                    </div>
                </div>

                <!-- Búsqueda -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <form method="get" action="<%= request.getContextPath() %>/almacen/ProductoAlmacenServlet">
                            <div class="row g-3">
                                <div class="col-md-10">
                                    <input type="text" class="form-control" name="busqueda" 
                                           placeholder="Buscar por nombre, SKU o descripción..." 
                                           value="<%= busqueda != null ? busqueda : "" %>">
                                </div>
                                <div class="col-md-2">
                                    <button type="submit" class="btn btn-primary w-100">
                                        <i class="fas fa-search me-2"></i>Buscar
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Tabla de productos -->
                <div class="card shadow-sm">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="fas fa-list me-2"></i>Lista de Productos</h5>
                        <span class="badge bg-primary">Total: <%= listaProductos.size() %></span>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover table-striped mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>SKU</th>
                                        <th>Nombre</th>
                                        <th>Descripción</th>
                                        <th>Categoría</th>
                                        <th>Precio</th>
                                        <th>Stock Total</th>
                                        <th>Unidades/Paquete</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (listaProductos.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center py-4 text-muted">
                                            <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                                            No se encontraron productos
                                        </td>
                                    </tr>
                                    <% } else { %>
                                        <% for (Producto producto : listaProductos) { %>
                                        <tr>
                                            <td><code><%= producto.getCodigoSku() %></code></td>
                                            <td><strong><%= producto.getNombre() %></strong></td>
                                            <td>
                                                <%= producto.getDescripcion() != null && producto.getDescripcion().length() > 50 ? 
                                                    producto.getDescripcion().substring(0, 50) + "..." : 
                                                    (producto.getDescripcion() != null ? producto.getDescripcion() : "-") %>
                                            </td>
                                            <td><%= producto.getCategoriaNombre() != null ? producto.getCategoriaNombre() : "-" %></td>
                                            <td>S/ <%= String.format("%.2f", producto.getPrecioActual()) %></td>
                                            <td>
                                                <span class="badge <%= producto.getStock() > 0 ? "bg-success" : "bg-danger" %>">
                                                    <%= producto.getStock() %>
                                                </span>
                                            </td>
                                            <td><%= producto.getUnidadesPorPaquete() %></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/almacen/ProductoAlmacenServlet?action=ver&id=<%= producto.getIdProducto() %>" 
                                                   class="btn btn-sm btn-info text-white" title="Ver detalles">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                            </td>
                                        </tr>
                                        <% } %>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

