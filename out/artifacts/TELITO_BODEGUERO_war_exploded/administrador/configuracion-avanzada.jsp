<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.ConfiguracionSistema" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Map<String, ArrayList<ConfiguracionSistema>> configuraciones = 
        (Map<String, ArrayList<ConfiguracionSistema>>) request.getAttribute("configuraciones");
    if (configuraciones == null) configuraciones = new java.util.HashMap<>();
    
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Configuración Avanzada"/>
    </jsp:include>
    <style>
        .config-section { margin-bottom: 2rem; }
        .config-item { margin-bottom: 1.5rem; padding: 1rem; background: #f8f9fa; border-radius: 8px; }
        .config-label { font-weight: 600; color: #006d77; margin-bottom: 0.5rem; }
        .config-description { font-size: 0.85rem; color: #6c757d; margin-bottom: 0.5rem; }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='ConfiguracionAvanzada'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="page-header mb-4">
                <h2 class="pageheader-title"><i class="fas fa-sliders-h me-2"></i>Configuración Avanzada del Sistema</h2>
                <p class="pageheader-text">Gestiona los parámetros del sistema, configuración de correos y notificaciones.</p>
            </div>

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

            <form method="post" action="<%= request.getContextPath() %>/ConfiguracionAvanzadaServlet">
                <input type="hidden" name="action" value="actualizar">
                
                <!-- Tabs para diferentes categorías -->
                <ul class="nav nav-tabs mb-4" id="configTabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="email-tab" data-bs-toggle="tab" data-bs-target="#email-pane" type="button" role="tab">
                            <i class="fas fa-envelope me-2"></i>Email
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="notificaciones-tab" data-bs-toggle="tab" data-bs-target="#notificaciones-pane" type="button" role="tab">
                            <i class="fas fa-bell me-2"></i>Notificaciones
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="sistema-tab" data-bs-toggle="tab" data-bs-target="#sistema-pane" type="button" role="tab">
                            <i class="fas fa-cog me-2"></i>Sistema
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="seguridad-tab" data-bs-toggle="tab" data-bs-target="#seguridad-pane" type="button" role="tab">
                            <i class="fas fa-shield-alt me-2"></i>Seguridad
                        </button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="reportes-tab" data-bs-toggle="tab" data-bs-target="#reportes-pane" type="button" role="tab">
                            <i class="fas fa-file-excel me-2"></i>Reportes
                        </button>
                    </li>
                </ul>

                <div class="tab-content" id="configTabContent">
                    <!-- Tab Email -->
                    <div class="tab-pane fade show active" id="email-pane" role="tabpanel">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0"><i class="fas fa-envelope me-2"></i>Configuración de Email</h5>
                            </div>
                            <div class="card-body">
                                <% 
                                    ArrayList<ConfiguracionSistema> emailConfigs = configuraciones.getOrDefault("EMAIL", new ArrayList<>());
                                    for (ConfiguracionSistema emailConfig : emailConfigs) {
                                %>
                                <div class="config-item">
                                    <label class="config-label"><%= emailConfig.getClave() %></label>
                                    <p class="config-description"><%= emailConfig.getDescripcion() != null ? emailConfig.getDescripcion() : "" %></p>
                                    <% if (emailConfig.isEditable()) { %>
                                        <% if ("BOOLEAN".equals(emailConfig.getTipo())) { %>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="<%= emailConfig.getClave() %>" 
                                                   value="true" <%= emailConfig.getValorBoolean() ? "checked" : "" %>>
                                            <label class="form-check-label">Habilitado</label>
                                        </div>
                                        <% } else { %>
                                        <input type="text" class="form-control" name="<%= emailConfig.getClave() %>" 
                                               value="<%= emailConfig.getValor() != null ? emailConfig.getValor() : "" %>">
                                        <% } %>
                                    <% } else { %>
                                        <input type="text" class="form-control" value="<%= emailConfig.getValor() != null ? emailConfig.getValor() : "" %>" disabled>
                                        <small class="text-muted">Esta configuración no es editable</small>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Notificaciones -->
                    <div class="tab-pane fade" id="notificaciones-pane" role="tabpanel">
                        <div class="card shadow-sm">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0"><i class="fas fa-bell me-2"></i>Configuración de Notificaciones</h5>
                            </div>
                            <div class="card-body">
                                <% 
                                    ArrayList<ConfiguracionSistema> notifConfigs = configuraciones.getOrDefault("NOTIFICACIONES", new ArrayList<>());
                                    for (ConfiguracionSistema notifConfig : notifConfigs) {
                                %>
                                <div class="config-item">
                                    <label class="config-label"><%= notifConfig.getClave() %></label>
                                    <p class="config-description"><%= notifConfig.getDescripcion() != null ? notifConfig.getDescripcion() : "" %></p>
                                    <% if (notifConfig.isEditable()) { %>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="<%= notifConfig.getClave() %>" 
                                                   value="true" <%= notifConfig.getValorBoolean() ? "checked" : "" %>>
                                            <label class="form-check-label">Habilitado</label>
                                        </div>
                                    <% } else { %>
                                        <input type="text" class="form-control" value="<%= notifConfig.getValor() != null ? notifConfig.getValor() : "" %>" disabled>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Sistema -->
                    <div class="tab-pane fade" id="sistema-pane" role="tabpanel">
                        <div class="card shadow-sm">
                            <div class="card-header bg-secondary text-white">
                                <h5 class="mb-0"><i class="fas fa-cog me-2"></i>Configuración del Sistema</h5>
                            </div>
                            <div class="card-body">
                                <% 
                                    ArrayList<ConfiguracionSistema> sistemaConfigs = configuraciones.getOrDefault("SISTEMA", new ArrayList<>());
                                    for (ConfiguracionSistema sistemaConfig : sistemaConfigs) {
                                %>
                                <div class="config-item">
                                    <label class="config-label"><%= sistemaConfig.getClave() %></label>
                                    <p class="config-description"><%= sistemaConfig.getDescripcion() != null ? sistemaConfig.getDescripcion() : "" %></p>
                                    <% if (sistemaConfig.isEditable()) { %>
                                        <% if ("BOOLEAN".equals(sistemaConfig.getTipo())) { %>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="<%= sistemaConfig.getClave() %>" 
                                                   value="true" <%= sistemaConfig.getValorBoolean() ? "checked" : "" %>>
                                            <label class="form-check-label">Habilitado</label>
                                        </div>
                                        <% } else { %>
                                        <input type="text" class="form-control" name="<%= sistemaConfig.getClave() %>" 
                                               value="<%= sistemaConfig.getValor() != null ? sistemaConfig.getValor() : "" %>">
                                        <% } %>
                                    <% } else { %>
                                        <input type="text" class="form-control" value="<%= sistemaConfig.getValor() != null ? sistemaConfig.getValor() : "" %>" disabled>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Seguridad -->
                    <div class="tab-pane fade" id="seguridad-pane" role="tabpanel">
                        <div class="card shadow-sm">
                            <div class="card-header bg-danger text-white">
                                <h5 class="mb-0"><i class="fas fa-shield-alt me-2"></i>Configuración de Seguridad</h5>
                            </div>
                            <div class="card-body">
                                <% 
                                    ArrayList<ConfiguracionSistema> seguridadConfigs = configuraciones.getOrDefault("SEGURIDAD", new ArrayList<>());
                                    for (ConfiguracionSistema seguridadConfig : seguridadConfigs) {
                                %>
                                <div class="config-item">
                                    <label class="config-label"><%= seguridadConfig.getClave() %></label>
                                    <p class="config-description"><%= seguridadConfig.getDescripcion() != null ? seguridadConfig.getDescripcion() : "" %></p>
                                    <% if (seguridadConfig.isEditable()) { %>
                                        <% if ("BOOLEAN".equals(seguridadConfig.getTipo())) { %>
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" type="checkbox" name="<%= seguridadConfig.getClave() %>" 
                                                   value="true" <%= seguridadConfig.getValorBoolean() ? "checked" : "" %>>
                                            <label class="form-check-label">Habilitado</label>
                                        </div>
                                        <% } else { %>
                                        <input type="text" class="form-control" name="<%= seguridadConfig.getClave() %>" 
                                               value="<%= seguridadConfig.getValor() != null ? seguridadConfig.getValor() : "" %>">
                                        <% } %>
                                    <% } else { %>
                                        <input type="text" class="form-control" value="<%= seguridadConfig.getValor() != null ? seguridadConfig.getValor() : "" %>" disabled>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Tab Reportes -->
                    <div class="tab-pane fade" id="reportes-pane" role="tabpanel">
                        <div class="card shadow-sm">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="fas fa-file-excel me-2"></i>Configuración de Reportes</h5>
                            </div>
                            <div class="card-body">
                                <% 
                                    ArrayList<ConfiguracionSistema> reportesConfigs = configuraciones.getOrDefault("REPORTES", new ArrayList<>());
                                    for (ConfiguracionSistema reporteConfig : reportesConfigs) {
                                %>
                                <div class="config-item">
                                    <label class="config-label"><%= reporteConfig.getClave() %></label>
                                    <p class="config-description"><%= reporteConfig.getDescripcion() != null ? reporteConfig.getDescripcion() : "" %></p>
                                    <% if (reporteConfig.isEditable()) { %>
                                        <input type="text" class="form-control" name="<%= reporteConfig.getClave() %>" 
                                               value="<%= reporteConfig.getValor() != null ? reporteConfig.getValor() : "" %>">
                                    <% } else { %>
                                        <input type="text" class="form-control" value="<%= reporteConfig.getValor() != null ? reporteConfig.getValor() : "" %>" disabled>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Botones de acción -->
                <div class="d-flex justify-content-end gap-2 mt-4">
                    <a href="<%= request.getContextPath() %>/inicio" class="btn btn-secondary">
                        <i class="fas fa-times me-2"></i>Cancelar
                    </a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-2"></i>Guardar Configuraciones
                    </button>
                </div>
            </form>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

