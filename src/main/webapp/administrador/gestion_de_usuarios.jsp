<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%@ page import="com.example.telito.almacen.beans.Distrito" %>
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
    
    // Cargar distritos para el select de Gerente de Tienda
    ArrayList<Distrito> distritos = (ArrayList<Distrito>) request.getAttribute("distritos");
    if (distritos == null) {
        distritos = new ArrayList<>();
    }
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
        /* Estilos para stat-cards */
        .stats-container { display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; margin-bottom: 40px; }
        .stat-card {
            background-color: #ffffff;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
        }
        .stat-card h3 { margin: 0 0 10px 0; font-size: 1rem; color: #6c757d; font-weight: 600; }
        .stat-card p { margin: 0; font-size: 2rem; font-weight: 800; color: #00a896; }
        @media (max-width: 768px) {
            .stats-container { grid-template-columns: 1fr; }
        }
        /* Estilo para el botón Limpiar */
        .btn-outline-secondary {
            color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-color: transparent !important;
            background-image: none !important;
        }
        .btn-outline-secondary:hover {
            color: #fff !important;
            background-color: #6c757d !important;
            border: 1px solid #6c757d !important;
            background-image: none !important;
        }
    </style>
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
        
        /* ===================== Estilos para Modal de Agregar Usuario ===================== */
        #addUserModal.modal { 
            display: none; 
            position: fixed; 
            z-index: 1050; 
            left: 0; 
            top: 0; 
            width: 100%; 
            height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(4px);
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        #addUserModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #addUserModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 700px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        @keyframes modalSlideIn { 
            from { 
                transform: scale(0.9) translateY(-20px); 
                opacity: 0; 
            } 
            to { 
                transform: scale(1) translateY(0); 
                opacity: 1; 
            } 
        }
        #addUserModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #addUserModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #addUserModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #addUserModal .modal-close { 
            color: white; 
            font-size: 24px; 
            font-weight: normal; 
            cursor: pointer; 
            opacity: 0.9; 
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        #addUserModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #addUserModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 160px);
        }
        #addUserModal .form-group {
            margin-bottom: 1rem;
        }
        #addUserModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #addUserModal .form-group label i {
            color: #00a896;
            font-size: 0.85rem;
        }
        #addUserModal .form-group input,
        #addUserModal .form-group select {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #addUserModal .form-group input:focus,
        #addUserModal .form-group select:focus {
            border-color: #00a896;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #addUserModal .form-hint {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #6c757d;
            font-size: 0.8rem;
            margin-top: 6px;
            padding: 8px 12px;
            background: rgba(0,168,150,0.05);
            border-radius: 6px;
        }
        #addUserModal .form-hint i {
            color: #00a896;
            flex-shrink: 0;
        }
        #addUserModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #addUserModal .modal-footer button {
            padding: 12px 28px;
            font-size: 0.95rem;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #addUserModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #addUserModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #addUserModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(40,167,69,0.3);
        }
        #addUserModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(40,167,69,0.4);
        }
        @media (max-width: 768px) {
            #addUserModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #addUserModal.show {
                padding: 10px;
            }
        }
        
        /* ===================== Estilos para Modal de Enviar por Correo ===================== */
        #sendEmailModal.modal { 
            display: none; 
            position: fixed; 
            z-index: 1050; 
            left: 0; 
            top: 0; 
            width: 100%; 
            height: 100%; 
            background-color: rgba(0,0,0,0.6); 
            backdrop-filter: blur(4px);
            overflow-y: auto;
            -webkit-overflow-scrolling: touch;
        }
        #sendEmailModal.show {
            display: flex !important;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        #sendEmailModal .modal-content { 
            background-color: #ffffff; 
            width: 100%;
            max-width: 700px; 
            max-height: 90vh; 
            border: none; 
            border-radius: 16px; 
            box-shadow: 0 20px 60px rgba(0,0,0,0.3); 
            animation: modalSlideIn 0.4s cubic-bezier(0.16, 1, 0.3, 1);
            position: relative;
            display: flex;
            flex-direction: column;
        }
        #sendEmailModal .modal-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%); 
            padding: 20px 25px; 
            border-radius: 16px 16px 0 0;
            box-shadow: 0 4px 12px rgba(0,168,150,0.2);
        }
        #sendEmailModal .modal-header h2 { 
            margin: 0; 
            color: white; 
            font-size: 1.4rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        #sendEmailModal .modal-header h2 i {
            background: rgba(255,255,255,0.2);
            padding: 8px;
            border-radius: 8px;
        }
        #sendEmailModal .modal-close { 
            color: white; 
            font-size: 24px; 
            font-weight: normal; 
            cursor: pointer; 
            opacity: 0.9; 
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: rgba(255,255,255,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        #sendEmailModal .modal-close:hover { 
            opacity: 1; 
            background: rgba(255,255,255,0.2);
            transform: rotate(90deg);
        }
        #sendEmailModal .modal-body {
            padding: 25px;
            overflow-y: auto;
            max-height: calc(90vh - 200px);
        }
        #sendEmailModal .form-group {
            margin-bottom: 1.25rem;
        }
        #sendEmailModal .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        #sendEmailModal .form-group label i {
            color: #00a896;
            font-size: 0.85rem;
        }
        #sendEmailModal .form-group input,
        #sendEmailModal .form-group textarea {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }
        #sendEmailModal .form-group input:focus,
        #sendEmailModal .form-group textarea:focus {
            border-color: #00a896;
            outline: none;
            box-shadow: 0 0 0 3px rgba(0,168,150,0.1);
        }
        #sendEmailModal .form-hint {
            display: flex;
            align-items: center;
            gap: 6px;
            color: #6c757d;
            font-size: 0.8rem;
            margin-top: 6px;
            padding: 8px 12px;
            background: rgba(0,168,150,0.05);
            border-radius: 6px;
        }
        #sendEmailModal .form-hint i {
            color: #00a896;
            flex-shrink: 0;
        }
        #sendEmailModal .alert-info {
            background: rgba(0,168,150,0.1);
            border-left: 4px solid #00a896;
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
        }
        #sendEmailModal .alert-warning {
            background: rgba(255,193,7,0.1);
            border-left: 4px solid #ffc107;
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
        }
        #sendEmailModal .modal-footer { 
            display: flex; 
            justify-content: flex-end; 
            gap: 12px; 
            padding: 20px 25px; 
            border-top: 2px solid #e9ecef;
            background: #f8f9fa;
            border-radius: 0 0 16px 16px;
        }
        #sendEmailModal .modal-footer button {
            padding: 12px 28px;
            font-size: 0.95rem;
            font-weight: 600;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        #sendEmailModal .modal-footer .btn-secondary {
            background: #6c757d;
            color: white;
        }
        #sendEmailModal .modal-footer .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(108,117,125,0.3);
        }
        #sendEmailModal .modal-footer button[type="submit"] {
            background: linear-gradient(135deg, #00a896 0%, #028f80 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(0,168,150,0.3);
        }
        #sendEmailModal .modal-footer button[type="submit"]:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(0,168,150,0.4);
        }
        @media (max-width: 768px) {
            #sendEmailModal .modal-content {
                width: 95%;
                max-width: 95%;
                max-height: 95vh;
                margin: 10px;
            }
            #sendEmailModal.show {
                padding: 10px;
            }
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
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
            <div>
                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-users me-2"></i>Gestión de Usuarios</h2>
                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra los usuarios del sistema.</p>
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
                <button type="button" id="openSendEmailModalBtn" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                    <i class="fas fa-envelope me-1"></i>Enviar por Correo
                </button>
                <button type="button" id="openModalBtn" class="btn btn-sm shadow-sm btn-agregar-usuario" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                    <i class="fas fa-plus me-1"></i>Agregar Usuario
                </button>
            </div>
        </div>
    </div>

    <%
        // Obtener estadísticas del servlet
        Integer totalUsuariosAttr = (Integer) request.getAttribute("totalUsuarios");
        Integer usuariosActivosAttr = (Integer) request.getAttribute("usuariosActivos");
        Integer usuariosInactivosAttr = (Integer) request.getAttribute("usuariosInactivos");
        int totalUsuarios = (totalUsuariosAttr != null) ? totalUsuariosAttr : 0;
        int usuariosActivos = (usuariosActivosAttr != null) ? usuariosActivosAttr : 0;
        int usuariosInactivos = (usuariosInactivosAttr != null) ? usuariosInactivosAttr : 0;
    %>

    <!-- ===================== Tarjetas de estadísticas ===================== -->
    <div class="stats-container">
        <div class="stat-card">
            <h3>Total de Usuarios</h3>
            <p><%= totalUsuarios %></p>
        </div>
        <div class="stat-card">
            <h3>Activos</h3>
            <p><%= usuariosActivos %></p>
        </div>
        <div class="stat-card">
            <h3>Inactivos</h3>
            <p><%= usuariosInactivos %></p>
        </div>
    </div>

    <!-- ===================== Card: Búsqueda y filtros ===================== -->
    <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
        <form action="<%= request.getContextPath() %>/UsuarioServlet" method="GET" id="filterForm">
            <input type="hidden" name="action" value="listar">
            <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
            <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                <div class="col-xl-5 col-lg-5 col-md-12 col-sm-12">
                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                    <div class="input-group">
                        <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="Nombre, correo o código..." value="<%= busqueda != null ? busqueda : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6">
                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-user-tag me-1"></i>Rol</label>
                    <select class="form-select form-select-sm shadow-sm" name="rol" id="rolFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <option value="" <%= (rolFiltro == null || rolFiltro.isEmpty()) ? "selected" : "" %>>Todos los Roles</option>
                        <option value="1" <%= "1".equals(rolFiltro) ? "selected" : "" %>>Administrador</option>
                        <option value="2" <%= "2".equals(rolFiltro) ? "selected" : "" %>>Logística</option>
                        <option value="3" <%= "3".equals(rolFiltro) ? "selected" : "" %>>Productor</option>
                        <option value="4" <%= "4".equals(rolFiltro) ? "selected" : "" %>>Almacén</option>
                        <option value="7" <%= "7".equals(rolFiltro) ? "selected" : "" %>>Gerente de Tienda</option>
                    </select>
                </div>
                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6">
                    <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                    <select class="form-select form-select-sm shadow-sm" name="estado" id="estadoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <option value="" <%= (estadoFiltro == null || estadoFiltro.isEmpty()) ? "selected" : "" %>>Todos</option>
                        <option value="1" <%= "1".equals(estadoFiltro) ? "selected" : "" %>>Activo</option>
                        <option value="0" <%= "0".equals(estadoFiltro) ? "selected" : "" %>>Inactivo</option>
                    </select>
                </div>
                <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6 d-flex align-items-end">
                    <a href="<%= request.getContextPath() %>/UsuarioServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                        <i class="fas fa-sync-alt me-1"></i>Limpiar
                    </a>
                </div>
            </div>
        </form>
    </div>

    <!-- ===================== Card: Tabla de usuarios ===================== -->
    <div class="row">
        <div class="col-12">
            <div class="table-card shadow-sm">
                <div class="card-header" style="padding: 0.5rem 0.75rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-users me-2"></i>Tabla de Usuarios</h5>
                            <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los usuarios del sistema</small>
                        </div>
                    </div>
                </div>
                <div class="card-body" style="padding: 0.75rem;">

                    <div class="table-responsive">
                        <table id="userTable" class="table table-hover align-middle mb-0 datatable-server-side" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                            <thead class="table-light">
                            <tr>
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
                                        <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
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
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const rolFilter = document.getElementById('rolFilter');
        const estadoFilter = document.getElementById('estadoFilter');
        
        // Variable para el timeout del debounce
        let searchTimeout = null;
        
        // Aplicar filtros automáticamente mientras se escribe en el campo de búsqueda (con debounce)
        if (searchInput && filterForm) {
            searchInput.addEventListener('input', function(e) {
                // Limpiar el timeout anterior
                if (searchTimeout) {
                    clearTimeout(searchTimeout);
                }
                
                // Esperar 500ms después de que el usuario deje de escribir antes de enviar
                searchTimeout = setTimeout(function() {
                    filterForm.submit();
                }, 500);
            });
            
            // Aplicar filtros al presionar Enter en el campo de búsqueda (inmediato)
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    // Cancelar el timeout si existe
                    if (searchTimeout) {
                        clearTimeout(searchTimeout);
                    }
                    filterForm.submit();
                }
            });
        }
        
        // Aplicar filtros cuando cambien los selects
        if (rolFilter && filterForm) {
            rolFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (estadoFilter && filterForm) {
            estadoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
    });

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
        
        // ===================== Manejo del Modal de Agregar Usuario =====================
        const addUserModal = document.getElementById('addUserModal');
        const openModalBtn = document.getElementById('openModalBtn');
        const closeModalBtn = document.querySelector('#addUserModal .modal-close');
        const cancelModalBtn = document.querySelector('#addUserModal .modal-cancel');
        const rolSelect = document.getElementById('modalRol');
        const codigoProductorContainer = document.getElementById('modalCodigoProductorContainer');
        const codigoProductorInput = document.getElementById('modalCodigoProductor');
        const distritoContainer = document.getElementById('modalDistritoContainer');
        const distritoSelect = document.getElementById('modalDistrito');
        
        // Función para abrir el modal
        function abrirModalUsuario() {
            if (addUserModal) {
                addUserModal.classList.add('show');
                addUserModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
                limpiarFormularioUsuario();
                toggleCodigoProductor();
                toggleDistrito();
            } else {
                console.error('Modal no encontrado');
            }
        }
        
        // Función para cerrar el modal
        function cerrarModalUsuario() {
            if (addUserModal) {
                addUserModal.classList.remove('show');
                addUserModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Función para limpiar el formulario
        function limpiarFormularioUsuario() {
            const nombres = document.getElementById('modalNombres');
            const apellidos = document.getElementById('modalApellidos');
            const email = document.getElementById('modalEmail');
            const password = document.getElementById('modalPassword');
            const passwordConfirm = document.getElementById('modalPasswordConfirm');
            
            if (nombres) nombres.value = '';
            if (apellidos) apellidos.value = '';
            if (email) email.value = '';
            if (password) password.value = '';
            if (passwordConfirm) passwordConfirm.value = '';
            if (rolSelect) rolSelect.selectedIndex = 0;
            if (codigoProductorInput) codigoProductorInput.value = '';
            if (codigoProductorContainer) codigoProductorContainer.style.display = 'none';
            if (distritoSelect) distritoSelect.selectedIndex = 0;
            if (distritoContainer) distritoContainer.style.display = 'none';
        }
        
        // Validación de contraseñas coincidentes
        const formAgregarUsuario = document.getElementById('formAgregarUsuario');
        if (formAgregarUsuario) {
            formAgregarUsuario.addEventListener('submit', function(e) {
                const password = document.getElementById('modalPassword').value;
                const passwordConfirm = document.getElementById('modalPasswordConfirm').value;
                
                if (password !== passwordConfirm) {
                    e.preventDefault();
                    alert('Las contraseñas no coinciden. Por favor, verifica que ambas contraseñas sean iguales.');
                    document.getElementById('modalPasswordConfirm').focus();
                    return false;
                }
            });
        }
        
        // Función para mostrar/ocultar campo de código de productor
        function toggleCodigoProductor() {
            if (rolSelect && codigoProductorContainer && codigoProductorInput) {
                if (rolSelect.value === '3') { // Rol Productor
                    codigoProductorContainer.style.display = 'block';
                    codigoProductorInput.removeAttribute('disabled');
                } else {
                    codigoProductorContainer.style.display = 'none';
                    codigoProductorInput.setAttribute('disabled', 'disabled');
                    codigoProductorInput.value = '';
                }
            }
        }
        
        // Función para mostrar/ocultar campo de distrito
        function toggleDistrito() {
            if (rolSelect && distritoContainer && distritoSelect) {
                if (rolSelect.value === '7') { // Rol Gerente de Tienda
                    distritoContainer.style.display = 'block';
                    distritoSelect.removeAttribute('disabled');
                    distritoSelect.setAttribute('required', 'required');
                } else {
                    distritoContainer.style.display = 'none';
                    distritoSelect.setAttribute('disabled', 'disabled');
                    distritoSelect.removeAttribute('required');
                    distritoSelect.selectedIndex = 0;
                }
            }
        }
        
        // Event listeners
        if (openModalBtn) {
            openModalBtn.addEventListener('click', function(e) {
                e.preventDefault();
                abrirModalUsuario();
            });
        } else {
            console.error('Botón openModalBtn no encontrado');
        }
        
        if (closeModalBtn) {
            closeModalBtn.addEventListener('click', cerrarModalUsuario);
        }
        
        if (cancelModalBtn) {
            cancelModalBtn.addEventListener('click', cerrarModalUsuario);
        }
        
        if (rolSelect) {
            rolSelect.addEventListener('change', function() {
                toggleCodigoProductor();
                toggleDistrito();
            });
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (addUserModal) {
            addUserModal.addEventListener('click', function(event) {
                if (event.target === addUserModal) {
                    cerrarModalUsuario();
                }
            });
        }
        
        // Cerrar modal con la tecla ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && addUserModal && addUserModal.classList.contains('show')) {
                cerrarModalUsuario();
            }
        });
        
        // ===================== Manejo del Modal de Enviar por Correo =====================
        const sendEmailModal = document.getElementById('sendEmailModal');
        const openSendEmailModalBtn = document.getElementById('openSendEmailModalBtn');
        const closeSendEmailModalBtn = document.querySelector('#sendEmailModal .modal-close');
        const cancelSendEmailModalBtn = document.querySelector('#sendEmailModal .modal-cancel');
        
        // Función para obtener los filtros actuales de la URL
        function obtenerFiltrosActuales() {
            const urlParams = new URLSearchParams(window.location.search);
            const busqueda = urlParams.get('busqueda') || '';
            const rol = urlParams.get('rol') || '';
            const estado = urlParams.get('estado') || '';
            const sortBy = urlParams.get('sortBy') || '';
            const sortOrder = urlParams.get('sortOrder') || '';
            
            return { busqueda, rol, estado, sortBy, sortOrder };
        }
        
        // Función para generar información de filtros
        function generarInfoFiltros(filtros) {
            let info = [];
            if (filtros.busqueda) info.push('Búsqueda: ' + filtros.busqueda);
            if (filtros.rol) {
                const rolNames = { '1': 'Administrador', '2': 'Logística', '3': 'Productor', '4': 'Almacén' };
                info.push('Rol: ' + (rolNames[filtros.rol] || filtros.rol));
            }
            if (filtros.estado) {
                info.push('Estado: ' + (filtros.estado === '1' ? 'Activo' : 'Inactivo'));
            }
            return info.length > 0 ? info.join('; ') : 'Sin filtros aplicados';
        }
        
        // Función para abrir el modal de enviar correo
        function abrirModalEnviarCorreo() {
            if (sendEmailModal) {
                const filtros = obtenerFiltrosActuales();
                
                // Actualizar campos hidden del formulario
                const busquedaInput = document.getElementById('modalBusqueda');
                const rolInput = document.getElementById('modalRolFiltro');
                const estadoInput = document.getElementById('modalEstadoFiltro');
                
                if (busquedaInput) busquedaInput.value = filtros.busqueda;
                if (rolInput) rolInput.value = filtros.rol;
                if (estadoInput) estadoInput.value = filtros.estado;
                
                // Limpiar formulario
                document.getElementById('modalEmailDestino').value = '';
                document.getElementById('modalAsunto').value = 'Reporte de Usuarios - TELITO BODEGUERO';
                document.getElementById('modalMensaje').value = '';
                
                sendEmailModal.classList.add('show');
                sendEmailModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            } else {
                console.error('Modal sendEmailModal no encontrado');
            }
        }
        
        // Función para cerrar el modal de enviar correo
        function cerrarModalEnviarCorreo() {
            if (sendEmailModal) {
                sendEmailModal.classList.remove('show');
                sendEmailModal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
        
        // Event listeners para el modal de enviar correo
        if (openSendEmailModalBtn) {
            openSendEmailModalBtn.addEventListener('click', function(e) {
                e.preventDefault();
                abrirModalEnviarCorreo();
            });
        } else {
            console.error('Botón openSendEmailModalBtn no encontrado');
        }
        
        if (closeSendEmailModalBtn) {
            closeSendEmailModalBtn.addEventListener('click', cerrarModalEnviarCorreo);
        }
        
        if (cancelSendEmailModalBtn) {
            cancelSendEmailModalBtn.addEventListener('click', cerrarModalEnviarCorreo);
        }
        
        // Cerrar modal al hacer clic fuera del contenido
        if (sendEmailModal) {
            sendEmailModal.addEventListener('click', function(event) {
                if (event.target === sendEmailModal) {
                    cerrarModalEnviarCorreo();
                }
            });
        }
        
        // Cerrar modal con la tecla ESC
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && sendEmailModal && sendEmailModal.classList.contains('show')) {
                cerrarModalEnviarCorreo();
            }
        });
    });
