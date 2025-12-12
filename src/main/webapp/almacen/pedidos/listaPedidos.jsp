<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Pedidos Pendientes"/>
        <jsp:param name="activeMenu" value="Registrar salidas"/>
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

                <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                    <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-truck-loading me-2"></i>Registro de Salidas</h2>
                    <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Gestiona pedidos y planes de transporte pendientes de preparación.</p>
                </div>

                <!-- TABLA DE PEDIDOS -->
                <div class="table-card shadow-sm mb-4">
                    <div class="card-header" style="padding: 0.5rem 0.75rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-clipboard-list me-2"></i>Pedidos Pendientes</h5>
                                <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona los pedidos pendientes de preparación</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <form action="<%= request.getContextPath() %>/almacen/PedidoServlet" method="GET">
                            <input type="hidden" name="action" value="lista">
                            <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 10 %>">
                            <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                <div class="col-xl-5 col-lg-5 col-md-12 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" placeholder="N° Pedido, cliente o destino..." value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                                    <select class="form-select form-select-sm shadow-sm" name="estado" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <option value="" <%= (request.getParameter("estado") == null || request.getParameter("estado").isEmpty()) ? "selected" : "" %>>Todos</option>
                                        <option value="Pendiente" <%= "Pendiente".equals(request.getParameter("estado")) ? "selected" : "" %>>Pendiente</option>
                                        <option value="Despachado" <%= "Despachado".equals(request.getParameter("estado")) ? "selected" : "" %>>Despachado</option>
                                    </select>
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-3 col-sm-3 d-flex align-items-end">
                                    <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search me-1"></i>Buscar
                                    </button>
                                </div>
                                <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6 d-flex align-items-end">
                                    <a href="<%= request.getContextPath() %>/almacen/PedidoServlet?action=lista" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-sync-alt me-1"></i>Limpiar
                                    </a>
                                </div>
                            </div>
                        </form>
                        <div class="table-responsive">
                            <table id="pedidosTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                <thead class="table-light">
                                <tr>
                                    <th onclick="sortTable(0)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-hashtag me-1"></i>N° Pedido
                                    </th>
                                    <th onclick="sortTable(1)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-user me-1"></i>Cliente
                                    </th>
                                    <th onclick="sortTable(2)" style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-map-marker-alt me-1"></i>Destino
                                    </th>
                                    <th onclick="sortTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-toggle-on me-1"></i>Estado
                                    </th>
                                    <th style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center">
                                        <i class="fas fa-cogs me-1"></i>Acciones
                                    </th>
                                </tr>
                                </thead>
                                <tbody id="pedidosTableBody">
                                <c:choose>
                                    <c:when test="${not empty listaPedidos}">
                                        <c:forEach var="pedido" items="${listaPedidos}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <span class="badge text-bg-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">${pedido.numeroPedido}</span>
                                                </td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${pedido.cliente != null ? pedido.cliente.nombre : 'N/A'}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${pedido.destino}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <c:choose>
                                                        <c:when test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                            <span class="badge text-bg-warning text-dark shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-hourglass-half me-1"></i>Pendiente
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${pedido.estadoPreparacion == 'Despachado'}">
                                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-check-circle me-1"></i>Despachado
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-question-circle me-1"></i>${pedido.estadoPreparacion}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <c:if test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                        <a href="PedidoServlet?action=preparar&id=${pedido.idPedido}" class="btn btn-sm btn-primary shadow-sm" style="font-size: 0.75rem; padding: 0.25rem 0.5rem;">
                                                            <i class="fas fa-box-open me-1"></i>Preparar
                                                        </a>
                                                    </c:if>
                                                    <c:if test="${pedido.estadoPreparacion != 'Pendiente'}">
                                                        <span class="text-muted" style="font-size: 0.8rem;"><i class="fas fa-check-circle me-1"></i>Ya preparado</span>
                                                    </c:if>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="5" class="text-center py-5">
                                                <div class="text-muted">
                                                    <i class="fas fa-box-open fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                    <p class="mb-0">No se encontraron pedidos con los filtros aplicados.</p>
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

                <!-- TABLA DE PLANES DE TRANSPORTE -->
                <div class="table-card shadow-sm">
                    <div class="card-header" style="padding: 0.5rem 0.75rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Planes de Transporte</h5>
                                <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona los planes de transporte pendientes</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <div class="table-responsive">
                            <table id="planesTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                <thead class="table-light">
                                <tr>
                                    <th onclick="sortTable(0, 'planesTable')" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-hashtag me-1"></i>N° Plan
                                    </th>
                                    <th onclick="sortTable(1, 'planesTable')" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-box me-1"></i>Producto
                                    </th>
                                    <th onclick="sortTable(2, 'planesTable')" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-barcode me-1"></i>Lote
                                    </th>
                                    <th onclick="sortTable(3, 'planesTable')" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-cubes me-1"></i>Paquetes
                                    </th>
                                    <th onclick="sortTable(4, 'planesTable')" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-user me-1"></i>Conductor
                                    </th>
                                    <th onclick="sortTable(5, 'planesTable')" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-map-marker-alt me-1"></i>Destino
                                    </th>
                                    <th onclick="sortTable(6, 'planesTable')" style="width: 13%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-calendar-alt me-1"></i>Fecha Entrega
                                    </th>
                                    <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center">
                                        <i class="fas fa-cogs me-1"></i>Estado
                                    </th>
                                </tr>
                                </thead>
                                <tbody id="planesTableBody">
                                <c:choose>
                                    <c:when test="${not empty listaPlanes}">
                                        <c:forEach var="plan" items="${listaPlanes}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${plan.numeroPlan}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${plan.nombreProducto}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>${plan.codigoLote}</strong></td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${plan.paquetesDisponibles} paquetes</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${plan.nombreConductor}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${plan.nombreDestino}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${plan.fechaEntrega}</td>
                                                <td class="text-center" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <c:choose>
                                                        <c:when test="${plan.estado == 'Pendiente'}">
                                                            <a href="PedidoServlet?action=prepararPlan&id=${plan.idPlan}" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.75rem; padding: 0.25rem 0.5rem;">
                                                                <i class="fas fa-box-open me-1"></i>Preparar
                                                            </a>
                                                        </c:when>
                                                        <c:when test="${plan.estado == 'Salida'}">
                                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-check-circle me-1"></i>Despachado
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-question-circle me-1"></i>${plan.estado}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="8" class="text-center py-5">
                                                <div class="text-muted">
                                                    <i class="fas fa-truck fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                    <p class="mb-0">No hay planes de transporte pendientes.</p>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
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

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    let sortDirections = {};
    let sortDirectionsPlanes = {};

    function sortTable(columnIndex, tableId = 'pedidosTable') {
        const table = document.getElementById(tableId);
        if (!table) return;

        const tbody = table.querySelector('tbody');
        if (!tbody) return;

        const rows = Array.from(tbody.querySelectorAll('tr'));
        if (rows.length === 0) return;

        const sortKey = tableId + '_' + columnIndex;
        const sortDir = sortDirections[sortKey] || sortDirectionsPlanes[sortKey] || 'asc';

        rows.sort((a, b) => {
            const aText = a.cells[columnIndex]?.textContent.trim() || '';
            const bText = b.cells[columnIndex]?.textContent.trim() || '';

            let comparison = 0;
            const aNum = parseFloat(aText.replace(/[^\d.-]/g, ''));
            const bNum = parseFloat(bText.replace(/[^\d.-]/g, ''));

            if (!isNaN(aNum) && !isNaN(bNum)) {
                comparison = aNum - bNum;
            } else {
                comparison = aText.localeCompare(bText, 'es', { numeric: true, sensitivity: 'base' });
            }

            return sortDir === 'asc' ? comparison : -comparison;
        });

        rows.forEach(row => tbody.appendChild(row));

        const newSortDir = sortDir === 'asc' ? 'desc' : 'asc';
        if (tableId === 'pedidosTable') {
            sortDirections[sortKey] = newSortDir;
        } else {
            sortDirectionsPlanes[sortKey] = newSortDir;
        }

        updateSortIndicators(table, columnIndex, newSortDir);
    }

    function updateSortIndicators(table, columnIndex, direction) {
        const headers = table.querySelectorAll('thead th');
        headers.forEach((header, index) => {
            header.classList.remove('sort-asc', 'sort-desc');
            if (index === columnIndex) {
                header.classList.add(direction === 'asc' ? 'sort-asc' : 'sort-desc');
            }
        });
    }

    document.querySelectorAll('thead th[onclick]').forEach(header => {
        header.style.cursor = 'pointer';
        header.style.userSelect = 'none';
        header.addEventListener('mouseenter', function() {
            if (!this.classList.contains('sort-asc') && !this.classList.contains('sort-desc')) {
                this.style.backgroundColor = '#f0f0f0';
            }
        });
        header.addEventListener('mouseleave', function() {
            if (!this.classList.contains('sort-asc') && !this.classList.contains('sort-desc')) {
                this.style.backgroundColor = '';
            }
        });
    });
</script>

<style>
    #pedidosTable thead th,
    #planesTable thead th {
        position: relative;
        user-select: none;
        transition: background-color 0.2s ease;
    }
    #pedidosTable thead th:hover,
    #planesTable thead th:hover {
        background-color: #83c5be !important;
    }
    #pedidosTable thead th.sort-asc::after,
    #planesTable thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    #pedidosTable thead th.sort-desc::after,
    #planesTable thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

</body>
</html>
