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

                <!-- Mensajes de alerta -->
                <c:if test="${not empty sessionScope.mensaje}">
                    <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                        ${sessionScope.mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                    </div>
                    <c:remove var="mensaje" scope="session"/>
                    <c:remove var="tipoMensaje" scope="session"/>
                </c:if>

                <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                    <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-warehouse me-2"></i>Gestión de Inventario</h2>
                    <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra el stock de productos y ajusta inventarios según sea necesario.</p>
                </div>

                <div class="row">
                    <div class="col-12">
                        <div class="table-card shadow-sm">
                            <div class="card-header" style="padding: 0.5rem 0.75rem;">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-box me-2"></i>Tabla de Productos</h5>
                                        <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los lotes del inventario</small>
                                    </div>
                                    <div class="d-flex gap-2 flex-wrap">
                                        <a href="<%= request.getContextPath() %>/almacen/LoteReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                                        </a>
                                        <a href="<%= request.getContextPath() %>/almacen/LoteReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body" style="padding: 0.75rem;">
                                <form action="<%= request.getContextPath() %>/almacen/LoteServlet" method="GET">
                                    <input type="hidden" name="action" value="lista">
                                    <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 10 %>">
                                    <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                        <div class="col-xl-6 col-lg-6 col-md-12 col-sm-12">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                            <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="SKU, producto o lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        </div>
                                        <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado de Stock</label>
                                            <select class="form-select form-select-sm shadow-sm" name="estado" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <option value="" ${param.estado == '' || param.estado == null ? 'selected' : ''}>Todos</option>
                                                <option value="En stock" ${param.estado == 'En stock' ? 'selected' : ''}>En stock</option>
                                                <option value="Poco stock" ${param.estado == 'Poco stock' ? 'selected' : ''}>Poco stock</option>
                                                <option value="Sin stock" ${param.estado == 'Sin stock' ? 'selected' : ''}>Sin stock</option>
                                            </select>
                                        </div>
                                        <div class="col-xl-2 col-lg-2 col-md-3 col-sm-3 d-flex align-items-end">
                                            <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-search me-1"></i>Buscar
                                            </button>
                                        </div>
                                        <div class="col-xl-2 col-lg-2 col-md-3 col-sm-3 d-flex align-items-end">
                                            <a href="<%= request.getContextPath() %>/almacen/LoteServlet?action=lista" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                                            </a>
                                        </div>
                                    </div>
                                </form>

                                <div class="table-responsive">
                                    <table id="inventoryTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                        <thead class="table-light">
                                        <tr>
                                            <th onclick="sortTable(0)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-barcode me-1"></i>SKU
                                            </th>
                                            <th onclick="sortTable(1)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-box me-1"></i>Nombre Producto
                                            </th>
                                            <th onclick="sortTable(2)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-tag me-1"></i>Lote
                                            </th>
                                            <th onclick="sortTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-cubes me-1"></i>Cantidad Disponible
                                            </th>
                                            <th onclick="sortTable(4)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-map-marker-alt me-1"></i>Ubicación
                                            </th>
                                            <th onclick="sortTable(5)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-calendar-alt me-1"></i>Fecha Vencimiento
                                            </th>
                                            <th onclick="sortTable(6)" style="width: 13%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-toggle-on me-1"></i>Estado
                                            </th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center">
                                                <i class="fas fa-cog me-1"></i>Acciones
                                            </th>
                                        </tr>
                                        </thead>
                                        <tbody id="productTableBody">
                                        <c:choose>
                                            <c:when test="${not empty listaLotes}">
                                        <c:forEach var="lote" items="${listaLotes}">
                                                    <tr class="align-middle" style="padding: 0;">
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.codigoSKU}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.nombreProducto}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>${lote.codigoLote}</strong></td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <button type="button" 
                                                            class="btn btn-link text-decoration-none fw-bold" 
                                                            onclick="mostrarResumenLotes(${lote.productoId}, '${lote.nombreProducto}')"
                                                                    style="cursor: pointer; color: #ffffff !important; font-size: 0.85rem; padding: 0.4rem 0.8rem !important; background-color: #28a745; border-radius: 6px; border: none;">
                                                        ${lote.paquetesDisponibles} paquetes
                                                    </button>
                                                </td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.nombreUbicacion}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.fechaVencimiento}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <c:choose>
                                                        <c:when test="${lote.estadoStock == 'Sin Stock'}">
                                                                    <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-times-circle me-1"></i>Sin Stock
                                                                    </span>
                                                        </c:when>
                                                        <c:when test="${lote.estadoStock == 'Poco Stock'}">
                                                                    <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-exclamation-triangle me-1"></i>Poco Stock
                                                                    </span>
                                                        </c:when>
                                                        <c:when test="${lote.estadoStock == 'En Stock'}">
                                                                    <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.4rem 0.9rem;">
                                                                        <i class="fas fa-check-circle me-1"></i>En Stock
                                                                    </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                                    <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-question-circle me-1"></i>No configurado
                                                                    </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;" class="text-center">
                                                    <div class="btn-group" role="group">
                                                                <a type="button" class="btn btn-sm btn-info shadow-sm"
                                                           href="LoteServlet?action=ajustar&id=${lote.idLote}" 
                                                                   title="Ajustar inventario" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                            <i class="fas fa-edit"></i> Ajustar
                                                        </a>
                                                                <a type="button" class="btn btn-sm btn-warning shadow-sm"
                                                           href="IncidenciaServlet?action=formReportar&idLote=${lote.idLote}" 
                                                                   title="Reportar incidencia" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                            <i class="fas fa-exclamation-triangle"></i> Incidencia
                                                        </a>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center py-5">
                                                        <div class="text-muted">
                                                            <i class="fas fa-box-open fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                            <p class="mb-0">No se encontraron lotes con los filtros aplicados.</p>
                                                            <small>Intenta ajustar los filtros de búsqueda</small>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                        </tbody>
                                    </table>
                                    
                                    <%-- Incluir componente de paginación --%>
                                    <jsp:include page="/WEB-INF/includes/pagination.jsp" />
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
    // Búsqueda en tiempo real (opcional, funciona junto con el formulario)
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
        const tableBody = document.getElementById('productTableBody');
            if (tableBody) {
                const tableRows = tableBody.getElementsByTagName('tr');

        searchInput.addEventListener('keyup', function() {
            const searchTerm = searchInput.value.toLowerCase();
            for (let i = 0; i < tableRows.length; i++) {
                const row = tableRows[i];
                        // Ignorar la fila de "no hay datos"
                        if (row.cells.length === 1) continue;
                const rowText = row.textContent.toLowerCase();
                if (rowText.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            }
        });
            }
        }
    });

    // Función para ordenar la tabla
    let sortDirection = {}; // Almacena la dirección de ordenamiento para cada columna
    
    function sortTable(columnIndex) {
        const table = document.getElementById('inventoryTable');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Determinar dirección de ordenamiento
        if (!sortDirection[columnIndex]) {
            sortDirection[columnIndex] = 'asc';
        } else {
            sortDirection[columnIndex] = sortDirection[columnIndex] === 'asc' ? 'desc' : 'asc';
        }
        
        // Ordenar las filas
        rows.sort((a, b) => {
            const aText = a.cells[columnIndex].textContent.trim();
            const bText = b.cells[columnIndex].textContent.trim();
            
            // Intentar comparar como números si es posible
            const aNum = parseFloat(aText.replace(/[^\d.-]/g, ''));
            const bNum = parseFloat(bText.replace(/[^\d.-]/g, ''));
            
            let comparison = 0;
            if (!isNaN(aNum) && !isNaN(bNum)) {
                comparison = aNum - bNum;
            } else {
                // Comparar como texto
                comparison = aText.localeCompare(bText, 'es', { numeric: true, sensitivity: 'base' });
            }
            
            return sortDirection[columnIndex] === 'asc' ? comparison : -comparison;
        });
        
        // Reordenar las filas en el DOM
        rows.forEach(row => tbody.appendChild(row));
        
        // Actualizar indicadores visuales en los encabezados
        const headers = table.querySelectorAll('thead th');
        headers.forEach((header, index) => {
            header.classList.remove('sort-asc', 'sort-desc');
            if (index === columnIndex) {
                header.classList.add(sortDirection[columnIndex] === 'asc' ? 'sort-asc' : 'sort-desc');
            }
        });
    }
</script>

<style>
    #inventoryTable thead th {
        position: relative;
        user-select: none;
        transition: background-color 0.2s ease;
    }
    #inventoryTable thead th:hover {
        background-color: #83c5be !important;
    }
    #inventoryTable thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    #inventoryTable thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

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