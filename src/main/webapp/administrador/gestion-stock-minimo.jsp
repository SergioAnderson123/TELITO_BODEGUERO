<%--
  Created by IntelliJ IDEA.
  User: Sergio
  Date: 21/10/2025
  Time: 17:17
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Stock Mínimo"/>
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
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Configuracion'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid px-4">
                <div class="page-header mb-4 d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h2 class="pageheader-title"><i class="fas fa-triangle-exclamation me-2"></i>Gestión de Stock Mínimo</h2>
                        <p class="pageheader-text">Configura los umbrales de stock mínimo y crítico para cada producto.</p>
                    </div>
                    <div class="d-flex gap-2 flex-wrap">
                        <a href="${pageContext.request.contextPath}/StockMinimoReporteServlet?action=exportar" class="btn btn-success shadow-sm">
                            <i class="fas fa-file-excel me-2"></i>Exportar a Excel
                        </a>
                        <a href="${pageContext.request.contextPath}/StockMinimoReporteServlet?action=formEnviar" class="btn btn-info text-white shadow-sm">
                            <i class="fas fa-envelope me-2"></i>Enviar por Correo
                        </a>
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

                <!-- Botón para agregar nueva configuración -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="d-flex gap-2 flex-wrap">
                            <button type="button" class="btn btn-primary shadow-sm" data-bs-toggle="modal" data-bs-target="#modalStockMinimo">
                                <i class="fas fa-plus me-2"></i>Nueva Configuración
                            </button>
                            <button type="button" class="btn btn-info shadow-sm" onclick="aplicarConfiguracionGlobal()">
                                <i class="fas fa-cogs me-2"></i>Aplicar Configuración Global
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Tabla de configuraciones -->
                <div class="table-card shadow-sm">
                    <div class="card-header">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h5 class="mb-0 fw-semibold"><i class="fas fa-list me-2"></i>Configuraciones de Stock Mínimo</h5>
                                <small class="text-white-50">Gestiona los umbrales de stock para cada producto</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table id="stockMinimoTable" class="table table-hover align-middle mb-0" style="font-size: 0.9rem; margin-bottom: 0 !important; width: 100%;">
                                <thead class="table-light">
                                <tr>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-box me-1"></i>Producto</th>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-barcode me-1"></i>Código</th>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-warehouse me-1"></i>Stock Mín. Lote</th>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-exclamation-triangle me-1"></i>Stock Crít. Lote</th>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-chart-line me-1"></i>Stock Mín. Total</th>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-exclamation-circle me-1"></i>Stock Crít. Total</th>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-toggle-on me-1"></i>Estado</th>
                                    <th style="font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-calendar me-1"></i>Última Actualización</th>
                                    <th class="text-end" style="width: 120px; font-size: 0.85rem; padding: 0.4rem 0.5rem;"><i class="fas fa-cog me-1"></i>Acciones</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="config" items="${listaStockMinimo}">
                                    <tr>
                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;">${config.producto.nombre}</td>
                                        <td style="padding: 0.35rem 0.5rem;"><span class="badge bg-secondary shadow-sm" style="font-size: 0.8rem; padding: 0.3rem 0.6rem;">${config.producto.codigoSku}</span></td>
                                        <td style="padding: 0.35rem 0.5rem;">
                                            <span class="badge shadow-sm" style="background-color: #b3e5fc; color: #01579b; font-size: 0.8rem; padding: 0.3rem 0.6rem;">${config.stockMinimoLote}</span>
                                        </td>
                                        <td style="padding: 0.35rem 0.5rem;">
                                            <span class="badge shadow-sm" style="background-color: #fff9c4; color: #f57f17; font-size: 0.8rem; padding: 0.3rem 0.6rem;">${config.stockCriticoLote}</span>
                                        </td>
                                        <td style="padding: 0.35rem 0.5rem;">
                                            <span class="badge shadow-sm" style="background-color: #b3e5fc; color: #01579b; font-size: 0.8rem; padding: 0.3rem 0.6rem;">${config.stockMinimoProducto}</span>
                                        </td>
                                        <td style="padding: 0.35rem 0.5rem;">
                                            <span class="badge shadow-sm" style="background-color: #ffcdd2; color: #c62828; font-size: 0.8rem; padding: 0.3rem 0.6rem;">${config.stockCriticoProducto}</span>
                                        </td>
                                        <td style="padding: 0.35rem 0.5rem;">
                                            <c:choose>
                                                <c:when test="${config.activo}">
                                                    <span class="badge shadow-sm" style="background-color: #c8e6c9; color: #2e7d32; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-check-circle me-1"></i>Activo
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge shadow-sm" style="background-color: #e0e0e0; color: #424242; font-size: 0.8rem; padding: 0.3rem 0.6rem;">
                                                        <i class="fas fa-times-circle me-1"></i>Inactivo
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="padding: 0.35rem 0.5rem; font-size: 0.85rem;"><small class="text-muted">${config.fechaActualizacion}</small></td>
                                        <td class="text-end" style="padding: 0.35rem 0.5rem;">
                                            <div class="dropdown">
                                                <button class="btn btn-sm btn-outline-secondary shadow-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false" style="font-size: 0.8rem; padding: 0.25rem 0.5rem;">
                                                    <i class="fas fa-ellipsis-v"></i>
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end">
                                                    <li><a class="dropdown-item" href="#" 
                                                           data-id="${config.idStockMinimo}"
                                                           data-nombre="${fn:escapeXml(config.producto.nombre)}"
                                                           data-stockminimolote="${config.stockMinimoLote}"
                                                           data-stockcriticolote="${config.stockCriticoLote}"
                                                           data-stockminimoproducto="${config.stockMinimoProducto}"
                                                           data-stockcriticoproducto="${config.stockCriticoProducto}"
                                                           data-activo="${config.activo}"
                                                           onclick="editarDesdeDropdown(this); return false;"><i class="fas fa-edit me-2"></i>Editar</a></li>
                                                    <li><hr class="dropdown-divider"></li>
                                                    <li><a class="dropdown-item text-danger" href="#" onclick="eliminarConfiguracion(${config.idStockMinimo}); return false;"><i class="fas fa-trash me-2"></i>Eliminar</a></li>
                                                </ul>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<!-- Modal para agregar/editar configuración -->
