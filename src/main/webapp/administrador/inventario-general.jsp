<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Inventario General"/>
    </jsp:include>
    <style>
        .card + .card { margin-top: 1.25rem; }
        .table thead th { vertical-align: middle; }
    </style>
    </head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Inventario'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid px-4">
                <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="pageheader-title"><i class="fas fa-boxes-stacked me-2"></i>Inventario General</h2>
                        <p class="pageheader-text">Vista de solo lectura consolidada de Logística, Almacén y Productores.</p>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/administrador/InventarioGeneralReporteServlet?action=exportar" class="btn btn-success">
                            <i class="fas fa-file-excel me-2"></i>Exportar a Excel
                        </a>
                        <a href="${pageContext.request.contextPath}/administrador/InventarioGeneralReporteServlet?action=formEnviar" class="btn btn-info text-white">
                            <i class="fas fa-envelope me-2"></i>Enviar por Correo
                        </a>
                    </div>
                </div>

                <!-- Mensajes de alerta -->
                <c:if test="${not empty sessionScope.mensaje}">
                    <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert">
                        ${sessionScope.mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="mensaje" scope="session"/>
                    <c:remove var="tipoMensaje" scope="session"/>
                </c:if>

                <!-- Logística -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0"><i class="fas fa-truck me-2"></i>Logística</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                <tr>
                                    <th>SKU</th>
                                    <th>Producto</th>
                                    <th>Paquetes</th>
                                    <th>Precio por Paquete</th>
                                    <th>Costo por Unidad</th>
                                    <th>Estado</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${empty listaLogistica}">
                                        <tr><td colspan="6" class="text-center py-4">Sin datos</td></tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="it" items="${listaLogistica}">
                                            <tr>
                                                <td><span class="badge bg-secondary">${it.codigoSKU}</span></td>
                                                <td>${it.nombreProducto}</td>
                                                <td>${it.paquetesDisponibles}</td>
                                                <td>S/. <fmt:formatNumber value="${it.precioPorPaquete}" minFractionDigits="2"/></td>
                                                <td>S/. <fmt:formatNumber value="${it.costoPorUnidad}" minFractionDigits="2"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${it.estadoStock == 'En Stock'}"><span class="badge bg-success">En stock</span></c:when>
                                                        <c:when test="${it.estadoStock == 'Poco Stock'}"><span class="badge bg-warning text-dark">Poco</span></c:when>
                                                        <c:otherwise><span class="badge bg-secondary">Sin stock</span></c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Almacén -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0"><i class="fas fa-warehouse me-2"></i>Almacén</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                <tr>
                                    <th>Código Lote</th>
                                    <th>Producto</th>
                                    <th>Ubicación</th>
                                    <th>Stock</th>
                                    <th>Vencimiento</th>
                                    <th>Estado</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${empty listaAlmacen}">
                                        <tr><td colspan="6" class="text-center py-4">Sin datos</td></tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="l" items="${listaAlmacen}">
                                            <tr>
                                                <td><span class="badge bg-secondary">${l.codigoLote}</span></td>
                                                <td>${l.nombreProducto}</td>
                                                <td>${l.nombreUbicacion}</td>
                                                <td>${l.stockActual}</td>
                                                <td><fmt:formatDate value="${l.fechaVencimiento}" pattern="dd/MM/yyyy"/></td>
                                                <td>${l.estado}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Productores -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0"><i class="fas fa-seedling me-2"></i>Productores</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead class="table-light">
                                <tr>
                                    <th>SKU</th>
                                    <th>Producto</th>
                                    <th>Categoría</th>
                                    <th>Stock Total</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${empty listaProductores}">
                                        <tr><td colspan="4" class="text-center py-4">Sin datos</td></tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="p" items="${listaProductores}">
                                            <tr>
                                                <td><span class="badge bg-secondary">${p.codigoSku}</span></td>
                                                <td>${p.nombre}</td>
                                                <td>${p.categoriaNombre}</td>
                                                <td>${p.stock}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
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
