<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Vehículos"/>
    </jsp:include>
    <style>
        /* Estilos mejorados para el dropdown de acciones */
        .dropdown-menu {
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15) !important;
            border: 1px solid rgba(0, 0, 0, 0.08) !important;
            border-radius: 8px !important;
            min-width: 180px !important;
            font-size: 0.9rem !important;
            padding: 0.5rem 0 !important;
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
            padding: 0.5rem 0.75rem !important;
            transition: all 0.2s ease;
        }
        
        .dropdown-item i {
            width: 20px;
            text-align: center;
        }
        
        .dropdown-item:hover {
            transform: translateX(3px);
            background-color: #f8f9fa;
        }
        
        .dropdown-item.text-primary:hover {
            background-color: #e3f2fd;
            color: #1976d2 !important;
        }
        
        .dropdown-item.text-danger:hover {
            background-color: #ffebee;
            color: #dc3545 !important;
        }
        
        /* Mejora del botón de acciones */
        .btn-outline-success:hover {
            transform: scale(1.05);
        }
        
        /* Estilos para el botón Agregar Vehículo */
        .btn-agregar-vehiculo {
            transition: all 0.3s ease;
        }
        
        .btn-agregar-vehiculo:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(40, 167, 69, 0.4) !important;
        }
        
        /* Eliminar scroll horizontal de la tabla */
        #vehiculoTable {
            width: 100% !important;
            max-width: 100% !important;
        }
        
        #vehiculoTable th,
        #vehiculoTable td {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        /* Permitir que el dropdown sea visible en la columna de acciones */
        #vehiculoTable td:last-child {
            overflow: visible !important;
            position: relative;
        }
        
        #vehiculoTable td:last-child .dropdown {
            position: static;
        }
        
        #vehiculoTable td:last-child .dropdown-menu {
            position: absolute !important;
            right: 0 !important;
            left: auto !important;
            z-index: 1050 !important;
            transform: none !important;
        }
        
        /* Eliminar scrollbar vertical no deseado */
        .card-body {
            overflow: visible !important;
        }
        
        /* Eliminar scrollbars de DataTables */
        .dataTables_wrapper {
            overflow: visible !important;
        }
        
        .dataTables_wrapper .dataTables_scroll {
            overflow: visible !important;
        }
        
        .dataTables_wrapper .dataTables_scrollBody {
            overflow: visible !important;
        }
        
        /* Contenedor de la tabla sin scrollbars */
        div[style*="overflow"] {
            overflow: visible !important;
        }
        
        /* Asegurar que el contenedor no corte el dropdown pero sin scrollbars */
        .table-responsive {
            overflow: visible !important;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/header_admin.jsp"/>
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Vehiculos"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <!-- Encabezado -->
                <div class="row">
                    <div class="col-12">
                        <div class="page-header mb-4">
                            <h2 class="pageheader-title"><i class="fas fa-truck me-2"></i>Gestión de Vehículos</h2>
                            <p class="pageheader-text">Administra los vehículos del sistema de transporte.</p>
                        </div>
                    </div>
                </div>

                <!-- Mensajes de alerta -->
                <c:if test="${not empty sessionScope.mensaje}">
                    <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert">
                        ${sessionScope.mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="mensaje" scope="session"/>
                    <c:remove var="tipoMensaje" scope="session"/>
                </c:if>

                <!-- Tabla de vehículos -->
                <div class="row">
                    <div class="col-12">
                        <div class="table-card shadow-sm">
                            <div class="card-header" style="padding: 0.5rem 0.75rem;">
                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                    <div>
                                        <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-truck me-2"></i>Tabla de Vehículos</h5>
                                        <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todos los vehículos del sistema</small>
                                    </div>
                                    <div class="d-flex gap-2 flex-wrap">
                                        <a href="${pageContext.request.contextPath}/administrador/VehiculoReporteServlet?action=exportar" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                                        </a>
                                        <a href="${pageContext.request.contextPath}/administrador/VehiculoReporteServlet?action=formEnviar" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                                        </a>
                                        <a href="${pageContext.request.contextPath}/administrador/VehiculoServlet?action=crear" class="btn btn-sm shadow-sm btn-agregar-vehiculo" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                                            <i class="fas fa-plus me-1"></i>Agregar Vehículo
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body" style="padding: 0.75rem;">
                                <form action="${pageContext.request.contextPath}/administrador/VehiculoServlet" method="GET">
                                    <input type="hidden" name="action" value="listar">
                                    <input type="hidden" name="size" value="${size != null ? size : 10}">
                                    <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                                        <div class="col-md-8">
                                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                                            <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" placeholder="Placa, marca o modelo..." value="${busqueda != null ? busqueda : ''}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <button type="submit" class="btn btn-sm btn-primary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-search me-1"></i>Buscar
                                            </button>
                                        </div>
                                        <div class="col-md-2 d-flex align-items-end">
                                            <a href="${pageContext.request.contextPath}/administrador/VehiculoServlet" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                                            </a>
                                        </div>
                                    </div>
                                </form>
                                <div style="width: 100%; position: relative; overflow-x: hidden; overflow-y: visible;">
                                    <table id="vehiculoTable" class="table table-hover align-middle mb-0 datatable-server-side" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                        <thead class="table-light">
                                        <tr>
                                            <th style="width: 5%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">#</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-id-card me-1"></i>Placa</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-industry me-1"></i>Marca</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-car me-1"></i>Modelo</th>
                                            <th style="width: 20%; font-size: 0.85rem; padding: 0.4rem 0.5rem;" class="fw-semibold"><i class="fas fa-weight me-1"></i>Capacidad (Kg)</th>
                                            <th class="text-end fw-semibold text-success" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-cog me-1"></i>Acciones</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <%
                                            Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                            Integer sizeObj = (Integer) request.getAttribute("size");
                                            int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                            int sizeInt = (sizeObj != null) ? sizeObj : 10;
                                            int contador = (currentPageInt - 1) * sizeInt + 1;
                                        %>
                                        <c:forEach var="vehiculo" items="${listaVehiculos}">
                                            <tr class="align-middle" style="padding: 0;">
                                                <td class="text-muted" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= contador++ %></td>
                                                <td style="padding: 0.35rem 0.5rem;">
                                                    <span class="badge bg-primary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-id-card me-1"></i>${vehiculo.placa}
                                                    </span>
                                                </td>
                                                <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;" class="fw-semibold">${vehiculo.marca}</td>
                                                <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;" class="fw-semibold">${vehiculo.modelo}</td>
                                                <td style="padding: 0.35rem 0.5rem;">
                                                    <span class="badge bg-info-subtle text-info border border-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-weight me-1"></i>${vehiculo.capacidadKg} kg
                                                    </span>
                                                </td>
                                                <td class="text-end" style="padding: 0.35rem 0.5rem;">
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-outline-success shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <ul class="dropdown-menu dropdown-menu-end shadow-lg">
                                                            <li>
                                                                <a class="dropdown-item text-primary" href="${pageContext.request.contextPath}/administrador/VehiculoServlet?action=editar&id=${vehiculo.idVehiculo}">
                                                                    <i class="fas fa-edit"></i> Editar
                                                                </a>
                                                            </li>
                                                            <li><hr class="dropdown-divider"></li>
                                                            <li>
                                                                <a class="dropdown-item text-danger" href="#" data-id="${vehiculo.idVehiculo}" data-placa="${vehiculo.placa}" onclick="confirmarEliminacion(this.dataset.id, this.dataset.placa)">
                                                                    <i class="fas fa-trash-alt"></i> Eliminar
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <%-- Incluir componente de paginación --%>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <jsp:include page="/administrador/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    function confirmarEliminacion(id, placa) {
        showConfirm(
            '¿Estás seguro de eliminar el vehículo con placa "' + placa + '"? Esta acción no se puede deshacer.',
            function() {
                window.location.href = '${pageContext.request.contextPath}/administrador/VehiculoServlet?action=eliminar&id=' + id;
            },
            'Confirmar eliminación'
        );
    }
</script>

<!-- Bootstrap JS ya está incluido en footer.jsp -->
</body>
</html>

