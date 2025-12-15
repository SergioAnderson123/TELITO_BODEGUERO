<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.almacen.beans.PlanTransporte" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    ArrayList<PlanTransporte> planes = (ArrayList<PlanTransporte>) request.getAttribute("planes");
    if (planes == null) {
        planes = new ArrayList<>();
    }
    int currentPage = (Integer) request.getAttribute("currentPage");
    int totalPages = (Integer) request.getAttribute("totalPages");
    int totalRows = (Integer) request.getAttribute("totalRows");
    Integer sizeAttr = (Integer) request.getAttribute("size");
    int size = (sizeAttr != null) ? sizeAttr : 10;
    String estadoFiltro = (String) request.getAttribute("estadoFiltro");
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (successMsg != null) {
        session.removeAttribute("successMsg");
    }
    if (errorMsg != null) {
        session.removeAttribute("errorMsg");
    }
    Usuario usuario = (Usuario) session.getAttribute("usuario");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/gerente-tienda/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Recepciones Pendientes"/>
    </jsp:include>
    <style>
        .table-responsive {
            border-radius: 12px;
            overflow: hidden;
        }
        .badge-estado {
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.85rem;
        }
        .badge-en-ruta {
            background-color: #ffc107;
            color: #000;
        }
        .badge-salida {
            background-color: #17a2b8;
            color: white;
        }
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
        
        /* Estilos para encabezados de tabla con hover verde y ordenamiento */
        #recepcionesTable thead th {
            position: relative;
            user-select: none;
            color: var(--text-muted) !important;
            text-transform: uppercase;
            cursor: pointer;
        }
        
        #recepcionesTable thead th:hover {
            background-color: var(--seafoam) !important;
        }
        
        #recepcionesTable thead th:last-child {
            cursor: default;
        }
    </style>
