<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>


<!doctype html>
<html lang="en">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Inventario"/>
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
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value='Gestion de inventario'/>
        <jsp:param name="activePage" value='Gestion de inventario'/>
    </jsp:include>
    <jsp:include page="/almacen/layouts/header_almacen.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <!-- Mensajes de alerta -->
                <c:if test="${not empty sessionScope.mensaje}">
                    <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert" style="padding: 0.5rem 0.75rem; margin-bottom: 0.5rem; font-size: 0.85rem;">
                        ${sessionScope.mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                    </div>
                    <c:remove var="mensaje" scope="session"/>
                    <c:remove var="tipoMensaje" scope="session"/>
                </c:if>

                <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-warehouse me-2"></i>Gestión de Inventario</h2>
                            <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra el stock de productos y ajusta inventarios según sea necesario.</p>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">
                            <a href="<%= request.getContextPath() %>/almacen/LoteReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                            </a>
                            <button type="button" id="openSendEmailModal" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                <i class="fas fa-envelope me-1"></i>Enviar por Correo
                            </button>
                        </div>
                    </div>
                </div>

                <%
                    // Obtener estadísticas del servlet
                    Integer totalLotesAttr = (Integer) request.getAttribute("totalLotes");
                    Integer enStockAttr = (Integer) request.getAttribute("enStock");
                    Integer sinStockAttr = (Integer) request.getAttribute("sinStock");
                    int totalLotes = (totalLotesAttr != null) ? totalLotesAttr : 0;
                    int enStock = (enStockAttr != null) ? enStockAttr : 0;
                    int sinStock = (sinStockAttr != null) ? sinStockAttr : 0;
                %>

                <!-- ===================== Tarjetas de estadísticas ===================== -->
                <div class="row g-2 mb-3">
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Lotes</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= totalLotes %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">En Stock</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= enStock %></p>
                        </div>
                    </div>
                    <div class="col-xl-4 col-lg-4 col-md-6 col-sm-12">
                        <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                            <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Sin Stock</h3>
                            <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= sinStock %></p>
                        </div>
                    </div>
                </div>

                <!-- ===================== Card: Búsqueda y filtros ===================== -->
                <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                    <form action="<%= request.getContextPath() %>/almacen/LoteServlet" method="GET" id="filterForm">
                        <input type="hidden" name="action" value="lista">
                        <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                        <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                            <div class="col-xl-6 col-lg-6 col-md-12 col-sm-12">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="SKU, producto o lote..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-xl-4 col-lg-4 col-md-6 col-sm-6">
                                <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado de Stock</label>
                                <select class="form-select form-select-sm shadow-sm" name="estado" id="estadoFilter" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <option value="" ${param.estado == '' || param.estado == null ? 'selected' : ''}>Todos</option>
                                    <option value="En stock" ${param.estado == 'En stock' ? 'selected' : ''}>En stock</option>
                                    <option value="Poco stock" ${param.estado == 'Poco stock' ? 'selected' : ''}>Poco stock</option>
                                    <option value="Sin stock" ${param.estado == 'Sin stock' ? 'selected' : ''}>Sin stock</option>
                                </select>
                            </div>
                            <div class="col-xl-2 col-lg-2 col-md-6 col-sm-6 d-flex align-items-end">
                                <a href="<%= request.getContextPath() %>/almacen/LoteServlet?action=lista" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-sync-alt me-1"></i>Limpiar
                                </a>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- ===================== Card: Tabla de productos ===================== -->
                <div class="row">
                    <div class="col-12">
                        <div class="table-card shadow-sm">
                            <div class="card-header" style="padding: 0.5rem 0.75rem;">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-box me-2"></i>Tabla de Productos</h5>
                                        <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los lotes del inventario</small>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body" style="padding: 0.75rem;">

                                <div class="table-responsive">
                                    <table id="inventoryTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                        <thead class="table-light">
                                        <tr>
                                            <th onclick="sortTable(0)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-barcode me-1"></i>SKU
                                            </th>
                                            <th onclick="sortTable(1)" style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-box me-1"></i>Nombre Producto
                                            </th>
                                            <th onclick="sortTable(2)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-tag me-1"></i>Lote
                                            </th>
                                            <th onclick="sortTable(3)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-cubes me-1"></i>Cantidad Disponible
                                            </th>
                                            <th onclick="sortTable(4)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-map-marker-alt me-1"></i>Ubicación
                                            </th>
                                            <th onclick="sortTable(5)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-calendar-alt me-1"></i>Fecha Vencimiento
                                            </th>
                                            <th onclick="sortTable(6)" style="width: 13%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                                <i class="fas fa-toggle-on me-1"></i>Estado
                                            </th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold text-center">
                                                <i class="fas fa-cog me-1"></i>Acciones
                                            </th>
                                        </tr>
                                        </thead>
                                        <tbody id="productTableBody">
                                        <c:choose>
                                            <c:when test="${not empty listaLotes}">
                                        <c:forEach var="lote" items="${listaLotes}">
                                                    <tr class="align-middle" style="padding: 0;">
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.codigoSKU}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.nombreProducto}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong>${lote.codigoLote}</strong></td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.paquetesDisponibles} paquetes</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.nombreUbicacion}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">${lote.fechaVencimiento}</td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                    <c:choose>
                                                        <c:when test="${lote.estadoStock == 'Sin Stock'}">
                                                                    <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-times-circle me-1"></i>Sin Stock
                                                                    </span>
                                                        </c:when>
                                                        <c:when test="${lote.estadoStock == 'Poco Stock'}">
                                                                    <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-exclamation-triangle me-1"></i>Poco Stock
                                                                    </span>
                                                        </c:when>
                                                        <c:when test="${lote.estadoStock == 'En Stock'}">
                                                                    <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-check-circle me-1"></i>En Stock
                                                                    </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                                    <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                                        <i class="fas fa-question-circle me-1"></i>No configurado
                                                                    </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;" class="text-center">
                                                    <a type="button" class="btn btn-sm btn-warning shadow-sm"
                                                           href="IncidenciaServlet?action=formReportar&idLote=${lote.idLote}" 
                                                                   title="Reportar incidencia" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-exclamation-triangle"></i> Incidencia
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center py-5">
                                                        <div class="text-muted">
                                                            <i class="fas fa-box-open fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                            <p class="mb-0">No se encontraron lotes con los filtros aplicados.</p>
                                                            <small>Intenta ajustar los filtros de búsqueda</small>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
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
        </div>
        <jsp:include page="/almacen/layouts/footer.jsp" />
    </div>
