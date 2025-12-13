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
                                
                                <!-- Paginación -->
                                <% if (totalPages > 1) { %>
                                    <nav aria-label="Paginación">
                                        <ul class="pagination justify-content-center mt-4">
                                            <% if (currentPage > 1) { %>
                                                <li class="page-item">
                                                    <a class="page-link" href="?action=historial&page=<%= currentPage - 1 %>">
                                                        <i class="fas fa-chevron-left"></i>
                                                    </a>
                                                </li>
                                            <% } %>
                                            
                                            <% for (int i = 1; i <= totalPages; i++) { %>
                                                <li class="page-item <%= i == currentPage ? "active" : "" %>">
                                                    <a class="page-link" href="?action=historial&page=<%= i %>"><%= i %></a>
                                                </li>
                                            <% } %>
                                            
                                            <% if (currentPage < totalPages) { %>
                                                <li class="page-item">
                                                    <a class="page-link" href="?action=historial&page=<%= currentPage + 1 %>">
                                                        <i class="fas fa-chevron-right"></i>
                                                    </a>
                                                </li>
                                            <% } %>
                                        </ul>
                                    </nav>
                                    <div class="text-center text-muted mt-2">
                                        Mostrando página <%= currentPage %> de <%= totalPages %> (Total: <%= totalRows %> recepciones)
                                    </div>
                                <% } %>
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

