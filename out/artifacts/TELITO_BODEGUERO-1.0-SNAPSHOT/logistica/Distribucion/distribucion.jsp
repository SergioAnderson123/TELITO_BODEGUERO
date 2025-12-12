<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.PlanTransporteBean" %>
<%@ page import="com.example.telito.logistica.beans.ConductorBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Distribucion y Transporte"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Distribucion'/>
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
                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Planes de Transporte</h2>
                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Seguimiento de entregas y análisis de rutas.</p>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Tabla de Transportes</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los planes de transporte</small>
                                </div>
                                <div class="d-flex gap-2 flex-wrap">
                                    <%
                                        String busquedaParam = request.getParameter("busqueda");
                                        String conductorParam = request.getParameter("conductor");
                                        String estadoParam = request.getParameter("estado");
                                        String fechaDesdeParam = request.getParameter("fecha_desde");
                                        String fechaHastaParam = request.getParameter("fecha_hasta");
                                        StringBuilder urlParams = new StringBuilder();
                                        if (busquedaParam != null && !busquedaParam.trim().isEmpty()) {
                                            urlParams.append("&busqueda=").append(java.net.URLEncoder.encode(busquedaParam, "UTF-8"));
                                        }
                                        if (conductorParam != null && !conductorParam.trim().isEmpty()) {
                                            urlParams.append("&conductor=").append(java.net.URLEncoder.encode(conductorParam, "UTF-8"));
                                        }
                                        if (estadoParam != null && !estadoParam.trim().isEmpty()) {
                                            urlParams.append("&estado=").append(java.net.URLEncoder.encode(estadoParam, "UTF-8"));
                                        }
                                        if (fechaDesdeParam != null && !fechaDesdeParam.trim().isEmpty()) {
                                            urlParams.append("&fecha_desde=").append(java.net.URLEncoder.encode(fechaDesdeParam, "UTF-8"));
                                        }
                                        if (fechaHastaParam != null && !fechaHastaParam.trim().isEmpty()) {
                                            urlParams.append("&fecha_hasta=").append(java.net.URLEncoder.encode(fechaHastaParam, "UTF-8"));
                                        }
                                        String urlBase = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=exportar" + urlParams.toString();
                                        String urlEnviar = request.getContextPath() + "/logistica/DistribucionTransporteReporteServlet?action=formEnviar" + urlParams.toString();
                                    %>
                                    <a href="<%= urlBase %>" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                        <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                                    </a>
                                    <a href="<%= urlEnviar %>" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                        <i class="fas fa-envelope me-1"></i>Enviar por Correo
                                    </a>
                                    <a href="${pageContext.request.contextPath}/planes-transporte?action=crear" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                                        <i class="fas fa-plus me-1"></i>Agregar Plan
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">
                            <form action="${pageContext.request.contextPath}/planes-transporte" method="GET">
                                <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                                <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                    <div class="col-md-2">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                        <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" placeholder="N° Viaje, Placa, Lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user me-1"></i>Conductor</label>
                                        <select class="form-select form-select-sm shadow-sm" name="conductor" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <option value="">Todos</option>
                                            <% ArrayList<ConductorBean> listaConductores = (ArrayList<ConductorBean>) request.getAttribute("listaConductores");
                                                if(listaConductores != null){
                                                    for(ConductorBean conductor : listaConductores){ %>
                                            <option value="<%= conductor.getId() %>" ${param.conductor == conductor.getId() ? 'selected' : ''} >
                                                <%= conductor.getNombreCompleto() %>
                                            </option>
                                            <%  }
                                            } %>
                                        </select>
                                    </div>
                                    <div class="col-xl-2 col-lg-3 col-md-6 col-sm-12">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                                        <select class="form-select form-select-sm shadow-sm" name="estado" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                            <option value="Pendiente" ${param.estado == 'Pendiente' ? 'selected' : ''}>Pendiente</option>
                                            <option value="Salida" ${param.estado == 'Salida' ? 'selected' : ''}>Salida</option>
                                            <option value="En Ruta" ${param.estado == 'En Ruta' ? 'selected' : ''}>En Ruta</option>
                                            <option value="Entregado" ${param.estado == 'Entregado' ? 'selected' : ''}>Entregado</option>
                                            <option value="Cancelado" ${param.estado == 'Cancelado' ? 'selected' : ''}>Cancelado</option>
                                        </select>
                                    </div>
                                    <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Desde</label>
                                        <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_desde" value="${param.fecha_desde}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    </div>
                                    <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Hasta</label>
                                        <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_hasta" value="${param.fecha_hasta}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    </div>
                                    <div class="col-md-1 d-flex align-items-end">
                                        <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <i class="fas fa-search me-1"></i>Buscar
                                        </button>
                                    </div>
                                    <div class="col-md-1 d-flex align-items-end">
                                        <a href="${pageContext.request.contextPath}/planes-transporte" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <i class="fas fa-sync-alt me-1"></i>Limpiar
                                        </a>
                                    </div>
                                </div>
                            </form>

                            <div class="table-responsive">
                                <table id="distribucionTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                    <thead class="table-light">
                                    <tr>
                                        <th onclick="sortTable(0)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-hashtag me-1"></i>N° de Viaje
                                        </th>
                                        <th onclick="sortTable(1)" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Producto
                                        </th>
                                        <th onclick="sortTable(2)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-barcode me-1"></i>Lote
                                        </th>
                                        <th onclick="sortTable(3)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-toggle-on me-1"></i>Estado
                                        </th>
                                        <th onclick="sortTable(4)" style="width: 13%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-user me-1"></i>Conductor
                                        </th>
                                        <th onclick="sortTable(5)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-car me-1"></i>Placa
                                        </th>
                                        <th onclick="sortTable(6)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-calendar me-1"></i>Fecha de Entrega
                                        </th>
                                        <th onclick="sortTable(7)" style="width: 14%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-map-marker-alt me-1"></i>Destino
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<PlanTransporteBean> listaPlanes = (ArrayList<PlanTransporteBean>) request.getAttribute("listaPlanes");
                                        
                                        Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                        Integer sizeObj = (Integer) request.getAttribute("size");
                                        int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                        int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                        
                                        if (listaPlanes != null && !listaPlanes.isEmpty()) {
                                            for (PlanTransporteBean plan : listaPlanes) {
                                    %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= plan.getNumeroViaje() %></strong></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= plan.getNombreProducto() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= plan.getCodigoLote() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <% if ("Entregado".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-check-circle me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("En Ruta".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-truck me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("Pendiente".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-clock me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("Salida".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-arrow-right me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else if ("Cancelado".equals(plan.getEstado())) { %>
                                            <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-times-circle me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } else { %>
                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-question-circle me-1"></i><%= plan.getEstado() %>
                                            </span>
                                            <% } %>
                                        </td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= plan.getNombreConductor() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= plan.getPlacaVehiculo() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= plan.getFechaEntrega() != null ? plan.getFechaEntrega() : "-" %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= plan.getNombreDestino() != null ? plan.getNombreDestino() : "-" %></td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center py-5">
                                            <div class="text-muted">
                                                <i class="fas fa-road fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No se encontraron planes con los filtros aplicados.</p>
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
                                    request.setAttribute("param2Name", "conductor");
                                    request.setAttribute("param2Value", request.getAttribute("conductorFiltro"));
                                    request.setAttribute("param3Name", "estado");
                                    request.setAttribute("param3Value", request.getAttribute("estadoFiltro"));
                                    request.setAttribute("param4Name", "fecha_desde");
                                    request.setAttribute("param4Value", request.getAttribute("fechaDesdeFiltro"));
                                    request.setAttribute("param5Name", "fecha_hasta");
                                    request.setAttribute("param5Value", request.getAttribute("fechaHastaFiltro"));
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
    // Función para ordenar la tabla
    let sortDirection = {}; // Almacena la dirección de ordenamiento para cada columna
    
    function sortTable(columnIndex) {
        const table = document.getElementById('distribucionTable');
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