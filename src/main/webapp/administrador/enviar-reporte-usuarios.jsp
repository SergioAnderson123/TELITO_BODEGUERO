<%@ page import="com.example.telito.administrador.daos.UsuarioDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String busqueda = request.getParameter("busqueda");
    String rolFiltro = request.getParameter("rol");
    String estadoFiltro = request.getParameter("estado");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) {
        session.removeAttribute("errorMsg");
    }
    
    // Obtener información de filtros para mostrar
    UsuarioDAO usuarioDAO = new UsuarioDAO();
    String filtrosInfo = "";
    if (busqueda != null && !busqueda.isEmpty()) {
        filtrosInfo += "Búsqueda: " + busqueda + "; ";
    }
    if (rolFiltro != null && !rolFiltro.isEmpty()) {
        String nombreRol = usuarioDAO.obtenerNombreRolPorId(Integer.parseInt(rolFiltro));
        filtrosInfo += "Rol: " + (nombreRol != null ? nombreRol : rolFiltro) + "; ";
    }
    if (estadoFiltro != null && !estadoFiltro.isEmpty()) {
        filtrosInfo += "Estado: " + ("1".equals(estadoFiltro) ? "Activo" : "Inactivo") + "; ";
    }
    if (filtrosInfo.isEmpty()) {
        filtrosInfo = "Sin filtros aplicados";
    } else {
        filtrosInfo = filtrosInfo.substring(0, filtrosInfo.length() - 2);
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Enviar Reporte por Correo"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Usuarios'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <% if (errorMsg != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <div class="page-header mb-4">
                <h2 class="pageheader-title">Enviar Reporte de Usuarios por Correo</h2>
                <p class="pageheader-text">Genera y envía un reporte Excel de usuarios por correo electrónico.</p>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="table-card">
                        <div class="card-header">
                            <h5 class="mb-0 fw-semibold">Formulario de Envío</h5>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info mb-4">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Filtros aplicados:</strong> <%= filtrosInfo %>
                            </div>

                            <form action="<%= request.getContextPath() %>/UsuarioReporteServlet" method="POST">
                                <input type="hidden" name="action" value="enviar">
                                <% if (busqueda != null && !busqueda.isEmpty()) { %>
                                <input type="hidden" name="busqueda" value="<%= busqueda %>">
                                <% } %>
                                <% if (rolFiltro != null && !rolFiltro.isEmpty()) { %>
                                <input type="hidden" name="rol" value="<%= rolFiltro %>">
                                <% } %>
                                <% if (estadoFiltro != null && !estadoFiltro.isEmpty()) { %>
                                <input type="hidden" name="estado" value="<%= estadoFiltro %>">
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
                                           value="Reporte de Usuarios - TELITO BODEGUERO" 
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
                                    <strong>Nota:</strong> El archivo Excel se generará con los mismos filtros que tienes aplicados en la tabla de usuarios. 
                                    Incluirá todas las columnas (ID, Nombres, Apellidos, Correo, Rol, Estado) y tendrá filtros automáticos habilitados.
                                </div>

                                <div class="d-flex justify-content-between">
                                    <a href="<%= request.getContextPath() %>/UsuarioServlet?action=listar<%
                                        if (busqueda != null && !busqueda.isEmpty()) out.print("&busqueda=" + java.net.URLEncoder.encode(busqueda, "UTF-8"));
                                        if (rolFiltro != null && !rolFiltro.isEmpty()) out.print("&rol=" + rolFiltro);
                                        if (estadoFiltro != null && !estadoFiltro.isEmpty()) out.print("&estado=" + estadoFiltro);
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
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