<div class="modal fade" id="modalStockMinimo" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Nueva Configuración de Stock</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="formStockMinimo" action="${pageContext.request.contextPath}/StockMinimoServlet" method="post">
                <div class="modal-body">
                    <input type="hidden" id="idStockMinimo" name="idStockMinimo">
                    <input type="hidden" id="action" name="action" value="crear">

                    <div class="mb-4">
                        <label for="productoId" class="form-label fw-bold">Producto</label>
                        <select class="form-select" id="productoId" name="productoId" required>
                            <option value="">Selecciona un producto</option>
                            <c:forEach var="producto" items="${listaProductos}">
                                <option value="${producto.idProducto}">${producto.nombre} (${producto.codigoSku})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Cards Visuales (Idea 2) -->
                    <div class="row g-3">
                        <!-- Card: Vista Almacén -->
                        <div class="col-md-6">
                            <div class="card border-info">
                                <div class="card-header bg-info text-white">
                                    <h6 class="mb-0"><i class="fas fa-warehouse me-2"></i>VISTA ALMACÉN</h6>
                                    <small>Por Lote Individual</small>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="stockMinimoLote" class="form-label">Stock Mínimo:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockMinimoLote" 
                                                   name="stockMinimoLote" min="0" required placeholder="Ej: 10">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Por cada lote individual</div>
                                    </div>
                                    <div class="mb-3">
                                        <label for="stockCriticoLote" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockCriticoLote" 
                                                   name="stockCriticoLote" min="0" required placeholder="Ej: 5">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Nivel crítico por lote</div>
                                    </div>
                                    <div class="alert alert-light mb-0">
                                        <small><strong>Aplica a:</strong> Cada lote por separado</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Card: Vista Logística -->
                        <div class="col-md-6">
                            <div class="card border-primary">
                                <div class="card-header bg-primary text-white">
                                    <h6 class="mb-0"><i class="fas fa-chart-line me-2"></i>VISTA LOGÍSTICA</h6>
                                    <small>Producto Agrupado</small>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="stockMinimoProducto" class="form-label">Stock Mínimo:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockMinimoProducto" 
                                                   name="stockMinimoProducto" min="0" required placeholder="Ej: 50">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Suma de todos los lotes</div>
                                    </div>
                                    <div class="mb-3">
                                        <label for="stockCriticoProducto" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockCriticoProducto" 
                                                   name="stockCriticoProducto" min="0" required placeholder="Ej: 20">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Nivel crítico total</div>
                                    </div>
                                    <div class="alert alert-light mb-0">
                                        <small><strong>Aplica a:</strong> Suma total del producto</small>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="activo" name="activo" checked>
                            <label class="form-check-label" for="activo">
                                Configuración activa
                            </label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Modal: Confirmar Aplicar Configuración Global -->
