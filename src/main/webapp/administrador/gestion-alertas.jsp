<%@ page import="com.example.telito.administrador.beans.AlertaConfig" %>
<%@ page import="java.util.ArrayList" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% ArrayList<AlertaConfig> listaAlertas = (ArrayList<AlertaConfig>) request.getAttribute("listaAlertas"); %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Alertas"/>
    </jsp:include>
    <style>
        /* Estilos mejorados para el dropdown de acciones */
        .dropdown-menu {
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            border: 1px solid rgba(0, 0, 0, 0.08) !important;
            border-radius: 8px !important;
            min-width: 180px !important;
            font-size: 0.9rem !important;
            padding: 0.5rem 0 !important;
            animation: fadeInDown 0.2s ease-out;
        }
        
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .dropdown-item {
            border-radius: 4px;
            margin: 2px 8px;
            padding: 0.5rem 0.75rem !important;
            transition: all 0.2s ease;
        }
        
        .dropdown-item i {
            width: 20px;
            text-align: center;
        }
        
        .dropdown-item:hover {
            transform: translateX(3px);
            background-color: #f8f9fa;
        }
        
        .dropdown-item.text-primary:hover {
            background-color: #e3f2fd;
            color: #1976d2 !important;
        }
        
        .dropdown-item.text-danger:hover {
            background-color: #ffebee;
            color: #dc3545 !important;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Configuracion"/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
    <div class="page-header mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
        <div>
            <h2 class="pageheader-title"><i class="fas fa-bell me-2"></i>Configuración de Alertas</h2>
            <p class="pageheader-text">Crea y administra las reglas de notificación del sistema.</p>
        </div>
        <div class="d-flex align-items-center gap-2 flex-wrap">
            <a href="<%= request.getContextPath() %>/AlertaReporteServlet?action=exportar" class="btn btn-success shadow-sm">
                <i class="fas fa-file-excel me-2"></i>Exportar a Excel
            </a>
            <a href="<%= request.getContextPath() %>/AlertaReporteServlet?action=formEnviar" class="btn btn-info text-white shadow-sm">
                <i class="fas fa-envelope me-2"></i>Enviar por Correo
            </a>
            <a href="<%= request.getContextPath() %>/AlertaServlet?action=formCrear" class="btn btn-primary shadow-sm">
                <i class="fas fa-plus me-2"></i>Crear Nueva Regla
            </a>
        </div>
    </div>

    <!-- Mensajes de éxito o error -->
    <% if (session.getAttribute("successMsg") != null) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fas fa-check-circle me-2"></i><%= session.getAttribute("successMsg") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        <% session.removeAttribute("successMsg"); %>
    </div>
    <% } %>
    <% if (session.getAttribute("errorMsg") != null) { %>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i><%= session.getAttribute("errorMsg") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        <% session.removeAttribute("errorMsg"); %>
    </div>
    <% } %>

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
                        <table id="alertaTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%;">
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
                                        <% if ("STOCK_MINIMO_LOTE".equals(tipoAlerta)) { %>
                                            <span class="badge shadow-sm" style="background-color: #fff9c4; color: #f57f17; font-size: 0.8rem; padding: 0.3rem 0.6rem;"><i class="fas fa-box me-1"></i>Stock Mín. Lote</span>
                                        <% } else if ("STOCK_CRITICO_LOTE".equals(tipoAlerta)) { %>
                                            <span class="badge shadow-sm" style="background-color: #ffcdd2; color: #c62828; font-size: 0.8rem; padding: 0.3rem 0.6rem;"><i class="fas fa-box me-1"></i>Stock Crít. Lote</span>
                                        <% } else if ("STOCK_MINIMO_TOTAL".equals(tipoAlerta)) { %>
                                            <span class="badge shadow-sm" style="background-color: #b3e5fc; color: #01579b; font-size: 0.8rem; padding: 0.3rem 0.6rem;"><i class="fas fa-chart-bar me-1"></i>Stock Mín. Total</span>
                                        <% } else if ("STOCK_CRITICO_TOTAL".equals(tipoAlerta)) { %>
                                            <span class="badge shadow-sm" style="background-color: #ffcdd2; color: #c62828; font-size: 0.8rem; padding: 0.3rem 0.6rem;"><i class="fas fa-chart-bar me-1"></i>Stock Crít. Total</span>
                                        <% } else if ("VENCIMIENTO".equals(tipoAlerta)) { %>
                                            <span class="badge shadow-sm" style="background-color: #fff9c4; color: #f57f17; font-size: 0.8rem; padding: 0.3rem 0.6rem;"><i class="fas fa-clock me-1"></i>Vencimiento</span>
                                        <% } else if ("MOVIMIENTO".equals(tipoAlerta)) { %>
                                            <span class="badge shadow-sm" style="background-color: #e0e0e0; color: #424242; font-size: 0.8rem; padding: 0.3rem 0.6rem;"><i class="fas fa-exchange-alt me-1"></i>Movimiento</span>
                                        <% } else { %>
                                            <span class="badge shadow-sm" style="background-color: #e0e0e0; color: #424242; font-size: 0.8rem; padding: 0.3rem 0.6rem;"><%= tipoAlerta %></span>
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
                                            <br><small class="text-muted" style="font-size: 0.75rem;"><i class="fas fa-folder me-1"></i>Categoría: <%= alerta.getCategoria().getNombre() %></small>
                                        <% } %>
                                    </td>
                                    <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;"><%= alerta.getRolANotificar().getNombre() %></td>
                                    <td style="padding: 0.35rem 0.5rem;">
                                        <% if (alerta.isActivo()) { %>
                                            <span class="badge shadow-sm" style="background-color: #c8e6c9; color: #2e7d32; font-size: 0.8rem; padding: 0.3rem 0.6rem;">Activa</span>
                                        <% } else { %>
                                            <span class="badge shadow-sm" style="background-color: #e0e0e0; color: #424242; font-size: 0.8rem; padding: 0.3rem 0.6rem;">Inactiva</span>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script>
    // Inicializar DataTables
    $(document).ready(function() {
        $('#alertaTable').DataTable({
            language: {
                url: 'https://cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json',
                search: "Buscar:",
                lengthMenu: "Mostrar _MENU_ registros",
                info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
                infoEmpty: "Mostrando 0 a 0 de 0 registros",
                infoFiltered: "(filtrado de _MAX_ registros totales)",
                paginate: {
                    first: "Primero",
                    last: "Último",
                    next: "Siguiente",
                    previous: "Anterior"
                }
            },
            pageLength: 10,
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "Todos"]],
            order: [[0, 'asc']],
            responsive: true,
            dom: '<"row"<"col-sm-12 col-md-6"l><"col-sm-12 col-md-6"f>>rt<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>'
        });
    });
</script>
</body>
</html>