</script>

<!-- ===================== Modal: Agregar Usuario ===================== -->
<div id="addUserModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-user-plus"></i> Agregar Nuevo Usuario</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/UsuarioServlet?action=guardar" id="formAgregarUsuario">
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalNombres">
                                <i class="fas fa-user"></i>
                                Nombres <span class="text-danger">*</span>
                            </label>
                            <input type="text" 
                                   name="nombres" 
                                   id="modalNombres" 
                                   placeholder="Ej: Juan" 
                                   required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalApellidos">
                                <i class="fas fa-user"></i>
                                Apellidos <span class="text-danger">*</span>
                            </label>
                            <input type="text" 
                                   name="apellidos" 
                                   id="modalApellidos" 
                                   placeholder="Ej: Pérez" 
                                   required>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalEmail">
                        <i class="fas fa-envelope"></i>
                        Correo electrónico <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email" 
                           id="modalEmail" 
                           placeholder="Ej: juan.perez@example.com" 
                           required>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalPassword">
                                <i class="fas fa-lock"></i>
                                Contraseña <span class="text-danger">*</span>
                            </label>
                            <input type="password" 
                                   name="password" 
                                   id="modalPassword" 
                                   placeholder="********" 
                                   required>
                            <div class="form-hint">
                                <i class="fas fa-info-circle"></i>
                                <span>Mínimo 4 caracteres</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="modalPasswordConfirm">
                                <i class="fas fa-lock"></i>
                                Confirmar Contraseña <span class="text-danger">*</span>
                            </label>
                            <input type="password" 
                                   id="modalPasswordConfirm" 
                                   placeholder="********" 
                                   required>
                            <div class="form-hint">
                                <i class="fas fa-info-circle"></i>
                                <span>Repite la contraseña</span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalRol">
                        <i class="fas fa-user-tag"></i>
                        Rol <span class="text-danger">*</span>
                    </label>
                    <select name="rol_id" id="modalRol" required>
                        <option value="" disabled selected>Selecciona un rol</option>
                        <option value="1">Administrador</option>
                        <option value="2">Logística</option>
                        <option value="3">Productor</option>
                        <option value="4">Almacén</option>
                        <option value="7">Gerente de Tienda</option>
                    </select>
                </div>
                
                <!-- Campo de código de productor (solo visible si el rol es Productor) -->
                <div class="form-group" id="modalCodigoProductorContainer" style="display: none;">
                    <label for="modalCodigoProductor">
                        <i class="fas fa-tag"></i>
                        Código de Productor
                    </label>
                    <input type="text" 
                           name="codigo_productor" 
                           id="modalCodigoProductor" 
                           placeholder="Ej: PROD-0001 (se generará automáticamente si se deja vacío)" 
                           pattern="PROD-[0-9]{4}" 
                           title="Formato: PROD-0001"
                           disabled>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Si se deja vacío, se generará automáticamente. Formato: PROD-0001, PROD-0002, etc.</span>
                    </div>
                </div>
                
                <!-- Campo de distrito (solo visible si el rol es Gerente de Tienda) -->
                <div class="form-group" id="modalDistritoContainer" style="display: none;">
                    <label for="modalDistrito">
                        <i class="fas fa-map-marker-alt"></i>
                        Distrito <span class="text-danger">*</span>
                    </label>
                    <select name="distrito_id" id="modalDistrito" required disabled>
                        <option value="" disabled selected>Selecciona un distrito</option>
                        <% for (Distrito distrito : distritos) { %>
                            <option value="<%= distrito.getIdDistrito() %>"><%= distrito.getNombre() %></option>
                        <% } %>
                    </select>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Selecciona el distrito donde trabajará este gerente de tienda.</span>
                    </div>
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-check"></i>
                    Crear Usuario
                </button>
            </div>
        </form>
    </div>