<div class="modal fade" id="modalConfirmarGlobal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form id="formConfiguracionGlobal" action="${pageContext.request.contextPath}/StockMinimoServlet" method="post">
                <input type="hidden" name="action" value="aplicarGlobal">
                
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-globe me-2"></i>Aplicar Configuración Global
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <div class="alert alert-info mb-3">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>¿Qué hace esta acción?</strong>
                        <p class="mb-0 mt-2">Aplicará los valores que elijas a <strong>todos los productos que NO tienen configuración</strong>. Los productos con configuración existente NO serán modificados.</p>
                    </div>
                    
                    <h6 class="mb-3"><i class="fas fa-cog me-2"></i>Define los valores predeterminados:</h6>
                    
                    <div class="row g-3">
                        <!-- Card: Vista Almacén -->
                        <div class="col-md-6">
                            <div class="card border-info">
                                <div class="card-header bg-info text-white">
                                    <h6 class="mb-0"><i class="fas fa-warehouse me-2"></i>VISTA ALMACÉN</h6>
                                    <small>Por Lote Individual</small>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="globalStockMinimoLote" class="form-label">Stock Mínimo:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="globalStockMinimoLote" 
                                                   name="stockMinimoLote" min="1" required placeholder="Ej: 10" value="10">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Paquetes por lote</div>
                                    </div>
                                    <div class="mb-0">
                                        <label for="globalStockCriticoLote" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="globalStockCriticoLote" 
                                                   name="stockCriticoLote" min="1" required placeholder="Ej: 5" value="5">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Nivel crítico por lote</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Card: Vista Logística -->
                        <div class="col-md-6">
                            <div class="card border-primary">
                                <div class="card-header bg-primary text-white">
                                    <h6 class="mb-0"><i class="fas fa-chart-line me-2"></i>VISTA LOGÍSTICA</h6>
                                    <small>Producto Agrupado</small>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <label for="globalStockMinimoProducto" class="form-label">Stock Mínimo:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="globalStockMinimoProducto" 
                                                   name="stockMinimoProducto" min="1" required placeholder="Ej: 50" value="50">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Suma de todos los lotes</div>
                                    </div>
                                    <div class="mb-0">
                                        <label for="globalStockCriticoProducto" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="globalStockCriticoProducto" 
                                                   name="stockCriticoProducto" min="1" required placeholder="Ej: 20" value="20">
                                            <span class="input-group-text"><i class="fas fa-box"></i></span>
                                        </div>
                                        <div class="form-text">Nivel crítico total</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="alert alert-warning mt-3 mb-0">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <strong>Importante:</strong> Esta configuración se aplicará solo a productos sin configuración previa.
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times me-1"></i>Cancelar
                    </button>
                    <button type="submit" class="btn btn-info">
                        <i class="fas fa-check me-1"></i>Aplicar a Todos
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.7/js/dataTables.bootstrap5.min.js"></script>
<script>
    // Inicializar DataTables
    $(document).ready(function() {
        $('#stockMinimoTable').DataTable({
            language: {
                url: 'https://cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json',
                search: "Buscar:",
                info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
                infoEmpty: "Mostrando 0 a 0 de 0 registros",
                infoFiltered: "(filtrado de _MAX_ registros totales)",
                paginate: {
                    first: "Primero",
                    last: "Último",
                    next: "Siguiente",
                    previous: "Anterior"
                }
            },
            pageLength: 5,
            order: [[0, 'asc']],
            responsive: true,
            dom: '<"row"<"col-sm-12 col-md-6"f><"col-sm-12 col-md-6"<"d-flex justify-content-end"i>>>rt<"row"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>'
        });
    });
