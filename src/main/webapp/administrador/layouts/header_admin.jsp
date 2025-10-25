<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%
    Usuario usuarioHeader = (Usuario) session.getAttribute("usuario");
    String nombreCompleto = usuarioHeader != null ? usuarioHeader.getNombres() + " " + usuarioHeader.getApellidos() : "Usuario";
    String fotoUrl = "https://ui-avatars.com/api/?name=User&background=006d77&color=fff&size=200";
    if (usuarioHeader != null) {
        String foto = usuarioHeader.getFotoPerfil();
        if (foto != null && !foto.trim().isEmpty()) {
            if (foto.startsWith("http://") || foto.startsWith("https://")) {
                fotoUrl = foto;
            } else {
                fotoUrl = request.getContextPath() + "/" + foto;
            }
        } else {
            fotoUrl = usuarioHeader.getFotoPerfilUrl();
        }
    }
%>
<div class="dashboard-header">
    <nav class="navbar navbar-expand">
        <div class="container-fluid">
            <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/inicio">
                <i class="fas fa-user-shield me-2" style="color: var(--seafoam);"></i>
                <span>Telito Bodeguero</span>
            </a>
            <ul class="navbar-nav ms-auto">
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                        <img src="<%= fotoUrl %>" alt="User" class="rounded-circle me-2" width="32" height="32">
                        <span style="color:#006d77;"><%= nombreCompleto %></span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/perfil"><i class="fas fa-user me-2"></i>Perfil</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesion</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </nav>
</div>

<script>
// Recargar página si se vuelve desde el perfil
if (sessionStorage.getItem('recargarDesdePerfil') === 'true') {
    sessionStorage.removeItem('recargarDesdePerfil');
    location.reload();
}
</script>

