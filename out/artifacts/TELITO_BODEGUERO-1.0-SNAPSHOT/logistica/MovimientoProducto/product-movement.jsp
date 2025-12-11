<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.MovimientoInventarioBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Movimiento de Producto"/>
    </jsp:include>
    <style>
        /* Estilo para el encabezado de la tabla igual que en productor */
        .table-card .card-header {
            background: linear-gradient(135deg, #00a896 0%, #83c5be 100%);
            color: #fff;
            border-radius: 12px 12px 0 0;
            padding: 20px 30px;
            margin: 0;
        }
        .table-card .card-header h5,
        .table-card .card-header small {
            color: white !important;
        }
        /* Estilo para el botón Limpiar igual que en productor - sobrescribir estilos globales */
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
        .btn-outline-secondary:focus {
            color: #fff !important;
            background-color: #6c757d !important;
            border: 1px solid #6c757d !important;
            box-shadow: 0 0 0 0.25rem rgba(108, 117, 125, 0.5) !important;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Movimiento'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
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
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-exchange-alt me-2"></i>Movimiento de Producto</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Trazabilidad y auditoría de movimientos de inventario.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <%
                            String busquedaParam = request.getParameter("busqueda");
                            String tipoParam = request.getParameter("tipo");
                            String periodoParam = request.getParameter("periodo");
                            StringBuilder urlParams = new StringBuilder();
                            if (busquedaParam != null && !busquedaParam.trim().isEmpty()) {
                                urlParams.append("&busqueda=").append(java.net.URLEncoder.encode(busquedaParam, "UTF-8"));
                            }
                            if (tipoParam != null && !tipoParam.trim().isEmpty()) {
                                urlParams.append("&tipo=").append(java.net.URLEncoder.encode(tipoParam, "UTF-8"));
                            }
                            if (periodoParam != null && !periodoParam.trim().isEmpty()) {
                                urlParams.append("&periodo=").append(java.net.URLEncoder.encode(periodoParam, "UTF-8"));
                            }
                            String urlBase = request.getContextPath() + "/logistica/MovimientoInventarioReporteServlet?action=exportar" + urlParams.toString();
                            String urlEnviar = request.getContextPath() + "/logistica/MovimientoInventarioReporteServlet?action=formEnviar" + urlParams.toString();
                        %>
                        <a href="<%= urlBase %>" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <a href="<%= urlEnviar %>" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </a>
                    </div>
                </div>
            </div>

            <%
                // Calcular estadísticas desde la lista de movimientos
                ArrayList<MovimientoInventarioBean> listaMovimientosStats = 
                    (ArrayList<MovimientoInventarioBean>) request.getAttribute("listaMovimientos");
                int totalMovimientos = 0;
                int movimientosEntrada = 0;
                int movimientosSalida = 0;
                int movimientosAjuste = 0;
                
                if (listaMovimientosStats != null) {
                    totalMovimientos = listaMovimientosStats.size();
                    for (MovimientoInventarioBean mov : listaMovimientosStats) {
                        String tipoMov = mov.getTipo();
                        if ("Entrada".equalsIgnoreCase(tipoMov)) {
                            movimientosEntrada++;
                        } else if ("Salida".equalsIgnoreCase(tipoMov)) {
                            movimientosSalida++;
                        } else if ("Ajuste".equalsIgnoreCase(tipoMov)) {
                            movimientosAjuste++;
                        }
                    }
                }
                
                // Si hay totalRows disponible, usarlo para el total real
                Integer totalRowsAttr = (Integer) request.getAttribute("totalRows");
                if (totalRowsAttr != null) {
                    totalMovimientos = totalRowsAttr;
                }
            %>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="stats-container" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 15px;">
                <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                    <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Movimientos</h3>
                    <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= totalMovimientos %></p>
                </div>
                <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                    <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Entradas</h3>
                    <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= movimientosEntrada %></p>
                </div>
                <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                    <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Salidas</h3>
                    <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= movimientosSalida %></p>
                </div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros ===================== -->
            <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                <form action="<%= request.getContextPath() %>/MovimientoProductoServlet" method="GET">
                    <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                    <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                        <div class="col-md-5">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                            <div class="input-group">
                                <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Producto o lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-filter me-1"></i>Tipo</label>
                            <select class="form-select form-select-sm shadow-sm" name="tipo" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="" ${param.tipo == '' ? 'selected' : ''}>Todos</option>
                                <option value="Entrada" ${param.tipo == 'Entrada' ? 'selected' : ''}>Entrada</option>
                                <option value="Salida" ${param.tipo == 'Salida' ? 'selected' : ''}>Salida</option>
                                <option value="Ajuste" ${param.tipo == 'Ajuste' ? 'selected' : ''}>Ajuste</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Periodo</label>
                            <select class="form-select form-select-sm shadow-sm" name="periodo" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="" ${param.periodo == '' ? 'selected' : ''}>Todos</option>
                                <option value="7" ${param.periodo == '7' ? 'selected' : ''}>Últimos 7 días</option>
                                <option value="30" ${param.periodo == '30' ? 'selected' : ''}>Últimos 30 días</option>
                                <option value="90" ${param.periodo == '90' ? 'selected' : ''}>Últimos 90 días</option>
                            </select>
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <a href="<%= request.getContextPath() %>/MovimientoProductoServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                            </a>
                        </div>
                    </div>
                </form>
            </div>

            <!-- ===================== Card: Tabla de movimientos ===================== -->
            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-exchange-alt me-2"></i>Tabla de Movimientos</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los movimientos de inventario</small>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">
                            <div style="width: 100%; position: relative;">
                                <table id="movementTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                    <thead class="table-light">
                                    <tr>
                                        <th onclick="sortTable(0)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-calendar-alt me-1"></i>Fecha
                                        </th>
                                        <th onclick="sortTable(1)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Producto
                                        </th>
                                        <th onclick="sortTable(2)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-exchange-alt me-1"></i>Tipo
                                        </th>
                                        <th onclick="sortTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-map-marker-alt me-1"></i>Destino
                                        </th>
                                        <th onclick="sortTable(4)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-barcode me-1"></i>Lote
                                        </th>
                                        <th onclick="sortTable(5)" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-user me-1"></i>Personal Responsable
                                        </th>
                                        <th onclick="sortTable(6)" style="width: 11%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-comment me-1"></i>Observaciones
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<MovimientoInventarioBean> listaMovimientos =
                                                (ArrayList<MovimientoInventarioBean>) request.getAttribute("listaMovimientos");

                                        if (listaMovimientos != null && !listaMovimientos.isEmpty()) {
                                            for (MovimientoInventarioBean movimiento : listaMovimientos) {
                                    %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getFechaFormateada() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getNombreProducto() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <% if ("Entrada".equalsIgnoreCase(movimiento.getTipo())) { %>
                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-arrow-down me-1"></i><%= movimiento.getTipo() %>
                                            </span>
                                            <% } else if ("Salida".equalsIgnoreCase(movimiento.getTipo())) { %>
                                            <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-arrow-up me-1"></i><%= movimiento.getTipo() %>
                                            </span>
                                            <% } else { %>
                                            <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-adjust me-1"></i><%= movimiento.getTipo() %>
                                            </span>
                                            <% } %>
                                        </td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getDestino() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <%= movimiento.getCodigoLote() %>
                                            </span>
                                        </td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getResponsable() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getObservaciones() %></td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="7" class="text-center py-5">
                                            <div class="text-muted">
                                                <i class="fas fa-inbox fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No se encontraron movimientos con los filtros aplicados.</p>
                                                <small>Intenta ajustar los filtros de búsqueda</small>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                </table>
                                
                                <%-- Incluir componente de paginación --%>
                                <%
                                    request.setAttribute("param1Name", "busqueda");
                                    request.setAttribute("param1Value", request.getAttribute("busqueda"));
                                    request.setAttribute("param2Name", "tipo");
                                    request.setAttribute("param2Value", request.getAttribute("tipoFiltro"));
                                    request.setAttribute("param3Name", "periodo");
                                    request.setAttribute("param3Value", request.getAttribute("periodoFiltro"));
                                %>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.querySelector('form[action*="MovimientoProductoServlet"]');
        const busquedaInput = form.querySelector('input[name="busqueda"]');
        const tipoSelect = form.querySelector('select[name="tipo"]');
        const periodoSelect = form.querySelector('select[name="periodo"]');
        
        // Aplicar filtros cuando cambien los selects
        if (tipoSelect) {
            tipoSelect.addEventListener('change', function() {
                form.submit();
            });
        }
        
        if (periodoSelect) {
            periodoSelect.addEventListener('change', function() {
                form.submit();
            });
        }
        
        // Aplicar filtros al presionar Enter en el campo de búsqueda
        if (busquedaInput) {
            busquedaInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    form.submit();
                }
            });
        }
        
        // Botón de búsqueda
        const searchButton = document.querySelector('.btn-primary.shadow-sm');
        if (searchButton) {
            searchButton.addEventListener('click', function(e) {
                e.preventDefault();
                form.submit();
            });
        }
    });
    
    // Función para ordenar la tabla
    let sortDirection = {}; // Almacena la dirección de ordenamiento para cada columna
    
    function sortTable(columnIndex) {
        const table = document.getElementById('movementTable');
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
            const aNum = parseFloat(aText);
            const bNum = parseFloat(bText);
            
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
    thead th {
        position: relative;
        user-select: none;
    }
    thead th:hover {
        background-color: var(--seafoam) !important;
    }
    thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

</body>
</html>
