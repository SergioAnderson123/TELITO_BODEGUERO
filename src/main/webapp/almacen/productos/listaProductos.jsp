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

                <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                    <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-boxes-stacked me-2"></i>Productos (Solo Lectura)</h2>
                    <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Consulta de productos disponibles en el sistema.</p>
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
                            <table class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                <thead class="table-light">
                                    <tr>
                                        <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-barcode me-1"></i>SKU</th>
                                        <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-box me-1"></i>Nombre</th>
                                        <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-info-circle me-1"></i>Descripción</th>
                                        <th style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-tags me-1"></i>Categoría</th>
                                        <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-dollar-sign me-1"></i>Precio</th>
                                        <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-warehouse me-1"></i>Stock</th>
                                        <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-cubes me-1"></i>Unid/Paq</th>
                                        <th style="width: 8%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center"><i class="fas fa-cog me-1"></i>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (listaProductos.isEmpty()) { %>
                                    <tr>
                                        <td colspan="8" class="text-center py-5">
                                            <div class="text-muted">
                                                <i class="fas fa-inbox fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No se encontraron productos</p>
                                                <small>Intenta ajustar los filtros de búsqueda</small>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } else { %>
                                        <% for (Producto producto : listaProductos) { %>
                                        <tr class="align-middle" style="padding: 0;">
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><code><%= producto.getCodigoSku() %></code></td>
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= producto.getNombre() %></strong></td>
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <%= producto.getDescripcion() != null && producto.getDescripcion().length() > 50 ? 
                                                    producto.getDescripcion().substring(0, 50) + "..." : 
                                                    (producto.getDescripcion() != null ? producto.getDescripcion() : "-") %>
                                            </td>
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= producto.getCategoriaNombre() != null ? producto.getCategoriaNombre() : "-" %></td>
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">S/ <%= String.format("%.2f", producto.getPrecioActual()) %></td>
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <span class="badge <%= producto.getStock() > 0 ? "text-bg-success" : "text-bg-danger" %> shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                    <%= producto.getStock() %> paquetes
                                                </span>
                                            </td>
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= producto.getUnidadesPorPaquete() %></td>
                                            <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;" class="text-center">
                                                <a href="<%= request.getContextPath() %>/almacen/ProductoAlmacenServlet?action=ver&id=<%= producto.getIdProducto() %>" 
                                                   class="btn btn-sm btn-info text-white shadow-sm" title="Ver detalles" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                    <i class="fas fa-eye"></i> Ver
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

