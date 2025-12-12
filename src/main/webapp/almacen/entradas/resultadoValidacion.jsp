<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    Map<String, Object> resultadoValidacion = (Map<String, Object>) request.getAttribute("resultadoValidacion");
    String nombreArchivo = (String) request.getAttribute("nombreArchivo");
    
    if (resultadoValidacion == null) {
        response.sendRedirect(request.getContextPath() + "/almacen/ExcelValidacionServlet?action=form");
        return;
    }
    
    Boolean esValido = (Boolean) resultadoValidacion.get("esValido");
    Integer totalFilas = (Integer) resultadoValidacion.get("totalFilas");
    Integer filasValidas = (Integer) resultadoValidacion.get("filasValidas");
    Integer filasConErrores = (Integer) resultadoValidacion.get("filasConErrores");
    @SuppressWarnings("unchecked")
    List<String> errores = (List<String>) resultadoValidacion.get("errores");
    @SuppressWarnings("unchecked")
    List<String> advertencias = (List<String>) resultadoValidacion.get("advertencias");
    @SuppressWarnings("unchecked")
    List<Map<String, Object>> filasValidadas = (List<Map<String, Object>>) resultadoValidacion.get("filasValidadas");
%>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Resultado de Validación"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Cargar Excel"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2><i class="fas fa-clipboard-check me-2"></i>Resultado de Validación</h2>
                            <p class="text-muted">Archivo: <strong><%= nombreArchivo != null ? nombreArchivo : "N/A" %></strong></p>
                        </div>
                    </div>
                </div>
                
                <!-- Resumen de validación -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header <%= esValido != null && esValido ? "bg-success text-white" : "bg-danger text-white" %>">
                                <h5 class="mb-0">
                                    <i class="fas fa-<%= esValido != null && esValido ? "check-circle" : "times-circle" %> me-2"></i>
                                    <%= esValido != null && esValido ? "Validación Exitosa" : "Validación Fallida" %>
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-3">
                                        <div class="text-center p-3 bg-light rounded">
                                            <h3 class="text-primary mb-0"><%= totalFilas != null ? totalFilas : 0 %></h3>
                                            <small class="text-muted">Total de Filas</small>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="text-center p-3 bg-light rounded">
                                            <h3 class="text-success mb-0"><%= filasValidas != null ? filasValidas : 0 %></h3>
                                            <small class="text-muted">Filas Válidas</small>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="text-center p-3 bg-light rounded">
                                            <h3 class="text-danger mb-0"><%= filasConErrores != null ? filasConErrores : 0 %></h3>
                                            <small class="text-muted">Filas con Errores</small>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="text-center p-3 bg-light rounded">
                                            <h3 class="text-warning mb-0"><%= advertencias != null ? advertencias.size() : 0 %></h3>
                                            <small class="text-muted">Advertencias</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Errores -->
                <% if (errores != null && !errores.isEmpty()) { %>
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card border-danger">
                            <div class="card-header bg-danger text-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-exclamation-triangle me-2"></i>Errores Encontrados
                                </h5>
                            </div>
                            <div class="card-body">
                                <ul class="list-group list-group-flush">
                                    <% for (String error : errores) { %>
                                        <li class="list-group-item"><%= error %></li>
                                    <% } %>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Advertencias -->
                <% if (advertencias != null && !advertencias.isEmpty()) { %>
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card border-warning">
                            <div class="card-header bg-warning text-dark">
                                <h5 class="mb-0">
                                    <i class="fas fa-exclamation-circle me-2"></i>Advertencias
                                </h5>
                            </div>
                            <div class="card-body">
                                <ul class="list-group list-group-flush">
                                    <% for (String advertencia : advertencias) { %>
                                        <li class="list-group-item"><%= advertencia %></li>
                                    <% } %>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Detalle de filas -->
                <% if (filasValidadas != null && !filasValidadas.isEmpty()) { %>
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-list me-2"></i>Detalle de Validación por Fila
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Fila</th>
                                                <th>Estado</th>
                                                <th>Código Lote</th>
                                                <th>SKU Producto</th>
                                                <th>Cantidad</th>
                                                <th>Ubicación</th>
                                                <th>Errores</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Map<String, Object> fila : filasValidadas) { 
                                                Boolean esValida = (Boolean) fila.get("esValida");
                                                Integer numeroFila = (Integer) fila.get("numeroFila");
                                                @SuppressWarnings("unchecked")
                                                Map<String, Object> datos = (Map<String, Object>) fila.get("datos");
                                                @SuppressWarnings("unchecked")
                                                List<String> erroresFila = (List<String>) fila.get("errores");
                                            %>
                                                <tr class="<%= esValida != null && esValida ? "table-success" : "table-danger" %>">
                                                    <td><%= numeroFila %></td>
                                                    <td>
                                                        <% if (esValida != null && esValida) { %>
                                                            <span class="badge bg-success">Válida</span>
                                                        <% } else { %>
                                                            <span class="badge bg-danger">Error</span>
                                                        <% } %>
                                                    </td>
                                                    <td><%= datos != null && datos.get("codigoLote") != null ? datos.get("codigoLote") : "-" %></td>
                                                    <td><%= datos != null && datos.get("codigoSKU") != null ? datos.get("codigoSKU") : "-" %></td>
                                                    <td><%= datos != null && datos.get("cantidad") != null ? datos.get("cantidad") : "-" %></td>
                                                    <td><%= datos != null && datos.get("ubicacion") != null ? datos.get("ubicacion") : "-" %></td>
                                                    <td>
                                                        <% if (erroresFila != null && !erroresFila.isEmpty()) { %>
                                                            <ul class="mb-0 small">
                                                                <% for (String error : erroresFila) { %>
                                                                    <li><%= error %></li>
                                                                <% } %>
                                                            </ul>
                                                        <% } else { %>
                                                            <span class="text-muted">-</span>
                                                        <% } %>
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
                <% } %>
                
                <!-- Acciones -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/almacen/ExcelValidacionServlet?action=form" 
                               class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Volver a Cargar Archivo
                            </a>
                            
                            <% if (esValido != null && esValido) { %>
                            <form method="POST" action="${pageContext.request.contextPath}/almacen/ExcelValidacionServlet?action=procesar" 
                                  style="display: inline;">
                                <button type="submit" class="btn btn-success" onclick="return confirm('¿Está seguro de que desea procesar e insertar estos datos?');">
                                    <i class="fas fa-save me-2"></i>Procesar e Insertar Datos
                                </button>
                            </form>
                            <% } else { %>
                            <button type="button" class="btn btn-success" disabled>
                                <i class="fas fa-save me-2"></i>Procesar e Insertar Datos
                            </button>
                            <small class="text-muted d-block mt-2">Debe corregir los errores antes de procesar</small>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

