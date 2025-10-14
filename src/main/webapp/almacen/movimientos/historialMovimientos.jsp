<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Historial de Movimientos"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Historial"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2 class="pageheader-title fs-1">Historial de Movimientos de Inventario</h2>
                        </div>
                    </div>
                </div>

                <div class="row mb-4">
                    <div class="col-lg-8">
                        <div class="top-search-bar">
                            <i class="fas fa-search search-icon"></i>
                            <input class="form-control" type="search" placeholder="Buscar en los resultados actuales..." aria-label="Search" id="searchInput">
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <select class="form-select" id="viewFilter">
                            <option value="todos" ${param.filtro != 'mios' ? 'selected' : ''}>
                                Todos los Movimientos
                            </option>
                            <option value="mios" ${param.filtro == 'mios' ? 'selected' : ''}>
                                Mis Movimientos
                            </option>
                        </select>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-header">Registro de todos los movimientos</h5>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="bg-light">
                                <tr>
                                    <th scope="col">Fecha y Hora</th>
                                    <th scope="col">Producto</th>
                                    <th scope="col">Lote</th>
                                    <th scope="col">Tipo</th>
                                    <th scope="col">Cantidad</th>
                                    <th scope="col">Responsable</th>
                                    <th scope="col">Motivo / Referencia</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="mov" items="${listaMovimientos}">
                                    <tr>
                                        <td><fmt:formatDate value="${mov.fecha}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                        <td><c:out value="${mov.nombreProducto}"/></td>
                                        <td><c:out value="${mov.codigoLote}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${mov.tipoMovimiento == 'Entrada'}"><span class="badge bg-success">Entrada</span></c:when>
                                                <c:when test="${mov.tipoMovimiento == 'Salida'}"><span class="badge bg-danger">Salida</span></c:when>
                                                <c:otherwise><span class="badge bg-secondary"><c:out value="${mov.tipoMovimiento}"/></span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td><c:out value="${mov.cantidad}"/></td>
                                        <td><c:out value="${mov.nombreUsuario}"/></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty mov.numeroPedido}">Pedido: <c:out value="${mov.numeroPedido}"/></c:when>
                                                <c:when test="${not empty mov.numeroOrdenCompra}">OC: <c:out value="${mov.numeroOrdenCompra}"/></c:when>
                                                <c:otherwise><c:out value="${mov.motivo}"/></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>

                            <nav class="mt-4" aria-label="Page navigation">
                                <ul class="pagination justify-content-center">
                                    <li class="page-item <c:if test='${paginaActual == 1}'>disabled</c:if>">
                                        <a class="page-link" href="MovimientoServlet?page=${paginaActual - 1}&filtro=${param.filtro}">Anterior</a>
                                    </li>

                                    <li class="page-item active" aria-current="page">
                                        <span class="page-link">Página ${paginaActual} de ${totalPaginas}</span>
                                    </li>

                                    <li class="page-item <c:if test='${paginaActual == totalPaginas}'>disabled</c:if>">
                                        <a class="page-link" href="MovimientoServlet?page=${paginaActual + 1}&filtro=${param.filtro}">Siguiente</a>
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
        // --- LÓGICA PARA LA BÚSQUEDA (sin cambios) ---
        const searchInput = document.getElementById('searchInput');
        const tableRows = document.querySelectorAll('.table tbody tr');

        searchInput.addEventListener('keyup', function (event) {
            const searchTerm = event.target.value.toLowerCase();
            tableRows.forEach(row => {
                const rowText = row.textContent.toLowerCase();
                row.style.display = rowText.includes(searchTerm) ? '' : 'none';
            });
        });

        // --- NUEVO: LÓGICA PARA EL FILTRO DE VISTA ---
        const viewFilter = document.getElementById('viewFilter');
        viewFilter.addEventListener('change', function() {
            const selectedFilter = this.value;
            // Recargamos la página, pasando el nuevo filtro como parámetro
            window.location.href = 'MovimientoServlet?filtro=' + selectedFilter;
        });
    });
</script>
</body>
</html>