</div>

<!-- ===================== Modal: Enviar Reporte por Correo ===================== -->
<div id="sendEmailModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/UsuarioReporteServlet" id="formEnviarCorreo">
            <input type="hidden" name="action" value="enviar">
            <input type="hidden" name="busqueda" id="modalBusqueda" value="">
            <input type="hidden" name="rol" id="modalRolFiltro" value="">
            <input type="hidden" name="estado" id="modalEstadoFiltro" value="">
            
            <div class="modal-body">
                <div class="form-group">
                    <label for="modalEmailDestino">
                        <i class="fas fa-envelope"></i>
                        Email de Destino <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email_destino" 
                           id="modalEmailDestino" 
                           placeholder="correo@ejemplo.com" 
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingresa el correo electrónico donde deseas recibir el reporte.</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalAsunto">
                        <i class="fas fa-tag"></i>
                        Asunto del Correo
                    </label>
                    <input type="text" 
                           name="asunto" 
                           id="modalAsunto" 
                           value="Reporte de Usuarios - TELITO BODEGUERO" 
                           placeholder="Asunto del correo">
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Si no especificas un asunto, se usará uno por defecto.</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalMensaje">
                        <i class="fas fa-comment"></i>
                        Mensaje Adicional (Opcional)
                    </label>
                    <textarea name="mensaje" 
                              id="modalMensaje" 
                              rows="4" 
                              placeholder="Escribe un mensaje personalizado que aparecerá en el correo..."></textarea>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Puedes agregar un mensaje personalizado que aparecerá en el cuerpo del correo.</span>
                    </div>
                </div>
                
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <strong>Nota:</strong> El archivo Excel se generará con los mismos filtros que tienes aplicados en la tabla de usuarios. 
                    Incluirá todas las columnas (ID, Nombres, Apellidos, Correo, Rol, Estado) y tendrá filtros automáticos habilitados.
                </div>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn-secondary modal-cancel">
                    <i class="fas fa-times"></i>
                    Cancelar
                </button>
                <button type="submit">
                    <i class="fas fa-paper-plane"></i>
                    Enviar Reporte
                </button>
            </div>
        </form>
    </div>
</div>

</body>
</html>