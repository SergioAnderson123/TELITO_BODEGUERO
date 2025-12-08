<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Crear Usuario"/>
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
            <div class="page-header mb-2">
                <h2 class="pageheader-title" style="font-size: 1.4rem;"><i class="fas fa-user-plus me-2"></i>Crear Nuevo Usuario</h2>
                <p class="pageheader-text" style="font-size: 0.85rem; margin-bottom: 0;">Complete los datos para registrar un nuevo usuario en el sistema.</p>
            </div>

            <div class="row">
                <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
                    <div class="card shadow-sm">
                        <div class="card-header bg-gradient-primary text-white mb-2" style="background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border-radius: 12px 12px 0 0; margin: -20px -20px 20px -20px; padding: 15px 20px;">
                            <h5 class="mb-0" style="font-size: 1.1rem;"><i class="fas fa-user-plus me-2"></i>Formulario de Registro</h5>
                            <small class="text-white-50" style="font-size: 0.8rem;">Complete todos los campos obligatorios marcados con <span class="text-white">*</span></small>
                        </div>
                        <div class="card-body" style="padding: 1.25rem;">
                            <%-- Mostrar errores de validación --%>
                            <%
                                java.util.ArrayList<String> errores = (java.util.ArrayList<String>) request.getAttribute("errores");
                                if (errores != null && !errores.isEmpty()) {
                            %>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert" style="padding: 0.75rem 1rem; margin-bottom: 1rem;">
                                <h6 class="alert-heading mb-2" style="font-size: 0.95rem;">
                                    <i class="fas fa-exclamation-triangle me-2"></i>Se encontraron los siguientes errores:
                                </h6>
                                <ul class="mb-0" style="font-size: 0.85rem; padding-left: 1.25rem;">
                                    <% for (String error : errores) { %>
                                        <li><%= error %></li>
                                    <% } %>
                                </ul>
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                            </div>
                            <% } %>
                            
                            <%-- Recuperar valores previos del formulario --%>
                            <%
                                String nombresPrevio = request.getAttribute("nombres") != null ? request.getAttribute("nombres").toString() : "";
                                String apellidosPrevio = request.getAttribute("apellidos") != null ? request.getAttribute("apellidos").toString() : "";
                                String emailPrevio = request.getAttribute("email") != null ? request.getAttribute("email").toString() : "";
                                String rolIdPrevio = request.getAttribute("rol_id") != null ? request.getAttribute("rol_id").toString() : "";
                            %>
                            
                            <form action="<%= request.getContextPath() %>/UsuarioServlet?action=guardar" method="POST" autocomplete="off" id="formCrearUsuario">
                                <div class="row">
                                    <div class="col-md-6 mb-2">
                                        <label for="nombres" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                            <i class="fas fa-user text-primary me-2"></i>Nombres <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control shadow-sm" id="nombres" name="nombres" 
                                               value="<%= nombresPrevio %>" placeholder="Ej: Juan" required style="font-size: 0.9rem; padding: 0.5rem 0.75rem;">
                                    </div>
                                    <div class="col-md-6 mb-2">
                                        <label for="apellidos" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                            <i class="fas fa-user text-primary me-2"></i>Apellidos <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control shadow-sm" id="apellidos" name="apellidos" 
                                               value="<%= apellidosPrevio %>" placeholder="Ej: Pérez" required style="font-size: 0.9rem; padding: 0.5rem 0.75rem;">
                                    </div>
                                </div>

                                <div class="mb-2">
                                    <label for="email" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                        <i class="fas fa-envelope text-primary me-2"></i>Correo electrónico <span class="text-danger">*</span>
                                    </label>
                                    <input type="email" class="form-control shadow-sm" id="email" name="email" 
                                           value="<%= emailPrevio %>" placeholder="Ej: juan.perez@example.com" required style="font-size: 0.9rem; padding: 0.5rem 0.75rem;">
                                </div>

                                <div class="mb-2">
                                    <label for="password" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                        <i class="fas fa-lock text-primary me-2"></i>Contraseña <span class="text-danger">*</span>
                                    </label>
                                    <input type="password" class="form-control shadow-sm" id="password" name="password" placeholder="********" required style="font-size: 0.9rem; padding: 0.5rem 0.75rem;">
                                    <small class="text-muted d-block mt-1" style="font-size: 0.75rem;">
                                        <i class="fas fa-info-circle me-1"></i>Mínimo 4 caracteres
                                    </small>
                                </div>

                                <div class="mb-2">
                                    <label for="rol" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                        <i class="fas fa-user-tag text-primary me-2"></i>Rol <span class="text-danger">*</span>
                                    </label>
                                    <select id="rol" name="rol_id" class="form-select shadow-sm" required style="font-size: 0.9rem; padding: 0.5rem 0.75rem;">
                                        <option value="" <%= rolIdPrevio.isEmpty() ? "selected" : "" %> disabled>Selecciona un rol</option>
                                        <option value="1" <%= "1".equals(rolIdPrevio) ? "selected" : "" %>>Administrador</option>
                                        <option value="2" <%= "2".equals(rolIdPrevio) ? "selected" : "" %>>Logística</option>
                                        <option value="3" <%= "3".equals(rolIdPrevio) ? "selected" : "" %>>Productor</option>
                                        <option value="4" <%= "4".equals(rolIdPrevio) ? "selected" : "" %>>Almacén</option>
                                    </select>
                                </div>

                                <!-- Campo de código de productor (solo visible si el rol es Productor) -->
                                <div class="mb-2" id="codigoProductorContainer" style="display: none;">
                                    <label for="codigo_productor" class="form-label fw-semibold" style="font-size: 0.9rem; margin-bottom: 0.4rem;">
                                        <i class="fas fa-tag text-primary me-2"></i>Código de Productor
                                    </label>
                                    <input type="text" class="form-control shadow-sm" id="codigo_productor" name="codigo_productor" 
                                           placeholder="Ej: PROD-0001 (se generará automáticamente si se deja vacío)" 
                                           pattern="PROD-[0-9]{4}" 
                                           title="Formato: PROD-0001" style="font-size: 0.9rem; padding: 0.5rem 0.75rem;">
                                    <small class="text-muted d-block mt-1" style="font-size: 0.75rem;">
                                        <i class="fas fa-info-circle me-1"></i> 
                                        Si se deja vacío, se generará automáticamente. Formato: PROD-0001, PROD-0002, etc.
                                    </small>
                                </div>

                                <div class="mt-3 pt-3 border-top d-flex justify-content-between align-items-center">
                                    <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-outline-secondary shadow-sm btn-sm" style="font-size: 0.85rem; padding: 0.4rem 0.9rem;">
                                        <i class="fas fa-times me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-primary shadow-sm btn-sm" style="font-size: 0.85rem; padding: 0.4rem 1.2rem;">
                                        <i class="fas fa-save me-2"></i>Crear Usuario
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
        
        // Verificar el valor inicial
        toggleCodigoProductor();
        
        // Escuchar cambios en el select de rol
        rolSelect.addEventListener('change', toggleCodigoProductor);
    });
</script>
</body>
</html>
