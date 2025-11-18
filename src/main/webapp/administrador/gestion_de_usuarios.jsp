<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    ArrayList<Usuario> listaUsuarios = (ArrayList<Usuario>) request.getAttribute("lista");
    String busqueda = (String) request.getAttribute("busqueda");
    String rolFiltro = (String) request.getAttribute("rolFiltro");
    String estadoFiltro = (String) request.getAttribute("estadoFiltro");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) {
        session.removeAttribute("successMsg");
    }

    // Parámetros de ordenamiento actuales
    String currentSortBy = (String) request.getAttribute("sortBy");
    String currentSortOrder = (String) request.getAttribute("sortOrder");
%>

<%! // BLOQUE DE DECLARACIÓN JSP PARA MÉTODOS AUXILIARES
    // Función auxiliar para generar URLs de ordenamiento
    public String getSortUrl(jakarta.servlet.http.HttpServletRequest request, String sortByColumn, String currentSortBy, String currentSortOrder, String busqueda, String rolFiltro, String estadoFiltro, int size) {
        String newSortOrder = "asc";
        if (sortByColumn.equals(currentSortBy)) {
            newSortOrder = (currentSortOrder != null && currentSortOrder.equalsIgnoreCase("asc")) ? "desc" : "asc";
        }
        String baseUrl = request.getContextPath() + "/UsuarioServlet?action=listar";
        if (busqueda != null && !busqueda.isEmpty()) baseUrl += "&busqueda=" + busqueda;
        if (rolFiltro != null && !rolFiltro.isEmpty()) baseUrl += "&rol=" + rolFiltro;
        if (estadoFiltro != null && !estadoFiltro.isEmpty()) baseUrl += "&estado=" + estadoFiltro;
        baseUrl += "&sortBy=" + sortByColumn + "&sortOrder=" + newSortOrder + "&page=1&size=" + (size > 0 ? size : 5);
        return baseUrl;
    }

    // Función auxiliar para mostrar el icono de ordenamiento
    public String getSortIcon(String sortByColumn, String currentSortBy, String currentSortOrder) {
        if (sortByColumn.equals(currentSortBy)) {
            return (currentSortOrder != null && currentSortOrder.equalsIgnoreCase("asc")) ? "<i class=\"fas fa-sort-up ms-1\"></i>" : "<i class=\"fas fa-sort-down ms-1\"></i>";
        }
        return "<i class=\"fas fa-sort ms-1\"></i>"; // Icono por defecto para no ordenado
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Usuarios"/>
    </jsp:include>
    <style>
        /* Estilos mejorados para el dropdown de acciones */
        .dropdown-menu {
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            border: 1px solid rgba(0, 0, 0, 0.08) !important;
            animation: fadeInDown 0.2s ease-out;
        }
        
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .dropdown-item {
            border-radius: 4px;
            margin: 2px 8px;
        }
        
        .dropdown-item:hover {
            transform: translateX(3px);
        }
        
        /* Mejora del botón de acciones */
        .btn-outline-success:hover {
            transform: scale(1.05);
        }
        
        /* Estilos para el botón Agregar Usuario */
        .btn-agregar-usuario {
            transition: all 0.3s ease;
        }
        
        .btn-agregar-usuario:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(40, 167, 69, 0.4) !important;
        }
        
        /* Eliminar scroll horizontal de la tabla */
        #userTable {
            width: 100% !important;
            max-width: 100% !important;
        }
        
        #userTable th,
        #userTable td {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        /* Permitir que el dropdown sea visible en la columna de acciones */
        #userTable td:last-child {
            overflow: visible !important;
            position: relative;
        }
        
        #userTable td:last-child .dropdown {
            position: static;
        }
        
        #userTable td:last-child .dropdown-menu {
            position: absolute !important;
            right: 0 !important;
            left: auto !important;
            z-index: 1050 !important;
            transform: none !important;
        }
        
        /* Asegurar que el contenedor no corte el dropdown */
        .table-responsive,
        div[style*="overflow"] {
            overflow-y: visible !important;
        }
        
        #userTable th:nth-child(2),
        #userTable td:nth-child(2) {
            max-width: 200px;
        }
        
        #userTable th:nth-child(3),
        #userTable td:nth-child(3) {
            max-width: 250px;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Usuarios'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
    <% if (successMsg != null) { %>
    <div class="alert alert-success alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
        <%= successMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
    </div>
    <% } %>

    <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;">Gestión de Usuarios</h2>
        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra los usuarios del sistema.</p>
    </div>

    <div class="row">
        <div class="col-12">
            <div class="table-card shadow-sm">
                <div class="card-header" style="padding: 0.5rem 0.75rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-users me-2"></i>Tabla de Usuarios</h5>
                            <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los usuarios del sistema</small>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <%
                                // Construir URL de parámetros para mantener filtros en la exportación
                                String exportUrl = request.getContextPath() + "/UsuarioReporteServlet?action=exportar";
                                if (busqueda != null && !busqueda.isEmpty()) exportUrl += "&busqueda=" + java.net.URLEncoder.encode(busqueda, "UTF-8");
                                if (rolFiltro != null && !rolFiltro.isEmpty()) exportUrl += "&rol=" + rolFiltro;
                                if (estadoFiltro != null && !estadoFiltro.isEmpty()) exportUrl += "&estado=" + estadoFiltro;
                                if (currentSortBy != null && !currentSortBy.isEmpty()) exportUrl += "&sortBy=" + currentSortBy;
                                if (currentSortOrder != null && !currentSortOrder.isEmpty()) exportUrl += "&sortOrder=" + currentSortOrder;
                                
                                String sendUrl = request.getContextPath() + "/UsuarioReporteServlet?action=formEnviar";
                                if (busqueda != null && !busqueda.isEmpty()) sendUrl += "&busqueda=" + java.net.URLEncoder.encode(busqueda, "UTF-8");
                                if (rolFiltro != null && !rolFiltro.isEmpty()) sendUrl += "&rol=" + rolFiltro;
                                if (estadoFiltro != null && !estadoFiltro.isEmpty()) sendUrl += "&estado=" + estadoFiltro;
                                if (currentSortBy != null && !currentSortBy.isEmpty()) sendUrl += "&sortBy=" + currentSortBy;
                                if (currentSortOrder != null && !currentSortOrder.isEmpty()) sendUrl += "&sortOrder=" + currentSortOrder;
                            %>
                            <a href="<%= exportUrl %>" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                            </a>
                            <a href="<%= sendUrl %>" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-envelope me-1"></i>Enviar por Correo
                            </a>
                            <a href="<%= request.getContextPath() %>/UsuarioServlet?action=formCrear" class="btn btn-sm shadow-sm btn-agregar-usuario" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                                <i class="fas fa-plus me-1"></i>Agregar Usuario
                            </a>
                        </div>
                    </div>
                </div>
                <div class="card-body" style="padding: 0.75rem;">
                    <form action="<%= request.getContextPath() %>/UsuarioServlet" method="GET">
                        <input type="hidden" name="action" value="listar">
                        <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-md-4">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" placeholder="Nombre, correo o código..." value="<%= busqueda != null ? busqueda : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user-tag me-1"></i>Rol</label>
                                <select class="form-select form-select-sm shadow-sm" name="rol" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="" <%= (rolFiltro == null || rolFiltro.isEmpty()) ? "selected" : "" %>>Todos los Roles</option>
                                    <option value="1" <%= "1".equals(rolFiltro) ? "selected" : "" %>>Administrador</option>
                                    <option value="2" <%= "2".equals(rolFiltro) ? "selected" : "" %>>Logística</option>
                                    <option value="3" <%= "3".equals(rolFiltro) ? "selected" : "" %>>Productor</option>
                                    <option value="4" <%= "4".equals(rolFiltro) ? "selected" : "" %>>Almacén</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                                <select class="form-select form-select-sm shadow-sm" name="estado" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="" <%= (estadoFiltro == null || estadoFiltro.isEmpty()) ? "selected" : "" %>>Todos</option>
                                    <option value="1" <%= "1".equals(estadoFiltro) ? "selected" : "" %>>Activo</option>
                                    <option value="0" <%= "0".equals(estadoFiltro) ? "selected" : "" %>>Inactivo</option>
                                </select>
                            </div>
                            <div class="col-md-2 d-flex align-items-end">
                                <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-search me-1"></i>Buscar
                                </button>
                            </div>
                            <div class="col-md-2 d-flex align-items-end">
                                <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-sync-alt me-1"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>

                    <div style="width: 100%; position: relative;">
                        <table id="userTable" class="table table-hover align-middle mb-0 datatable-server-side" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                            <thead class="table-light">
                            <tr>
                                <th style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">#</th>
                                <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                    <a href="<%= getSortUrl(request, "usuario", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro, (Integer) (request.getAttribute("size") != null ? request.getAttribute("size") : 5)) %>" class="text-decoration-none text-dark fw-semibold">
                                        <i class="fas fa-user me-1"></i>Usuario<%= getSortIcon("usuario", currentSortBy, currentSortOrder) %>
                                    </a>
                                </th>
                                <th style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                    <a href="<%= getSortUrl(request, "correo", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro, (Integer) (request.getAttribute("size") != null ? request.getAttribute("size") : 5)) %>" class="text-decoration-none text-dark fw-semibold">
                                        <i class="fas fa-envelope me-1"></i>Correo<%= getSortIcon("correo", currentSortBy, currentSortOrder) %>
                                    </a>
                                </th>
                                <th style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                    <a href="<%= getSortUrl(request, "rol", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro, (Integer) (request.getAttribute("size") != null ? request.getAttribute("size") : 5)) %>" class="text-decoration-none text-dark fw-semibold">
                                        <i class="fas fa-user-tag me-1"></i>Rol<%= getSortIcon("rol", currentSortBy, currentSortOrder) %>
                                    </a>
                                </th>
                                <th style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                    <a href="<%= getSortUrl(request, "estado", currentSortBy, currentSortOrder, busqueda, rolFiltro, estadoFiltro, (Integer) (request.getAttribute("size") != null ? request.getAttribute("size") : 5)) %>" class="text-decoration-none text-dark fw-semibold">
                                        <i class="fas fa-toggle-on me-1"></i>Estado<%= getSortIcon("estado", currentSortBy, currentSortOrder) %>
                                    </a>
                                </th>
                                <th class="text-end fw-semibold text-success" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                    <i class="fas fa-cog me-1"></i>Acciones
                                </th>
                            </tr>
                            </thead>
                            <tbody>
                            <% 
                                Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                Integer sizeObj = (Integer) request.getAttribute("size");
                                int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                int contador = (currentPageInt - 1) * sizeInt + 1;
                            %>
                            <% if (listaUsuarios != null && !listaUsuarios.isEmpty()) { %>
                            <% for (Usuario usuario : listaUsuarios) {
                                String roleName = usuario.getRol().getNombre();
                                String badgeClass = "text-bg-secondary"; // Default color
                                switch (roleName) {
                                    case "Administrador":
                                        badgeClass = "text-bg-primary";
                                        break;
                                    case "Logística":
                                        badgeClass = "text-bg-info";
                                        break;
                                    case "Productor":
                                        badgeClass = "text-bg-success";
                                        break;
                                    case "Almacén":
                                        badgeClass = "text-bg-warning";
                                        break;
                                }
                            %>
                            <tr class="align-middle" style="padding: 0;">
                                <td class="text-muted" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= contador++ %></td>
                                <td style="padding: 0.35rem 0.5rem;">
                                    <div class="d-flex align-items-center">
                                        <div class="avatar-wrapper me-2">
                                            <%
                                                // Construir la URL correcta de la foto de perfil
                                                String fotoUrl = usuario.getFotoPerfil();
                                                if (fotoUrl != null && !fotoUrl.trim().isEmpty()) {
                                                    // Si es una ruta local (no una URL externa), usar el contexto
                                                    if (!fotoUrl.startsWith("http://") && !fotoUrl.startsWith("https://")) {
                                                        // La ruta viene como "uploads/perfiles/xxx.jpg", necesitamos "/uploads/perfiles/xxx.jpg"
                                                        if (!fotoUrl.startsWith("/")) {
                                                            fotoUrl = "/" + fotoUrl;
                                                        }
                                                        fotoUrl = request.getContextPath() + fotoUrl;
                                                    }
                                                } else {
                                                    // Si no hay foto, generar avatar con iniciales
                                                    fotoUrl = usuario.getFotoPerfilUrl();
                                                }
                                            %>
                                            <img src="<%= fotoUrl %>" 
                                                 alt="<%= usuario.getNombres() %> <%= usuario.getApellidos() %>" 
                                                 class="rounded-circle shadow-sm" 
                                                 width="38" 
                                                 height="38"
                                                 style="object-fit: cover; border: 2px solid #e9ecef;"
                                                 onerror="this.src='<%= usuario.getFotoPerfilUrl() %>'">
                                        </div>
                                        <div>
                                            <h6 class="mb-0 fw-semibold text-dark" style="font-size: 0.9rem; line-height: 1.2;"><%= usuario.getNombres() %> <%= usuario.getApellidos() %></h6>
                                            <small class="text-muted" style="font-size: 0.75rem; line-height: 1.2;">ID: <%= usuario.getIdUsuario() %></small>
                                        </div>
                                    </div>
                                </td>
                                <td style="padding: 0.35rem 0.5rem;">
                                    <div style="font-size: 0.85rem; line-height: 1.3;">
                                        <i class="fas fa-envelope text-muted me-1"></i>
                                        <span class="text-dark"><%= usuario.getEmail() %></span>
                                    </div>
                                    <% if (usuario.getCodigoProductor() != null && !usuario.getCodigoProductor().isEmpty()) { %>
                                        <div class="mt-0" style="margin-top: 0.2rem !important;">
                                            <span class="badge bg-info-subtle text-info border border-info" style="font-size: 0.7rem; padding: 0.15rem 0.4rem;">
                                                <i class="fas fa-tag me-1"></i><%= usuario.getCodigoProductor() %>
                                            </span>
                                        </div>
                                    <% } %>
                                </td>
                                <td style="padding: 0.35rem 0.5rem;">
                                    <span class="badge <%= badgeClass %> shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                        <i class="fas fa-user-tag me-1"></i><%= roleName %>
                                    </span>
                                </td>
                                <td style="padding: 0.35rem 0.5rem;">
                                    <% if (usuario.isActivo()) { %>
                                        <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-check-circle me-1"></i>Activo
                                        </span>
                                    <% } else { %>
                                        <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-times-circle me-1"></i>Inactivo
                                        </span>
                                    <% } %>
                                </td>
                                <td class="text-end" style="padding: 0.35rem 0.5rem;">
                                    <div class="dropdown">
                                        <button class="btn btn-sm btn-outline-success shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.35rem 0.6rem; border-color: #28a745; color: #28a745; transition: all 0.2s ease;" onmouseover="this.style.background='#28a745'; this.style.color='white';" onmouseout="this.style.background='transparent'; this.style.color='#28a745';">
                                            <i class="fas fa-ellipsis-v"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end shadow-lg border-0" style="min-width: 180px; font-size: 0.9rem; border-radius: 8px; padding: 8px 0; margin-top: 8px;">
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center py-2 px-3" href="<%= request.getContextPath() %>/UsuarioServlet?action=editar&id=<%= usuario.getIdUsuario() %>" style="transition: all 0.2s ease; color: #495057;" onmouseover="this.style.background='#e3f2fd'; this.style.color='#1976d2'; this.style.paddingLeft='20px';" onmouseout="this.style.background='transparent'; this.style.color='#495057'; this.style.paddingLeft='12px';">
                                                    <i class="fas fa-edit me-3" style="width: 20px; color: #1976d2; font-size: 1rem;"></i>
                                                    <span style="font-weight: 500;">Editar</span>
                                                </a>
                                            </li>
                                            <li><hr class="dropdown-divider my-1" style="margin: 4px 0;"></li>
                                            <li>
                                                <a class="dropdown-item d-flex align-items-center py-2 px-3" href="#" onclick="confirmarEliminar('<%= request.getContextPath() %>/UsuarioServlet?action=borrar&id=<%= usuario.getIdUsuario() %>'); return false;" style="transition: all 0.2s ease; color: #dc3545;" onmouseover="this.style.background='#ffebee'; this.style.color='#c62828'; this.style.paddingLeft='20px';" onmouseout="this.style.background='transparent'; this.style.color='#dc3545'; this.style.paddingLeft='12px';">
                                                    <i class="fas fa-trash-alt me-3" style="width: 20px; color: #dc3545; font-size: 1rem;"></i>
                                                    <span style="font-weight: 500;">Eliminar</span>
                                                </a>
                                            </li>
                                        </ul>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            <% } else { %>
                            <tr>
                                <td colspan="6" class="text-center py-5">
                                    <div class="text-muted">
                                        <i class="fas fa-users-slash fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                        <p class="mb-0">No se encontraron usuarios con los filtros aplicados.</p>
                                        <small>Intenta ajustar los filtros de búsqueda</small>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                        
                        <%-- Incluir componente de paginación --%>
                        <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                    </div>
                </div>
            </div>
        </div>
    </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<!-- Bootstrap JS ya está incluido en footer.jsp -->
<script>
    // Función para confirmar eliminación con modal personalizado
    function confirmarEliminar(url) {
        showConfirm(
            '¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.',
            function() {
                window.location.href = url;
            },
            'Confirmar eliminación'
        );
    }
    
    // Inicializar tooltips después de que la página cargue
    document.addEventListener('DOMContentLoaded', function() {
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    });
</script>
</body>
</html>