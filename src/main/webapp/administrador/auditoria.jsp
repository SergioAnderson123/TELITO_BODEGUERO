<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.AuditoriaLog" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    ArrayList<AuditoriaLog> listaAuditoria = (ArrayList<AuditoriaLog>) request.getAttribute("listaAuditoria");
    if (listaAuditoria == null) listaAuditoria = new ArrayList<>();
    
    int totalRegistros = request.getAttribute("totalRegistros") != null ? (Integer) request.getAttribute("totalRegistros") : 0;
    int currentPage = request.getAttribute("currentPage") != null ? (Integer) request.getAttribute("currentPage") : 
                      (request.getAttribute("page") != null ? (Integer) request.getAttribute("page") : 1);
    int size = request.getAttribute("size") != null ? (Integer) request.getAttribute("size") : 5;
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
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Auditoria'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-clipboard-list me-2"></i>Auditoría del Sistema</h2>
                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Registro de acciones importantes realizadas en el sistema.</p>
            </div>

            <%
                // Obtener estadísticas del servlet
                Integer totalRegistrosAuditoriaAttr = (Integer) request.getAttribute("totalRegistrosAuditoria");
                Integer accionesHoyAttr = (Integer) request.getAttribute("accionesHoy");
                Integer accionesFallidasAttr = (Integer) request.getAttribute("accionesFallidas");
                int totalRegistrosAuditoria = (totalRegistrosAuditoriaAttr != null) ? totalRegistrosAuditoriaAttr : 0;
                int accionesHoy = (accionesHoyAttr != null) ? accionesHoyAttr : 0;
                int accionesFallidas = (accionesFallidasAttr != null) ? accionesFallidasAttr : 0;
            %>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="stats-container">
                <div class="stat-card">
                    <h3>Total de Registros</h3>
                    <p><%= totalRegistrosAuditoria %></p>
                </div>
                <div class="stat-card">
                    <h3>Acciones Hoy</h3>
                    <p><%= accionesHoy %></p>
                </div>
                <div class="stat-card">
                    <h3>Acciones Fallidas (Hoy)</h3>
                    <p><%= accionesFallidas %></p>
                </div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros ===================== -->
            <div class="card shadow-sm mb-4" id="filterCard">
                <div class="card-header bg-primary text-white" style="padding: 0.5rem 0.75rem;">
                    <h5 class="mb-0" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-filter me-2"></i>Filtros de Búsqueda</h5>
                </div>
                <div class="card-body" style="padding: 0.75rem;">
                    <form method="get" action="<%= request.getContextPath() %>/AuditoriaServlet" id="filterForm">
                        <input type="hidden" name="size" value="<%= size %>">
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
                                <select class="form-select" name="modulo" id="moduloFilter">
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
                                <select class="form-select" name="estado" id="estadoFilter">
                                    <option value="">Todos</option>
                                    <option value="EXITOSO" <%= "EXITOSO".equals(estado) ? "selected" : "" %>>Exitoso</option>
                                    <option value="FALLIDO" <%= "FALLIDO".equals(estado) ? "selected" : "" %>>Fallido</option>
                                    <option value="ERROR" <%= "ERROR".equals(estado) ? "selected" : "" %>>Error</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Fecha Desde</label>
                                <input type="date" class="form-control" name="fecha_desde" id="fechaDesdeFilter" value="<%= fechaDesde != null ? fechaDesde : "" %>">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Fecha Hasta</label>
                                <input type="date" class="form-control" name="fecha_hasta" id="fechaHastaFilter" value="<%= fechaHasta != null ? fechaHasta : "" %>">
                            </div>
                            <div class="col-md-6 d-flex align-items-end gap-2">
                                <a href="<%= request.getContextPath() %>/AuditoriaServlet" class="btn btn-outline-secondary">
                                    <i class="fas fa-sync-alt me-2"></i>Limpiar
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
                        <%-- Incluir componente de paginación --%>
                        <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                    </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script>
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const filterForm = document.getElementById('filterForm');
        const moduloFilter = document.getElementById('moduloFilter');
        const estadoFilter = document.getElementById('estadoFilter');
        const fechaDesdeFilter = document.getElementById('fechaDesdeFilter');
        const fechaHastaFilter = document.getElementById('fechaHastaFilter');
        
        // Aplicar filtros cuando cambien los selects
        if (moduloFilter && filterForm) {
            moduloFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (estadoFilter && filterForm) {
            estadoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        // Aplicar filtros cuando cambien las fechas
        if (fechaDesdeFilter && filterForm) {
            fechaDesdeFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (fechaHastaFilter && filterForm) {
            fechaHastaFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
    });
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

