<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    Map<String, Object> resultadoProcesamiento = (Map<String, Object>) request.getAttribute("resultadoProcesamiento");
    
    if (resultadoProcesamiento == null) {
        response.sendRedirect(request.getContextPath() + "/almacen/ExcelValidacionServlet?action=form");
        return;
    }
    
    Boolean exito = (Boolean) resultadoProcesamiento.get("exito");
    Integer registrosInsertados = (Integer) resultadoProcesamiento.get("registrosInsertados");
    Integer registrosConError = (Integer) resultadoProcesamiento.get("registrosConError");
    @SuppressWarnings("unchecked")
    List<String> errores = (List<String>) resultadoProcesamiento.get("errores");
%>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Resultado de Procesamiento"/>
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
                            <h2><i class="fas fa-<%= exito != null && exito ? "check-circle text-success" : "times-circle text-danger" %> me-2"></i>Resultado de Procesamiento</h2>
                        </div>
                    </div>
                </div>
                
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header <%= exito != null && exito ? "bg-success text-white" : "bg-warning text-dark" %>">
                                <h5 class="mb-0">
                                    <i class="fas fa-<%= exito != null && exito ? "check-circle" : "exclamation-triangle" %> me-2"></i>
                                    <%= exito != null && exito ? "Procesamiento Completado" : "Procesamiento con Errores" %>
                                </h5>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="text-center p-3 bg-light rounded">
                                            <h3 class="text-success mb-0"><%= registrosInsertados != null ? registrosInsertados : 0 %></h3>
                                            <small class="text-muted">Registros Insertados</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="text-center p-3 bg-light rounded">
                                            <h3 class="text-danger mb-0"><%= registrosConError != null ? registrosConError : 0 %></h3>
                                            <small class="text-muted">Registros con Error</small>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="text-center p-3 bg-light rounded">
                                            <h3 class="text-primary mb-0"><%= (registrosInsertados != null ? registrosInsertados : 0) + (registrosConError != null ? registrosConError : 0) %></h3>
                                            <small class="text-muted">Total Procesados</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <% if (errores != null && !errores.isEmpty()) { %>
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card border-danger">
                            <div class="card-header bg-danger text-white">
                                <h5 class="mb-0">
                                    <i class="fas fa-exclamation-triangle me-2"></i>Errores Durante el Procesamiento
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
                
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="d-flex justify-content-between">
                            <a href="${pageContext.request.contextPath}/almacen/ExcelValidacionServlet?action=form" 
                               class="btn btn-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Volver a Cargar Archivo
                            </a>
                            <a href="${pageContext.request.contextPath}/almacen/LoteServlet" 
                               class="btn btn-primary">
                                <i class="fas fa-box me-2"></i>Ver Inventario
                            </a>
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

