<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Nueva Alerta"/>
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
                    <h2 class="pageheader-title"><i class="fas fa-bell me-2"></i>Nueva Alerta</h2>
                    <p class="pageheader-text">Crea una nueva regla de alerta del sistema.</p>
                </div>

                <div class="row">
                    <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
                        <div class="card shadow-sm">
                            <div class="card-header bg-gradient-primary text-white mb-4" style="background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border-radius: 12px 12px 0 0; margin: -30px -30px 30px -30px; padding: 25px 30px;">
                                <h5 class="mb-0"><i class="fas fa-bell me-2"></i>Datos de la Alerta</h5>
                                <small class="text-white-50">Complete todos los campos obligatorios</small>
                            </div>
                            <div class="card-body">
                                <c:if test="${not empty error}">
                                    <div class="alert alert-danger">${error}</div>
                                </c:if>
                                <form action="${pageContext.request.contextPath}/AlertaServlet" method="post">
                                    <input type="hidden" name="action" value="crear">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-4">
                                                <label for="nombre" class="form-label fw-semibold">
                                                    <i class="fas fa-tag text-primary me-2"></i>Nombre <span class="text-danger">*</span>
                                                </label>
                                                <input type="text" class="form-control shadow-sm" id="nombre" name="nombre" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-4">
                                                <label for="tipoAlerta" class="form-label fw-semibold">
                                                    <i class="fas fa-filter text-primary me-2"></i>Tipo de Alerta <span class="text-danger">*</span>
                                                </label>
                                                <select class="form-select shadow-sm" id="tipoAlerta" name="tipoAlerta" required>
                                                    <option value="">Selecciona un tipo</option>
                                                    <optgroup label="Alertas por Lote (Almacén)">
                                                        <option value="STOCK_MINIMO_LOTE">📦 Stock Mínimo por Lote</option>
                                                        <option value="STOCK_CRITICO_LOTE">📦 Stock Crítico por Lote</option>
                                                    </optgroup>
                                                    <optgroup label="Alertas por Producto Total (Logística)">
                                                        <option value="STOCK_MINIMO_TOTAL">📊 Stock Mínimo Total</option>
                                                        <option value="STOCK_CRITICO_TOTAL">📊 Stock Crítico Total</option>
                                                    </optgroup>
                                                    <optgroup label="Otras Alertas">
                                                        <option value="VENCIMIENTO">⏰ Próximo a Vencer</option>
                                                        <option value="MOVIMIENTO">🔄 Movimiento de Inventario</option>
                                                    </optgroup>
                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-4">
                                                <label for="umbralDias" class="form-label fw-semibold">
                                                    <i class="fas fa-calendar-alt text-primary me-2"></i>Umbral (días)
                                                </label>
                                                <input type="number" class="form-control shadow-sm" id="umbralDias" name="umbralDias" min="0" placeholder="Solo para Vencimiento">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-4">
                                                <label for="categoriaId" class="form-label fw-semibold">
                                                    <i class="fas fa-folder text-primary me-2"></i>Categoría
                                                </label>
                                                <select class="form-select shadow-sm" id="categoriaId" name="categoriaId">
                                                    <option value="">Todas</option>
                                                    <c:forEach var="categoria" items="${listaCategorias}">
                                                        <option value="${categoria.idCategoria}">${categoria.nombre}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="mb-4">
                                                <label for="rolANotificar" class="form-label fw-semibold">
                                                    <i class="fas fa-user-tag text-primary me-2"></i>Rol a Notificar <span class="text-danger">*</span>
                                                </label>
                                                <select class="form-select shadow-sm" id="rolANotificar" name="rolANotificar" required>
                                                    <option value="">Selecciona un rol</option>
                                                    <option value="ADMINISTRADOR">Administrador</option>
                                                    <option value="LOGISTICA">Logística</option>
                                                    <option value="ALMACENERO">Almacenero</option>
                                                    <option value="PRODUCTOR">Productor</option>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="mb-3">
                                                <div class="form-check mt-4">
                                                    <input class="form-check-input" type="checkbox" id="activo" name="activo" checked>
                                                    <label class="form-check-label" for="activo">Alerta activa</label>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mb-4">
                                        <label for="mensajePersonalizado" class="form-label fw-semibold">
                                            <i class="fas fa-comment text-primary me-2"></i>Mensaje Personalizado
                                        </label>
                                        <textarea class="form-control shadow-sm" id="mensajePersonalizado" name="mensajePersonalizado" rows="3" placeholder="Mensaje opcional"></textarea>
                                    </div>

                                    <div class="mt-5 pt-4 border-top d-flex justify-content-between align-items-center">
                                        <a href="${pageContext.request.contextPath}/AlertaServlet" class="btn btn-outline-secondary shadow-sm">
                                            <i class="fas fa-times me-2"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-primary shadow-sm px-4">
                                            <i class="fas fa-save me-2"></i>Guardar
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header"><h6 class="card-title mb-0"><i class="fas fa-info-circle me-2"></i>Información</h6></div>
                            <div class="card-body">
                                <p class="text-muted small">
                                    Configura alertas para notificar a roles específicos cuando se cumplan condiciones.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
// Mostrar/ocultar umbral según tipo
const tipoSel = document.getElementById('tipoAlerta');
const umbralInput = document.getElementById('umbralDias');
if (tipoSel && umbralInput) {
  tipoSel.addEventListener('change', function(){
    const needs = this.value === 'VENCIMIENTO';
    umbralInput.required = needs;
    if (!needs) umbralInput.value = '';
  });
}
</script>
</body>
</html>
