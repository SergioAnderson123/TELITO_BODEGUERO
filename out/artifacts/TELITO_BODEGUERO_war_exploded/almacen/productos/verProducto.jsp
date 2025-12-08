<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.administrador.beans.Producto" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    Producto producto = (Producto) request.getAttribute("producto");
    if (producto == null) {
        response.sendRedirect(request.getContextPath() + "/almacen/ProductoAlmacenServlet");
        return;
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Detalles de Producto"/>
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
                        <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                            <div>
                                <h2><i class="fas fa-box me-2"></i>Detalles de Producto</h2>
                            </div>
                            <a href="<%= request.getContextPath() %>/almacen/ProductoAlmacenServlet" class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Volver
                            </a>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-8">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0">Información del Producto</h5>
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <strong>Código SKU:</strong>
                                        <p class="mb-0"><code><%= producto.getCodigoSku() %></code></p>
                                    </div>
                                    <div class="col-md-6">
                                        <strong>Nombre:</strong>
                                        <p class="mb-0"><%= producto.getNombre() %></p>
                                    </div>
                                </div>
                                
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <strong>Categoría:</strong>
                                        <p class="mb-0"><%= producto.getCategoriaNombre() != null ? producto.getCategoriaNombre() : "-" %></p>
                                    </div>
                                    <div class="col-md-6">
                                        <strong>Precio Actual:</strong>
                                        <p class="mb-0 fs-5">S/ <%= String.format("%.2f", producto.getPrecioActual()) %></p>
                                    </div>
                                </div>
                                
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <strong>Stock Total:</strong>
                                        <p class="mb-0">
                                            <span class="badge <%= producto.getStock() > 0 ? "bg-success" : "bg-danger" %> fs-6">
                                                <%= producto.getStock() %> unidades
                                            </span>
                                        </p>
                                    </div>
                                    <div class="col-md-6">
                                        <strong>Unidades por Paquete:</strong>
                                        <p class="mb-0"><%= producto.getUnidadesPorPaquete() %></p>
                                    </div>
                                </div>
                                
                                <% if (producto.getDescripcion() != null && !producto.getDescripcion().isEmpty()) { %>
                                <hr>
                                <div class="mb-3">
                                    <strong>Descripción:</strong>
                                    <p class="mb-0"><%= producto.getDescripcion() %></p>
                                </div>
                                <% } %>
                                
                                <div class="alert alert-info mt-3">
                                    <i class="fas fa-info-circle me-2"></i>
                                    <strong>Nota:</strong> Esta es una vista de solo lectura. Para modificar productos, contacte al administrador.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