</script>
<script>
    function editarConfiguracion(id, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo) {
        document.getElementById('modalTitle').textContent = 'Editar Configuración de Stock';
        document.getElementById('idStockMinimo').value = id;
        document.getElementById('action').value = 'actualizar';
        document.getElementById('stockMinimoLote').value = stockMinimoLote;
        document.getElementById('stockCriticoLote').value = stockCriticoLote;
        document.getElementById('stockMinimoProducto').value = stockMinimoProducto;
        document.getElementById('stockCriticoProducto').value = stockCriticoProducto;
        document.getElementById('activo').checked = activo;
        document.getElementById('productoId').disabled = true;

        // Mostrar el modal
        var modal = new bootstrap.Modal(document.getElementById('modalStockMinimo'));
        modal.show();
    }

    function editarConfiguracionFromButton(btn) {
        const id = parseInt(btn.dataset.id);
        const nombre = btn.dataset.nombre;
        const stockMinimoLote = parseInt(btn.dataset.stockminimolote);
        const stockCriticoLote = parseInt(btn.dataset.stockcriticolote);
        const stockMinimoProducto = parseInt(btn.dataset.stockminimoproducto);
        const stockCriticoProducto = parseInt(btn.dataset.stockcriticoproducto);
        const activo = String(btn.dataset.activo) === 'true';
        editarConfiguracion(id, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo);
    }
    
    function editarConfiguracionDirecta(id, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo) {
        editarConfiguracion(id, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo);
    }
    
    function editarDesdeDropdown(element) {
        const id = parseInt(element.dataset.id);
        const nombre = element.dataset.nombre;
        const stockMinimoLote = parseInt(element.dataset.stockminimolote);
        const stockCriticoLote = parseInt(element.dataset.stockcriticolote);
        const stockMinimoProducto = parseInt(element.dataset.stockminimoproducto);
        const stockCriticoProducto = parseInt(element.dataset.stockcriticoproducto);
        const activo = element.dataset.activo === 'true';
        editarConfiguracion(id, nombre, stockMinimoLote, stockCriticoLote, stockMinimoProducto, stockCriticoProducto, activo);
    }

    function eliminarConfiguracion(id) {
        showConfirm(
            '¿Estás seguro de que deseas eliminar esta configuración?',
            function() {
                var form = document.createElement('form');
                form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/StockMinimoServlet';

            var actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'eliminar';

            var idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'idStockMinimo';
            idInput.value = id;

            form.appendChild(actionInput);
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
            },
            'Confirmar eliminación'
        );
    }

    function aplicarConfiguracionGlobal() {
        // Mostrar modal para que el admin elija los valores
        var modal = new bootstrap.Modal(document.getElementById('modalConfirmarGlobal'));
        modal.show();
    }

    // Limpiar formulario al cerrar modal
    document.getElementById('modalStockMinimo').addEventListener('hidden.bs.modal', function () {
        document.getElementById('formStockMinimo').reset();
        document.getElementById('modalTitle').textContent = 'Nueva Configuración de Stock';
        document.getElementById('action').value = 'crear';
        document.getElementById('productoId').disabled = false;
    });
</script>
</body>
</html>