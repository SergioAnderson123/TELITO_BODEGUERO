<%--
  Created by IntelliJ IDEA.
  User: Sergio
  Date: 21/10/2025
  Time: 17:32
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Alertas"/>
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
                    <h2 class="pageheader-title"><i class="fas fa-bell me-2"></i>Gestión de Alertas</h2>
                    <p class="pageheader-text">Configura las reglas de alerta del sistema para notificaciones automáticas.</p>
                </div>

                <!-- Botón para agregar nueva alerta -->
                <div class="row mb-4">
                    <div class="col-12">
                        <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalAlerta">
                            <i class="fas fa-plus me-2"></i>Nueva Alerta
                        </button>
                    </div>
                </div>

                <!-- Tabla de alertas -->
                <div class="card">
                    <div class="card-header">
                        <h5 class="card-title mb-0"><i class="fas fa-list me-2"></i>Configuraciones de Alertas</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-dark">
                                <tr>
                                    <th>Nombre</th>
                                    <th>Tipo de Alerta</th>
                                    <th>Umbral (días)</th>
                                    <th>Categoría</th>
                                    <th>Rol a Notificar</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="alerta" items="${listaAlertas}">
                                    <tr>
                                        <td>${alerta.nombre}</td>
                                        <td>
                                            <span class="badge bg-info">${alerta.tipoAlerta}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${alerta.umbralDias != null}">
                                                    <span class="badge bg-warning">${alerta.umbralDias} días</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${alerta.categoria != null}">
                                                    <span class="badge bg-secondary">${alerta.categoria.nombre}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted">Todas</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-primary">${alerta.rolANotificar.nombre}</span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${alerta.activo}">
                                                    <span class="badge bg-success">Activo</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Inactivo</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <button type="button" class="btn btn-sm btn-outline-primary"
                                                    onclick="editarAlerta(${alerta.idAlertaConfig}, '${alerta.nombre}', '${alerta.tipoAlerta}', ${alerta.umbralDias}, '${alerta.categoria != null ? alerta.categoria.idCategoria : ''}', '${alerta.rolANotificar.nombre}', '${alerta.mensajePersonalizado}', ${alerta.activo})">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                            <button type="button" class="btn btn-sm btn-outline-danger"
                                                    onclick="eliminarAlerta(${alerta.idAlertaConfig})">
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

<!-- Modal para agregar/editar alerta -->
<div class="modal fade" id="modalAlerta" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Nueva Configuración de Alerta</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="formAlerta" action="${pageContext.request.contextPath}/AlertaServlet" method="post">
                <div class="modal-body">
                    <input type="hidden" id="idAlertaConfig" name="idAlertaConfig">
                    <input type="hidden" id="action" name="action" value="crear">

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="nombre" class="form-label">Nombre de la Alerta</label>
                                <input type="text" class="form-control" id="nombre" name="nombre"
                                       required placeholder="Ej: Stock Mínimo Almacén">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="tipoAlerta" class="form-label">Tipo de Alerta</label>
                                <select class="form-select" id="tipoAlerta" name="tipoAlerta" required>
                                    <option value="">Selecciona un tipo</option>
                                    <option value="STOCK_MINIMO">Stock Mínimo</option>
                                    <option value="STOCK_CRITICO">Stock Crítico</option>
                                    <option value="CADUCIDAD_PROXIMA">Caducidad Próxima</option>
                                    <option value="CADUCIDAD_VENCIDA">Producto Vencido</option>
                                    <option value="MOVIMIENTO_ANORMAL">Movimiento Anormal</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="umbralDias" class="form-label">Umbral (días)</label>
                                <input type="number" class="form-control" id="umbralDias" name="umbralDias"
                                       min="0" placeholder="Solo para alertas de caducidad">
                                <div class="form-text">Solo aplica para alertas de caducidad</div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="categoriaId" class="form-label">Categoría</label>
                                <select class="form-select" id="categoriaId" name="categoriaId">
                                    <option value="">Todas las categorías</option>
                                    <c:forEach var="categoria" items="${listaCategorias}">
                                        <option value="${categoria.idCategoria}">${categoria.nombre}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="rolANotificar" class="form-label">Rol a Notificar</label>
                                <select class="form-select" id="rolANotificar" name="rolANotificar" required>
                                    <option value="">Selecciona un rol</option>
                                    <option value="ADMINISTRADOR">Administrador</option>
                                    <option value="LOGISTICA">Logística</option>
                                    <option value="ALMACEN">Almacén</option>
                                    <option value="PRODUCTOR">Productor</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <div class="form-check mt-4">
                                    <input class="form-check-input" type="checkbox" id="activo" name="activo" checked>
                                    <label class="form-check-label" for="activo">
                                        Alerta activa
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="mensajePersonalizado" class="form-label">Mensaje Personalizado</label>
                        <textarea class="form-control" id="mensajePersonalizado" name="mensajePersonalizado"
                                  rows="3" placeholder="Mensaje personalizado para la alerta (opcional)"></textarea>
                        <div class="form-text">Variables disponibles: {producto}, {lote}, {stock_actual}, {dias_restantes}</div>
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
    function editarAlerta(id, nombre, tipoAlerta, umbralDias, categoriaId, rolANotificar, mensajePersonalizado, activo) {
        document.getElementById('modalTitle').textContent = 'Editar Configuración de Alerta';
        document.getElementById('idAlertaConfig').value = id;
        document.getElementById('action').value = 'actualizar';
        document.getElementById('nombre').value = nombre;
        document.getElementById('tipoAlerta').value = tipoAlerta;
        document.getElementById('umbralDias').value = umbralDias || '';
        document.getElementById('categoriaId').value = categoriaId || '';
        document.getElementById('rolANotificar').value = rolANotificar;
        document.getElementById('mensajePersonalizado').value = mensajePersonalizado || '';
        document.getElementById('activo').checked = activo;

        // Mostrar el modal
        var modal = new bootstrap.Modal(document.getElementById('modalAlerta'));
        modal.show();
    }

    function eliminarAlerta(id) {
        if (confirm('¿Estás seguro de que deseas eliminar esta configuración de alerta?')) {
            var form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/AlertaServlet';

            var actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'eliminar';

            var idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'idAlertaConfig';
            idInput.value = id;

            form.appendChild(actionInput);
            form.appendChild(idInput);
            document.body.appendChild(form);
            form.submit();
        }
    }

    // Limpiar formulario al cerrar modal
    document.getElementById('modalAlerta').addEventListener('hidden.bs.modal', function () {
        document.getElementById('formAlerta').reset();
        document.getElementById('modalTitle').textContent = 'Nueva Configuración de Alerta';
        document.getElementById('action').value = 'crear';
    });

    // Mostrar/ocultar campo umbral según tipo de alerta
    document.getElementById('tipoAlerta').addEventListener('change', function() {
        var umbralField = document.getElementById('umbralDias');
        var tiposConUmbral = ['CADUCIDAD_PROXIMA', 'CADUCIDAD_VENCIDA'];

        if (tiposConUmbral.includes(this.value)) {
            umbralField.required = true;
            umbralField.parentElement.style.display = 'block';
        } else {
            umbralField.required = false;
            umbralField.value = '';
        }
    });
</script>
</body>
</html>