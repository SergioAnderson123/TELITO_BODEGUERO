<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Pedidos Pendientes"/>
    </jsp:include>
</head>

<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Registrar salidas"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2><i class="fas fa-truck me-2"></i>Pedidos Pendientes de Despacho</h2>
                            <p class="text-muted">Gestiona los pedidos pendientes de preparación y despacho.</p>
                        </div>
                    </div>
                </div>

                <div class="mx-auto d-none d-md-block mb-4">
                    <div class="top-search-bar">
                        <i class="fas fa-search search-icon"></i>
                        <input class="form-control" type="search" placeholder="Buscar por número de pedido o destino..." aria-label="Search" id="searchInput">
                    </div>
                </div>
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Tabla de Pedidos</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">Numero de Pedido</th>
                                            <th scope="col">Destino</th>
                                            <th scope="col">Estado de preparación</th>
                                            <th scope="col">Preparar pedido</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="pedido" items="${listaPedidos}">
                                            <tr>
                                                <td>${pedido.numeroPedido}</td>
                                                <td>${pedido.destino}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                            <span class="badge bg-danger">Pendiente</span>
                                                        </c:when>
                                                        <c:when test="${pedido.estadoPreparacion == 'En preparación'}">
                                                            <span class="badge bg-warning text-dark">En preparación</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-success">Despachado</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:if test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                    <a href="PedidoServlet?action=preparar&id=${pedido.idPedido}" class="btn btn-primary btn-sm">Preparar</a>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>

                                    <nav class="mt-4" aria-label="Page navigation">
                                        <ul class="pagination justify-content-center">
                                            <li class="page-item <c:if test='${paginaActual == 1}'>disabled</c:if>">
                                                <a class="page-link" href="PedidoServlet?page=${paginaActual - 1}">Anterior</a>
                                            </li>

                                            <li class="page-item active" aria-current="page">
                                                <span class="page-link">Página ${paginaActual} de ${totalPaginas}</span>
                                            </li>

                                            <li class="page-item <c:if test='${paginaActual == totalPaginas}'>disabled</c:if>">
                                                <a class="page-link" href="PedidoServlet?page=${paginaActual + 1}">Siguiente</a>
                                            </li>
                                        </ul>
                                    </nav>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    // Tu script de búsqueda no necesita cambios.
    // Nota: Ahora solo filtrará los resultados de la página actual.
    document.addEventListener('DOMContentLoaded', function () {
        const searchInput = document.getElementById('searchInput');
        const table = document.querySelector('.table');
        const tableRows = table.querySelectorAll('tbody tr');

        searchInput.addEventListener('keyup', function (event) {
            const searchTerm = event.target.value.toLowerCase();
            tableRows.forEach(row => {
                const numeroPedidoText = row.cells[0].textContent.toLowerCase();
                const destinoText = row.cells[1].textContent.toLowerCase();
                if (numeroPedidoText.includes(searchTerm) || destinoText.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    });
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>