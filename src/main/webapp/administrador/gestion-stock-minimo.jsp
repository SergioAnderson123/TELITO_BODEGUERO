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
                                <thead class="table-dark">
                                <tr>
                                    <th>Producto</th>
                                    <th>Código</th>
                                    <th>Stock Mínimo</th>
                                    <th>Stock Crítico</th>
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
                                            <span class="badge bg-warning">${config.stockMinimo}</span>
                                        </td>
                                        <td>
                                            <span class="badge bg-danger">${config.stockCritico}</span>
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
                                                    data-stockminimo="${config.stockMinimo}"
                                                    data-stockcritico="${config.stockCritico}"
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
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Nueva Configuración de Stock</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="formStockMinimo" action="${pageContext.request.contextPath}/StockMinimoServlet" method="post">
                <div class="modal-body">
                    <input type="hidden" id="idStockMinimo" name="idStockMinimo">
                    <input type="hidden" id="action" name="action" value="crear">

                    <div class="mb-3">
                        <label for="productoId" class="form-label">Producto</label>
                        <select class="form-select" id="productoId" name="productoId" required>
                            <option value="">Selecciona un producto</option>
                            <c:forEach var="producto" items="${listaProductos}">
                                <option value="${producto.idProducto}">${producto.nombre} (${producto.codigoSku})</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="stockMinimo" class="form-label">Stock Mínimo</label>
                        <input type="number" class="form-control" id="stockMinimo" name="stockMinimo"
                               min="0" required placeholder="Ej: 10">
                        <div class="form-text">Cantidad mínima antes de generar alerta</div>
                    </div>

                    <div class="mb-3">
                        <label for="stockCritico" class="form-label">Stock Crítico</label>
                        <input type="number" class="form-control" id="stockCritico" name="stockCritico"
                               min="0" required placeholder="Ej: 5">
                        <div class="form-text">Cantidad crítica que requiere acción inmediata</div>
                    </div>

                    <div class="mb-3">
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function editarConfiguracion(id, nombre, stockMinimo, stockCritico, activo) {
        document.getElementById('modalTitle').textContent = 'Editar Configuración de Stock';
        document.getElementById('idStockMinimo').value = id;
        document.getElementById('action').value = 'actualizar';
        document.getElementById('stockMinimo').value = stockMinimo;
        document.getElementById('stockCritico').value = stockCritico;
        document.getElementById('activo').checked = activo;
        document.getElementById('productoId').disabled = true;

        // Mostrar el modal
        var modal = new bootstrap.Modal(document.getElementById('modalStockMinimo'));
        modal.show();
    }

    function editarConfiguracionFromButton(btn) {
        const id = parseInt(btn.dataset.id);
        const nombre = btn.dataset.nombre;
        const stockMinimo = parseInt(btn.dataset.stockminimo);
        const stockCritico = parseInt(btn.dataset.stockcritico);
        const activo = String(btn.dataset.activo) === 'true';
        editarConfiguracion(id, nombre, stockMinimo, stockCritico, activo);
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
        if (confirm('¿Aplicar configuración global a todos los productos sin configuración específica?')) {
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/StockMinimoServlet';

            var actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'aplicarGlobal';

            form.appendChild(actionInput);
            document.body.appendChild(form);
            form.submit();
        }
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