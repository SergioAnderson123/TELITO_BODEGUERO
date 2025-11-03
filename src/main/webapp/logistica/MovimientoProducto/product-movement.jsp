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
            <div class="row">
                <div class="col-12">
                    <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                        <div>
                            <h2><i class="fas fa-exchange-alt me-2"></i>Movimiento de Producto</h2>
                            <p class="text-muted mb-0">Trazabilidad y auditoría de movimientos de inventario.</p>
                        </div>
                        <div class="d-flex gap-2">
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
                            <a href="<%= urlBase %>" class="btn btn-sm btn-success">
                                <i class="fas fa-file-excel me-2"></i>Exportar a Excel
                            </a>
                            <a href="<%= urlEnviar %>" class="btn btn-sm btn-info text-white">
                                <i class="fas fa-envelope me-2"></i>Enviar por Correo
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Mensajes de alerta -->
            <c:if test="${not empty sessionScope.mensaje}">
                <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert">
                    ${sessionScope.mensaje}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="mensaje" scope="session"/>
                <c:remove var="tipoMensaje" scope="session"/>
            </c:if>

            <div class="card mb-4">
                <div class="card-body">
                    <form class="row g-3" method="GET" action="${pageContext.request.contextPath}/MovimientoProductoServlet">

                        <div class="col-md-5">
                            <label for="busquedaTexto" class="form-label">Buscar por Producto / Lote</label>
                            <input type="text" class="form-control" id="busquedaTexto" name="busqueda" placeholder="Ej: Coca Cola, L001..." value="${param.busqueda}">
                        </div>

                        <div class="col-md-3">
                            <label for="filtroTipo" class="form-label">Tipo de Movimiento</label>
                            <select id="filtroTipo" name="tipo" class="form-select">
                                <option value="" ${param.tipo == '' ? 'selected' : ''}>Todos</option>
                                <option value="Entrada" ${param.tipo == 'Entrada' ? 'selected' : ''}>Entrada</option>
                                <option value="Salida" ${param.tipo == 'Salida' ? 'selected' : ''}>Salida</option>
                                <option value="Ajuste" ${param.tipo == 'Ajuste' ? 'selected' : ''}>Ajuste</option>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label for="filtroFecha" class="form-label">Periodo</label>
                            <select id="filtroFecha" name="periodo" class="form-select">
                                <option value="" ${param.periodo == '' ? 'selected' : ''}>Todos</option>
                                <option value="7" ${param.periodo == '7' ? 'selected' : ''}>Últimos 7 días</option>
                                <option value="30" ${param.periodo == '30' ? 'selected' : ''}>Últimos 30 días</option>
                                <option value="90" ${param.periodo == '90' ? 'selected' : ''}>Últimos 90 días</option>
                            </select>
                        </div>

                        <div class="col-md-1 d-flex align-items-end">
                            <button type="submit" class="btn btn-primary w-100">Buscar</button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="table-responsive">
                                <table id="movementTable" class="table table-hover text-center">
                                    <thead>
                                    <tr>
                                        <th onclick="sortTable(0)" style="cursor:pointer">Fecha</th>
                                        <th onclick="sortTable(1)" style="cursor:pointer">Producto</th>
                                        <th onclick="sortTable(2)" style="cursor:pointer">Tipo</th>
                                        <th onclick="sortTable(3)" style="cursor:pointer">Destino</th>
                                        <th onclick="sortTable(4)" style="cursor:pointer">Lote</th>
                                        <th onclick="sortTable(5)" style="cursor:pointer">Personal Responsable</th>
                                        <th onclick="sortTable(6)" style="cursor:pointer">Observaciones</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<MovimientoInventarioBean> listaMovimientos =
                                                (ArrayList<MovimientoInventarioBean>) request.getAttribute("listaMovimientos");

                                        if (listaMovimientos != null && !listaMovimientos.isEmpty()) {
                                            for (MovimientoInventarioBean movimiento : listaMovimientos) {
                                    %>
                                    <tr>
                                        <td><%= movimiento.getFechaFormateada() %></td>
                                        <td><%= movimiento.getNombreProducto() %></td>
                                        <td>
                                            <% if ("Entrada".equalsIgnoreCase(movimiento.getTipo())) { %>
                                            <span class="badge bg-success"><%= movimiento.getTipo() %></span>
                                            <% } else if ("Salida".equalsIgnoreCase(movimiento.getTipo())) { %>
                                            <span class="badge bg-danger"><%= movimiento.getTipo() %></span>
                                            <% } else { %>
                                            <span class="badge bg-warning text-dark"><%= movimiento.getTipo() %></span>
                                            <% } %>
                                        </td>
                                        <td><%= movimiento.getDestino() %></td>
                                        <td><%= movimiento.getCodigoLote() %></td>
                                        <td><%= movimiento.getResponsable() %></td>
                                        <td><%= movimiento.getObservaciones() %></td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="7" class="text-center text-muted">
                                            <i class="fas fa-inbox fa-2x mb-2"></i><br>
                                            No hay movimientos disponibles para mostrar.
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                </table>
                            </div>

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
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>