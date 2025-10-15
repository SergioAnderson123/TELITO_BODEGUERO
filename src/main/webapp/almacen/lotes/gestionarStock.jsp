<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<!doctype html>
<html lang="en">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Inventario"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value='Gestion de inventario'/>
        <jsp:param name="activePage" value='Gestion de inventario'/>
    </jsp:include>
    <jsp:include page="/almacen/layouts/header_almacen.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <!-- ENCABEZADO -->
                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2><i class="fas fa-box me-2"></i>Gestión de Inventario</h2>
                            <p class="text-muted">Administra el stock de productos y ajusta inventarios según sea necesario.</p>
                        </div>
                    </div>
                </div>

                <!-- BUSCADOR -->
                <div class="mx-auto d-none d-md-block">
                    <div class="top-search-bar">
                        <i class="fas fa-search search-icon"></i>
                        <input class="form-control" type="search" placeholder="Nombre del producto, codigo..." aria-label="Search" id ="searchInput">
                    </div>
                </div>

                <!-- Complex Table Example -->
                <div class="row mt-4">
                    <div class="col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Tabla de Productos</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">SKU</th>
                                            <th scope="col">Nombre</th>
                                            <th scope="col">Lote</th>
                                            <th scope="col">Cantidad disponible</th>
                                            <th scope="col">Ubicación</th>
                                            <th scope="col">Fecha de Vencimiento</th>
                                            <th scope="col">Estado</th>
                                            <th scope="col">Ajustar stock</th>
                                        </tr>
                                        </thead>
                                        <tbody id="productTableBody">
                                        <c:forEach var="lote" items="${listaLotes}">
                                            <tr>
                                                    <%-- CORREGIDO: Ahora muestra el SKU del producto --%>
                                                <td>${lote.codigoLote}</td>
                                                <td>${lote.nombreProducto}</td>
                                                <td>${lote.codigoLote}</td>
                                                <td>${lote.stockActual}</td>
                                                <td>${lote.nombreUbicacion}</td>
                                                <td>${lote.fechaVencimiento}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${lote.stockActual == 0}">
                                                            <span class="badge bg-danger">Sin Stock</span>
                                                        </c:when>
                                                        <c:when test="${lote.stockActual > 0 && lote.stockActual <= 20}">
                                                            <span class="badge bg-warning text-dark">Poco Stock</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-success">En Stock</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <a type="button" class="btn btn-sm btn-info"
                                                       href="LoteServlet?action=ajustar&id=${lote.idLote}">Ajustar</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                    <%-- Paginación --%>
                                    <nav class="mt-4">
                                        <ul class="pagination justify-content-center">

                                            <%-- Botón "Anterior" --%>
                                            <li class="page-item ${paginaActual == 1 ? 'disabled' : ''}">
                                                <a class="page-link" href="LoteServlet?page=${paginaActual - 1}">Anterior</a>
                                            </li>

                                            <%-- Indicador de página --%>
                                            <li class="page-item active" aria-current="page">
                                                <span class="page-link">Página ${paginaActual} de ${totalPaginas}</span>
                                            </li>

                                            <%-- Botón "Siguiente" --%>
                                            <li class="page-item ${paginaActual == totalPaginas ? 'disabled' : ''}">
                                                <a class="page-link" href="LoteServlet?page=${paginaActual + 1}">Siguiente</a>
                                            </li>

                                        </ul>
                                    </nav>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/almacen/layouts/footer.jsp" />
    </div>
</div>


<script>
    // Se asegura que el script se ejecute cuando la página haya cargado por completo
    document.addEventListener('DOMContentLoaded', function() {

        // 1. Se guarda una referencia a la barra de búsqueda y al cuerpo de la tabla
        const searchInput = document.getElementById('searchInput');
        const tableBody = document.getElementById('productTableBody');
        const tableRows = tableBody.getElementsByTagName('tr'); // Obtenemos todas las filas

        // 2. Se "escucha" cada vez que el usuario teclea algo en la barra de búsqueda
        searchInput.addEventListener('keyup', function() {

            // 3. Se convierte lo que el usuario escribe a minúsculas para una búsqueda sin distinción
            const searchTerm = searchInput.value.toLowerCase();

            // 4. Se recorre cada una de las filas de la tabla
            for (let i = 0; i < tableRows.length; i++) {
                const row = tableRows[i];

                // 5. Se obtiene todo el texto de la fila actual y lo convertimos a minúsculas
                const rowText = row.textContent.toLowerCase();

                // 6. Se compara si el texto de la fila contiene el término de búsqueda
                if (rowText.includes(searchTerm)) {
                    // Si coincide, se asegura de que la fila sea visible
                    row.style.display = '';
                } else {
                    // Si no coincide, se ocutla la fila
                    row.style.display = 'none';
                }
            }
        });
    });
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>