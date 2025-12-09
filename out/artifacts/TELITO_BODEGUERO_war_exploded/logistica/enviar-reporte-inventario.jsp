<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) {
        session.removeAttribute("errorMsg");
    }
    
    // Obtener parámetros de filtros para preservarlos
    String busqueda = (String) request.getAttribute("busqueda");
    String estado = (String) request.getAttribute("estado");
    if (busqueda == null) busqueda = request.getParameter("busqueda");
    if (estado == null) estado = request.getParameter("estado");
    
    // Construir información de filtros
    StringBuilder filtrosInfo = new StringBuilder();
    if (busqueda != null && !busqueda.trim().isEmpty()) {
        filtrosInfo.append("Búsqueda: ").append(busqueda);
    }
    if (estado != null && !estado.trim().isEmpty()) {
        if (filtrosInfo.length() > 0) filtrosInfo.append(", ");
        filtrosInfo.append("Estado: ").append(estado);
    }
    if (filtrosInfo.length() == 0) {
        filtrosInfo.append("Todos los productos");
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Enviar Reporte por Correo"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value="Inventario"/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <% if (errorMsg != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <div class="page-header mb-4">
                <h2 class="pageheader-title"><i class="fas fa-envelope me-2"></i>Enviar Reporte de Inventario por Correo</h2>
                <p class="pageheader-text">Genera y envía un reporte Excel del Inventario Logística por correo electrónico.</p>
            </div>

            <div class="row">
                <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-file-excel me-2"></i>Formulario de Envío</h5>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info mb-4">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Información del reporte:</strong> Se generará un reporte Excel que incluye:
                                <ul class="mb-0 mt-2">
                                    <li>SKU y Nombre del Producto</li>
                                    <li>Paquetes Disponibles</li>
                                    <li>Precio por Paquete y Costo por Unidad</li>
                                    <li>Estado de Stock</li>
                                    <li>Valor Total (calculado automáticamente)</li>
                                    <li><strong>Total General</strong> del inventario</li>
                                </ul>
                                <p class="mb-0 mt-2"><strong>Filtros aplicados:</strong> <%= filtrosInfo.toString() %></p>
                            </div>

                            <form action="<%= request.getContextPath() %>/logistica/InventarioLogisticaReporteServlet" method="POST">
                                <input type="hidden" name="action" value="enviar">
                                <% if (busqueda != null && !busqueda.trim().isEmpty()) { %>
                                <input type="hidden" name="busqueda" value="<%= busqueda %>">
                                <% } %>
                                <% if (estado != null && !estado.trim().isEmpty()) { %>
                                <input type="hidden" name="estado" value="<%= estado %>">
                                <% } %>

                                <div class="mb-3">
                                    <label for="email_destino" class="form-label">
                                        <i class="fas fa-envelope me-2"></i>Email de Destino <span class="text-danger">*</span>
                                    </label>
                                    <input type="email" class="form-control" id="email_destino" name="email_destino" 
                                           placeholder="correo@ejemplo.com" required>
                                    <small class="form-text text-muted">Ingresa el correo electrónico donde deseas recibir el reporte.</small>
                                </div>

                                <div class="mb-3">
                                    <label for="asunto" class="form-label">
                                        <i class="fas fa-tag me-2"></i>Asunto del Correo
                                    </label>
                                    <input type="text" class="form-control" id="asunto" name="asunto" 
                                           value="Reporte de Inventario Logística - TELITO BODEGUERO" 
                                           placeholder="Asunto del correo">
                                    <small class="form-text text-muted">Si no especificas un asunto, se usará uno por defecto.</small>
                                </div>

                                <div class="mb-3">
                                    <label for="mensaje" class="form-label">
                                        <i class="fas fa-comment me-2"></i>Mensaje Adicional (Opcional)
                                    </label>
                                    <textarea class="form-control" id="mensaje" name="mensaje" rows="4" 
                                              placeholder="Escribe un mensaje personalizado que aparecerá en el correo..."></textarea>
                                    <small class="form-text text-muted">Puedes agregar un mensaje personalizado que aparecerá en el cuerpo del correo.</small>
                                </div>

                                <div class="alert alert-warning">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    <strong>Nota:</strong> El archivo Excel incluye filtros automáticos que puedes usar para ordenar y filtrar los datos directamente en Excel.
                                </div>

                                <div class="d-flex justify-content-between mt-4 pt-3 border-top">
                                    <a href="<%= request.getContextPath() %>/InventarioServlet<%
                                        if (busqueda != null || estado != null) {
                                            out.print("?");
                                            if (busqueda != null) {
                                                out.print("busqueda=" + java.net.URLEncoder.encode(busqueda, "UTF-8"));
                                                if (estado != null) out.print("&");
                                            }
                                            if (estado != null) {
                                                out.print("estado=" + java.net.URLEncoder.encode(estado, "UTF-8"));
                                            }
                                        }
                                    %>" class="btn btn-secondary">
                                        <i class="fas fa-arrow-left me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane me-2"></i>Enviar Reporte
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

