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
    Usuario usuario = (Usuario) session.getAttribute("usuario");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/gerente-tienda/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Historial de Recepciones"/>
    </jsp:include>
    <style>
        .table-responsive {
            border-radius: 12px;
            overflow: hidden;
        }
        .badge-entregado {
            background-color: #28a745;
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.85rem;
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
        
        /* Estilos para encabezados de tabla con hover verde y ordenamiento */
        #historialTable thead th {
            position: relative;
            user-select: none;
            color: var(--text-muted) !important;
            text-transform: uppercase;
            cursor: pointer;
        }
        
        #historialTable thead th:hover {
            background-color: var(--seafoam) !important;
        }
        
        #historialTable thead th:last-child {
            cursor: default;
        }
    </style>
</head>
<body>
    <div class="dashboard-main-wrapper">
        <jsp:include page="/gerente-tienda/layouts/sidebar_gerente.jsp">
            <jsp:param name="activeMenu" value="Historial"/>
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
                                    <i class="fas fa-history me-2"></i>Historial de Recepciones
                                </h2>
                                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">
                                    Registro de todas las recepciones completadas
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <%
                        // Obtener estadísticas desde el servlet
                        Integer totalRecepciones = (Integer) request.getAttribute("totalRecepciones");
                        Integer recepcionesHoy = (Integer) request.getAttribute("recepcionesHoy");
                        Integer recepcionesUltimos7Dias = (Integer) request.getAttribute("recepcionesUltimos7Dias");
                        if (totalRecepciones == null) totalRecepciones = 0;
                        if (recepcionesHoy == null) recepcionesHoy = 0;
                        if (recepcionesUltimos7Dias == null) recepcionesUltimos7Dias = 0;
                    %>
                    
                    <!-- ===================== Tarjetas de estadísticas ===================== -->
                    <div class="row g-2 mb-3">
                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Recepciones</h3>
                                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= totalRecepciones %></p>
                            </div>
                        </div>
                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Recepciones Hoy</h3>
                                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= recepcionesHoy %></p>
                            </div>
                        </div>
                        <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                            <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                                <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Últimos 7 Días</h3>
                                <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= recepcionesUltimos7Dias %></p>
                            </div>
                        </div>
                    </div>

                    <!-- ===================== Card: Búsqueda y filtros ===================== -->
                    <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                        <form action="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet" method="GET" id="filterForm">
                            <input type="hidden" name="action" value="historial">
                            <input type="hidden" name="size" value="<%= size %>">
                            <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                <div class="col-xl-4 col-lg-4 col-md-12 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                    <div class="input-group">
                                        <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="N° Plan, producto o lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <button class="btn btn-sm shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem; background-color: #00a896; border-color: #00a896; color: white;">
                                            <i class="fas fa-search"></i>
                                        </button>
                                    </div>
                                </div>
                                <div class="col-xl-3 col-lg-3 col-md-6 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Desde</label>
                                    <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_desde" id="fechaDesdeFilter" value="${param.fecha_desde}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                </div>
                                <div class="col-xl-3 col-lg-3 col-md-6 col-sm-12">
                                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-calendar me-1"></i>Fecha Hasta</label>
                                    <input type="date" class="form-control form-control-sm shadow-sm" name="fecha_hasta" id="fechaHastaFilter" value="${param.fecha_hasta}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                </div>
                                <div class="col-xl-2 col-lg-2 col-md-12 col-sm-12 d-flex align-items-end">
                                    <a href="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet?action=historial" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-sync-alt me-1"></i>Limpiar
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Tabla de Historial -->
                    <div class="table-card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-list me-2"></i>Historial de Recepciones Completadas</h5>
                        </div>
                        <div class="card-body">
                            <% if (planes.isEmpty()) { %>
                                <div class="text-center py-5">
                                    <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                    <p class="text-muted">No hay recepciones completadas aún.</p>
                                </div>
                            <% } else { %>
                                <div class="table-responsive">
                                    <table id="historialTable" class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-hashtag me-1"></i>N° Plan</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-box me-1"></i>Producto</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-barcode me-1"></i>Lote</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-user me-1"></i>Conductor</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-truck me-1"></i>Vehículo</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-calendar-alt me-1"></i>Fecha Entrega</th>
                                                <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor: default;" class="fw-semibold"><i class="fas fa-check-circle me-1"></i>Estado</th>
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
                                                        <span class="badge-entregado">
                                                            <i class="fas fa-check-circle me-1"></i>Entregado
                                                        </span>
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
                                    request.setAttribute("param2Name", "fecha_desde");
                                    request.setAttribute("param2Value", request.getAttribute("fechaDesde"));
                                    request.setAttribute("param3Name", "fecha_hasta");
                                    request.setAttribute("param3Value", request.getAttribute("fechaHasta"));
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

