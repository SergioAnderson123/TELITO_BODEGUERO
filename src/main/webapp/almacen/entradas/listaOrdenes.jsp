<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Órdenes de Compra Pendientes"/>
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
    </style>
</head>

<body>
<div class="dashboard-main-wrapper">

    <%-- ===== INICIO DE LA CORRECCIÓN ===== --%>
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <%-- ===== FIN DE LA CORRECCIÓN ===== --%>

    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Registrar entradas"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-clipboard-list me-2"></i>Órdenes de Compra Pendientes</h2>
                            <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Gestiona las órdenes de compra pendientes de recepción en el almacén.</p>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <a href="<%= request.getContextPath() %>/almacen/EntradaReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                            </a>
                            <button type="button" id="openSendEmailModal" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-envelope me-1"></i>Enviar por Correo
                            </button>
                        </div>
                    </div>
                </div>

                <%
                    // Obtener mensajes de éxito/error de la sesión
                    String successMsg = (String) session.getAttribute("successMsg");
                    String errorMsg = (String) session.getAttribute("errorMsg");
                    if (successMsg != null) session.removeAttribute("successMsg");
                    if (errorMsg != null) session.removeAttribute("errorMsg");
                    
                    // Obtener estadísticas del servlet
                    Integer totalOrdenesAttr = (Integer) request.getAttribute("totalOrdenes");
                    Integer ordenesPendientesAttr = (Integer) request.getAttribute("ordenesPendientes");
                    Integer ordenesRegistradasAttr = (Integer) request.getAttribute("ordenesRegistradas");
                    int totalOrdenes = (totalOrdenesAttr != null) ? totalOrdenesAttr : 0;
                    int ordenesPendientes = (ordenesPendientesAttr != null) ? ordenesPendientesAttr : 0;
                    int ordenesRegistradas = (ordenesRegistradasAttr != null) ? ordenesRegistradasAttr : 0;
                %>

                <!-- ===================== Mensajes de éxito/error ===================== -->
                <% if (successMsg != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                    <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" style="font-size: 0.7rem;"></button>
                </div>
                <% } %>
                <% if (errorMsg != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                    <i class="fas fa-exclamation-circle me-2"></i><%= errorMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" style="font-size: 0.7rem;"></button>
                </div>
                <% } %>

                <!-- ===================== Tarjetas de estadísticas ===================== -->
                <div class="stats-container">
                    <div class="stat-card">
                        <h3>Total de Órdenes</h3>
                        <p><%= totalOrdenes %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Pendientes</h3>
                        <p><%= ordenesPendientes %></p>
                    </div>
                    <div class="stat-card">
                        <h3>Registradas</h3>
                        <p><%= ordenesRegistradas %></p>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                    <form action="<%= request.getContextPath() %>/almacen/EntradaServlet" method="GET" id="filterForm">
                        <input type="hidden" name="action" value="lista">
                        <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-xl-4 col-lg-4 col-md-12 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="N° Orden o producto..." value="<%= request.getParameter("busqueda") != null ? request.getParameter("busqueda") : "" %>" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-truck me-1"></i>Proveedor</label>
                                <select class="form-select form-select-sm shadow-sm" name="proveedor" id="proveedorFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="">Todos</option>
                                    <%
                                        try {
                                            String proveedorParam = request.getParameter("proveedor");
                                            java.util.ArrayList<java.util.Map<String, Object>> listaProductores = 
                                                (java.util.ArrayList<java.util.Map<String, Object>>) request.getAttribute("listaProductores");
                                            if (listaProductores != null && !listaProductores.isEmpty()) {
                                                for (java.util.Map<String, Object> productor : listaProductores) {
                                                    if (productor != null) {
                                                        Object idObj = productor.get("id");
                                                        Object nombreObj = productor.get("nombre");
                                                        if (idObj != null && nombreObj != null) {
                                                            String productorId = String.valueOf(idObj);
                                                            String productorNombre = String.valueOf(nombreObj);
                                                            String selected = (proveedorParam != null && proveedorParam.equals(productorId)) ? "selected" : "";
                                    %>
                                    <option value="<%= productorId %>" <%= selected %>><%= productorNombre %></option>
                                    <%
                                                        }
                                                    }
                                                }
                                            }
                                        } catch (Exception e) {
                                            // Si hay error, simplemente no mostrar productores en el select
                                            System.err.println("Error al mostrar productores en JSP: " + e.getMessage());
                                            e.printStackTrace();
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-xl-3 col-lg-3 col-md-6 col-sm-6">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                                <select class="form-select form-select-sm shadow-sm" name="estado" id="estadoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="">Todos</option>
                                    <%
                                        String estadoParam = request.getParameter("estado");
                                        String[] estados = {"Pendiente", "Aprobado", "En Proceso", "Rechazado", "Recibido", "Registrado"};
                                        for (String estado : estados) {
                                            String selected = (estadoParam != null && estadoParam.equals(estado)) ? "selected" : "";
                                    %>
                                    <option value="<%= estado %>" <%= selected %>><%= estado %></option>
                                    <%
                                        }
                                    %>
                                </select>
                            </div>
                            <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6 d-flex align-items-end">
                                <a href="<%= request.getContextPath() %>/almacen/EntradaServlet?action=lista" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-sync-alt me-1"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ===================== Card: Tabla de órdenes ===================== -->
                <div class="table-card shadow-sm">
                    <div class="card-header" style="padding: 0.5rem 0.75rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-clipboard-list me-2"></i>Tabla de Órdenes de Compra</h5>
                                <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona las órdenes de compra pendientes de recepción</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body" style="padding: 0.75rem;">
                        <div class="table-responsive">
                            <table id="ordenesTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                <thead class="table-light">
                                <tr>
                                    <th onclick="sortTable(0)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-hashtag me-1"></i>Número de Orden
                                    </th>
                                    <th onclick="sortTable(1)" style="width: 25%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-box me-1"></i>Producto
                                    </th>
                                    <th onclick="sortTable(2)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-truck me-1"></i>Proveedor
                                    </th>
                                    <th onclick="sortTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-cubes me-1"></i>Cantidad Esperada
                                    </th>
                                    <th onclick="sortTable(4)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                        <i class="fas fa-toggle-on me-1"></i>Estado
                                    </th>
                                    <th style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center">
                                        <i class="fas fa-cogs me-1"></i>Acción
                                    </th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${not empty listaOrdenes}">
                                <c:forEach var="orden" items="${listaOrdenes}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>${orden.numeroOrden}</strong></td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${orden.nombreProducto}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${orden.nombreProveedor}</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${orden.cantidad} paquetes</td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <c:choose>
                                                <c:when test="${orden.estado == 'Registrado'}">
                                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-check-circle me-1"></i>Registrado
                                                            </span>
                                                </c:when>
                                                <c:otherwise>
                                                            <span class="badge text-bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                <i class="fas fa-clock me-1"></i>${orden.estado}
                                                            </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                                <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;" class="text-center">
                                            <c:choose>
                                                <c:when test="${orden.estado == 'Registrado'}">
                                                            <span class="text-muted" style="font-size: 0.8rem;">
                                                                <i class="fas fa-check-circle me-1"></i>Ya registrado
                                                            </span>
                                                </c:when>
                                                <c:otherwise>
                                                            <a class="btn btn-sm btn-primary shadow-sm"
                                                               href="${pageContext.request.contextPath}/almacen/EntradaServlet?action=recibir&id=${orden.idOrdenCompra}"
                                                               style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-clipboard-check me-1"></i>Registrar Entrada
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="text-center py-5">
                                                <div class="text-muted">
                                                    <i class="fas fa-box-open fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                    <p class="mb-0">No se encontraron órdenes con los filtros aplicados.</p>
                                                    <small>Intenta ajustar los filtros de búsqueda</small>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>

                            <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                        </div>
                    </div>
                </div>

            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function () {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const proveedorFilter = document.getElementById('proveedorFilter');
        const estadoFilter = document.getElementById('estadoFilter');
        
        // Aplicar filtros cuando cambien los selects
        if (proveedorFilter && filterForm) {
            proveedorFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        if (estadoFilter && filterForm) {
            estadoFilter.addEventListener('change', function() {
                filterForm.submit();
            });
        }
        
        // Aplicar filtros al presionar Enter en el campo de búsqueda
        if (searchInput && filterForm) {
            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    filterForm.submit();
                }
            });
        }
        
        // Búsqueda en tiempo real (opcional, funciona junto con el formulario)
        if (searchInput) {
            const tableBody = document.querySelector('#ordenesTable tbody');
            if (tableBody) {
                const tableRows = tableBody.getElementsByTagName('tr');
                searchInput.addEventListener('keyup', function (event) {
                    const searchTerm = event.target.value.toLowerCase();
                    for (let i = 0; i < tableRows.length; i++) {
                        const row = tableRows[i];
                        // Ignorar la fila de "no hay datos"
                        if (row.cells.length === 1) continue;
                        const rowText = row.textContent.toLowerCase();
                        row.style.display = rowText.includes(searchTerm) ? '' : 'none';
                    }
                });
            }
        }
    });

    // Función para ordenar la tabla
    let sortDirection = {};
    
    function sortTable(columnIndex) {
        const table = document.getElementById('ordenesTable');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Ignorar fila de "no hay datos"
        const dataRows = rows.filter(row => row.cells.length > 1);
        if (dataRows.length === 0) return;
        
        // Determinar dirección de ordenamiento
        if (!sortDirection[columnIndex]) {
            sortDirection[columnIndex] = 'asc';
        } else {
            sortDirection[columnIndex] = sortDirection[columnIndex] === 'asc' ? 'desc' : 'asc';
        }
        
        // Ordenar las filas
        dataRows.sort((a, b) => {
            const aText = a.cells[columnIndex].textContent.trim();
            const bText = b.cells[columnIndex].textContent.trim();
            
            // Intentar comparar como números si es posible
            const aNum = parseFloat(aText.replace(/[^\d.-]/g, ''));
            const bNum = parseFloat(bText.replace(/[^\d.-]/g, ''));
            
            if (!isNaN(aNum) && !isNaN(bNum)) {
                return sortDirection[columnIndex] === 'asc' ? aNum - bNum : bNum - aNum;
            }
            
            // Comparar como texto
            if (sortDirection[columnIndex] === 'asc') {
                return aText.localeCompare(bText);
            } else {
                return bText.localeCompare(aText);
            }
        });
        
        // Limpiar indicadores anteriores
        const headers = table.querySelectorAll('th');
        headers.forEach((header, idx) => {
            if (idx !== columnIndex) {
                header.innerHTML = header.innerHTML.replace(/ [▲▼]/, '');
            }
        });
        
        // Agregar indicador visual
        const currentHeader = headers[columnIndex];
        const indicator = sortDirection[columnIndex] === 'asc' ? ' ▲' : ' ▼';
        if (!currentHeader.innerHTML.includes('▲') && !currentHeader.innerHTML.includes('▼')) {
            currentHeader.innerHTML += indicator;
        } else {
            currentHeader.innerHTML = currentHeader.innerHTML.replace(/ [▲▼]/, indicator);
        }
        
        // Reordenar filas en el DOM
        const noDataRow = rows.find(row => row.cells.length === 1);
        dataRows.forEach(row => tbody.removeChild(row));
        dataRows.forEach(row => tbody.appendChild(row));
        if (noDataRow) {
            tbody.appendChild(noDataRow);
        }
    }
