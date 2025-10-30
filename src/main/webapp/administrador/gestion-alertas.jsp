<%@ page import="com.example.telito.administrador.beans.AlertaConfig" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Mensajes de éxito o error --%>
<% if (session.getAttribute("successMsg") != null) { %>
<div class="alert alert-success" role="alert">
    <%= session.getAttribute("successMsg") %>
    <% session.removeAttribute("successMsg"); %>
</div>
<% } %>
<% if (session.getAttribute("errorMsg") != null) { %>
<div class="alert alert-danger" role="alert">
    <%= session.getAttribute("errorMsg") %>
    <% session.removeAttribute("errorMsg"); %>
</div>
<% } %>

<% ArrayList<AlertaConfig> listaAlertas = (ArrayList<AlertaConfig>) request.getAttribute("listaAlertas"); %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Alertas"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Configuracion"/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
    <div class="page-header mb-4 d-flex justify-content-between align-items-center">
        <div>
            <h2 class="pageheader-title" style="font-weight: 700;">Configuración de Alertas</h2>
            <p class="pageheader-text">Crea y administra las reglas de notificación del sistema.</p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <form method="get" action="<%= request.getContextPath() %>/AlertaServlet" class="d-flex align-items-center me-2">
                <input type="hidden" name="action" value="listar">
                <input type="hidden" name="page" value="1">
                <label class="me-2 text-muted small">Mostrar</label>
                <select name="size" class="form-select form-select-sm" onchange="this.form.submit()">
                    <option value="10" <%= (request.getAttribute("size")!=null && (Integer)request.getAttribute("size")==10) ? "selected" : "" %>>10</option>
                    <option value="25" <%= (request.getAttribute("size")!=null && (Integer)request.getAttribute("size")==25) ? "selected" : "" %>>25</option>
                    <option value="50" <%= (request.getAttribute("size")!=null && (Integer)request.getAttribute("size")==50) ? "selected" : "" %>>50</option>
                </select>
            </form>
            <a href="<%= request.getContextPath() %>/AlertaServlet?action=formCrear" class="btn btn-primary"><i class="fas fa-plus"></i> Crear Nueva Regla</a>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="table-card">
                <div class="card-header">
                    <h5 class="mb-0 fw-semibold">Reglas de Alerta</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead>
                            <tr>
                                <th>Nombre de la Regla</th>
                                <th>Tipo</th>
                                <th>Condición</th>
                                <th>Rol a Notificar</th>
                                <th>Estado</th>
                                <th class="text-end">Acciones</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (listaAlertas != null && !listaAlertas.isEmpty()) { %>
                                <% for (AlertaConfig alerta : listaAlertas) { %>
                                <tr>
                                    <td class="fw-medium"><%= alerta.getNombre() %></td>
                                    <td>
                                        <% String tipoAlerta = alerta.getTipoAlerta(); %>
                                        <% if ("STOCK_MINIMO_LOTE".equals(tipoAlerta)) { %>
                                            <span class="badge bg-warning text-dark">📦 Stock Mín. Lote</span>
                                        <% } else if ("STOCK_CRITICO_LOTE".equals(tipoAlerta)) { %>
                                            <span class="badge bg-danger">📦 Stock Crít. Lote</span>
                                        <% } else if ("STOCK_MINIMO_TOTAL".equals(tipoAlerta)) { %>
                                            <span class="badge bg-info text-dark">📊 Stock Mín. Total</span>
                                        <% } else if ("STOCK_CRITICO_TOTAL".equals(tipoAlerta)) { %>
                                            <span class="badge bg-danger">📊 Stock Crít. Total</span>
                                        <% } else if ("VENCIMIENTO".equals(tipoAlerta)) { %>
                                            <span class="badge bg-warning text-dark">⏰ Vencimiento</span>
                                        <% } else if ("MOVIMIENTO".equals(tipoAlerta)) { %>
                                            <span class="badge bg-secondary">🔄 Movimiento</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary"><%= tipoAlerta %></span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if ("VENCIMIENTO".equals(tipoAlerta) && alerta.getUmbralDias() != null) { %>
                                            Vence en <strong><%= alerta.getUmbralDias() %></strong> días
                                        <% } else if (tipoAlerta.startsWith("STOCK_")) { %>
                                            <span class="text-muted">Según configuración</span>
                                        <% } else { %>
                                            --
                                        <% } %>
                                        <% if (alerta.getCategoria() != null) { %>
                                            <br><small class="text-muted">📁 Categoría: <%= alerta.getCategoria().getNombre() %></small>
                                        <% } %>
                                    </td>
                                    <td><%= alerta.getRolANotificar().getNombre() %></td>
                                    <td>
                                        <% if (alerta.isActivo()) { %>
                                            <span class="badge bg-success-soft text-success">Activa</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary-soft text-secondary">Inactiva</span>
                                        <% } %>
                                    </td>
                                    <td class="text-end">
                                        <a href="<%= request.getContextPath() %>/AlertaServlet?action=editar&id=<%= alerta.getIdAlertaConfig() %>" class="btn btn-sm btn-outline-primary">Editar</a>
                                        <% if (alerta.isActivo()) { %>
                                            <a href="#" class="btn btn-sm btn-outline-danger" onclick="showConfirm('¿Estás seguro de que quieres deshabilitar esta regla?', function() { window.location.href='<%= request.getContextPath() %>/AlertaServlet?action=borrar&id=<%= alerta.getIdAlertaConfig() %>'; }, 'Confirmar acción'); return false;">Deshabilitar</a>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            <% } else { %>
                                <tr><td colspan="6" class="text-center py-4">No hay reglas de alerta configuradas. ¡Crea la primera!</td></tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<%
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer size = (Integer) request.getAttribute("size");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (size == null) size = 10;
    String base = request.getContextPath() + "/AlertaServlet?action=listar";
%>
<nav aria-label="Paginación de alertas" class="d-flex justify-content-between align-items-center mt-3 px-4">
    <div class="text-muted small">Página <%= currentPage %> de <%= totalPages %></div>
    <ul class="pagination mb-0">
        <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
            <a class="page-link" href="<%= base %>&page=<%= currentPage - 1 %>&size=<%= size %>">Anterior</a>
        </li>
        <% for (int p = 1; p <= totalPages; p++) { %>
        <li class="page-item <%= p == currentPage ? "active" : "" %>"><a class="page-link" href="<%= base %>&page=<%= p %>&size=<%= size %>"><%= p %></a></li>
        <% } %>
        <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
            <a class="page-link" href="<%= base %>&page=<%= currentPage + 1 %>&size=<%= size %>">Siguiente</a>
        </li>
    </ul>
</nav>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const sidebar = document.getElementById('sidebar');
        const content = document.getElementById('content');
        const header = document.getElementById('header');
        const sidebarToggle = document.getElementById('sidebar-toggle');
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => {
                sidebar.classList.toggle('hidden');
                content.classList.toggle('full-width');
                header.classList.toggle('full-width');
            });
        }
    });
</script>
</body>
</html>