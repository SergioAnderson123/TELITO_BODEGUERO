<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% Usuario usuario = (Usuario) request.getAttribute("usuario"); %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Editar Usuario"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Usuarios'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content" style="padding-bottom: 30px;">
            <div class="page-header mb-2" style="margin-bottom: 0.75rem !important;">
                <h2 class="pageheader-title" style="font-size: 1.3rem; margin-bottom: 0.25rem;"><i class="fas fa-user-edit me-2"></i>Editar Usuario</h2>
                <p class="pageheader-text" style="font-size: 0.85rem; margin-bottom: 0;">Modifica la información del usuario.</p>
            </div>

            <div class="row">
                <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
                    <div class="card shadow-sm">
                        <div class="card-header bg-gradient-primary text-white" style="background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border-radius: 12px 12px 0 0; margin: -30px -30px 20px -30px; padding: 15px 30px;">
                            <h5 class="mb-0" style="font-size: 1.05rem;"><i class="fas fa-user-edit me-2"></i>Editar Información de Usuario</h5>
                            <small class="text-white" style="font-size: 0.85rem; font-weight: 500; opacity: 0.95; display: block; margin-top: 0.25rem;">Modifica los datos del usuario seleccionado</small>
                        </div>
                        <div class="card-body" style="padding: 1.25rem 1.5rem;">
                            <form action="<%= request.getContextPath() %>/UsuarioServlet?action=actualizar" method="POST" id="formEditarUsuario">
                                <input type="hidden" name="id_usuario" value="<%= usuario.getIdUsuario() %>">

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="nombres" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                            <i class="fas fa-user text-primary me-2"></i>Nombres
                                        </label>
                                        <input type="text" class="form-control shadow-sm form-control-sm" id="nombres" name="nombres" value="<%= usuario.getNombres() %>" style="padding: 0.5rem 0.75rem;">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="apellidos" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                            <i class="fas fa-user text-primary me-2"></i>Apellidos
                                        </label>
                                        <input type="text" class="form-control shadow-sm form-control-sm" id="apellidos" name="apellidos" value="<%= usuario.getApellidos() %>" style="padding: 0.5rem 0.75rem;">
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="email" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                        <i class="fas fa-envelope text-primary me-2"></i>Correo electrónico
                                    </label>
                                    <input type="email" class="form-control shadow-sm form-control-sm" id="email" name="email" value="<%= usuario.getEmail() %>" style="padding: 0.5rem 0.75rem;">
                                </div>

                                <div class="mb-3">
                                    <label for="rol" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                        <i class="fas fa-user-tag text-primary me-2"></i>Rol
                                    </label>
                                    <select id="rol" name="rol_id" class="form-select shadow-sm form-select-sm" style="padding: 0.5rem 0.75rem;">
                                        <option value="1" <%= (usuario.getRol().getIdRol() == 1) ? "selected" : "" %>>Administrador</option>
                                        <option value="2" <%= (usuario.getRol().getIdRol() == 2) ? "selected" : "" %>>Logística</option>
                                        <option value="3" <%= (usuario.getRol().getIdRol() == 3) ? "selected" : "" %>>Productor</option>
                                        <option value="4" <%= (usuario.getRol().getIdRol() == 4) ? "selected" : "" %>>Almacén</option>
                                    </select>
                                </div>

                                <!-- Campo de código de productor (solo visible si el rol es Productor) -->
                                <div class="mb-3" id="codigoProductorContainer" style="display: <%= (usuario.getRol().getIdRol() == 3) ? "block" : "none" %>;">
                                    <label for="codigo_productor" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                        <i class="fas fa-tag text-primary me-2"></i>Código de Productor
                                    </label>
                                    <input type="text" class="form-control shadow-sm form-control-sm" id="codigo_productor" name="codigo_productor" 
                                           value="<%= usuario.getCodigoProductor() != null ? usuario.getCodigoProductor() : "" %>"
                                           placeholder="Ej: PROD-0001" 
                                           pattern="PROD-[0-9]{4}" 
                                           title="Formato: PROD-0001"
                                           style="padding: 0.5rem 0.75rem;"
                                           <%= (usuario.getRol().getIdRol() != 3) ? "disabled" : "" %>>
                                    <small class="text-muted d-block mt-1" style="font-size: 0.8rem;">
                                        <i class="fas fa-info-circle me-1"></i> 
                                        Código único para identificar al productor. Formato: PROD-0001, PROD-0002, etc.
                                    </small>
                                </div>

                                <div class="mb-3 p-2 bg-light rounded border">
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="activo" name="activo" value="true" 
                                               <%= usuario.isActivo() ? "checked" : "" %> style="width: 2.5rem; height: 1.25rem; cursor: pointer;">
                                        <label class="form-check-label fw-semibold ms-2" for="activo" style="cursor: pointer; font-size: 0.9rem;">
                                            <i class="fas fa-toggle-<%= usuario.isActivo() ? "on" : "off" %> me-2 text-<%= usuario.isActivo() ? "success" : "secondary" %>"></i>
                                            Usuario Activo
                                        </label>
                                    </div>
                                    <small class="text-muted d-block mt-1 ms-4" style="font-size: 0.8rem;">
                                        <i class="fas fa-info-circle me-1"></i>
                                        Desmarcar esta casilla deshabilita el acceso del usuario al sistema.
                                    </small>
                                </div>

                                <div class="mt-3 pt-3 border-top d-flex justify-content-between align-items-center">
                                    <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-sm btn-outline-secondary shadow-sm">
                                        <i class="fas fa-times me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-sm btn-primary shadow-sm px-4">
                                        <i class="fas fa-save me-2"></i>Guardar cambios
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
<script>
    // Mostrar/ocultar campo de código de productor según el rol seleccionado
    document.addEventListener('DOMContentLoaded', function() {
        const rolSelect = document.getElementById('rol');
        const codigoProductorContainer = document.getElementById('codigoProductorContainer');
        const codigoProductorInput = document.getElementById('codigo_productor');
        
        function toggleCodigoProductor() {
            if (rolSelect.value === '3') { // Rol Productor
                codigoProductorContainer.style.display = 'block';
                codigoProductorInput.removeAttribute('disabled');
            } else {
                codigoProductorContainer.style.display = 'none';
                codigoProductorInput.setAttribute('disabled', 'disabled');
                codigoProductorInput.value = '';
            }
        }
        
        // Escuchar cambios en el select de rol
        rolSelect.addEventListener('change', toggleCodigoProductor);
    });
</script>
</body>
</html>
