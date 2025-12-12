<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Historial de Movimientos"/>
    </jsp:include>
    <style>
        /* Estilos para stat-cards */
        .stats-container { display: grid; grid-template-columns: repeat(4, 1fr); gap: 30px; margin-bottom: 40px; }
        .stat-card {
            background-color: #ffffff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }
        .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: #6c757d; font-weight: 600; }
        .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: #00a896; }
        @media (max-width: 1200px) {
            .stats-container { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 768px) {
            .stats-container { grid-template-columns: 1fr; }
        }
        /* Estilo para el botón Limpiar */
        .btn-outline-secondary {
            color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-color: transparent !important;
            background-image: none !important;
        }
        .btn-outline-secondary:hover {
            color: #fff !important;
            background-color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-image: none !important;
        }
    </style>
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
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-history me-2"></i>Historial de Movimientos</h2>
                            <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Consulta el registro completo de movimientos de inventario.</p>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <a href="<%= request.getContextPath() %>/almacen/MovimientoReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                            </a>
                            <a href="<%= request.getContextPath() %>/almacen/MovimientoReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-envelope me-1"></i>Enviar por Correo
                            </a>
                        </div>
                    </div>
                </div>

                <%
                    // Obtener estadísticas del servlet
                    Integer totalMovimientosAttr = (Integer) request.getAttribute("totalMovimientos");
                    Integer movimientosEntradaAttr = (Integer) request.getAttribute("movimientosEntrada");
                    Integer movimientosSalidaAttr = (Integer) request.getAttribute("movimientosSalida");
                    Integer movimientosAjusteAttr = (Integer) request.getAttribute("movimientosAjuste");
                    int totalMovimientos = (totalMovimientosAttr != null) ? totalMovimientosAttr : 0;
                    int movimientosEntrada = (movimientosEntradaAttr != null) ? movimientosEntradaAttr : 0;
                    int movimientosSalida = (movimientosSalidaAttr != null) ? movimientosSalidaAttr : 0;
                    int movimientosAjuste = (movimientosAjusteAttr != null) ? movimientosAjusteAttr : 0;
                %>

                <!-- ===================== Tarjetas de estadísticas ===================== -->
                <div class="stats-container">
                    <div class="stat-card">
                        <h3>Total de Movimientos</h3>
                        <p><%= totalMovimientos %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Entradas</h3>
                        <p><%= movimientosEntrada %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Salidas</h3>
                        <p><%= movimientosSalida %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Ajustes</h3>
                        <p><%= movimientosAjuste %></p>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                    <form action="<%= request.getContextPath() %>/almacen/MovimientoServlet" method="GET" id="filterForm">
                        <input type="hidden" name="action" value="listar">
                        <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-xl-4 col-lg-4 col-md-12 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Producto o lote..." value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-filter me-1"></i>Tipo</label>
                                <select class="form-select form-select-sm shadow-sm" name="tipo" id="tipoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="" <%= request.getParameter("tipo") == null || request.getParameter("tipo").isEmpty() ? "selected" : "" %>>Todos</option>
                                    <option value="Entrada" <%= "Entrada".equals(request.getParameter("tipo")) ? "selected" : "" %>>Entrada</option>
                                    <option value="Salida" <%= "Salida".equals(request.getParameter("tipo")) ? "selected" : "" %>>Salida</option>
                                    <option value="Ajuste" <%= "Ajuste".equals(request.getParameter("tipo")) ? "selected" : "" %>>Ajuste</option>
                                </select>
                            </div>
                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user me-1"></i>Vista</label>
                                <select class="form-select form-select-sm shadow-sm" name="filtro" id="filtroFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="todos" <%= !"mios".equals(request.getParameter("filtro")) ? "selected" : "" %>>Todos</option>
                                    <option value="mios" <%= "mios".equals(request.getParameter("filtro")) ? "selected" : "" %>>Mis Movimientos</option>
                                </select>
                            </div>
                            <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6 d-flex align-items-end">
                                <a href="<%= request.getContextPath() %>/almacen/MovimientoServlet?action=listar" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-sync-alt me-1"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ===================== Card: Tabla de movimientos ===================== -->
                <div class="table-card shadow-sm">
                    <div class="card-header" style="padding: 0.5rem 0.75rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-history me-2"></i>Tabla de Movimientos</h5>
                                <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona el historial completo de movimientos de inventario</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <div class="table-responsive">
                            <table id="movimientosTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                <thead class="table-light">
                                <tr>
                                    <th onclick="sortTable(0)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-calendar-alt me-1"></i>Fecha y Hora
                                    </th>
                                    <th onclick="sortTable(1)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-box me-1"></i>Producto
                                    </th>
                                    <th onclick="sortTable(2)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-hashtag me-1"></i>Lote
                                    </th>
                                    <th onclick="sortTable(3)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-filter me-1"></i>Tipo
                                    </th>
                                    <th onclick="sortTable(4)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-cubes me-1"></i>Cantidad
                                    </th>
                                    <th onclick="sortTable(5)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-user me-1"></i>Responsable
                                    </th>
                                    <th style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                        <i class="fas fa-info-circle me-1"></i>Motivo / Referencia
                                    </th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty listaMovimientos}">
                                        <c:forEach var="mov" items="${listaMovimientos}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><fmt:formatDate value="${mov.fecha}" pattern="dd/MM/yyyy HH:mm:ss"/></td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${mov.nombreProducto}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>${mov.codigoLote}</strong></td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <c:choose>
                                                        <c:when test="${mov.motivo.startsWith('Ajuste de inventario')}">
                                                            <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-adjust me-1"></i>Ajuste
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${mov.tipoMovimiento == 'Entrada'}">
                                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-arrow-down me-1"></i>Entrada
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${mov.tipoMovimiento == 'Salida'}">
                                                            <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-arrow-up me-1"></i>Salida
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                ${mov.tipoMovimiento}
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${mov.cantidad} paquetes</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${mov.nombreUsuario}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <c:choose>
                                                        <c:when test="${not empty mov.numeroPedido}">
                                                            <span class="badge text-bg-info shadow-sm" style="font-size: 0.75rem; padding: 0.25rem 0.5rem;">
                                                                <i class="fas fa-shopping-cart me-1"></i>Pedido: ${mov.numeroPedido}
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${not empty mov.numeroOrdenCompra}">
                                                            <span class="badge text-bg-primary shadow-sm" style="font-size: 0.75rem; padding: 0.25rem 0.5rem;">
                                                                <i class="fas fa-file-invoice me-1"></i>OC: ${mov.numeroOrdenCompra}
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <small class="text-muted">${mov.motivo}</small>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="7" class="text-center py-5">
                                                <div class="text-muted">
                                                    <i class="fas fa-box-open fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                    <p class="mb-0">No se encontraron movimientos con los filtros aplicados.</p>
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
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function () {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const tipoFilter = document.getElementById('tipoFilter');
        const filtroFilter = document.getElementById('filtroFilter');
        
        // Aplicar filtros cuando cambien los selects
        if (tipoFilter && filterForm) {
            tipoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (filtroFilter && filterForm) {
            filtroFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        // Aplicar filtros al presionar Enter en el campo de búsqueda
        if (searchInput && filterForm) {
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    filterForm.submit();
                }
            });
        }
    });

    // Búsqueda en tiempo real (opcional, funciona junto con el formulario)
    document.addEventListener('DOMContentLoaded', function () {
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            const tableBody = document.querySelector('#movimientosTable tbody');
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
        const table = document.getElementById('movimientosTable');
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
    #movementTable thead th {
        position: relative;
        user-select: none;
        transition: background-color 0.2s ease;
    }
    #movementTable thead th:hover {
        background-color: #83c5be !important;
    }
    #movementTable thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    #movementTable thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>