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
        <div>
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
                                            <a href="<%= request.getContextPath() %>/AlertaServlet?action=borrar&id=<%= alerta.getIdAlertaConfig() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('¿Estás seguro de que quieres deshabilitar esta regla?')">Deshabilitar</a>
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