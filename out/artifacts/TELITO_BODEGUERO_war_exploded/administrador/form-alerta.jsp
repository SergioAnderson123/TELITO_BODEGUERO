<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Nueva Alerta"/>
    </jsp:include>
    <style>
        /* REGLA DE ORO: Todo debe caber en una sola pantalla sin scroll vertical */
        html, body {
            overflow-y: hidden !important;
            overflow-x: hidden !important;
        }
        
        .dashboard-content {
            padding: 10px 20px !important;
            overflow-y: hidden !important;
        }
        
        .page-header {
            margin-bottom: 15px !important;
            padding-bottom: 10px !important;
        }
        
        .page-header h2 {
            font-size: 1.3rem !important;
            margin-bottom: 3px !important;
        }
        
        .page-header p {
            font-size: 0.85rem !important;
            margin-bottom: 0 !important;
        }
        
        .card {
            margin-bottom: 0 !important;
            padding: 15px !important;
        }
        
        .card-header {
            padding: 12px 20px !important;
            margin: -15px -15px 15px -15px !important;
        }
        
        .card-header h5 {
            font-size: 1rem !important;
            margin-bottom: 2px !important;
        }
        
        .card-header small {
            font-size: 0.7rem !important;
        }
        
        .card-body {
            padding: 10px !important;
        }
        
        .form-label {
            font-size: 0.85rem !important;
            margin-bottom: 5px !important;
            font-weight: 600 !important;
        }
        
        .form-control, .form-select {
            font-size: 0.85rem !important;
            padding: 6px 12px !important;
            margin-bottom: 12px !important;
        }
        
        .mb-4 {
            margin-bottom: 12px !important;
        }
        
        .mb-3 {
            margin-bottom: 10px !important;
        }
        
        .mt-4 {
            margin-top: 10px !important;
        }
        
        .mt-5 {
            margin-top: 15px !important;
        }
        
        .pt-4 {
            padding-top: 12px !important;
        }
        
        textarea {
            min-height: 60px !important;
            resize: none !important;
        }
        
        .btn {
            font-size: 0.85rem !important;
            padding: 6px 16px !important;
        }
        
        .form-check {
            margin-top: 8px !important;
        }
        
        .form-check-label {
            font-size: 0.85rem !important;
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
            <div class="container-fluid px-3">
                <div class="page-header mb-2">
                    <h2 class="pageheader-title"><i class="fas fa-bell me-2"></i>Nueva Alerta</h2>
                    <p class="pageheader-text">Crea una nueva regla de alerta del sistema.</p>
                </div>

                <div class="row g-2">
                    <div class="col-12">
                        <div class="card shadow-sm">
                            <div class="card-header bg-gradient-primary text-white" style="background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border-radius: 12px 12px 0 0;">
                                <h5 class="mb-0"><i class="fas fa-bell me-2"></i>Datos de la Alerta</h5>
                                <small class="text-white-50">Complete todos los campos obligatorios</small>
                            </div>
                            <div class="card-body">
                                <c:if test="${not empty error}">
                                    <div class="alert alert-danger">${error}</div>
                                </c:if>
                                <form action="${pageContext.request.contextPath}/AlertaServlet" method="post">
                                    <input type="hidden" name="action" value="crear">
                                    <div class="row g-2">
                                        <div class="col-md-6">
                                            <label for="nombre" class="form-label fw-semibold">
                                                <i class="fas fa-tag me-1" style="color: #006d77; font-size: 0.75rem;"></i>Nombre <span class="text-danger">*</span>
                                            </label>
                                            <input type="text" class="form-control shadow-sm" id="nombre" name="nombre" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="tipoAlerta" class="form-label fw-semibold">
                                                <i class="fas fa-filter me-1" style="color: #006d77; font-size: 0.75rem;"></i>Tipo de Alerta <span class="text-danger">*</span>
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

                                    <div class="row g-2">
                                        <div class="col-md-6">
                                            <label for="umbralDias" class="form-label fw-semibold">
                                                <i class="fas fa-calendar-alt me-1" style="color: #006d77; font-size: 0.75rem;"></i>Umbral (días)
                                            </label>
                                            <input type="number" class="form-control shadow-sm" id="umbralDias" name="umbralDias" min="0" placeholder="Solo para Vencimiento">
                                            <small class="text-muted" style="font-size: 0.7rem;">Solo aplica para alertas de vencimiento</small>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="categoriaId" class="form-label fw-semibold">
                                                <i class="fas fa-folder me-1" style="color: #006d77; font-size: 0.75rem;"></i>Categoría
                                            </label>
                                            <select class="form-select shadow-sm" id="categoriaId" name="categoriaId">
                                                <option value="">Todas</option>
                                                <c:forEach var="categoria" items="${listaCategorias}">
                                                    <option value="${categoria.idCategoria}">${categoria.nombre}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="row g-2">
                                        <div class="col-md-6">
                                            <label for="rolANotificar" class="form-label fw-semibold">
                                                <i class="fas fa-user-tag me-1" style="color: #006d77; font-size: 0.75rem;"></i>Rol a Notificar <span class="text-danger">*</span>
                                            </label>
                                            <select class="form-select shadow-sm" id="rolANotificar" name="rolANotificar" required>
                                                <option value="">Selecciona un rol</option>
                                                <option value="ADMINISTRADOR">Administrador</option>
                                                <option value="LOGISTICA">Logística</option>
                                                <option value="ALMACENERO">Almacenero</option>
                                                <option value="PRODUCTOR">Productor</option>
                                            </select>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold d-block" style="margin-bottom: 5px;">
                                                <i class="fas fa-toggle-on me-1" style="color: #006d77; font-size: 0.75rem;"></i>Estado
                                            </label>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" id="activo" name="activo" checked>
                                                <label class="form-check-label" for="activo">Alerta activa</label>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mb-2">
                                        <label for="mensajePersonalizado" class="form-label fw-semibold">
                                            <i class="fas fa-comment me-1" style="color: #006d77; font-size: 0.75rem;"></i>Mensaje Personalizado
                                        </label>
                                        <textarea class="form-control shadow-sm" id="mensajePersonalizado" name="mensajePersonalizado" rows="2" placeholder="Mensaje opcional (puede usar variables: {producto}, {lote}, {stock_actual}, {umbral})"></textarea>
                                    </div>

                                    <div class="mt-2 pt-2 border-top d-flex justify-content-between align-items-center">
                                        <a href="${pageContext.request.contextPath}/AlertaServlet" class="btn btn-outline-secondary shadow-sm">
                                            <i class="fas fa-times me-1"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-primary shadow-sm px-4" style="background: linear-gradient(160deg, #006d77 0%, #83c5be 100%); border: none;">
                                            <i class="fas fa-save me-1"></i>Guardar
                                        </button>
                                    </div>
                                </form>
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
