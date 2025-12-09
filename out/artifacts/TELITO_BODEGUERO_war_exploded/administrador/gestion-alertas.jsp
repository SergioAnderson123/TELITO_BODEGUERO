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
    <style>
        /* REGLA DE ORO: Todo debe caber en una sola pantalla sin scroll vertical ni horizontal */
        html, body {
            overflow-x: hidden !important;
            max-width: 100vw !important;
        }
        
        .dashboard-content {
            padding: 10px !important;
            overflow-y: hidden !important;
            overflow-x: hidden !important;
            max-width: 100% !important;
        }
        
        .dashboard-wrapper {
            overflow-x: hidden !important;
            max-width: 100% !important;
        }
        
        .table-responsive {
            overflow-x: auto !important;
            max-width: 100% !important;
        }
        
        /* Cards mejorados con colores que combinan con el sidebar */
        .table-card {
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }
        
        .card-header {
            background: linear-gradient(160deg, #006d77 0%, #83c5be 100%) !important;
            color: white !important;
            border-radius: 12px 12px 0 0 !important;
            padding: 15px 20px !important;
        }
        
        /* Badges mejorados con colores turquoise/seafoam */
        .badge-stock-min {
            background: linear-gradient(160deg, #83c5be 0%, #006d77 100%);
            color: white;
            font-weight: 600;
            padding: 6px 12px;
            border-radius: 20px;
        }
        
        .badge-stock-crit {
            background: linear-gradient(160deg, #e63946 0%, #d62828 100%);
            color: white;
            font-weight: 600;
            padding: 6px 12px;
            border-radius: 20px;
        }
        
        .badge-vencimiento {
            background: linear-gradient(160deg, #ffb703 0%, #fb8500 100%);
            color: white;
            font-weight: 600;
            padding: 6px 12px;
            border-radius: 20px;
        }
        
        .badge-movimiento {
            background: linear-gradient(160deg, #83c5be 0%, #006d77 100%);
            color: white;
            font-weight: 600;
            padding: 6px 12px;
            border-radius: 20px;
        }
        
        /* Botones mejorados con colores del sidebar */
        .btn-primary {
            background: linear-gradient(160deg, #006d77 0%, #83c5be 100%);
            border: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0, 109, 119, 0.4);
            background: linear-gradient(160deg, #005a63 0%, #6fb3a8 100%);
        }
        
        .btn-success {
            background: linear-gradient(160deg, #06a77d 0%, #83c5be 100%);
            border: none;
            font-weight: 600;
        }
        
        .btn-info {
            background: linear-gradient(160deg, #006d77 0%, #83c5be 100%);
            border: none;
            font-weight: 600;
        }
        
        /* Tabla mejorada */
        .table-hover tbody tr:hover {
            background: linear-gradient(90deg, rgba(0, 109, 119, 0.05) 0%, white 100%);
            transform: scale(1.01);
            transition: all 0.2s ease;
        }
        
        /* Page header */
        .page-header h2 {
            color: #006d77;
            font-weight: 800;
        }
    </style>
    
    <div class="page-header mb-3 d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h2 class="pageheader-title"><i class="fas fa-bell me-2"></i>Gestión de Alertas</h2>
            <p class="pageheader-text">Crea y administra las reglas de notificación del sistema.</p>
        </div>
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <a href="<%= request.getContextPath() %>/administrador/DashboardAlertasServlet" class="btn btn-info text-white shadow-sm">
                <i class="fas fa-chart-line me-2"></i>Dashboard
            </a>
            <a href="<%= request.getContextPath() %>/AlertaReporteServlet?action=exportar" class="btn btn-success shadow-sm">
                <i class="fas fa-file-excel me-2"></i>Exportar
            </a>
            <a href="<%= request.getContextPath() %>/AlertaReporteServlet?action=formEnviar" class="btn btn-secondary shadow-sm">
                <i class="fas fa-envelope me-2"></i>Enviar Email
            </a>
            <a href="<%= request.getContextPath() %>/AlertaServlet?action=formCrear" class="btn btn-primary shadow-sm">
                <i class="fas fa-plus me-2"></i>Nueva Regla
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="table-card shadow-sm">
                <div class="card-header" style="padding: 0.5rem 0.75rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-bell me-2"></i>Reglas de Alerta</h5>
                            <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todas las reglas de notificación</small>
                        </div>
                    </div>
                </div>
                <div class="card-body" style="padding: 0.75rem;">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important;">
                            <thead class="table-light">
                            <tr>
                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-tag me-1"></i>Nombre de la Regla</th>
                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-filter me-1"></i>Tipo</th>
                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-code me-1"></i>Condición</th>
                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-user-tag me-1"></i>Rol a Notificar</th>
                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-toggle-on me-1"></i>Estado</th>
                                <th class="text-end" style="width: 150px; font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-cog me-1"></i>Acciones</th>
                            </tr>
                            </thead>
                            <tbody>
                            <% if (listaAlertas != null && !listaAlertas.isEmpty()) { %>
                                <% for (AlertaConfig alerta : listaAlertas) { %>
                                <tr class="align-middle" style="padding: 0;">
                                    <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;" class="fw-semibold"><%= alerta.getNombre() %></td>
                                    <td style="padding: 0.35rem 0.5rem;">
                                        <% String tipoAlerta = alerta.getTipoAlerta(); %>
                                        <% if ("STOCK_MINIMO_LOTE".equals(tipoAlerta) || "STOCK_MINIMO".equals(tipoAlerta)) { %>
                                            <span class="badge-stock-min"><i class="fas fa-box me-1"></i>Stock Mín. Lote</span>
                                        <% } else if ("STOCK_CRITICO_LOTE".equals(tipoAlerta) || "STOCK_CRITICO".equals(tipoAlerta)) { %>
                                            <span class="badge-stock-crit"><i class="fas fa-exclamation-circle me-1"></i>Stock Crít. Lote</span>
                                        <% } else if ("STOCK_MINIMO_TOTAL".equals(tipoAlerta)) { %>
                                            <span class="badge-stock-min"><i class="fas fa-chart-line me-1"></i>Stock Mín. Total</span>
                                        <% } else if ("STOCK_CRITICO_TOTAL".equals(tipoAlerta)) { %>
                                            <span class="badge-stock-crit"><i class="fas fa-chart-line me-1"></i>Stock Crít. Total</span>
                                        <% } else if ("VENCIMIENTO".equals(tipoAlerta)) { %>
                                            <span class="badge-vencimiento"><i class="fas fa-clock me-1"></i>Vencimiento</span>
                                        <% } else if ("MOVIMIENTO".equals(tipoAlerta)) { %>
                                            <span class="badge-movimiento"><i class="fas fa-exchange-alt me-1"></i>Movimiento</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;"><%= tipoAlerta %></span>
                                        <% } %>
                                    </td>
                                    <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">
                                        <% if ("VENCIMIENTO".equals(tipoAlerta) && alerta.getUmbralDias() != null) { %>
                                            Vence en <strong><%= alerta.getUmbralDias() %></strong> días
                                        <% } else if (tipoAlerta.startsWith("STOCK_")) { %>
                                            <span class="text-muted">Según configuración</span>
                                        <% } else { %>
                                            --
                                        <% } %>
                                        <% if (alerta.getCategoria() != null) { %>
                                            <br><small class="text-muted" style="font-size: 0.75rem;">📁 Categoría: <%= alerta.getCategoria().getNombre() %></small>
                                        <% } %>
                                    </td>
                                    <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;"><%= alerta.getRolANotificar().getNombre() %></td>
                                    <td style="padding: 0.35rem 0.5rem;">
                                        <% if (alerta.isActivo()) { %>
                                            <span class="badge bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">Activa</span>
                                        <% } else { %>
                                            <span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">Inactiva</span>
                                        <% } %>
                                    </td>
                                    <td class="text-end" style="padding: 0.35rem 0.5rem;">
                                        <div class="dropdown">
                                            <button class="btn btn-sm btn-outline-secondary shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;">
                                                <i class="fas fa-ellipsis-v"></i>
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-end">
                                                <li><a class="dropdown-item" href="<%= request.getContextPath() %>/AlertaServlet?action=editar&id=<%= alerta.getIdAlertaConfig() %>"><i class="fas fa-edit me-2"></i>Editar</a></li>
                                                <% if (alerta.isActivo()) { %>
                                                <li><hr class="dropdown-divider"></li>
                                                <li><a class="dropdown-item text-danger" href="#" onclick="showConfirm('¿Estás seguro de que quieres deshabilitar esta regla?', function() { window.location.href='<%= request.getContextPath() %>/AlertaServlet?action=borrar&id=<%= alerta.getIdAlertaConfig() %>'; }, 'Confirmar acción'); return false;"><i class="fas fa-ban me-2"></i>Deshabilitar</a></li>
                                                <% } %>
                                            </ul>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            <% } else { %>
                                <tr>
                                    <td colspan="6" class="text-center py-5" style="font-size: 0.85rem;">
                                        <div class="text-muted">
                                            <i class="fas fa-bell-slash fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                            <p class="mb-0">No hay reglas de alerta configuradas</p>
                                            <small>¡Crea la primera regla de alerta!</small>
                                        </div>
                                    </td>
                                </tr>
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
    Integer totalRows = (Integer) request.getAttribute("totalRows");
    Integer size = (Integer) request.getAttribute("size");
    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (size == null) size = 6;
    if (totalRows == null) totalRows = 0;
    
    // Calcular rango de registros mostrados
    int startRow = totalRows > 0 ? (currentPage - 1) * size + 1 : 0;
    int endRow = Math.min(currentPage * size, totalRows);
    
    String baseUrl = request.getContextPath() + "/AlertaServlet?action=listar";
    request.setAttribute("baseUrl", baseUrl);
    request.setAttribute("currentPage", currentPage);
    request.setAttribute("totalPages", totalPages);
    request.setAttribute("totalRows", totalRows);
    request.setAttribute("size", size);
    request.setAttribute("itemName", "reglas");
%>
<jsp:include page="/WEB-INF/includes/pagination.jsp" />

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