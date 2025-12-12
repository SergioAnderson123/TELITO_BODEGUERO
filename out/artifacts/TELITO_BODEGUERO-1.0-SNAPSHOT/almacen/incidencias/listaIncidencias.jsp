<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.almacen.beans.Incidencia" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%
    ArrayList<Incidencia> incidencias = (ArrayList<Incidencia>) request.getAttribute("incidencias");
    if (incidencias == null) incidencias = new ArrayList<>();
    
    int totalRegistros = request.getAttribute("totalRegistros") != null ? (Integer) request.getAttribute("totalRegistros") : 0;
    int currentPage = request.getAttribute("page") != null ? (Integer) request.getAttribute("page") : 1;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
    boolean esAdministrador = request.getAttribute("esAdministrador") != null ? (Boolean) request.getAttribute("esAdministrador") : false;
    
    String estado = (String) request.getAttribute("estado");
    String tipo = (String) request.getAttribute("tipo");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Incidencias de Inventario"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Incidencias"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="page-header">
                            <h2 class="pageheader-title"><i class="fas fa-exclamation-triangle me-2"></i>Incidencias de Inventario</h2>
                            <p class="pageheader-text">Reporta y gestiona faltantes y sobrantes de inventario.</p>
                        </div>
                    </div>
                </div>

                <% if (successMsg != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>
                
                <% if (errorMsg != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <div class="table-card shadow-sm">
                    <div class="card-header" style="padding: 0.5rem 0.75rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-exclamation-triangle me-2"></i>Tabla de Incidencias</h5>
                                <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todas las incidencias de inventario</small>
                            </div>
                            <% if (!esAdministrador) { %>
                            <a href="<%= request.getContextPath() %>/almacen/LoteServlet" class="btn btn-sm btn-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-plus me-1"></i>Reportar desde Inventario
                            </a>
                            <% } %>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <form action="<%= request.getContextPath() %>/almacen/IncidenciaServlet" method="GET">
                            <input type="hidden" name="action" value="listar">
                            <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 10 %>">
                            <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                <div class="col-xl-4 col-lg-4 col-md-12 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Producto o lote..." value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                                    <select class="form-select form-select-sm shadow-sm" name="estado" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <option value="" <%= estado == null || estado.isEmpty() ? "selected" : "" %>>Todos</option>
                                        <option value="Pendiente" <%= "Pendiente".equals(estado) ? "selected" : "" %>>Pendiente</option>
                                        <option value="En Revisión" <%= "En Revisión".equals(estado) ? "selected" : "" %>>En Revisión</option>
                                        <option value="Resuelta" <%= "Resuelta".equals(estado) ? "selected" : "" %>>Resuelta</option>
                                        <option value="Cerrada" <%= "Cerrada".equals(estado) ? "selected" : "" %>>Cerrada</option>
                                    </select>
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-filter me-1"></i>Tipo</label>
                                    <select class="form-select form-select-sm shadow-sm" name="tipo" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <option value="" <%= tipo == null || tipo.isEmpty() ? "selected" : "" %>>Todos</option>
                                        <option value="Faltante" <%= "Faltante".equals(tipo) ? "selected" : "" %>>Faltante</option>
                                        <option value="Sobrante" <%= "Sobrante".equals(tipo) ? "selected" : "" %>>Sobrante</option>
                                    </select>
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-3 col-sm-3 d-flex align-items-end">
                                    <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search me-1"></i>Buscar
                                    </button>
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6 d-flex align-items-end">
                                    <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=listar" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-sync-alt me-1"></i>Limpiar
                                    </a>
                                </div>
                            </div>
                        </form>
                        <div style="width: 100%; position: relative;">
                            <table id="incidenciasTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                <thead class="table-light">
                                    <tr>
                                        <th onclick="sortTable(0)" style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-hashtag me-1"></i>ID
                                        </th>
                                        <th onclick="sortTable(1)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-filter me-1"></i>Tipo
                                        </th>
                                        <th onclick="sortTable(2)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Producto
                                        </th>
                                        <th onclick="sortTable(3)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-hashtag me-1"></i>Código Lote
                                        </th>
                                        <th onclick="sortTable(4)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-cubes me-1"></i>Cant. Sistema
                                        </th>
                                        <th onclick="sortTable(5)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-cubes me-1"></i>Cant. Reportada
                                        </th>
                                        <th onclick="sortTable(6)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-calculator me-1"></i>Diferencia
                                        </th>
                                        <th onclick="sortTable(7)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-toggle-on me-1"></i>Estado
                                        </th>
                                        <th onclick="sortTable(8)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-user me-1"></i>Reportado por
                                        </th>
                                        <th onclick="sortTable(9)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-calendar-alt me-1"></i>Fecha
                                        </th>
                                        <th style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center">
                                            <i class="fas fa-cogs me-1"></i>Acciones
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty incidencias}">
                                            <c:forEach var="inc" items="${incidencias}">
                                                <tr class="align-middle" style="padding: 0;">
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>${inc.idIncidencia}</strong></td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                        <c:choose>
                                                            <c:when test="${inc.tipoIncidencia == 'Faltante'}">
                                                                <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                    <i class="fas fa-minus-circle me-1"></i>Faltante
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                    <i class="fas fa-plus-circle me-1"></i>Sobrante
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${inc.nombreProducto}</td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><code style="font-size: 0.8rem;">${inc.codigoLote}</code></td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${inc.cantidadSistema}</td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${inc.cantidadReportada}</td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                        <c:choose>
                                                            <c:when test="${inc.diferencia < 0}">
                                                                <span class="fw-bold text-danger">
                                                                    ${inc.diferencia}
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="fw-bold text-success">
                                                                    +${inc.diferencia}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                        <c:choose>
                                                            <c:when test="${inc.estado == 'Pendiente'}">
                                                                <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                    <i class="fas fa-clock me-1"></i>Pendiente
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${inc.estado == 'En Revisión'}">
                                                                <span class="badge text-bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                    <i class="fas fa-eye me-1"></i>En Revisión
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${inc.estado == 'Resuelta'}">
                                                                <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                    <i class="fas fa-check-circle me-1"></i>Resuelta
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${inc.estado == 'Cerrada'}">
                                                                <span class="badge text-bg-dark shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                    <i class="fas fa-lock me-1"></i>Cerrada
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                    ${inc.estado}
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${inc.nombreUsuarioReporte}</td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                        <c:choose>
                                                            <c:when test="${inc.fechaReporte != null}">
                                                                <fmt:formatDate value="${inc.fechaReporte}" pattern="dd/MM/yyyy HH:mm"/>
                                                            </c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;" class="text-center">
                                                        <div class="btn-group" role="group">
                                                            <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=ver&id=${inc.idIncidencia}" 
                                                               class="btn btn-sm btn-info text-white shadow-sm" title="Ver detalles" style="font-size: 0.75rem; padding: 0.25rem 0.5rem;">
                                                                <i class="fas fa-eye"></i>
                                                            </a>
                                                            <c:if test="${esAdministrador && inc.estado == 'Pendiente'}">
                                                                <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=formResolver&id=${inc.idIncidencia}" 
                                                                   class="btn btn-sm btn-success shadow-sm" title="Resolver" style="font-size: 0.75rem; padding: 0.25rem 0.5rem;">
                                                                    <i class="fas fa-check"></i>
                                                                </a>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="11" class="text-center py-5">
                                                    <div class="text-muted">
                                                        <i class="fas fa-inbox fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                        <p class="mb-0">No se encontraron incidencias con los filtros aplicados.</p>
                                                        <small>Intenta ajustar los filtros de búsqueda</small>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                            <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    // Búsqueda en tiempo real (opcional, funciona junto con el formulario)
    document.addEventListener('DOMContentLoaded', function () {
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            const tableBody = document.querySelector('#incidenciasTable tbody');
            if (tableBody) {
                const tableRows = tableBody.getElementsByTagName('tr');
                searchInput.addEventListener('keyup', function (event) {
                    const searchTerm = event.target.value.toLowerCase();
                    for (let i = 0; i < tableRows.length; i++) {
                        const row = tableRows[i];
                        // Ignorar la fila de "no hay datos"
                        if (row.cells.length === 1) continue;
                        const rowText = row.textContent.toLowerCase();
                        row.style.display = rowText.includes(searchTerm) ? '' : 'none';
                    }
                });
            }
        }
    });

    // Función para ordenar la tabla
    let sortDirection = {};
    
    function sortTable(columnIndex) {
        const table = document.getElementById('incidenciasTable');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Ignorar fila de "no hay datos"
        const dataRows = rows.filter(row => row.cells.length > 1);
        if (dataRows.length === 0) return;
        
        // Determinar dirección de ordenamiento
        if (!sortDirection[columnIndex]) {
            sortDirection[columnIndex] = 'asc';
        } else {
            sortDirection[columnIndex] = sortDirection[columnIndex] === 'asc' ? 'desc' : 'asc';
        }
        
        // Ordenar las filas
        dataRows.sort((a, b) => {
            const aText = a.cells[columnIndex].textContent.trim();
            const bText = b.cells[columnIndex].textContent.trim();
            
            // Intentar comparar como números si es posible
            const aNum = parseFloat(aText.replace(/[^\d.-]/g, ''));
            const bNum = parseFloat(bText.replace(/[^\d.-]/g, ''));
            
            if (!isNaN(aNum) && !isNaN(bNum)) {
                return sortDirection[columnIndex] === 'asc' ? aNum - bNum : bNum - aNum;
            }
            
            // Comparar como texto
            if (sortDirection[columnIndex] === 'asc') {
                return aText.localeCompare(bText);
            } else {
                return bText.localeCompare(aText);
            }
        });
        
        // Limpiar indicadores anteriores
        const headers = table.querySelectorAll('th');
        headers.forEach((header, idx) => {
            if (idx !== columnIndex) {
                header.innerHTML = header.innerHTML.replace(/ [▲▼]/, '');
            }
        });
        
        // Agregar indicador visual
        const currentHeader = headers[columnIndex];
        const indicator = sortDirection[columnIndex] === 'asc' ? ' ▲' : ' ▼';
        if (!currentHeader.innerHTML.includes('▲') && !currentHeader.innerHTML.includes('▼')) {
            currentHeader.innerHTML += indicator;
        } else {
            currentHeader.innerHTML = currentHeader.innerHTML.replace(/ [▲▼]/, indicator);
        }
        
        // Reordenar filas en el DOM
        const noDataRow = rows.find(row => row.cells.length === 1);
        dataRows.forEach(row => tbody.removeChild(row));
        dataRows.forEach(row => tbody.appendChild(row));
        if (noDataRow) {
            tbody.appendChild(noDataRow);
        }
    }
</script>

<style>
    #incidenciasTable thead th {
        position: relative;
        user-select: none;
        transition: background-color 0.2s ease;
    }
    #incidenciasTable thead th:hover {
        background-color: #83c5be !important;
    }
    #incidenciasTable thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    #incidenciasTable thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

