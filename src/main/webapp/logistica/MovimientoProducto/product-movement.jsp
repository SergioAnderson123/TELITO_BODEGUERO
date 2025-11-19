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
                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-exchange-alt me-2"></i>Movimiento de Producto</h2>
                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Trazabilidad y auditoría de movimientos de inventario.</p>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-exchange-alt me-2"></i>Tabla de Movimientos</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los movimientos de inventario</small>
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
                        <div class="card-body" style="padding: 0.75rem;">
                            <form action="<%= request.getContextPath() %>/MovimientoProductoServlet" method="GET">
                                <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                                <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                    <div class="col-md-4">
                                        <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                        <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" placeholder="Producto o lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    </div>
                                    <div class="col-md-2">
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
                                        <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <i class="fas fa-search me-1"></i>Buscar
                                        </button>
                                    </div>
                                    <div class="col-md-2 d-flex align-items-end">
                                        <a href="<%= request.getContextPath() %>/MovimientoProductoServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <i class="fas fa-sync-alt me-1"></i>Limpiar
                                        </a>
                                    </div>
                                </div>
                            </form>

                            <div style="width: 100%; position: relative;">
                                <table id="movementTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                    <thead class="table-light">
                                    <tr>
                                        <th style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">#</th>
                                        <th style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                            <i class="fas fa-calendar me-1"></i>Fecha
                                        </th>
                                        <th style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Producto
                                        </th>
                                        <th style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                            <i class="fas fa-exchange-alt me-1"></i>Tipo
                                        </th>
                                        <th style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                            <i class="fas fa-map-marker-alt me-1"></i>Destino
                                        </th>
                                        <th style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                            <i class="fas fa-barcode me-1"></i>Lote
                                        </th>
                                        <th style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                            <i class="fas fa-user me-1"></i>Personal Responsable
                                        </th>
                                        <th style="width: 11%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold">
                                            <i class="fas fa-comment me-1"></i>Observaciones
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<MovimientoInventarioBean> listaMovimientos =
                                                (ArrayList<MovimientoInventarioBean>) request.getAttribute("listaMovimientos");
                                        
                                        Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                        Integer sizeObj = (Integer) request.getAttribute("size");
                                        int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                        int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                        int contador = (currentPageInt - 1) * sizeInt + 1;

                                        if (listaMovimientos != null && !listaMovimientos.isEmpty()) {
                                            for (MovimientoInventarioBean movimiento : listaMovimientos) {
                                    %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td class="text-muted" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= contador++ %></td>
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
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getCodigoLote() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getResponsable() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= movimiento.getObservaciones() != null ? movimiento.getObservaciones() : "-" %></td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center py-5">
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

</body>
</html>