</div>


<script>
    // Búsqueda en tiempo real (opcional, funciona junto con el formulario)
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
        const tableBody = document.getElementById('productTableBody');
            if (tableBody) {
                const tableRows = tableBody.getElementsByTagName('tr');

        searchInput.addEventListener('keyup', function() {
            const searchTerm = searchInput.value.toLowerCase();
            for (let i = 0; i < tableRows.length; i++) {
                const row = tableRows[i];
                        // Ignorar la fila de "no hay datos"
                        if (row.cells.length === 1) continue;
                const rowText = row.textContent.toLowerCase();
                if (rowText.includes(searchTerm)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            }
        });
            }
        }
    });

    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const filterForm = document.getElementById('filterForm');
        const searchInput = document.getElementById('searchInput');
        const estadoFilter = document.getElementById('estadoFilter');
        
        // Aplicar filtros cuando cambien los selects
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
    });

    // Función para ordenar la tabla
    let sortDirection = {}; // Almacena la dirección de ordenamiento para cada columna
    
    function sortTable(columnIndex) {
        const table = document.getElementById('inventoryTable');
        const tbody = table.querySelector('tbody');
        const rows = Array.from(tbody.querySelectorAll('tr'));
        
        // Determinar dirección de ordenamiento
        if (!sortDirection[columnIndex]) {
            sortDirection[columnIndex] = 'asc';
        } else {
            sortDirection[columnIndex] = sortDirection[columnIndex] === 'asc' ? 'desc' : 'asc';
        }
        
        // Ordenar las filas
        rows.sort((a, b) => {
            const aText = a.cells[columnIndex].textContent.trim();
            const bText = b.cells[columnIndex].textContent.trim();
            
            // Intentar comparar como números si es posible
            const aNum = parseFloat(aText.replace(/[^\d.-]/g, ''));
            const bNum = parseFloat(bText.replace(/[^\d.-]/g, ''));
            
            let comparison = 0;
            if (!isNaN(aNum) && !isNaN(bNum)) {
                comparison = aNum - bNum;
            } else {
                // Comparar como texto
                comparison = aText.localeCompare(bText, 'es', { numeric: true, sensitivity: 'base' });
            }
            
            return sortDirection[columnIndex] === 'asc' ? comparison : -comparison;
        });
        
        // Reordenar las filas en el DOM
        rows.forEach(row => tbody.appendChild(row));
        
        // Actualizar indicadores visuales en los encabezados
        const headers = table.querySelectorAll('thead th');
        headers.forEach((header, index) => {
            header.classList.remove('sort-asc', 'sort-desc');
            if (index === columnIndex) {
                header.classList.add(sortDirection[columnIndex] === 'asc' ? 'sort-asc' : 'sort-desc');
            }
        });
    }
</script>

<style>
    #inventoryTable thead th {
        position: relative;
        user-select: none;
        transition: background-color 0.2s ease;
    }
    #inventoryTable thead th:hover {
        background-color: #83c5be !important;
    }
    #inventoryTable thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    #inventoryTable thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

