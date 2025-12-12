<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.OrdenCompraBean" %>
<%@ page import="com.example.telito.logistica.beans.ProveedorBean" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Orden de Compra"/>
    </jsp:include>
    <!-- Incluir modales personalizados -->
    <jsp:include page="/WEB-INF/includes/modal-alerts.jsp" />
    <style>
        /* Estilo para el encabezado de la tabla igual que en productor */
        .table-card .card-header {
            background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%);
            color: #fff;
            border-radius: 12px 12px 0 0;
            padding: 0.5rem 0.75rem;
            margin: 0;
        }
        .table-card .card-header h5,
        .table-card .card-header small {
            color: white !important;
        }
        /* Estilo para el botón Limpiar igual que en productor - sobrescribir estilos globales */
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
        .btn-outline-secondary:focus {
            color: #fff !important;
            background-color: #6c757d !important;
            border: 1px solid #6c757d !important;
            box-shadow: 0 0 0 0.25rem rgba(108, 117, 125, 0.5) !important;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='OrdenCompra'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
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
                        <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;"><i class="fas fa-file-invoice-dollar me-2"></i>Orden de Compra</h2>
                        <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">Administra las órdenes de compra del sistema.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <%
                            String busquedaParam = request.getParameter("busqueda");
                            String proveedorParam = request.getParameter("proveedor");
                            String estadoParam = request.getParameter("estado");
                            StringBuilder urlParams = new StringBuilder();
                            if (busquedaParam != null && !busquedaParam.trim().isEmpty()) {
                                urlParams.append("&busqueda=").append(java.net.URLEncoder.encode(busquedaParam, "UTF-8"));
                            }
                            if (proveedorParam != null && !proveedorParam.trim().isEmpty()) {
                                urlParams.append("&proveedor=").append(java.net.URLEncoder.encode(proveedorParam, "UTF-8"));
                            }
                            if (estadoParam != null && !estadoParam.trim().isEmpty()) {
                                urlParams.append("&estado=").append(java.net.URLEncoder.encode(estadoParam, "UTF-8"));
                            }
                            String urlBase = request.getContextPath() + "/logistica/OrdenCompraReporteServlet?action=exportar" + urlParams.toString();
                            String urlEnviar = request.getContextPath() + "/logistica/OrdenCompraReporteServlet?action=formEnviar" + urlParams.toString();
                        %>
                        <a href="<%= urlBase %>" class="btn btn-sm btn-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-file-excel me-1"></i>Exportar a Excel
                        </a>
                        <a href="<%= urlEnviar %>" class="btn btn-sm btn-info text-white shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                            <i class="fas fa-envelope me-1"></i>Enviar por Correo
                        </a>
                        <a href="${pageContext.request.contextPath}/orden-compra?action=crear" class="btn btn-sm shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem; background: linear-gradient(135deg, #28a745 0%, #20c997 100%); border: none; color: white; font-weight: 600;">
                            <i class="fas fa-plus me-1"></i>Agregar Orden
                        </a>
                    </div>
                </div>
            </div>

            <%
                // Calcular estadísticas desde la lista de órdenes
                ArrayList<OrdenCompraBean> listaOrdenesStats = 
                    (ArrayList<OrdenCompraBean>) request.getAttribute("listaOrdenes");
                int totalOrdenes = 0;
                int ordenesPendientes = 0;
                int ordenesAprobadas = 0;
                
                Integer totalRowsAttr = (Integer) request.getAttribute("totalRows");
                if (totalRowsAttr != null) {
                    totalOrdenes = totalRowsAttr;
                }
                
                if (listaOrdenesStats != null) {
                    for (OrdenCompraBean orden : listaOrdenesStats) {
                        String estado = orden.getEstado();
                        if ("Pendiente".equalsIgnoreCase(estado)) {
                            ordenesPendientes++;
                        } else if ("Aprobado".equalsIgnoreCase(estado)) {
                            ordenesAprobadas++;
                        }
                    }
                }
            %>

            <!-- ===================== Tarjetas de estadísticas ===================== -->
            <div class="stats-container" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-bottom: 15px;">
                <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                    <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Total de Órdenes</h3>
                    <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= totalOrdenes %></p>
                </div>
                <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                    <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Pendientes</h3>
                    <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= ordenesPendientes %></p>
                </div>
                <div class="stat-card" style="background-color: #ffffff; padding: 12px 15px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);">
                    <h3 style="margin: 0 0 5px 0; font-size: 0.8rem; color: #6c757d; font-weight: 600;">Aprobadas</h3>
                    <p style="margin: 0; font-size: 1.5rem; font-weight: 700; color: #006d77;"><%= ordenesAprobadas %></p>
                </div>
            </div>

            <!-- ===================== Card: Búsqueda y filtros ===================== -->
            <div class="card shadow-sm" style="padding: 0.75rem; margin-bottom: 15px;">
                <form action="${pageContext.request.contextPath}/orden-compra" method="GET">
                    <input type="hidden" name="size" value="<%= request.getAttribute("size") != null ? request.getAttribute("size") : 5 %>">
                    <div class="row g-2 mb-2" style="margin-bottom: 0.75rem !important;">
                        <div class="col-md-5">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-search me-1"></i>Buscar</label>
                            <div class="input-group">
                                <input type="text" class="form-control form-control-sm shadow-sm" name="busqueda" id="searchInput" placeholder="N° Orden o producto..." value="${param.busqueda}" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <button class="btn btn-sm btn-primary shadow-sm" type="button" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-truck me-1"></i>Proveedor</label>
                            <select class="form-select form-select-sm shadow-sm" name="proveedor" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="">Todos</option>
                                <% ArrayList<ProveedorBean> listaProveedores = (ArrayList<ProveedorBean>) request.getAttribute("listaProveedores");
                                    if(listaProveedores != null){
                                        for(ProveedorBean proveedor : listaProveedores){ %>
                                <option value="<%= proveedor.getId() %>" ${param.proveedor == proveedor.getId() ? 'selected' : ''} >
                                    <%= proveedor.getNombre() %>
                                </option>
                                <%  }
                                } %>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label small text-muted mb-0" style="font-size: 0.8rem; margin-bottom: 0.25rem !important;"><i class="fas fa-toggle-on me-1"></i>Estado</label>
                            <select class="form-select form-select-sm shadow-sm" name="estado" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <option value="" ${param.estado == '' ? 'selected' : ''}>Todos</option>
                                <option value="Pendiente" ${param.estado == 'Pendiente' ? 'selected' : ''}>Pendiente</option>
                                <option value="Aprobado" ${param.estado == 'Aprobado' ? 'selected' : ''}>Aprobado</option>
                                <option value="Rechazado" ${param.estado == 'Rechazado' ? 'selected' : ''}>Rechazado</option>
                                <option value="Recibido" ${param.estado == 'Recibido' ? 'selected' : ''}>Recibido</option>
                            </select>
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <a href="${pageContext.request.contextPath}/orden-compra" class="btn btn-sm btn-outline-secondary w-100 shadow-sm" style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                <i class="fas fa-sync-alt me-1"></i>Limpiar
                            </a>
                        </div>
                    </div>
                </form>
            </div>

            <!-- ===================== Card: Tabla de órdenes ===================== -->
            <div class="row">
                <div class="col-12">
                    <div class="table-card shadow-sm">
                        <div class="card-header" style="padding: 0.5rem 0.75rem;">
                            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <div>
                                    <h5 class="mb-0 fw-semibold" style="font-size: 1.05rem; line-height: 1.2;"><i class="fas fa-file-invoice-dollar me-2"></i>Tabla de Ordenes</h5>
                                    <small class="text-white-50" style="font-size: 0.75rem; line-height: 1.2;">Gestiona todas las órdenes de compra</small>
                                </div>
                            </div>
                        </div>
                        <div class="card-body" style="padding: 0.75rem;">
                            <div style="width: 100%; position: relative;">
                                <table id="purchaseTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%; table-layout: auto;">
                                    <thead class="table-light">
                                    <tr>
                                        <th onclick="sortTable(0)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-hashtag me-1"></i>N° de Orden
                                        </th>
                                        <th onclick="sortTable(1)" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-truck me-1"></i>Proveedor
                                        </th>
                                        <th onclick="sortTable(2)" style="width: 18%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-box me-1"></i>Producto
                                        </th>
                                        <th onclick="sortTable(3)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-cubes me-1"></i>Cantidad
                                        </th>
                                        <th onclick="sortTable(4)" style="width: 15%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-user me-1"></i>Personal Responsable
                                        </th>
                                        <th onclick="sortTable(5)" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-toggle-on me-1"></i>Estado
                                        </th>
                                        <th onclick="sortTable(6)" style="width: 10%; font-size: 0.85rem; padding: 0.4rem 0.5rem; cursor:pointer;" class="fw-semibold">
                                            <i class="fas fa-dollar-sign me-1"></i>Monto
                                        </th>
                                        <th class="text-center fw-semibold" style="width: 12%; font-size: 0.85rem; padding: 0.4rem 0.5rem;">
                                            <i class="fas fa-cog me-1"></i>Acciones
                                        </th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                        ArrayList<OrdenCompraBean> listaOrdenes = (ArrayList<OrdenCompraBean>) request.getAttribute("listaOrdenes");
                                        
                                        Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                        Integer sizeObj = (Integer) request.getAttribute("size");
                                        int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                        int sizeInt = (sizeObj != null) ? sizeObj : 5;
                                        
                                        if (listaOrdenes != null && !listaOrdenes.isEmpty()) {
                                            for (OrdenCompraBean orden : listaOrdenes) {
                                    %>
                                    <tr class="align-middle" style="padding: 0;">
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= orden.getNumeroOrden() %></strong></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getNombreProveedor() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getNombreProducto() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getCantidadPaquetes() %> paquetes</td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><%= orden.getPersonalResponsable() %></td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;">
                                            <% if ("Pendiente".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-warning shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-clock me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else if ("Aprobado".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-success shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-check-circle me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else if ("Rechazado".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-danger shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-times-circle me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else if ("Recibido".equals(orden.getEstado())) { %>
                                            <span class="badge text-bg-info shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-inbox me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } else { %>
                                            <span class="badge text-bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                <i class="fas fa-question-circle me-1"></i><%= orden.getEstado() %>
                                            </span>
                                            <% } %>
                                        </td>
                                        <td style="font-size: 0.85rem; padding: 0.35rem 0.5rem;"><strong><%= orden.getMontoTotal() %></strong></td>
                                        <td class="text-center" style="font-size: 0.85rem; padding: 0.5rem;">
                                            <% if ("Recibido".equals(orden.getEstado())) { %>
                                            <button class="btn btn-sm shadow-sm" onclick="editarOrden('<%= orden.getNumeroOrden() %>')" style="font-size: 0.8rem; padding: 0.35rem 0.6rem; border: 1px solid #6c757d; color: #212529; background-color: #f8f9fa; transition: all 0.2s ease; white-space: nowrap;" onmouseover="this.style.backgroundColor='#e9ecef'; this.style.borderColor='#6c757d';" onmouseout="this.style.backgroundColor='#f8f9fa'; this.style.borderColor='#6c757d';">
                                                <i class="fas fa-eye me-1"></i>Ver
                                            </button>
                                            <% } else { %>
                                            <span class="text-muted" style="font-size: 0.75rem;">-</span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } else {
                                    %>
                                    <tr>
                                        <td colspan="8" class="text-center py-5">
                                            <div class="text-muted">
                                                <i class="fas fa-file-invoice fa-3x mb-3 d-block" style="opacity: 0.3;"></i>
                                                <p class="mb-0">No se encontraron órdenes con los filtros aplicados.</p>
                                                <small>Intenta ajustar los filtros de búsqueda</small>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
                                        }
                                    %>
                                    </tbody>
                                </table>
                                
                                <%-- Incluir componente de paginación --%>
                                <%
                                    request.setAttribute("param1Name", "busqueda");
                                    request.setAttribute("param1Value", request.getAttribute("busqueda"));
                                    request.setAttribute("param2Name", "proveedor");
                                    request.setAttribute("param2Value", request.getAttribute("proveedorFiltro"));
                                    request.setAttribute("param3Name", "estado");
                                    request.setAttribute("param3Value", request.getAttribute("estadoFiltro"));
                                %>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<!-- Modal: Ver Detalles de Orden Recibida -->
<div class="modal fade" id="detalleOrdenModal" tabindex="-1" aria-labelledby="detalleOrdenModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                <h5 class="modal-title" id="detalleOrdenModalLabel">
                    <i class="fas fa-box-open me-2"></i>Detalles de Orden Recibida
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="loadingDetalle" class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-3 text-muted">Cargando detalles de la orden...</p>
                </div>
                <div id="detalleOrdenContainer" style="display: none;">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>Orden:</strong> <span id="detalleNumeroOrden"></span>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Productor:</label>
                            <p id="detalleProductor" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Personal Responsable:</label>
                            <p id="detallePersonalResponsable" class="form-control-plaintext">-</p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Producto:</label>
                            <p id="detalleProducto" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">SKU:</label>
                            <p id="detalleSKU" class="form-control-plaintext"><span class="badge bg-secondary">-</span></p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Cantidad Solicitada:</label>
                            <p id="detalleCantidad" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Monto Total:</label>
                            <p id="detalleMontoTotal" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Estado:</label>
                            <p id="detalleEstado" class="form-control-plaintext"><span class="badge">-</span></p>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <h6 class="mb-3"><i class="fas fa-boxes me-2"></i>Lote Asignado por el Productor</h6>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Código de Lote:</label>
                            <p id="detalleCodigoLote" class="form-control-plaintext"><strong>-</strong></p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Fecha de Vencimiento:</label>
                            <p id="detalleFechaVencimiento" class="form-control-plaintext">-</p>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Stock Disponible:</label>
                            <p id="detalleStockDisponible" class="form-control-plaintext">-</p>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Ubicación:</label>
                            <p id="detalleUbicacion" class="form-control-plaintext">-</p>
                        </div>
                    </div>
                </div>
                <div id="errorDetalle" class="alert alert-warning" style="display: none;">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    No se pudieron cargar los detalles de la orden.
                </div>
            </div>
            <div class="modal-footer d-flex justify-content-between">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-arrow-left me-2"></i>Volver
                </button>
                <div>
                    <button type="button" class="btn btn-danger me-2" id="btnRechazar" onclick="cambiarEstadoOrden('Rechazado')">
                        <i class="fas fa-times-circle me-2"></i>Rechazar
                    </button>
                    <button type="button" class="btn btn-success" id="btnAprobar" onclick="cambiarEstadoOrden('Aprobado')">
                        <i class="fas fa-check-circle me-2"></i>Aprobar
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Aplicar filtros automáticamente al cambiar valores
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.querySelector('form[action*="orden-compra"]');
        const busquedaInput = form ? form.querySelector('input[name="busqueda"]') : null;
        const proveedorSelect = form ? form.querySelector('select[name="proveedor"]') : null;
        const estadoSelect = form ? form.querySelector('select[name="estado"]') : null;
        
        // Aplicar filtros cuando cambien los selects
        if (proveedorSelect) {
            proveedorSelect.addEventListener('change', function() {
                form.submit();
            });
        }
        
        if (estadoSelect) {
            estadoSelect.addEventListener('change', function() {
                form.submit();
            });
        }
        
        // Aplicar filtros al presionar Enter en el campo de búsqueda
        if (busquedaInput) {
            busquedaInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    form.submit();
                }
            });
        }
        
        // Botón de búsqueda
        const searchButton = form ? form.querySelector('.btn-primary.shadow-sm') : null;
        if (searchButton) {
            searchButton.addEventListener('click', function(e) {
                e.preventDefault();
                form.submit();
            });
        }
    });
    
    // Función para ordenar la tabla
    let sortDirection = {}; // Almacena la dirección de ordenamiento para cada columna
    
    function sortTable(columnIndex) {
        const table = document.getElementById('purchaseTable');
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
    
    // Función para limpiar backdrops múltiples (overlays oscuros)
    function limpiarBackdrops() {
        const backdrops = document.querySelectorAll('.modal-backdrop');
        if (backdrops.length > 1) {
            // Si hay más de un backdrop, eliminar los extras
            for (let i = 1; i < backdrops.length; i++) {
                backdrops[i].remove();
            }
        }
        // Asegurarse de que el body no tenga múltiples clases
        document.body.classList.remove('modal-open');
        if (backdrops.length > 0) {
            document.body.classList.add('modal-open');
        }
    }
    
    // Variable global para la instancia del modal de detalles
    let detalleOrdenModalInstance = null;
    
    // Función para obtener o crear la instancia del modal
    function getDetalleOrdenModal() {
        if (!detalleOrdenModalInstance) {
            const modalElement = document.getElementById('detalleOrdenModal');
            detalleOrdenModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
            
            // Limpiar backdrops cuando se cierre el modal
            modalElement.addEventListener('hidden.bs.modal', function() {
                limpiarBackdrops();
            });
        }
        return detalleOrdenModalInstance;
    }
    
    // Función para ver detalles de orden recibida
    function editarOrden(numeroOrden) {
        console.log('Abriendo detalles de orden:', numeroOrden);
        
        // Mostrar loading y ocultar contenido
        document.getElementById('loadingDetalle').style.display = 'block';
        document.getElementById('detalleOrdenContainer').style.display = 'none';
        document.getElementById('errorDetalle').style.display = 'none';
        
        // Obtener o crear la instancia del modal (reutilizar si ya existe)
        const modal = getDetalleOrdenModal();
        modal.show();
        
        // Extraer el número de orden (ej: "OC005" -> 5)
        const idOrden = numeroOrden.replace(/\D/g, '');
        ordenActualId = idOrden; // Guardar en variable global
        console.log('ID Orden extraído:', idOrden);
        
        // Habilitar botones al abrir el modal
        document.getElementById('btnAprobar').disabled = false;
        document.getElementById('btnRechazar').disabled = false;
        
        // Cargar los detalles de la orden vía AJAX
        fetch('${pageContext.request.contextPath}/orden-compra?action=obtenerDetalle&idOrden=' + idOrden)
            .then(response => response.json())
            .then(data => {
                console.log('Datos recibidos:', data);
                
                document.getElementById('loadingDetalle').style.display = 'none';
                
                if (data.success) {
                    // Llenar los campos del modal con los datos
                    document.getElementById('detalleNumeroOrden').textContent = numeroOrden;
                    document.getElementById('detalleProductor').textContent = data.productor || '-';
                    document.getElementById('detallePersonalResponsable').textContent = data.personalResponsable || '-';
                    document.getElementById('detalleProducto').textContent = data.producto || '-';
                    document.getElementById('detalleSKU').innerHTML = '<span class="badge bg-secondary">' + (data.sku || '-') + '</span>';
                    document.getElementById('detalleCantidad').textContent = (data.cantidad || '-') + ' paquetes';
                    document.getElementById('detalleMontoTotal').textContent = data.montoTotal || '-';
                    
                    // Badge de estado
                    let estadoBadge = '<span class="badge bg-info">' + (data.estado || '-') + '</span>';
                    document.getElementById('detalleEstado').innerHTML = estadoBadge;
                    
                    // Datos del lote
                    document.getElementById('detalleCodigoLote').innerHTML = '<strong>' + (data.codigoLote || '-') + '</strong>';
                    document.getElementById('detalleFechaVencimiento').textContent = data.fechaVencimiento || 'Sin fecha';
                    document.getElementById('detalleStockDisponible').textContent = (data.stockDisponible || '0') + ' unidades';
                    document.getElementById('detalleUbicacion').textContent = data.ubicacion || '-';
                    
                    document.getElementById('detalleOrdenContainer').style.display = 'block';
                } else {
                    document.getElementById('errorDetalle').style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Error al cargar detalles:', error);
                document.getElementById('loadingDetalle').style.display = 'none';
                document.getElementById('errorDetalle').style.display = 'block';
            });
    }
    
    // Variable global para guardar el ID de la orden actual
    let ordenActualId = null;
    
    // Función para cambiar el estado de la orden (Aprobar o Rechazar)
    function cambiarEstadoOrden(nuevoEstado) {
        if (!ordenActualId) {
            showError('No se ha seleccionado ninguna orden');
            return;
        }
        
        const mensajeConfirm = nuevoEstado === 'Aprobado' 
            ? '¿Está seguro de APROBAR esta orden?' 
            : '¿Está seguro de RECHAZAR esta orden?';
        
        const tituloConfirm = nuevoEstado === 'Aprobado' 
            ? 'Aprobar Orden' 
            : 'Rechazar Orden';
        
        // Cerrar el modal de detalles primero para evitar overlays múltiples
        const detalleModal = getDetalleOrdenModal();
        detalleModal.hide();
        
        // Esperar a que el modal se cierre completamente antes de mostrar el de confirmación
        const detalleModalElement = document.getElementById('detalleOrdenModal');
        detalleModalElement.addEventListener('hidden.bs.modal', function onHidden() {
            detalleModalElement.removeEventListener('hidden.bs.modal', onHidden);
            
            // Ahora mostrar el modal de confirmación
            showConfirm(
                mensajeConfirm,
                function() {
                    console.log('Cambiando estado a:', nuevoEstado, 'para orden:', ordenActualId);
                    
                    // Deshabilitar botones
                    document.getElementById('btnAprobar').disabled = true;
                    document.getElementById('btnRechazar').disabled = true;
                    
                    // Hacer petición para cambiar el estado
                    fetch('${pageContext.request.contextPath}/orden-compra', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'action=cambiarEstado&idOrden=' + ordenActualId + '&nuevoEstado=' + encodeURIComponent(nuevoEstado)
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            showSuccess('Orden ' + (nuevoEstado === 'Aprobado' ? 'aprobada' : 'rechazada') + ' exitosamente');
                            // Recargar la página después de 1 segundo
                            setTimeout(() => location.reload(), 1500);
                        } else {
                            showError('Error: ' + (data.message || 'No se pudo cambiar el estado'));
                            document.getElementById('btnAprobar').disabled = false;
                            document.getElementById('btnRechazar').disabled = false;
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        showError('Error de conexión al cambiar el estado. Por favor, intenta de nuevo.');
                        document.getElementById('btnAprobar').disabled = false;
                        document.getElementById('btnRechazar').disabled = false;
                    });
                },
                tituloConfirm
            );
        }, { once: true });
    }
</script>

<style>
    thead th {
        position: relative;
        user-select: none;
    }
    thead th:hover {
        background-color: var(--seafoam) !important;
    }
    thead th.sort-asc::after {
        content: ' ▲';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
    thead th.sort-desc::after {
        content: ' ▼';
        font-size: 0.7em;
        color: var(--turquoise-dark);
    }
</style>

</body>
</html>