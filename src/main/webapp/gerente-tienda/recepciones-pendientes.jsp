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
                    <div class="card mb-4">
                        <div class="card-body">
                            <form method="GET" action="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet" class="row g-3">
                                <input type="hidden" name="action" value="recepciones-pendientes">
                                <div class="col-md-4">
                                    <label for="estado" class="form-label">Estado</label>
                                    <select name="estado" id="estado" class="form-select">
                                        <option value="" <%= (estadoFiltro == null || estadoFiltro.isEmpty()) ? "selected" : "" %>>Todos</option>
                                        <option value="En Ruta" <%= "En Ruta".equals(estadoFiltro) ? "selected" : "" %>>En Ruta</option>
                                        <option value="Salida" <%= "Salida".equals(estadoFiltro) ? "selected" : "" %>>Salida</option>
                                    </select>
                                </div>
                                <div class="col-md-4 d-flex align-items-end">
                                    <button type="submit" class="btn btn-primary me-2">
                                        <i class="fas fa-filter me-1"></i>Filtrar
                                    </button>
                                    <a href="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes" class="btn btn-outline-secondary">
                                        <i class="fas fa-times me-1"></i>Limpiar
                                    </a>
                                </div>
                            </form>
                        </div>
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
                                    <table class="table table-hover mb-0">
                                        <thead>
                                            <tr>
                                                <th>N° Plan</th>
                                                <th>Producto</th>
                                                <th>Lote</th>
                                                <th>Conductor</th>
                                                <th>Vehículo</th>
                                                <th>Fecha Entrega</th>
                                                <th>Estado</th>
                                                <th>Acciones</th>
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
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="/gerente-tienda/layouts/footer.jsp"/>
</body>
</html>

