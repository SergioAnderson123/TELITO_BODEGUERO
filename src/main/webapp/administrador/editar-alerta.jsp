<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/administrador/layouts/head.jsp" />
<jsp:include page="/administrador/layouts/header_admin.jsp" />

<div class="container-fluid">
    <div class="row">
        <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
            <jsp:param name="activeMenu" value="configuracion" />
        </jsp:include>

        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4">
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Editar Alerta</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <a href="<%= request.getContextPath() %>/AlertaServlet" class="btn btn-outline-secondary">
                        <i class="fas fa-arrow-left"></i> Volver
                    </a>
                </div>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle"></i> ${success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="row">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="card-title mb-0">
                                <i class="fas fa-bell"></i> Editar Configuración de Alerta
                            </h5>
                        </div>
                        <div class="card-body">
                            <form action="<%= request.getContextPath() %>/AlertaServlet" method="post">
                                <input type="hidden" name="action" value="actualizar">
                                <input type="hidden" name="id" value="${alerta.idAlertaConfig}">

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="nombre" class="form-label">Nombre de la Alerta</label>
                                            <input type="text" class="form-control" id="nombre" name="nombre"
                                                   value="${alerta.nombre}" required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="tipoAlerta" class="form-label">Tipo de Alerta</label>
                                            <select class="form-select" id="tipoAlerta" name="tipoAlerta" required>
                                                <option value="">Seleccionar tipo</option>
                                                <optgroup label="Alertas por Lote (Almacén)">
                                                    <option value="STOCK_MINIMO_LOTE" ${alerta.tipoAlerta == 'STOCK_MINIMO_LOTE' ? 'selected' : ''}>📦 Stock Mínimo por Lote</option>
                                                    <option value="STOCK_CRITICO_LOTE" ${alerta.tipoAlerta == 'STOCK_CRITICO_LOTE' ? 'selected' : ''}>📦 Stock Crítico por Lote</option>
                                                </optgroup>
                                                <optgroup label="Alertas por Producto Total (Logística)">
                                                    <option value="STOCK_MINIMO_TOTAL" ${alerta.tipoAlerta == 'STOCK_MINIMO_TOTAL' ? 'selected' : ''}>📊 Stock Mínimo Total</option>
                                                    <option value="STOCK_CRITICO_TOTAL" ${alerta.tipoAlerta == 'STOCK_CRITICO_TOTAL' ? 'selected' : ''}>📊 Stock Crítico Total</option>
                                                </optgroup>
                                                <optgroup label="Otras Alertas">
                                                    <option value="VENCIMIENTO" ${alerta.tipoAlerta == 'VENCIMIENTO' ? 'selected' : ''}>⏰ Próximo a Vencer</option>
                                                    <option value="MOVIMIENTO" ${alerta.tipoAlerta == 'MOVIMIENTO' ? 'selected' : ''}>🔄 Movimiento de Inventario</option>
                                                </optgroup>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="categoria" class="form-label">Categoría</label>
                                            <select class="form-select" id="categoria" name="categoria">
                                                <option value="">Todas las categorías</option>
                                                <c:forEach var="categoria" items="${listaCategorias}">
                                                    <option value="${categoria.idCategoria}"
                                                        ${alerta.categoria != null && alerta.categoria.idCategoria == categoria.idCategoria ? 'selected' : ''}>
                                                            ${categoria.nombre}
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="umbralDias" class="form-label">Umbral (días)</label>
                                            <input type="number" class="form-control" id="umbralDias" name="umbralDias"
                                                   value="${alerta.umbralDias}" min="0" placeholder="Solo para alertas de vencimiento">
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="rolANotificar" class="form-label">Rol a Notificar</label>
                                            <select class="form-select" id="rolANotificar" name="rolANotificar" required>
                                                <option value="">Seleccionar rol</option>
                                                <option value="ADMINISTRADOR" ${alerta.rolANotificar != null && alerta.rolANotificar.nombre == 'ADMINISTRADOR' ? 'selected' : ''}>Administrador</option>
                                                <option value="ALMACENERO" ${alerta.rolANotificar != null && alerta.rolANotificar.nombre == 'ALMACENERO' ? 'selected' : ''}>Almacenero</option>
                                                <option value="LOGISTICA" ${alerta.rolANotificar != null && alerta.rolANotificar.nombre == 'LOGISTICA' ? 'selected' : ''}>Logística</option>
                                                <option value="PRODUCTOR" ${alerta.rolANotificar != null && alerta.rolANotificar.nombre == 'PRODUCTOR' ? 'selected' : ''}>Productor</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <div class="form-check mt-4">
                                                <input class="form-check-input" type="checkbox" id="activo" name="activo"
                                                ${alerta.activo ? 'checked' : ''}>
                                                <label class="form-check-label" for="activo">
                                                    Alerta Activa
                                                </label>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="mensajePersonalizado" class="form-label">Mensaje Personalizado</label>
                                    <textarea class="form-control" id="mensajePersonalizado" name="mensajePersonalizado"
                                              rows="3" placeholder="Mensaje personalizado para la alerta">${alerta.mensajePersonalizado}</textarea>
                                </div>

                                <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                    <a href="<%= request.getContextPath() %>/AlertaServlet" class="btn btn-secondary me-md-2">
                                        <i class="fas fa-times"></i> Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save"></i> Actualizar Alerta
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="card">
                        <div class="card-header">
                            <h6 class="card-title mb-0">
                                <i class="fas fa-info-circle"></i> Información
                            </h6>
                        </div>
                        <div class="card-body">
                            <p class="text-muted small">
                                <strong>Tipos de Alertas:</strong><br>
                                • <strong>Stock Mínimo:</strong> Se activa cuando el stock baja del umbral mínimo<br>
                                • <strong>Stock Crítico:</strong> Se activa cuando el stock está muy bajo<br>
                                • <strong>Vencimiento:</strong> Se activa X días antes del vencimiento<br>
                                • <strong>Movimiento:</strong> Se activa en movimientos de inventario
                            </p>
                            <hr>
                            <p class="text-muted small">
                                <strong>Roles disponibles:</strong><br>
                                • Administrador: Acceso completo<br>
                                • Almacenero: Control de inventario<br>
                                • Logística: Gestión de distribución<br>
                                • Productor: Gestión de productos
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/administrador/layouts/footer.jsp" />