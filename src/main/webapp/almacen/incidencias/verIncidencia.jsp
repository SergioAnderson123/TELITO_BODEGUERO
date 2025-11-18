<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.almacen.beans.Incidencia" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    Incidencia incidencia = (Incidencia) request.getAttribute("incidencia");
    if (incidencia == null) {
        response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
        return;
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    boolean esAdministrador = false;
    if (session.getAttribute("usuario") != null) {
        com.example.telito.administrador.beans.Usuario usuario = 
            (com.example.telito.administrador.beans.Usuario) session.getAttribute("usuario");
        esAdministrador = usuario.getRol() != null && "Administrador".equals(usuario.getRol().getNombre());
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Detalles de Incidencia"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Incidencias"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header mb-4 d-flex justify-content-between align-items-center">
                            <div>
                                <h2><i class="fas fa-exclamation-triangle me-2"></i>Detalles de Incidencia #<%= incidencia.getIdIncidencia() %></h2>
                            </div>
                            <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet" class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Volver
                            </a>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-8">
                        <div class="card shadow-sm mb-4">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0">Información de la Incidencia</h5>
                            </div>
                            <div class="card-body">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <strong>Tipo:</strong>
                                        <span class="badge <%= "Faltante".equals(incidencia.getTipoIncidencia()) ? "bg-danger" : "bg-warning" %> ms-2">
                                            <%= incidencia.getTipoIncidencia() %>
                                        </span>
                                    </div>
                                    <div class="col-md-6">
                                        <strong>Estado:</strong>
                                        <% 
                                            String estadoClass = "bg-secondary";
                                            if ("Pendiente".equals(incidencia.getEstado())) estadoClass = "bg-warning";
                                            else if ("Resuelta".equals(incidencia.getEstado())) estadoClass = "bg-success";
                                            else if ("Cerrada".equals(incidencia.getEstado())) estadoClass = "bg-dark";
                                        %>
                                        <span class="badge <%= estadoClass %> ms-2"><%= incidencia.getEstado() %></span>
                                    </div>
                                </div>
                                
                                <hr>
                                
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <strong>Producto:</strong>
                                        <p class="mb-0"><%= incidencia.getNombreProducto() %></p>
                                    </div>
                                    <div class="col-md-6">
                                        <strong>Código Lote:</strong>
                                        <p class="mb-0"><code><%= incidencia.getCodigoLote() %></code></p>
                                    </div>
                                </div>
                                
                                <div class="row mb-3">
                                    <div class="col-md-4">
                                        <strong>Cantidad en Sistema:</strong>
                                        <p class="mb-0 fs-5"><%= incidencia.getCantidadSistema() %></p>
                                    </div>
                                    <div class="col-md-4">
                                        <strong>Cantidad Reportada:</strong>
                                        <p class="mb-0 fs-5"><%= incidencia.getCantidadReportada() %></p>
                                    </div>
                                    <div class="col-md-4">
                                        <strong>Diferencia:</strong>
                                        <p class="mb-0 fs-5">
                                            <span class="<%= incidencia.getDiferencia() < 0 ? "text-danger" : "text-success" %> fw-bold">
                                                <%= incidencia.getDiferencia() > 0 ? "+" : "" %><%= incidencia.getDiferencia() %>
                                            </span>
                                        </p>
                                    </div>
                                </div>
                                
                                <hr>
                                
                                <div class="mb-3">
                                    <strong>Motivo:</strong>
                                    <p class="mb-0"><%= incidencia.getMotivo() %></p>
                                </div>
                                
                                <% if (incidencia.getDescripcion() != null && !incidencia.getDescripcion().isEmpty()) { %>
                                <div class="mb-3">
                                    <strong>Descripción:</strong>
                                    <p class="mb-0"><%= incidencia.getDescripcion() %></p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-lg-4">
                        <div class="card shadow-sm mb-4">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">Información del Reporte</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Reportado por:</strong><br><%= incidencia.getNombreUsuarioReporte() %></p>
                                <p><strong>Fecha de Reporte:</strong><br>
                                    <%= incidencia.getFechaReporte() != null ? dateFormat.format(incidencia.getFechaReporte()) : "-" %>
                                </p>
                                
                                <% if (incidencia.getFechaResolucion() != null) { %>
                                <hr>
                                <p><strong>Resuelto por:</strong><br>
                                    <%= incidencia.getNombreUsuarioResolucion() != null ? incidencia.getNombreUsuarioResolucion() : "-" %>
                                </p>
                                <p><strong>Fecha de Resolución:</strong><br>
                                    <%= dateFormat.format(incidencia.getFechaResolucion()) %>
                                </p>
                                <% if (incidencia.getObservacionesResolucion() != null && !incidencia.getObservacionesResolucion().isEmpty()) { %>
                                <p><strong>Observaciones:</strong><br>
                                    <%= incidencia.getObservacionesResolucion() %>
                                </p>
                                <% } %>
                                <% } %>
                            </div>
                        </div>
                        
                        <% if (esAdministrador && "Pendiente".equals(incidencia.getEstado())) { %>
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=formResolver&id=<%= incidencia.getIdIncidencia() %>" 
                                   class="btn btn-success w-100">
                                    <i class="fas fa-check me-2"></i>Resolver Incidencia
                                </a>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

