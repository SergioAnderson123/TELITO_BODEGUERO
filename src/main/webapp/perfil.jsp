<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%
    Usuario usuarioPerfil = (Usuario) request.getAttribute("usuarioPerfil");
    if (usuarioPerfil == null) {
        usuarioPerfil = (Usuario) session.getAttribute("usuario");
    }
    
    if (usuarioPerfil == null) {
        response.sendRedirect(request.getContextPath() + "/acceso/login");
        return;
    }
    
    String mensaje = request.getParameter("successMsg");
    String error = request.getParameter("errorMsg");
    String rolNombre = usuarioPerfil.getRol() != null ? usuarioPerfil.getRol().getNombre() : "Usuario";
    
    // Guardar el referer para poder volver
    String refererUrl = (String) session.getAttribute("perfilReferer");
    if (refererUrl == null || refererUrl.isEmpty()) {
        String referer = request.getHeader("referer");
        if (referer != null && !referer.contains("/perfil")) {
            session.setAttribute("perfilReferer", referer);
            refererUrl = referer;
        }
    }
    
    // Construir la URL correcta de la foto
    String fotoUrl = usuarioPerfil.getFotoPerfil();
    if (fotoUrl != null && !fotoUrl.trim().isEmpty()) {
        // Si es una ruta local (no una URL externa), usar el ImageServlet
        if (!fotoUrl.startsWith("http://") && !fotoUrl.startsWith("https://")) {
            // La ruta viene como "uploads/perfiles/xxx.jpg", necesitamos "/uploads/perfiles/xxx.jpg"
            if (!fotoUrl.startsWith("/")) {
                fotoUrl = "/" + fotoUrl;
            }
            fotoUrl = request.getContextPath() + fotoUrl;
        }
    } else {
        // Si no hay foto, generar avatar con iniciales
        fotoUrl = usuarioPerfil.getFotoPerfilUrl();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perfil - Telito Bodeguero</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <!-- Incluir modales personalizados -->
    <jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />
    
    <style>
        :root {
            --turquoise-dark: #006d77;
            --seafoam: #83c5be;
            --seafoam-light: #edf6f9;
            --white: #ffffff;
            --text-dark: #2b2d42;
            --text-muted: #6c757d;
            --border-color: #e9ecef;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: var(--seafoam-light);
            color: var(--text-dark);
            min-height: 100vh;
            padding: 40px 0;
        }
        
        .profile-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .profile-card {
            background-color: var(--white);
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .profile-header {
            background: linear-gradient(135deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            padding: 40px;
            text-align: center;
            color: white;
        }
        
        .profile-photo {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 4px solid white;
            margin-bottom: 15px;
            object-fit: cover;
        }
        
        .profile-header h2 {
            margin: 0;
            font-size: 1.8rem;
            font-weight: 700;
        }
        
        .profile-role {
            display: inline-block;
            margin-top: 10px;
            padding: 6px 16px;
            background-color: rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            font-size: 0.9rem;
        }
        
        .profile-body {
            padding: 40px;
        }
        
        .form-label {
            color: var(--text-dark);
            font-weight: 600;
            margin-bottom: 8px;
        }
        
        .form-control:focus {
            border-color: var(--turquoise-dark);
            box-shadow: 0 0 0 0.2rem rgba(0, 109, 119, 0.15);
        }
        
        .btn-primary {
            background-color: var(--turquoise-dark);
            border-color: var(--turquoise-dark);
            padding: 10px 30px;
            font-weight: 600;
        }
        
        .btn-primary:hover {
            background-color: #055e68;
            border-color: #055e68;
        }
        
        .btn-secondary {
            background-color: var(--text-muted);
            border-color: var(--text-muted);
            padding: 10px 30px;
        }
        
        .alert {
            border-radius: 8px;
            margin-bottom: 25px;
        }
        
        .photo-preview-container {
            text-align: center;
            margin-bottom: 20px;
        }
        
        .photo-preview {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            margin: 15px auto;
            border: 3px solid var(--border-color);
            object-fit: cover;
        }
        
        .btn-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
    </style>
</head>
<body>

<div class="profile-container">
    <!-- Encabezado del perfil -->
    <div class="profile-card">
        <div class="profile-header">
            <img src="<%= fotoUrl %>" alt="Foto de perfil" class="profile-photo" id="headerPhoto">
            <h2><%= usuarioPerfil.getNombres() %> <%= usuarioPerfil.getApellidos() %></h2>
            <span class="profile-role"><i class="fas fa-user-tag me-2"></i><%= rolNombre %></span>
        </div>
        
        <div class="profile-body">
            <!-- Mensajes de éxito/error -->
            <% if (mensaje != null && !mensaje.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i><%= mensaje %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i><%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <!-- Formulario de edición de perfil -->
            <form action="${pageContext.request.contextPath}/perfil" method="post" id="perfilForm" enctype="multipart/form-data">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <label for="nombres" class="form-label">
                            <i class="fas fa-user me-2"></i>Nombres
                        </label>
                        <input type="text" class="form-control" id="nombres" name="nombres" 
                               value="<%= usuarioPerfil.getNombres() %>" required>
                    </div>
                    
                    <div class="col-md-6">
                        <label for="apellidos" class="form-label">
                            <i class="fas fa-user me-2"></i>Apellidos
                        </label>
                        <input type="text" class="form-control" id="apellidos" name="apellidos" 
                               value="<%= usuarioPerfil.getApellidos() %>" required>
                    </div>
                </div>
                
                <div class="mb-4">
                    <label for="email" class="form-label">
                        <i class="fas fa-envelope me-2"></i>Correo electrónico
                    </label>
                    <input type="email" class="form-control" id="email" name="email" 
                           value="<%= usuarioPerfil.getEmail() %>" disabled>
                    <small class="text-muted">El correo electrónico no se puede modificar</small>
                </div>
                
                <div class="mb-4">
                    <label class="form-label">
                        <i class="fas fa-camera me-2"></i>Foto de perfil
                    </label>
                    
                    <!-- Tabs para elegir entre archivo o URL -->
                    <ul class="nav nav-tabs mb-3" id="photoTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="file-tab" data-bs-toggle="tab" data-bs-target="#file-pane" type="button" role="tab">
                                <i class="fas fa-upload me-2"></i>Subir archivo
                            </button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="url-tab" data-bs-toggle="tab" data-bs-target="#url-pane" type="button" role="tab">
                                <i class="fas fa-link me-2"></i>Desde URL
                            </button>
                        </li>
                    </ul>
                    
                    <div class="tab-content" id="photoTabContent">
                        <!-- Tab: Subir archivo -->
                        <div class="tab-pane fade show active" id="file-pane" role="tabpanel">
                            <input type="file" class="form-control" id="fotoPerfilArchivo" name="fotoPerfilArchivo" 
                                   accept="image/jpeg,image/jpg,image/png,image/gif,image/webp">
                            <small class="text-muted">
                                Formatos permitidos: JPG, PNG, GIF, WEBP. Tamaño máximo: 5MB
                            </small>
                        </div>
                        
                        <!-- Tab: URL -->
                        <div class="tab-pane fade" id="url-pane" role="tabpanel">
                            <input type="url" class="form-control" id="fotoPerfil" name="fotoPerfil" 
                                   value="<%= usuarioPerfil.getFotoPerfil() != null && usuarioPerfil.getFotoPerfil().startsWith("http") ? usuarioPerfil.getFotoPerfil() : "" %>"
                                   placeholder="https://ejemplo.com/mi-foto.jpg">
                            <small class="text-muted">
                                Ingresa la URL de tu foto de perfil
                            </small>
                        </div>
                    </div>
                    
                    <!-- Vista previa de la foto -->
                    <div class="photo-preview-container">
                        <img src="<%= fotoUrl %>" alt="Vista previa" class="photo-preview" id="photoPreview">
                    </div>
                </div>
                
                <!-- Botones de acción -->
                <div class="btn-actions">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save me-2"></i>Guardar cambios
                    </button>
                    <%
                    String volverUrl = (String) session.getAttribute("perfilReferer");
                    if (volverUrl == null || volverUrl.isEmpty()) {
                        // Redirigir según el rol del usuario
                        volverUrl = com.example.telito.util.AuthorizationHelper.obtenerUrlRedireccionPorRol(session, request.getContextPath());
                    }
                    %>
                    <a href="<%= volverUrl %>" class="btn btn-secondary" id="btnVolver">
                        <i class="fas fa-arrow-left me-2"></i>Volver
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Script para vista previa de la foto -->
<script>
    // Vista previa desde URL
    document.getElementById('fotoPerfil').addEventListener('input', function() {
        const url = this.value.trim();
        const preview = document.getElementById('photoPreview');
        const headerPhoto = document.getElementById('headerPhoto');
        
        if (url) {
            const img = new Image();
            img.onload = function() {
                preview.src = url;
                headerPhoto.src = url;
            };
            img.onerror = function() {
                console.log('Error al cargar la imagen desde URL');
            };
            img.src = url;
        } else {
            updateDefaultAvatar();
        }
    });
    
    // Vista previa desde archivo local
    document.getElementById('fotoPerfilArchivo').addEventListener('change', function() {
        const file = this.files[0];
        const preview = document.getElementById('photoPreview');
        const headerPhoto = document.getElementById('headerPhoto');
        
        if (file) {
            // Validar el tamaño (5MB máximo)
            if (file.size > 5 * 1024 * 1024) {
                showAlert('El archivo es demasiado grande. El tamaño máximo es 5MB.', 'Archivo muy grande', 'warning');
                this.value = '';
                return;
            }
            
            // Validar el tipo
            const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
            if (!validTypes.includes(file.type)) {
                showAlert('Formato de archivo no válido. Use JPG, PNG, GIF o WEBP.', 'Formato no válido', 'warning');
                this.value = '';
                return;
            }
            
            // Mostrar vista previa
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                headerPhoto.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    });
    
    // Actualizar vista previa cuando cambian los nombres
    document.getElementById('nombres').addEventListener('input', updateDefaultAvatar);
    document.getElementById('apellidos').addEventListener('input', updateDefaultAvatar);
    
    function updateDefaultAvatar() {
        const fotoUrl = document.getElementById('fotoPerfil').value.trim();
        const fotoArchivo = document.getElementById('fotoPerfilArchivo').files[0];
        
        if (!fotoUrl && !fotoArchivo) {
            const nombres = document.getElementById('nombres').value;
            const apellidos = document.getElementById('apellidos').value;
            let iniciales = '';
            if (nombres) iniciales += nombres.charAt(0);
            if (apellidos) iniciales += apellidos.charAt(0);
            const defaultUrl = 'https://ui-avatars.com/api/?name=' + iniciales + '&background=006d77&color=fff&size=200';
            document.getElementById('photoPreview').src = defaultUrl;
            document.getElementById('headerPhoto').src = defaultUrl;
        }
    }
    
    // Limpiar el otro campo cuando se selecciona uno
    document.getElementById('file-tab').addEventListener('click', function() {
        document.getElementById('fotoPerfil').value = '';
    });
    
    document.getElementById('url-tab').addEventListener('click', function() {
        document.getElementById('fotoPerfilArchivo').value = '';
    });
    
    // Al hacer clic en volver, marcar para recargar la página destino y limpiar referer
    document.getElementById('btnVolver').addEventListener('click', function(e) {
        e.preventDefault(); // Prevenir navegación inmediata
        
        // Marcar para recargar
        sessionStorage.setItem('recargarDesdePerfil', 'true');
        
        // Limpiar el referer de la sesión
        fetch('<%= request.getContextPath() %>/perfil?clearReferer=true', { 
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        }).then(() => {
            // Navegar después de limpiar
            window.location.href = this.href;
        }).catch(() => {
            // Si falla, navegar de todos modos
            window.location.href = this.href;
        });
    });
</script>

</body>
</html>