</head>
<body>
    <div class="dashboard-main-wrapper">
        <jsp:include page="/gerente-tienda/layouts/sidebar_gerente.jsp">
            <jsp:param name="activeMenu" value="Recepciones Pendientes"/>
        </jsp:include>
        
        <div class="dashboard-wrapper">
            <jsp:include page="/gerente-tienda/layouts/header_gerente.jsp"/>
            
            <div class="dashboard-content">
                <div class="container-fluid">
                    <!-- Page Header -->
                    <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;">
                                    <i class="fas fa-truck-loading me-2"></i>Recepciones Pendientes
                                </h2>
                                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">
                                    Planes de transporte destinados a tu distrito
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Mensajes -->
                    <% if (successMsg != null) { %>
                        <div class="alert alert-success alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                            <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                        </div>
                    <% } %>
                    <% if (errorMsg != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                            <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                        </div>
                    <% } %>
                    
                    <%
                        // Obtener estadísticas desde el servlet
                        Integer totalPendientes = (Integer) request.getAttribute("totalPendientes");
                        Integer pendientesHoy = (Integer) request.getAttribute("pendientesHoy");
                        Integer pendientesUltimos7Dias = (Integer) request.getAttribute("pendientesUltimos7Dias");
                        if (totalPendientes == null) totalPendientes = 0;
                        if (pendientesHoy == null) pendientesHoy = 0;
                        if (pendientesUltimos7Dias == null) pendientesUltimos7Dias = 0;
                    %>
                    
                    <!-- ===================== Tarjetas de estadísticas ===================== -->
                    <div class="row g-2 mb-3">
                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Pendientes</h3>
                                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= totalPendientes %></p>
                            </div>
                        </div>
                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Pendientes Hoy</h3>
                                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= pendientesHoy %></p>
                            </div>
                        </div>
                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Últimos 7 Días</h3>
                                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= pendientesUltimos7Dias %></p>
                            </div>
                        </div>
                    </div>

                    <!-- ===================== Card: Búsqueda y filtros ===================== -->
                    <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                        <form action="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet" method="GET" id="filterForm">
                            <input type="hidden" name="action" value="recepciones-pendientes">
                            <input type="hidden" name="size" value="<%= size %>">
                            <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                <div class="col-xl-3 col-lg-3 col-md-12 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="N° Plan, producto o lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <button class="btn btn-sm shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem; background-color: #00a896; border-color: #00a896; color: white;">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                                    <select class="form-select form-select-sm shadow-sm" name="estado" id="estadoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <option value="" ${empty param.estado ? 'selected' : ''}>Todos</option>
                                        <option value="En Ruta" ${param.estado == 'En Ruta' ? 'selected' : ''}>En Ruta</option>
                                        <option value="Salida" ${param.estado == 'Salida' ? 'selected' : ''}>Salida</option>
                                    </select>
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Desde</label>
                                    <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_desde" id="fechaDesdeFilter" value="${param.fecha_desde}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Hasta</label>
                                    <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_hasta" id="fechaHastaFilter" value="${param.fecha_hasta}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                </div>
                                <div class="col-xl-3 col-lg-3 col-md-12 col-sm-12 d-flex align-items-end">
                                    <a href="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-sync-alt me-1"></i>Limpiar
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Tabla de Recepciones -->
                    <div class="table-card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-list me-2"></i>Lista de Recepciones Pendientes</h5>
                        </div>
                        <div class="card-body">
                            <% if (planes.isEmpty()) { %>
                                <div class="text-center py-5">
                                    <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                    <p class="text-muted">No hay recepciones pendientes en este momento.</p>
                                </div>
                            <% } else { %>
                                <div class="table-responsive">
                                    <table id="recepcionesTable" class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-hashtag me-1"></i>N° Plan</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-box me-1"></i>Producto</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-barcode me-1"></i>Lote</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-user me-1"></i>Conductor</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-truck me-1"></i>Vehículo</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-calendar-alt me-1"></i>Fecha Entrega</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-toggle-on me-1"></i>Estado</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: default;" class="fw-semibold"><i class="fas fa-cog me-1"></i>Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (PlanTransporte plan : planes) { %>
                                                <tr>
                                                    <td><strong><%= plan.getNumeroPlan() %></strong></td>
                                                    <td><%= plan.getNombreProducto() %></td>
                                                    <td><%= plan.getCodigoLote() %></td>
                                                    <td><%= plan.getNombreConductor() %></td>
                                                    <td><%= plan.getPlacaVehiculo() %></td>
                                                    <td><%= plan.getFechaEntrega() %></td>
                                                    <td>
                                                        <% if ("En Ruta".equals(plan.getEstado())) { %>
                                                            <span class="badge badge-estado badge-en-ruta">
                                                                <i class="fas fa-truck me-1"></i>En Ruta
                                                            </span>
                                                        <% } else if ("Salida".equals(plan.getEstado())) { %>
                                                            <span class="badge badge-estado badge-salida">
                                                                <i class="fas fa-arrow-right me-1"></i>Salida
                                                            </span>
                                                        <% } else { %>
                                                            <span class="badge bg-secondary"><%= plan.getEstado() %></span>
                                                        <% } %>
                                                    </td>
                                                    <td>
                                                        <a href="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet?action=confirmar-recepcion&id_plan=<%= plan.getIdPlan() %>" 
                                                           class="btn btn-sm btn-success">
                                                            <i class="fas fa-check me-1"></i>Confirmar Recepción
                                                        </a>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <%-- Incluir componente de paginación --%>
                                <%
                                    request.setAttribute("param1Name", "busqueda");
                                    request.setAttribute("param1Value", request.getAttribute("busqueda"));
                                    request.setAttribute("param2Name", "estado");
                                    request.setAttribute("param2Value", request.getAttribute("estadoFiltro"));
                                    request.setAttribute("param3Name", "fecha_desde");
                                    request.setAttribute("param3Value", request.getAttribute("fechaDesde"));
                                    request.setAttribute("param4Name", "fecha_hasta");
                                    request.setAttribute("param4Value", request.getAttribute("fechaHasta"));
                                %>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="/gerente-tienda/layouts/footer.jsp"/>
    
    <script>
        // Aplicar filtros automáticamente al cambiar valores
        document.addEventListener('DOMContentLoaded', function() {
            const filterForm = document.getElementById('filterForm');
            const searchInput = document.getElementById('searchInput');
            const estadoFilter = document.getElementById('estadoFilter');
            const fechaDesdeFilter = document.getElementById('fechaDesdeFilter');
            const fechaHastaFilter = document.getElementById('fechaHastaFilter');
            
            // Variable para el timeout del debounce
            let searchTimeout = null;
            
            // Aplicar filtros automáticamente mientras se escribe en el campo de búsqueda (con debounce)
            if (searchInput && filterForm) {
                searchInput.addEventListener('input', function(e) {
                    // Limpiar el timeout anterior
                    if (searchTimeout) {
                        clearTimeout(searchTimeout);
                    }
                    
                    // Esperar 500ms después de que el usuario deje de escribir antes de enviar
                    searchTimeout = setTimeout(function() {
                        filterForm.submit();
                    }, 500);
                });
                
                // Aplicar filtros al presionar Enter en el campo de búsqueda (inmediato)
                searchInput.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        // Cancelar el timeout si existe
                        if (searchTimeout) {
                            clearTimeout(searchTimeout);
                        }
                        filterForm.submit();
                    }
                });
            }
            
            // Aplicar filtros cuando cambien el estado
            if (estadoFilter && filterForm) {
                estadoFilter.addEventListener('change', function() {
                    filterForm.submit();
                });
            }
            
            // Aplicar filtros cuando cambien los campos de fecha
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
</body>
</html>

