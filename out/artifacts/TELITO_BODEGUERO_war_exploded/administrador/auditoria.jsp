<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.AuditoriaLog" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    ArrayList<AuditoriaLog> listaAuditoria = (ArrayList<AuditoriaLog>) request.getAttribute("listaAuditoria");
    if (listaAuditoria == null) listaAuditoria = new ArrayList<>();
    
    int totalRegistros = request.getAttribute("totalRegistros") != null ? (Integer) request.getAttribute("totalRegistros") : 0;
    int currentPage = request.getAttribute("page") != null ? (Integer) request.getAttribute("page") : 1;
    int size = request.getAttribute("size") != null ? (Integer) request.getAttribute("size") : 20;
    int totalPages = request.getAttribute("totalPages") != null ? (Integer) request.getAttribute("totalPages") : 1;
    
    String usuarioId = (String) request.getAttribute("usuarioId");
    String accion = (String) request.getAttribute("accion");
    String modulo = (String) request.getAttribute("modulo");
    String estado = (String) request.getAttribute("estado");
    String fechaDesde = (String) request.getAttribute("fechaDesde");
    String fechaHasta = (String) request.getAttribute("fechaHasta");
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Auditoría del Sistema"/>
    </jsp:include>
    <style>
        .badge-exitoso { background-color: #28a745; color: white; }
        .badge-fallido { background-color: #dc3545; color: white; }
        .badge-error { background-color: #ffc107; color: #212529; }
        .table-responsive { max-height: 600px; overflow-y: auto; }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Auditoria'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-4">
                <h2 class="pageheader-title"><i class="fas fa-clipboard-list me-2"></i>Auditoría del Sistema</h2>
                <p class="pageheader-text">Registro de acciones importantes realizadas en el sistema.</p>
            </div>

            <!-- Filtros -->
            <div class="card shadow-sm mb-4">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="fas fa-filter me-2"></i>Filtros de Búsqueda</h5>
                </div>
                <div class="card-body">
                    <form method="get" action="<%= request.getContextPath() %>/AuditoriaServlet">
                        <div class="row g-3">
                            <div class="col-md-3">
                                <label class="form-label">Usuario ID</label>
                                <input type="number" class="form-control" name="usuario_id" value="<%= usuarioId != null ? usuarioId : "" %>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Acción</label>
                                <input type="text" class="form-control" name="accion" value="<%= accion != null ? accion : "" %>" placeholder="Ej: CREAR_USUARIO">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Módulo</label>
                                <select class="form-select" name="modulo">
                                    <option value="">Todos</option>
                                    <option value="USUARIOS" <%= "USUARIOS".equals(modulo) ? "selected" : "" %>>Usuarios</option>
                                    <option value="PRODUCTOS" <%= "PRODUCTOS".equals(modulo) ? "selected" : "" %>>Productos</option>
                                    <option value="INVENTARIO" <%= "INVENTARIO".equals(modulo) ? "selected" : "" %>>Inventario</option>
                                    <option value="ALMACEN" <%= "ALMACEN".equals(modulo) ? "selected" : "" %>>Almacén</option>
                                    <option value="LOGISTICA" <%= "LOGISTICA".equals(modulo) ? "selected" : "" %>>Logística</option>
                                    <option value="SISTEMA" <%= "SISTEMA".equals(modulo) ? "selected" : "" %>>Sistema</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Estado</label>
                                <select class="form-select" name="estado">
                                    <option value="">Todos</option>
                                    <option value="EXITOSO" <%= "EXITOSO".equals(estado) ? "selected" : "" %>>Exitoso</option>
                                    <option value="FALLIDO" <%= "FALLIDO".equals(estado) ? "selected" : "" %>>Fallido</option>
                                    <option value="ERROR" <%= "ERROR".equals(estado) ? "selected" : "" %>>Error</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Fecha Desde</label>
                                <input type="date" class="form-control" name="fecha_desde" value="<%= fechaDesde != null ? fechaDesde : "" %>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Fecha Hasta</label>
                                <input type="date" class="form-control" name="fecha_hasta" value="<%= fechaHasta != null ? fechaHasta : "" %>">
                            </div>
                            <div class="col-md-6 d-flex align-items-end gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-search me-2"></i>Buscar
                                </button>
                                <a href="<%= request.getContextPath() %>/AuditoriaServlet" class="btn btn-secondary">
                                    <i class="fas fa-redo me-2"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Tabla de resultados -->
            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-list me-2"></i>Registros de Auditoría</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los registros de auditoría del sistema</small>
                                </div>
                                <span class="badge bg-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">Total: <%= totalRegistros %></span>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important;">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width: 40px; font-size: 0.85rem; padding: 0.4rem 0.5rem;">ID</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;">Usuario</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;">Acción</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;">Módulo</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;">Descripción</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;">Estado</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;">Fecha</th>
                                            <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;">IP</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (listaAuditoria.isEmpty()) { %>
                                        <tr>
                                            <td colspan="8" class="text-center py-4 text-muted" style="font-size: 0.85rem;">
                                                <i class="fas fa-inbox fa-2x mb-2 d-block" style="opacity: 0.3;"></i>
                                                No se encontraron registros de auditoría
                                            </td>
                                        </tr>
                                        <% } else { %>
                                            <% for (AuditoriaLog log : listaAuditoria) { %>
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;" class="text-muted"><%= log.getIdAuditoria() %></td>
                                                <td style="padding: 0.35rem 0.5rem;">
                                                    <strong style="font-size: 0.9rem; line-height: 1.2;"><%= log.getUsuarioNombre() %></strong><br>
                                                    <small class="text-muted" style="font-size: 0.75rem;">ID: <%= log.getUsuarioId() %></small>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;"><code><%= log.getAccion() %></code></td>
                                                <td style="padding: 0.35rem 0.5rem;">
                                                    <span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;"><%= log.getModulo() %></span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">
                                                    <%= log.getDescripcion() != null && log.getDescripcion().length() > 50 ? 
                                                        log.getDescripcion().substring(0, 50) + "..." : 
                                                        (log.getDescripcion() != null ? log.getDescripcion() : "-") %>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem;">
                                                    <% 
                                                        String estadoClass = "bg-success";
                                                        if ("FALLIDO".equals(log.getEstado())) estadoClass = "bg-warning text-dark";
                                                        else if ("ERROR".equals(log.getEstado())) estadoClass = "bg-danger";
                                                    %>
                                                    <span class="badge <%= estadoClass %> shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;"><%= log.getEstado() %></span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">
                                                    <%= log.getFechaAccion() != null ? dateFormat.format(log.getFechaAccion()) : "-" %>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem;"><small class="text-muted" style="font-size: 0.75rem;"><%= log.getIpAddress() != null ? log.getIpAddress() : "-" %></small></td>
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
                                <a class="page-link" href="?page=<%= currentPage - 1 %>&size=<%= size %>">Anterior</a>
                            </li>
                            <% } %>
                            <% for (int i = 1; i <= totalPages; i++) { %>
                                <% if (i == currentPage) { %>
                                <li class="page-item active">
                                    <span class="page-link"><%= i %></span>
                                </li>
                                <% } else { %>
                                <li class="page-item">
                                    <a class="page-link" href="?page=<%= i %>&size=<%= size %>"><%= i %></a>
                                </li>
                                <% } %>
                            <% } %>
                            <% if (currentPage < totalPages) { %>
                            <li class="page-item">
                                <a class="page-link" href="?page=<%= currentPage + 1 %>&size=<%= size %>">Siguiente</a>
                            </li>
                            <% } %>
                        </ul>
                    </nav>
                </div>
                <% } %>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

