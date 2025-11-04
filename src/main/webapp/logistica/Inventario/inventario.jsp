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
            <div class="row">
                <div class="col-12">
                    <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                        <div>
                            <h2><i class="fas fa-warehouse me-2"></i>Gestion de Inventario</h2>
                            <p class="text-muted mb-0">Administra el inventario agrupado por producto con información de stock y precios.</p>
                        </div>
                        <div class="d-flex gap-2">
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
                    <form class="row g-3" method="GET" action="${pageContext.request.contextPath}/InventarioServlet">

                        <div class="col-md-8">
                            <label for="busquedaTexto" class="form-label">Buscar por SKU / Producto</label>
                            <input type="text" class="form-control" id="busquedaTexto" name="busqueda" placeholder="Ej: SKU001, Coca Cola..." value="${param.busqueda}">
                        </div>

                        <div class="col-md-3">
                            <label for="filtroEstado" class="form-label">Estado de Stock</label>
                            <select id="filtroEstado" name="estado" class="form-select">
                                <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                <option value="En stock" ${param.estado == 'En stock' ? 'selected' : ''}>En stock</option>
                                <option value="Poco stock" ${param.estado == 'Poco stock' ? 'selected' : ''}>Poco stock</option>
                                <option value="Sin stock" ${param.estado == 'Sin stock' ? 'selected' : ''}>Sin stock</option>
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
                        <div class="card-header">
                            <h5>Tabla de Productos</h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table id="inventoryTable" class="table table-hover text-center">
                                    <thead class="bg-light">
                                    <tr>
                                        <th scope="col">SKU</th>
                                        <th scope="col">Nombre Producto</th>
                                        <th scope="col">Cantidad Disponible</th>
                                        <th scope="col">Precio por Paquete</th>
                                        <th scope="col">Costo por Unidad</th>
                                        <th scope="col">Estado</th>
                                    </tr>
                                    </thead>
                                    <tbody id="productTableBody">
                                    <%
                                        ArrayList<InventarioBean> listaInventario = (ArrayList<InventarioBean>) request.getAttribute("listaInventario");
                                        if (listaInventario != null && !listaInventario.isEmpty()) {
                                            for (InventarioBean inventario : listaInventario) {
                                    %>
                                    <tr>
                                        <td><span class="badge bg-secondary"><%= inventario.getCodigoSKU() %></span></td>
                                        <td><%= inventario.getNombreProducto() %></td>
                                        <td><%= inventario.getPaquetesDisponibles() %> paquetes</td>
                                        <td>S/. <%= String.format("%.2f", inventario.getPrecioPorPaquete()) %></td>
                                        <td>S/. <%= String.format("%.2f", inventario.getCostoPorUnidad()) %></td>
                                        <td>
                                            <% 
                                                String estadoStock = inventario.getEstadoStock();
                                                if ("Sin Stock".equals(estadoStock)) { 
                                            %>
                                                <span class="badge bg-danger">Sin Stock</span>
                                            <% } else if ("Poco Stock".equals(estadoStock)) { %>
                                                <span class="badge bg-warning text-dark">Poco Stock</span>
                                            <% } else if ("En Stock".equals(estadoStock)) { %>
                                                <span class="badge bg-success">En Stock</span>
                                            <% } else { %>
                                                <span class="badge bg-secondary">No configurado</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="6" class="text-center text-muted">
                                            <i class="fas fa-box-open fa-2x mb-2"></i><br>
                                            No hay inventario disponible para mostrar.
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                </table>
                            </div>

                            <%-- Paginación del lado del servidor --%>
                            <%
                                Integer currentPage = (Integer) request.getAttribute("currentPage");
                                Integer totalPages = (Integer) request.getAttribute("totalPages");
                                Integer totalRows = (Integer) request.getAttribute("totalRows");
                                Integer size = (Integer) request.getAttribute("size");
                                String busqueda = (String) request.getAttribute("busqueda");
                                String estadoFiltro = (String) request.getAttribute("estadoFiltro");
                                
                                if (currentPage == null) currentPage = 1;
                                if (totalPages == null) totalPages = 1;
                                if (totalRows == null) totalRows = 0;
                                if (size == null) size = 10;
                                
                                int startRow = (currentPage - 1) * size + 1;
                                int endRow = Math.min(currentPage * size, totalRows);
                            %>

                            <% if (totalPages > 1 || totalRows > 0) { %>
                            <div class="d-flex justify-content-between align-items-center mt-3 flex-wrap">
                                <div class="pagination-info mb-2 mb-sm-0">
                                    <span class="text-muted">
                                        <% if (totalRows > 0) { %>
                                            Mostrando <%= startRow %>-<%= endRow %> de <%= totalRows %> productos
                                        <% } else { %>
                                            No hay registros para mostrar
                                        <% } %>
                                    </span>
                                </div>

                                <% if (totalPages > 1) { %>
                                <nav aria-label="Paginación de inventario">
                                    <ul class="pagination pagination-sm mb-0">
                                        <%-- Botón Anterior --%>
                                        <li class="page-item <%= (currentPage <= 1) ? "disabled" : "" %>">
                                            <a class="page-link" href="<%= request.getContextPath() %>/InventarioServlet?page=<%= currentPage - 1 %>&size=<%= size %><%= (busqueda != null ? "&busqueda=" + busqueda : "") %><%= (estadoFiltro != null ? "&estado=" + estadoFiltro : "") %>" tabindex="-1">
                                                <i class="fas fa-chevron-left"></i>
                                            </a>
                                        </li>

                                        <%-- Primera página --%>
                                        <% if (currentPage > 3) { %>
                                        <li class="page-item">
                                            <a class="page-link" href="<%= request.getContextPath() %>/InventarioServlet?page=1&size=<%= size %><%= (busqueda != null ? "&busqueda=" + busqueda : "") %><%= (estadoFiltro != null ? "&estado=" + estadoFiltro : "") %>">1</a>
                                        </li>
                                        <% if (currentPage > 4) { %>
                                        <li class="page-item disabled"><span class="page-link">...</span></li>
                                        <% } %>
                                        <% } %>

                                        <%-- Páginas alrededor de la actual --%>
                                        <%
                                            int startPage = Math.max(1, currentPage - 2);
                                            int endPage = Math.min(totalPages, currentPage + 2);
                                            for (int i = startPage; i <= endPage; i++) {
                                        %>
                                        <li class="page-item <%= (i == currentPage) ? "active" : "" %>">
                                            <a class="page-link" href="<%= request.getContextPath() %>/InventarioServlet?page=<%= i %>&size=<%= size %><%= (busqueda != null ? "&busqueda=" + busqueda : "") %><%= (estadoFiltro != null ? "&estado=" + estadoFiltro : "") %>"><%= i %></a>
                                        </li>
                                        <% } %>

                                        <%-- Última página --%>
                                        <% if (currentPage < totalPages - 2) { %>
                                        <% if (currentPage < totalPages - 3) { %>
                                        <li class="page-item disabled"><span class="page-link">...</span></li>
                                        <% } %>
                                        <li class="page-item">
                                            <a class="page-link" href="<%= request.getContextPath() %>/InventarioServlet?page=<%= totalPages %>&size=<%= size %><%= (busqueda != null ? "&busqueda=" + busqueda : "") %><%= (estadoFiltro != null ? "&estado=" + estadoFiltro : "") %>"><%= totalPages %></a>
                                        </li>
                                        <% } %>

                                        <%-- Botón Siguiente --%>
                                        <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : "" %>">
                                            <a class="page-link" href="<%= request.getContextPath() %>/InventarioServlet?page=<%= currentPage + 1 %>&size=<%= size %><%= (busqueda != null ? "&busqueda=" + busqueda : "") %><%= (estadoFiltro != null ? "&estado=" + estadoFiltro : "") %>">
                                                <i class="fas fa-chevron-right"></i>
                                            </a>
                                        </li>
                                    </ul>
                                </nav>
                                <% } %>
                            </div>
                            <% } %>
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