</script>

<style>
    #ordenesTable thead th {
        position: relative;
        user-select: none;
        transition: background-color 0.2s ease;
    }
    #ordenesTable thead th:hover {
        background-color: #83c5be !important;
    }
    #ordenesTable thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    #ordenesTable thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- Modal de Enviar por Correo -->
<div id="sendEmailModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/almacen/EntradaReporteServlet" id="formEnviarCorreo">
            <input type="hidden" name="action" value="enviar">
            
            <div class="modal-body">
                <div class="alert alert-info" style="margin-bottom: 20px; padding: 15px; border-radius: 8px; background-color: #d1ecf1; border: 1px solid #bee5eb;">
                    <div style="display: flex; align-items: start; gap: 12px;">
                        <i class="fas fa-info-circle" style="color: #0c5460; font-size: 1.3rem; margin-top: 3px;"></i>
                        <div>
                            <strong style="color: #0c5460; display: block; margin-bottom: 8px;">Información del reporte:</strong>
                            <div style="font-size: 0.9rem; color: #0c5460;">
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Código de Orden y Proveedor</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Fecha de Pedido y Entrega Esperada</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Estado de la Orden</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Productos y Cantidades</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Costo Total</span>
                                </p>
                            </div>
                            <p style="margin: 10px 0 0 0; font-size: 0.85rem; color: #0c5460;">
                                <strong>Filtros aplicados:</strong> Todas las órdenes de compra
                            </p>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="email_destino">
                        <i class="fas fa-envelope"></i>
                        Correo Electrónico de Destino *
                    </label>
                    <input type="email" 
                           id="email_destino" 
                           name="email_destino" 
                           class="form-control" 
                           placeholder="ejemplo@correo.com"
                           required>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Ingrese el email donde desea recibir el reporte</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="asunto">
                        <i class="fas fa-tag"></i>
                        Asunto del Correo *
                    </label>
                    <input type="text" 
                           id="asunto" 
                           name="asunto" 
                           class="form-control" 
                           value="Reporte de Órdenes de Compra - Almacén"
                           required>
                </div>
                
                <div class="form-group">
                    <label for="mensaje">
                        <i class="fas fa-comment-alt"></i>
                        Mensaje Adicional (Opcional)
                    </label>
                    <textarea id="mensaje" 
                              name="mensaje" 
                              class="form-control" 
                              rows="4"
                              placeholder="Puede agregar información adicional sobre el reporte..."></textarea>
                    <div class="form-hint">
                        <i class="fas fa-lightbulb"></i>
                        <span>Este mensaje se incluirá en el cuerpo del correo electrónico</span>
                    </div>
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

<script>
// Modal de Enviar por Correo
const sendEmailModal = document.getElementById('sendEmailModal');
const openSendEmailBtn = document.getElementById('openSendEmailModal');

if (sendEmailModal && openSendEmailBtn) {
    const closeSendEmailBtn = sendEmailModal.querySelector('.modal-close');
    const cancelSendEmailBtn = sendEmailModal.querySelector('.modal-cancel');
    
    openSendEmailBtn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        sendEmailModal.classList.add('show');
        sendEmailModal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
    });
    
    function cerrarModalEnviar() {
        sendEmailModal.classList.remove('show');
        sendEmailModal.style.display = 'none';
        document.body.style.overflow = '';
    }
    
    if (closeSendEmailBtn) {
        closeSendEmailBtn.addEventListener('click', cerrarModalEnviar);
    }
    
    if (cancelSendEmailBtn) {
        cancelSendEmailBtn.addEventListener('click', cerrarModalEnviar);
    }
    
    sendEmailModal.addEventListener('click', function(event) {
        if (event.target === sendEmailModal) {
            cerrarModalEnviar();
        }
    });
}
</script>

</body>
</html>