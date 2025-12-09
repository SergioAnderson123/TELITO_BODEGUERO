<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.almacen.beans.Incidencia" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    Incidencia incidencia = (Incidencia) request.getAttribute("incidencia");
    if (incidencia == null) {
        response.sendRedirect(request.getContextPath() + "/almacen/IncidenciaServlet");
        return;
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Resolver Incidencia"/>
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
                        <div class="page-header mb-4">
                            <h2><i class="fas fa-check-circle me-2"></i>Resolver Incidencia #<%= incidencia.getIdIncidencia() %></h2>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-5">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0">Resumen de la Incidencia</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Tipo:</strong> 
                                    <span class="badge <%= "Faltante".equals(incidencia.getTipoIncidencia()) ? "bg-danger" : "bg-warning" %>">
                                        <%= incidencia.getTipoIncidencia() %>
                                    </span>
                                </p>
                                <p><strong>Producto:</strong> <%= incidencia.getNombreProducto() %></p>
                                <p><strong>Código Lote:</strong> <code><%= incidencia.getCodigoLote() %></code></p>
                                <p><strong>Cantidad Sistema:</strong> <%= incidencia.getCantidadSistema() %></p>
                                <p><strong>Cantidad Reportada:</strong> <%= incidencia.getCantidadReportada() %></p>
                                <p><strong>Diferencia:</strong> 
                                    <span class="<%= incidencia.getDiferencia() < 0 ? "text-danger" : "text-success" %> fw-bold">
                                        <%= incidencia.getDiferencia() > 0 ? "+" : "" %><%= incidencia.getDiferencia() %>
                                    </span>
                                </p>
                                <p><strong>Motivo:</strong> <%= incidencia.getMotivo() %></p>
                                <% if (incidencia.getDescripcion() != null && !incidencia.getDescripcion().isEmpty()) { %>
                                <p><strong>Descripción:</strong> <%= incidencia.getDescripcion() %></p>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-7">
                        <div class="card shadow-sm">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0">Formulario de Resolución</h5>
                            </div>
                            <div class="card-body">
                                <form method="POST" action="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=resolver">
                                    <input type="hidden" name="idIncidencia" value="<%= incidencia.getIdIncidencia() %>">
                                    
                                    <div class="mb-3">
                                        <label for="estado" class="form-label">Estado:</label>
                                        <select class="form-select" id="estado" name="estado" required>
                                            <option value="En Revisión" <%= "En Revisión".equals(incidencia.getEstado()) ? "selected" : "" %>>En Revisión</option>
                                            <option value="Resuelta" <%= "Resuelta".equals(incidencia.getEstado()) ? "selected" : "" %>>Resuelta</option>
                                            <option value="Cerrada" <%= "Cerrada".equals(incidencia.getEstado()) ? "selected" : "" %>>Cerrada</option>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label for="observaciones" class="form-label">Observaciones de Resolución:</label>
                                        <textarea class="form-control" id="observaciones" name="observaciones" 
                                                  rows="5" placeholder="Ingrese las observaciones sobre la resolución de esta incidencia..."></textarea>
                                        <small class="text-muted">Describa las acciones tomadas o la razón de la resolución</small>
                                    </div>

                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle me-2"></i>
                                        <strong>Nota:</strong> Al marcar como "Resuelta" o "Cerrada", se registrará la fecha y hora de resolución.
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 mt-4">
                                        <a href="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=ver&id=<%= incidencia.getIdIncidencia() %>" 
                                           class="btn btn-secondary">
                                            <i class="fas fa-times me-2"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-success">
                                            <i class="fas fa-check me-2"></i>Guardar Resolución
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

