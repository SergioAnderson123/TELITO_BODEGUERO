<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.InventarioBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    boolean soloLectura = false;
    if (usuario != null && usuario.getRol().getNombre().equals("ADMINISTRADOR")) {
        soloLectura = true; // El administrador accede en modo solo lectura
    }
%>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestion de Inventario"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Inventario'/>
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
                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-warehouse me-2"></i>Gestion de Inventario</h2>
                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra el inventario agrupado por producto con información de stock y precios.</p>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-warehouse me-2"></i>Tabla de Productos</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los productos del inventario</small>
                                </div>
                                <div class="d-flex gap-2 flex-wrap">
                                    <%
                                        String busquedaParam = request.getParameter("busqueda");
                                        String estadoParam = request.getParameter("estado");
                                        StringBuilder urlParams = new StringBuilder();
                                        if (busquedaParam != null && !busquedaParam.trim().isEmpty()) {
                                            urlParams.append("&busqueda=").append(java.net.URLEncoder.encode(busquedaParam, "UTF-8"));
                                        }
                                        if (estadoParam != null && !estadoParam.trim().isEmpty()) {
                                            urlParams.append("&estado=").append(java.net.URLEncoder.encode(estadoParam, "UTF-8"));
                                        }
                                        String urlBase = request.getContextPath() + "/logistica/InventarioLogisticaReporteServlet?action=exportar" + urlParams.toString();
                                        String urlEnviar = request.getContextPath() + "/logistica/InventarioLogisticaReporteServlet?action=formEnviar" + urlParams.toString();
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
                        <div class="card-body" style="padding: 0.75rem;">
                            <form action="<%= request.getContextPath() %>/InventarioServlet" method="GET">
                                <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                                <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                    <div class="col-md-6">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                        <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" placeholder="SKU o producto..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado de Stock</label>
                                        <select class="form-select form-select-sm shadow-sm" name="estado" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                            <option value="En stock" ${param.estado == 'En stock' ? 'selected' : ''}>En stock</option>
                                            <option value="Poco stock" ${param.estado == 'Poco stock' ? 'selected' : ''}>Poco stock</option>
                                            <option value="Sin stock" ${param.estado == 'Sin stock' ? 'selected' : ''}>Sin stock</option>
                                        </select>
                                    </div>
                                    <div class="col-md-1 d-flex align-items-end">
                                        <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <i class="fas fa-search me-1"></i>Buscar
                                        </button>
                                    </div>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="<%= request.getContextPath() %>/InventarioServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <i class="fas fa-sync-alt me-1"></i>Limpiar
                                        </a>
                                    </div>
                                </div>
                            </form>

                            <div style="width: 100%; position: relative;">
                                <table id="inventoryTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                    <thead class="table-light">
                                    <tr>
                                        <th onclick="sortTable(0)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-barcode me-1"></i>SKU
                                        </th>
                                        <th onclick="sortTable(1)" style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Nombre Producto
                                        </th>
                                        <th onclick="sortTable(2)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-cubes me-1"></i>Cantidad Disponible
                                        </th>
                                        <th onclick="sortTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-dollar-sign me-1"></i>Precio por Paquete
                                        </th>
                                        <th onclick="sortTable(4)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-coins me-1"></i>Costo por Unidad
                                        </th>
                                        <th onclick="sortTable(5)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-toggle-on me-1"></i>Estado
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<InventarioBean> listaInventario = (ArrayList<InventarioBean>) request.getAttribute("listaInventario");
                                        
                                        Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                        Integer sizeObj = (Integer) request.getAttribute("size");
                                        int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                        int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                        int contador = (currentPageInt - 1) * sizeInt + 1;
                                        
                                        if (listaInventario != null && !listaInventario.isEmpty()) {
                                            for (InventarioBean inventario : listaInventario) {
                                    %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= inventario.getCodigoSKU() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= inventario.getNombreProducto() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= inventario.getPaquetesDisponibles() %> paquetes</td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>S/. <%= String.format("%.2f", inventario.getPrecioPorPaquete()) %></strong></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>S/. <%= String.format("%.2f", inventario.getCostoPorUnidad()) %></strong></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <% 
                                                String estadoStock = inventario.getEstadoStock();
                                                if ("Sin Stock".equals(estadoStock) || "Sin stock".equals(estadoStock)) { 
                                            %>
                                                <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                    <i class="fas fa-times-circle me-1"></i>Sin Stock
                                                </span>
                                            <% } else if ("Poco Stock".equals(estadoStock) || "Poco stock".equals(estadoStock)) { %>
                                                <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                    <i class="fas fa-exclamation-triangle me-1"></i>Poco Stock
                                                </span>
                                            <% } else if ("En Stock".equals(estadoStock) || "En stock".equals(estadoStock)) { %>
                                                <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                    <i class="fas fa-check-circle me-1"></i>En Stock
                                                </span>
                                            <% } else { %>
                                                <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                    <i class="fas fa-question-circle me-1"></i>No configurado
                                                </span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="6" class="text-center py-5">
                                            <div class="text-muted">
                                                <i class="fas fa-box-open fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No se encontraron productos con los filtros aplicados.</p>
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
                                    request.setAttribute("param2Name", "estado");
                                    request.setAttribute("param2Value", request.getAttribute("estadoFiltro"));
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