<!-- Modal para mostrar resumen de lotes -->
<div class="modal fade" id="resumenLotesModal" tabindex="-1" aria-labelledby="resumenLotesModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="resumenLotesModalLabel">
                    <i class="fas fa-boxes me-2"></i>Resumen de Lotes
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <h6 class="mb-3" id="modalProductoNombre"></h6>
                <div id="loadingResumen" class="text-center py-3">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                </div>
                <div id="contenidoResumen" style="display: none;">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm">
                            <thead class="table-light">
                                <tr>
                                    <th>Código Lote</th>
                                    <th>Stock (Unidades)</th>
                                    <th>Paquetes</th>
                                    <th>Fecha Vencimiento</th>
                                </tr>
                            </thead>
                            <tbody id="tablaResumenLotes">
                            </tbody>
                        </table>
                    </div>
                    <div id="sinLotes" class="alert alert-info" style="display: none;">
                        No hay lotes disponibles para este producto.
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
            </div>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    function mostrarResumenLotes(productoId, nombreProducto) {
        // Actualizar título del modal
        document.getElementById('modalProductoNombre').textContent = 'Producto: ' + nombreProducto;
        
        // Mostrar loading y ocultar contenido
        document.getElementById('loadingResumen').style.display = 'block';
        document.getElementById('contenidoResumen').style.display = 'none';
        
        // Limpiar tabla
        document.getElementById('tablaResumenLotes').innerHTML = '';
        
        // Abrir modal
        const modal = new bootstrap.Modal(document.getElementById('resumenLotesModal'));
        modal.show();
        
        // Cargar datos via AJAX
        fetch('${pageContext.request.contextPath}/almacen/LoteServlet?action=obtenerResumenLotes&productoId=' + productoId)
            .then(response => response.json())
            .then(data => {
                document.getElementById('loadingResumen').style.display = 'none';
                
                if (data.success && data.lotes && data.lotes.length > 0) {
                    document.getElementById('contenidoResumen').style.display = 'block';
                    document.getElementById('sinLotes').style.display = 'none';
                    
                    const tbody = document.getElementById('tablaResumenLotes');
                    tbody.innerHTML = '';
                    
                    data.lotes.forEach(lote => {
                        const row = document.createElement('tr');
                        const fechaVencimiento = lote.fechaVencimiento || 'Sin fecha';
                        
                        row.innerHTML = 
                            '<td><strong>' + lote.codigoLote + '</strong></td>' +
                            '<td>' + lote.stockActual + ' unidades</td>' +
                            '<td><span class="badge bg-primary">' + lote.paquetes + ' paquetes</span></td>' +
                            '<td>' + fechaVencimiento + '</td>';
                        tbody.appendChild(row);
                    });
                } else {
                    document.getElementById('contenidoResumen').style.display = 'block';
                    document.getElementById('sinLotes').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error al cargar resumen de lotes:', error);
                document.getElementById('loadingResumen').style.display = 'none';
                document.getElementById('contenidoResumen').style.display = 'block';
                document.getElementById('sinLotes').innerHTML = 
                    '<div class="alert alert-danger">Error al cargar el resumen de lotes. Por favor, intenta de nuevo.</div>';
            });
    }
</script>

<!-- Modal: Enviar Reporte por Correo -->
<div id="sendEmailModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2><i class="fas fa-envelope"></i> Enviar Reporte por Correo</h2>
            <span class="modal-close">&times;</span>
        </div>
        
        <form method="POST" action="<%= request.getContextPath() %>/almacen/LoteReporteServlet" id="formEnviarCorreo">
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
                                    <span>SKU y Nombre del Producto</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Código de Lote</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Cantidad Disponible y Paquetes</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Fecha de Vencimiento</span>
                                </p>
                                <p style="margin: 5px 0; display: flex; align-items: center; gap: 8px;">
                                    <i class="fas fa-check-circle" style="color: #17a2b8;"></i>
                                    <span>Ubicación y Estado</span>
                                </p>
                            </div>
                            <p style="margin: 10px 0 0 0; font-size: 0.85rem; color: #0c5460;">
                                <strong>Filtros aplicados:</strong> Todos los lotes
                            </p>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="modalEmailDestino">
                        <i class="fas fa-envelope"></i>
                        Email de Destino <span class="text-danger">*</span>
                    </label>
                    <input type="email" 
                           name="email_destino" 
                           id="modalEmailDestino" 
                           placeholder="ejemplo@correo.com" 
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
                           value="Reporte de Inventario - Almacén - TELITO BODEGUERO" 
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
                              placeholder="Escribe un mensaje adicional para el destinatario..."></textarea>
                    <div class="form-hint">
                        <i class="fas fa-info-circle"></i>
                        <span>Puedes agregar un mensaje personalizado que aparecerá en el cuerpo del correo.</span>
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