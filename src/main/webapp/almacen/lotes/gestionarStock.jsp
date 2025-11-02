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
                                                <td><span class="badge bg-secondary">${lote.codigoSKU}</span></td>
                                                <td>${lote.nombreProducto}</td>
                                                <td><strong>${lote.codigoLote}</strong></td>
                                                <td>
                                                    <button type="button" 
                                                            class="btn btn-link p-0 text-decoration-none text-primary fw-bold" 
                                                            onclick="mostrarResumenLotes(${lote.productoId}, '${lote.nombreProducto}')"
                                                            style="cursor: pointer;">
                                                        ${lote.paquetesDisponibles} paquetes
                                                    </button>
                                                </td>
                                                <td>${lote.nombreUbicacion}</td>
                                                <td>${lote.fechaVencimiento}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${lote.estadoStock == 'Sin Stock'}">
                                                            <span class="badge bg-danger">Sin Stock</span>
                                                        </c:when>
                                                        <c:when test="${lote.estadoStock == 'Poco Stock'}">
                                                            <span class="badge bg-warning text-dark">Poco Stock</span>
                                                        </c:when>
                                                        <c:when test="${lote.estadoStock == 'En Stock'}">
                                                            <span class="badge bg-success">En Stock</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">No configurado</span>
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

<!-- Modal para mostrar resumen de lotes -->
<div class="modal fade" id="resumenLotesModal" tabindex="-1" aria-labelledby="resumenLotesModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="resumenLotesModalLabel">
                    <i class="fas fa-boxes me-2"></i>Resumen de Lotes
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <h6 class="mb-3" id="modalProductoNombre"></h6>
                <div id="loadingResumen" class="text-center py-3">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                </div>
                <div id="contenidoResumen" style="display: none;">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm">
                            <thead class="table-light">
                                <tr>
                                    <th>Código Lote</th>
                                    <th>Stock (Unidades)</th>
                                    <th>Paquetes</th>
                                    <th>Fecha Vencimiento</th>
                                </tr>
                            </thead>
                            <tbody id="tablaResumenLotes">
                            </tbody>
                        </table>
                    </div>
                    <div id="sinLotes" class="alert alert-info" style="display: none;">
                        No hay lotes disponibles para este producto.
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function mostrarResumenLotes(productoId, nombreProducto) {
        // Actualizar título del modal
        document.getElementById('modalProductoNombre').textContent = 'Producto: ' + nombreProducto;
        
        // Mostrar loading y ocultar contenido
        document.getElementById('loadingResumen').style.display = 'block';
        document.getElementById('contenidoResumen').style.display = 'none';
        
        // Limpiar tabla
        document.getElementById('tablaResumenLotes').innerHTML = '';
        
        // Abrir modal
        const modal = new bootstrap.Modal(document.getElementById('resumenLotesModal'));
        modal.show();
        
        // Cargar datos via AJAX
        fetch('${pageContext.request.contextPath}/almacen/LoteServlet?action=obtenerResumenLotes&productoId=' + productoId)
            .then(response => response.json())
            .then(data => {
                document.getElementById('loadingResumen').style.display = 'none';
                
                if (data.success && data.lotes && data.lotes.length > 0) {
                    document.getElementById('contenidoResumen').style.display = 'block';
                    document.getElementById('sinLotes').style.display = 'none';
                    
                    const tbody = document.getElementById('tablaResumenLotes');
                    tbody.innerHTML = '';
                    
                    data.lotes.forEach(lote => {
                        const row = document.createElement('tr');
                        const fechaVencimiento = lote.fechaVencimiento || 'Sin fecha';
                        
                        row.innerHTML = 
                            '<td><strong>' + lote.codigoLote + '</strong></td>' +
                            '<td>' + lote.stockActual + ' unidades</td>' +
                            '<td><span class="badge bg-primary">' + lote.paquetes + ' paquetes</span></td>' +
                            '<td>' + fechaVencimiento + '</td>';
                        tbody.appendChild(row);
                    });
                } else {
                    document.getElementById('contenidoResumen').style.display = 'block';
                    document.getElementById('sinLotes').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error al cargar resumen de lotes:', error);
                document.getElementById('loadingResumen').style.display = 'none';
                document.getElementById('contenidoResumen').style.display = 'block';
                document.getElementById('sinLotes').innerHTML = 
                    '<div class="alert alert-danger">Error al cargar el resumen de lotes. Por favor, intenta de nuevo.</div>';
            });
    }
</script>

</body>
</html>