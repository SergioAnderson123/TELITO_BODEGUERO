<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.almacen.beans.Incidencia" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

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
                <div class="row">
                    <div class="col-12">
                        <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                            <div>
                                <h2><i class="fas fa-exclamation-triangle me-2"></i>Incidencias de Inventario</h2>
                                <p class="text-muted mb-0">Reporta y gestiona faltantes y sobrantes de inventario.</p>
                            </div>
                            <% if (!esAdministrador) { %>
                            <a href="<%= request.getContextPath() %>/almacen/LoteServlet" class="btn btn-primary">
                                <i class="fas fa-plus me-2"></i>Reportar desde Inventario
                            </a>
                            <% } %>
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

                <!-- Filtros -->
                <div class="card shadow-sm mb-4">
                    <div class="card-body">
                        <form method="get" action="<%= request.getContextPath() %>/almacen/IncidenciaServlet">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label">Estado</label>
                                    <select class="form-select" name="estado">
                                        <option value="">Todos</option>
                                        <option value="Pendiente" <%= "Pendiente".equals(estado) ? "selected" : "" %>>Pendiente</option>
                                        <option value="En Revisión" <%= "En Revisión".equals(estado) ? "selected" : "" %>>En Revisión</option>
                                        <option value="Resuelta" <%= "Resuelta".equals(estado) ? "selected" : "" %>>Resuelta</option>
                                        <option value="Cerrada" <%= "Cerrada".equals(estado) ? "selected" : "" %>>Cerrada</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Tipo</label>
                                    <select class="form-select" name="tipo">
                                        <option value="">Todos</option>
                                        <option value="Faltante" <%= "Faltante".equals(tipo) ? "selected" : "" %>>Faltante</option>
                                        <option value="Sobrante" <%= "Sobrante".equals(tipo) ? "selected" : "" %>>Sobrante</option>
                                    </select>
                                </div>
                                <div class="col-md-4 d-flex align-items-end gap-2">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-search me-2"></i>Filtrar
                                    </button>
                                    <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet" class="btn btn-secondary">
                                        <i class="fas fa-redo me-2"></i>Limpiar
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Tabla de incidencias -->
                <div class="card shadow-sm">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="fas fa-list me-2"></i>Lista de Incidencias</h5>
                        <span class="badge bg-primary">Total: <%= totalRegistros %></span>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover table-striped mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>ID</th>
                                        <th>Tipo</th>
                                        <th>Producto</th>
                                        <th>Código Lote</th>
                                        <th>Cant. Sistema</th>
                                        <th>Cant. Reportada</th>
                                        <th>Diferencia</th>
                                        <th>Estado</th>
                                        <th>Reportado por</th>
                                        <th>Fecha</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (incidencias.isEmpty()) { %>
                                    <tr>
                                        <td colspan="11" class="text-center py-4 text-muted">
                                            <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                                            No se encontraron incidencias
                                        </td>
                                    </tr>
                                    <% } else { %>
                                        <% for (Incidencia inc : incidencias) { %>
                                        <tr>
                                            <td><%= inc.getIdIncidencia() %></td>
                                            <td>
                                                <span class="badge <%= "Faltante".equals(inc.getTipoIncidencia()) ? "bg-danger" : "bg-warning" %>">
                                                    <%= inc.getTipoIncidencia() %>
                                                </span>
                                            </td>
                                            <td><%= inc.getNombreProducto() %></td>
                                            <td><code><%= inc.getCodigoLote() %></code></td>
                                            <td><%= inc.getCantidadSistema() %></td>
                                            <td><%= inc.getCantidadReportada() %></td>
                                            <td>
                                                <span class="<%= inc.getDiferencia() < 0 ? "text-danger" : "text-success" %> fw-bold">
                                                    <%= inc.getDiferencia() > 0 ? "+" : "" %><%= inc.getDiferencia() %>
                                                </span>
                                            </td>
                                            <td>
                                                <% 
                                                    String estadoClass = "bg-secondary";
                                                    if ("Pendiente".equals(inc.getEstado())) estadoClass = "bg-warning";
                                                    else if ("Resuelta".equals(inc.getEstado())) estadoClass = "bg-success";
                                                    else if ("Cerrada".equals(inc.getEstado())) estadoClass = "bg-dark";
                                                %>
                                                <span class="badge <%= estadoClass %>"><%= inc.getEstado() %></span>
                                            </td>
                                            <td><%= inc.getNombreUsuarioReporte() %></td>
                                            <td><%= inc.getFechaReporte() != null ? dateFormat.format(inc.getFechaReporte()) : "-" %></td>
                                            <td>
                                                <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=ver&id=<%= inc.getIdIncidencia() %>" 
                                                   class="btn btn-sm btn-info text-white" title="Ver detalles">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <% if (esAdministrador && "Pendiente".equals(inc.getEstado())) { %>
                                                <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=formResolver&id=<%= inc.getIdIncidencia() %>" 
                                                   class="btn btn-sm btn-success" title="Resolver">
                                                    <i class="fas fa-check"></i>
                                                </a>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% } %>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <% if (totalPages > 1) { %>
                    <div class="card-footer">
                        <nav aria-label="Paginación">
                            <ul class="pagination justify-content-center mb-0">
                                <% if (currentPage > 1) { %>
                                <li class="page-item">
                                    <a class="page-link" href="?page=<%= currentPage - 1 %>&estado=<%= estado != null ? estado : "" %>&tipo=<%= tipo != null ? tipo : "" %>">Anterior</a>
                                </li>
                                <% } %>
                                <% for (int i = 1; i <= totalPages; i++) { %>
                                    <% if (i == currentPage) { %>
                                    <li class="page-item active">
                                        <span class="page-link"><%= i %></span>
                                    </li>
                                    <% } else { %>
                                    <li class="page-item">
                                        <a class="page-link" href="?page=<%= i %>&estado=<%= estado != null ? estado : "" %>&tipo=<%= tipo != null ? tipo : "" %>"><%= i %></a>
                                    </li>
                                    <% } %>
                                <% } %>
                                <% if (currentPage < totalPages) { %>
                                <li class="page-item">
                                    <a class="page-link" href="?page=<%= currentPage + 1 %>&estado=<%= estado != null ? estado : "" %>&tipo=<%= tipo != null ? tipo : "" %>">Siguiente</a>
                                </li>
                                <% } %>
                            </ul>
                        </nav>
                    </div>
                    <% } %>
                </div>
            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

