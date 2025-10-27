<%--
  Created by IntelliJ IDEA.
  User: Sergio
  Date: 21/10/2025
  Time: 17:17
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Stock Mínimo"/>
    </jsp:include>
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
                <div class="page-header mb-4">
                    <h2 class="pageheader-title"><i class="fas fa-triangle-exclamation me-2"></i>Gestión de Stock Mínimo</h2>
                    <p class="pageheader-text">Configura los umbrales de stock mínimo y crítico para cada producto.</p>
                </div>

                <!-- Botón para agregar nueva configuración -->
                <div class="row mb-4">
                    <div class="col-12">
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalStockMinimo">
                            <i class="fas fa-plus me-2"></i>Nueva Configuración
                        </button>
                        <button type="button" class="btn btn-info ms-2" onclick="aplicarConfiguracionGlobal()">
                            <i class="fas fa-cogs me-2"></i>Aplicar Configuración Global
                        </button>
                    </div>
                </div>

                <!-- Tabla de configuraciones -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0"><i class="fas fa-list me-2"></i>Configuraciones de Stock Mínimo</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="bg-light">
                                <tr>
                                    <th>Producto</th>
                                    <th>Código</th>
                                    <th>Stock Mín. Lote</th>
                                    <th>Stock Crít. Lote</th>
                                    <th>Stock Mín. Total</th>
                                    <th>Stock Crít. Total</th>
                                    <th>Estado</th>
                                    <th>Última Actualización</th>
                                    <th>Acciones</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="config" items="${listaStockMinimo}">
                                    <tr>
                                        <td>${config.producto.nombre}</td>
                                        <td><span class="badge bg-secondary">${config.producto.codigoSku}</span></td>
                                        <td>
                                            <span class="badge bg-info">${config.stockMinimoLote}</span>
                                        </td>
                                        <td>
                                            <span class="badge bg-warning">${config.stockCriticoLote}</span>
                                        </td>
                                        <td>
                                            <span class="badge bg-primary">${config.stockMinimoProducto}</span>
                                        </td>
                                        <td>
                                            <span class="badge bg-danger">${config.stockCriticoProducto}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${config.activo}">
                                                    <span class="badge bg-success">Activo</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Inactivo</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${config.fechaActualizacion}</td>
                                        <td>
                                            <button type="button" class="btn btn-sm btn-outline-primary"
                                                    data-id="${config.idStockMinimo}"
                                                    data-nombre="${config.producto.nombre}"
                                                    data-stockminimolote="${config.stockMinimoLote}"
                                                    data-stockcriticolote="${config.stockCriticoLote}"
                                                    data-stockminimoproducto="${config.stockMinimoProducto}"
                                                    data-stockcriticoproducto="${config.stockCriticoProducto}"
                                                    data-activo="${config.activo}"
                                                    onclick="editarConfiguracionFromButton(this)">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-outline-danger"
                                                    onclick="eliminarConfiguracion(${config.idStockMinimo})">
                                                <i class="fas fa-trash"></i>
                                            </button>
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
                                            <span class="input-group-text">📦</span>
                                        </div>
                                        <div class="form-text">Por cada lote individual</div>
                                    </div>
                                    <div class="mb-3">
                                        <label for="stockCriticoLote" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockCriticoLote" 
                                                   name="stockCriticoLote" min="0" required placeholder="Ej: 5">
                                            <span class="input-group-text">📦</span>
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
                                            <span class="input-group-text">📦</span>
                                        </div>
                                        <div class="form-text">Suma de todos los lotes</div>
                                    </div>
                                    <div class="mb-3">
                                        <label for="stockCriticoProducto" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="stockCriticoProducto" 
                                                   name="stockCriticoProducto" min="0" required placeholder="Ej: 20">
                                            <span class="input-group-text">📦</span>
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
                                            <span class="input-group-text">📦</span>
                                        </div>
                                        <div class="form-text">Paquetes por lote</div>
                                    </div>
                                    <div class="mb-0">
                                        <label for="globalStockCriticoLote" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="globalStockCriticoLote" 
                                                   name="stockCriticoLote" min="1" required placeholder="Ej: 5" value="5">
                                            <span class="input-group-text">📦</span>
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
                                            <span class="input-group-text">📦</span>
                                        </div>
                                        <div class="form-text">Suma de todos los lotes</div>
                                    </div>
                                    <div class="mb-0">
                                        <label for="globalStockCriticoProducto" class="form-label">Stock Crítico:</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" id="globalStockCriticoProducto" 
                                                   name="stockCriticoProducto" min="1" required placeholder="Ej: 20" value="20">
                                            <span class="input-group-text">📦</span>
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

    function eliminarConfiguracion(id) {
        if (confirm('¿Estás seguro de que deseas eliminar esta configuración?')) {
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
        }
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