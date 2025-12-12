<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Órdenes de Compra Pendientes"/>
    </jsp:include>
    <style>
        /* Estilos para stat-cards */
        .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 40px; }
        .stat-card {
            background-color: #ffffff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }
        .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: #6c757d; font-weight: 600; }
        .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: #00a896; }
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

    <%-- ===== INICIO DE LA CORRECCIÓN ===== --%>
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <%-- ===== FIN DE LA CORRECCIÓN ===== --%>

    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Registrar entradas"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-clipboard-list me-2"></i>Órdenes de Compra Pendientes</h2>
                            <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Gestiona las órdenes de compra pendientes de recepción en el almacén.</p>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <a href="<%= request.getContextPath() %>/almacen/EntradaReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                            </a>
                            <a href="<%= request.getContextPath() %>/almacen/EntradaReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-envelope me-1"></i>Enviar por Correo
                            </a>
                        </div>
                    </div>
                </div>

                <%
                    // Obtener estadísticas del servlet
                    Integer totalOrdenesAttr = (Integer) request.getAttribute("totalOrdenes");
                    Integer ordenesPendientesAttr = (Integer) request.getAttribute("ordenesPendientes");
                    Integer ordenesRegistradasAttr = (Integer) request.getAttribute("ordenesRegistradas");
                    int totalOrdenes = (totalOrdenesAttr != null) ? totalOrdenesAttr : 0;
                    int ordenesPendientes = (ordenesPendientesAttr != null) ? ordenesPendientesAttr : 0;
                    int ordenesRegistradas = (ordenesRegistradasAttr != null) ? ordenesRegistradasAttr : 0;
                %>

                <!-- ===================== Tarjetas de estadísticas ===================== -->
                <div class="stats-container">
                    <div class="stat-card">
                        <h3>Total de Órdenes</h3>
                        <p><%= totalOrdenes %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Pendientes</h3>
                        <p><%= ordenesPendientes %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Registradas</h3>
                        <p><%= ordenesRegistradas %></p>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                    <form action="<%= request.getContextPath() %>/almacen/EntradaServlet" method="GET" id="filterForm">
                        <input type="hidden" name="action" value="lista">
                        <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-xl-4 col-lg-4 col-md-12 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="N° Orden o producto..." value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-xl-4 col-lg-4 col-md-6 col-sm-6">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-truck me-1"></i>Proveedor</label>
                                <select class="form-select form-select-sm shadow-sm" name="proveedor" id="proveedorFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="">Todos</option>
                                    <%
                                        try {
                                            String proveedorParam = request.getParameter("proveedor");
                                            java.util.ArrayList<java.util.Map<String, Object>> listaProductores = 
                                                (java.util.ArrayList<java.util.Map<String, Object>>) request.getAttribute("listaProductores");
                                            if (listaProductores != null && !listaProductores.isEmpty()) {
                                                for (java.util.Map<String, Object> productor : listaProductores) {
                                                    if (productor != null) {
                                                        Object idObj = productor.get("id");
                                                        Object nombreObj = productor.get("nombre");
                                                        if (idObj != null && nombreObj != null) {
                                                            String productorId = String.valueOf(idObj);
                                                            String productorNombre = String.valueOf(nombreObj);
                                                            String selected = (proveedorParam != null && proveedorParam.equals(productorId)) ? "selected" : "";
                                    %>
                                    <option value="<%= productorId %>" <%= selected %>><%= productorNombre %></option>
                                    <%
                                                        }
                                                    }
                                                }
                                            }
                                        } catch (Exception e) {
                                            // Si hay error, simplemente no mostrar productores en el select
                                            System.err.println("Error al mostrar productores en JSP: " + e.getMessage());
                                            e.printStackTrace();
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-xl-4 col-lg-4 col-md-6 col-sm-6 d-flex align-items-end">
                                <a href="<%= request.getContextPath() %>/almacen/EntradaServlet?action=lista" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-sync-alt me-1"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ===================== Card: Tabla de órdenes ===================== -->
                <div class="table-card shadow-sm">
                    <div class="card-header" style="padding: 0.5rem 0.75rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-clipboard-list me-2"></i>Tabla de Órdenes de Compra</h5>
                                <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona las órdenes de compra pendientes de recepción</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <div class="table-responsive">
                            <table id="ordenesTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                <thead class="table-light">
                                <tr>
                                    <th onclick="sortTable(0)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-hashtag me-1"></i>Número de Orden
                                    </th>
                                    <th onclick="sortTable(1)" style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-box me-1"></i>Producto
                                    </th>
                                    <th onclick="sortTable(2)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-truck me-1"></i>Proveedor
                                    </th>
                                    <th onclick="sortTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-cubes me-1"></i>Cantidad Esperada
                                    </th>
                                    <th onclick="sortTable(4)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-toggle-on me-1"></i>Estado
                                    </th>
                                    <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center">
                                        <i class="fas fa-cogs me-1"></i>Acción
                                    </th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty listaOrdenes}">
                                <c:forEach var="orden" items="${listaOrdenes}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>${orden.numeroOrden}</strong></td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${orden.nombreProducto}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${orden.nombreProveedor}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${orden.cantidad} paquetes</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <c:choose>
                                                <c:when test="${orden.estado == 'Registrado'}">
                                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-check-circle me-1"></i>Registrado
                                                            </span>
                                                </c:when>
                                                <c:otherwise>
                                                            <span class="badge text-bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-clock me-1"></i>${orden.estado}
                                                            </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;" class="text-center">
                                            <c:choose>
                                                <c:when test="${orden.estado == 'Registrado'}">
                                                            <span class="text-muted" style="font-size: 0.8rem;">
                                                                <i class="fas fa-check-circle me-1"></i>Ya registrado
                                                            </span>
                                                </c:when>
                                                <c:otherwise>
                                                            <a class="btn btn-sm btn-primary shadow-sm"
                                                               href="${pageContext.request.contextPath}/almacen/EntradaServlet?action=recibir&id=${orden.idOrdenCompra}"
                                                               style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-clipboard-check me-1"></i>Registrar Entrada
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="text-center py-5">
                                                <div class="text-muted">
                                                    <i class="fas fa-box-open fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                    <p class="mb-0">No se encontraron órdenes con los filtros aplicados.</p>
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
        const proveedorFilter = document.getElementById('proveedorFilter');
        
        // Aplicar filtros cuando cambien los selects
        if (proveedorFilter && filterForm) {
            proveedorFilter.addEventListener('change', function() {
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
        
        // Búsqueda en tiempo real (opcional, funciona junto con el formulario)
        if (searchInput) {
            const tableBody = document.querySelector('#ordenesTable tbody');
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
        const table = document.getElementById('ordenesTable');
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
    #ordenesTable thead th {
        position: relative;
        user-select: none;
        transition: background-color 0.2s ease;
    }
    #ordenesTable thead th:hover {
        background-color: #83c5be !important;
    }
    #ordenesTable thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    #ordenesTable thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>