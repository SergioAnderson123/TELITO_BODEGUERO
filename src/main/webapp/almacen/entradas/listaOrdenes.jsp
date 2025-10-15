<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Órdenes de Compra Pendientes"/>
    </jsp:include>
</head>

<body>
<div class="dashboard-main-wrapper">

    <%-- ===== INICIO DE LA CORRECCIÓN ===== --%>
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <%-- ===== FIN DE LA CORRECCIÓN ===== --%>

    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Registrar entradas"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2><i class="fas fa-clipboard-list me-2"></i>Órdenes de Compra Pendientes</h2>
                            <p class="text-muted">Gestiona las órdenes de compra pendientes de recepción en el almacén.</p>
                        </div>
                    </div>
                </div>

                <div class="mx-auto d-none d-md-block mb-4">
                    <div class="top-search-bar">
                        <i class="fas fa-search search-icon"></i>
                        <input class="form-control" type="search" placeholder="Buscar por producto o proveedor..." aria-label="Search" id="searchInput">
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h5>Tabla de Órdenes de Compra</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="bg-light">
                                <tr>
                                    <th scope="col">Número de Orden</th>
                                    <th scope="col">Producto</th>
                                    <th scope="col">Proveedor</th>
                                    <th scope="col">Cantidad Esperada</th>
                                    <th scope="col">Estado</th>
                                    <th scope="col">Acción</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="orden" items="${listaOrdenes}">
                                    <tr>
                                        <td><c:out value="${orden.numeroOrden}"/></td>
                                        <td><c:out value="${orden.nombreProducto}"/></td>
                                        <td><c:out value="${orden.nombreProveedor}"/></td>
                                        <td><c:out value="${orden.cantidad}"/></td>
                                        <td>
                                            <span class="badge bg-info text-dark"><c:out value="${orden.estado}"/></span>
                                        </td>
                                        <td>
                                            <a class="btn btn-primary btn-sm"
                                               href="${pageContext.request.contextPath}/almacen/EntradaServlet?action=recibir&id=${orden.idOrdenCompra}">
                                                Registrar Entrada
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>

                            <nav class="mt-4" aria-label="Page navigation">
                                <ul class="pagination justify-content-center">
                                    <li class="page-item <c:if test='${paginaActual == 1}'>disabled</c:if>">
                                        <a class="page-link" href="EntradaServlet?page=${paginaActual - 1}">Anterior</a>
                                    </li>
                                    <li class="page-item active" aria-current="page">
                                        <span class="page-link">Página ${paginaActual} de ${totalPaginas}</span>
                                    </li>
                                    <li class="page-item <c:if test='${paginaActual == totalPaginas}'>disabled</c:if>">
                                        <a class="page-link" href="EntradaServlet?page=${paginaActual + 1}">Siguiente</a>
                                    </li>
                                </ul>
                            </nav>

                        </div>
                    </div>
                </div>

            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const searchInput = document.getElementById('searchInput');
        const tableRows = document.querySelectorAll('.table tbody tr');
        searchInput.addEventListener('keyup', function (event) {
            const searchTerm = event.target.value.toLowerCase();
            tableRows.forEach(row => {
                const rowText = row.textContent.toLowerCase();
                row.style.display = rowText.includes(searchTerm) ? '' : 'none';
            });
        });
    });
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>