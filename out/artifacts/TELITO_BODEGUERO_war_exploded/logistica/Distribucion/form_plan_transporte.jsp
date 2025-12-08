<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.LoteBean" %>
<%@ page import="com.example.telito.logistica.beans.ConductorBean" %>
<%@ page import="com.example.telito.logistica.beans.VehiculoBean" %>
<%@ page import="com.example.telito.logistica.beans.DistritoBean" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Generar Plan de Transporte"/>
    </jsp:include>
    <style>
        /* REGLA DE ORO: Todo debe caber en una sola pantalla sin scroll vertical */
        .dashboard-content {
            padding: 10px !important;
            overflow-y: hidden !important;
        }
        
        .page-header {
            margin-bottom: 10px !important;
        }
        
        .page-header h2 {
            color: #006d77;
            font-weight: 700;
            margin-bottom: 2px;
            font-size: 1.15rem;
        }
        
        .page-header p {
            color: #6c757d;
            font-size: 0.8rem;
            margin-bottom: 0;
        }
        
        /* Estilos para secciones del formulario - ULTRA COMPACTAS */
        .form-section {
            background: white;
            border-radius: 6px;
            padding: 8px 12px;
            margin-bottom: 8px;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
            border: 1px solid #e9ecef;
        }
        
        .form-section-title {
            color: #006d77;
            font-weight: 700;
            font-size: 0.85rem;
            margin-bottom: 6px;
            padding-bottom: 5px;
            border-bottom: 2px solid #edf6f9;
            display: flex;
            align-items: center;
        }
        
        .form-section-title i {
            margin-right: 6px;
            color: #83c5be;
            font-size: 0.9rem;
        }
        
        /* Campos del formulario - ULTRA COMPACTOS */
        .form-label {
            font-weight: 600;
            color: #2b2d42;
            margin-bottom: 3px;
            font-size: 0.8rem;
        }
        
        .form-label i {
            color: #006d77;
            margin-right: 4px;
            width: 14px;
            font-size: 0.8rem;
        }
        
        .form-control, .form-select {
            border: 2px solid #e9ecef;
            border-radius: 5px;
            padding: 5px 10px;
            font-size: 0.85rem;
            transition: all 0.3s ease;
            height: auto;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: #83c5be;
            box-shadow: 0 0 0 0.2rem rgba(131, 197, 190, 0.25);
        }
        
        /* Card principal - ULTRA COMPACTO */
        .main-card {
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            border: none;
            overflow: hidden;
        }
        
        .card-header-custom {
            background: linear-gradient(160deg, #006d77 0%, #83c5be 100%);
            color: white;
            padding: 8px 15px;
            border: none;
        }
        
        .card-header-custom h5 {
            margin: 0;
            font-weight: 700;
            font-size: 0.95rem;
        }
        
        .card-header-custom small {
            color: rgba(255, 255, 255, 0.9);
            font-size: 0.75rem;
        }
        
        /* Botones - ULTRA COMPACTOS */
        .btn-custom-dark {
            background: linear-gradient(160deg, #006d77 0%, #83c5be 100%);
            border: none;
            color: white;
            font-weight: 600;
            padding: 6px 16px;
            border-radius: 5px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 4px rgba(0, 109, 119, 0.3);
            font-size: 0.85rem;
        }
        
        .btn-custom-dark:hover {
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(0, 109, 119, 0.4);
            color: white;
        }
        
        .btn-secondary {
            border-radius: 5px;
            padding: 6px 16px;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 0.85rem;
        }
        
        .btn-secondary:hover {
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.15);
        }
        
        /* Información adicional - COMPACTA pero visible */
        .info-text {
            font-size: 0.7rem;
            color: #6c757d;
            margin-top: 2px;
            margin-bottom: 0;
            line-height: 1.2;
        }
        
        .info-text i {
            color: #83c5be;
            margin-right: 3px;
            font-size: 0.65rem;
        }
        
        /* Iconos en los campos */
        .input-group-icon {
            position: relative;
        }
        
        .input-group-icon i {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #83c5be;
            pointer-events: none;
            font-size: 0.8rem;
        }
        
        .input-group-icon .form-control,
        .input-group-icon .form-select {
            padding-right: 30px;
        }
        
        /* Reducir márgenes entre campos */
        .mb-3 {
            margin-bottom: 0.5rem !important;
        }
        
        /* Espaciado del card body */
        .card-body {
            padding: 12px !important;
        }
        
        /* Botones de acción más compactos */
        .border-top {
            margin-top: 8px !important;
            padding-top: 8px !important;
        }
        
        /* Asegurar que no haya scroll */
        body {
            overflow-x: hidden;
            overflow-y: hidden !important;
        }
        
        html {
            overflow-y: hidden !important;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value='Distribucion'/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header">
                        <h2><i class="fas fa-truck me-2"></i>Generar Nuevo Plan de Transporte</h2>
                        <p class="text-muted">Complete el formulario para crear un nuevo plan de distribución y transporte</p>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-9 col-md-11 col-sm-12 mx-auto">
                    <div class="card main-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-clipboard-list me-2"></i>Información del Plan de Transporte</h5>
                            <small><i class="fas fa-info-circle me-1"></i>Complete todos los campos obligatorios para generar el plan</small>
                        </div>
                        <div class="card-body" style="padding: 30px;">
                            <form method="POST" action="${pageContext.request.contextPath}/planes-transporte" id="formPlanTransporte">
                                <input type="hidden" name="action" value="guardar">

                                <!-- Sección 1: Producto y Lote -->
                                <div class="form-section">
                                    <div class="form-section-title">
                                        <i class="fas fa-box"></i>Producto y Lote a Transportar
                                    </div>
                                    <div class="input-group-icon">
                                        <label for="lote" class="form-label">
                                            <i class="fas fa-tags"></i>Seleccionar Lote <span class="text-danger">*</span>
                                        </label>
                                        <select class="form-select" id="lote" name="lote_id" required>
                                            <option value="" selected disabled>Seleccione un lote...</option>
                                            <% ArrayList<LoteBean> listaLotes = (ArrayList<LoteBean>) request.getAttribute("listaLotes");
                                                if (listaLotes != null) {
                                                    for (LoteBean lote : listaLotes) { %>
                                            <option value="<%= lote.getId() %>"><%= lote.getNombreProducto() %> - Lote: <%= lote.getCodigoLote() %></option>
                                            <%     }
                                            } %>
                                        </select>
                                        <i class="fas fa-chevron-down"></i>
                                    </div>
                                    <small class="info-text">
                                        <i class="fas fa-info-circle"></i>Seleccione el producto y lote que será transportado
                                    </small>
                                </div>

                                <!-- Sección 2: Asignación de Recursos -->
                                <div class="form-section">
                                    <div class="form-section-title">
                                        <i class="fas fa-users-cog"></i>Asignación de Recursos
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <div class="input-group-icon">
                                                <label for="conductor" class="form-label">
                                                    <i class="fas fa-user-tie"></i>Conductor <span class="text-danger">*</span>
                                                </label>
                                                <select class="form-select" id="conductor" name="conductor_id" required>
                                                    <option value="" selected disabled>Seleccione un conductor...</option>
                                                    <% ArrayList<ConductorBean> listaConductores = (ArrayList<ConductorBean>) request.getAttribute("listaConductores");
                                                        if (listaConductores != null) {
                                                            for (ConductorBean conductor : listaConductores) { %>
                                                    <option value="<%= conductor.getId() %>"><%= conductor.getNombreCompleto() %></option>
                                                    <%     }
                                                        } %>
                                                </select>
                                                <i class="fas fa-chevron-down"></i>
                                            </div>
                                            <small class="info-text">
                                                <i class="fas fa-info-circle"></i>Seleccione el conductor responsable del transporte
                                            </small>
                                        </div>

                                        <div class="col-md-6 mb-3">
                                            <div class="input-group-icon">
                                                <label for="vehiculo" class="form-label">
                                                    <i class="fas fa-truck"></i>Vehículo <span class="text-danger">*</span>
                                                </label>
                                                <select class="form-select" id="vehiculo" name="vehiculo_id" required>
                                                    <option value="" selected disabled>Seleccione un vehículo...</option>
                                                    <% ArrayList<VehiculoBean> listaVehiculos = (ArrayList<VehiculoBean>) request.getAttribute("listaVehiculos");
                                                        if (listaVehiculos != null) {
                                                            for (VehiculoBean vehiculo : listaVehiculos) { %>
                                                    <option value="<%= vehiculo.getId() %>"><%= vehiculo.getPlaca() %></option>
                                                    <%     }
                                                        } %>
                                                </select>
                                                <i class="fas fa-chevron-down"></i>
                                            </div>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <small class="info-text">
                                                <i class="fas fa-info-circle"></i>Seleccione el vehículo que realizará el transporte
                                            </small>
                                        </div>
                                    </div>
                                </div>

                                <!-- Sección 3: Programación y Destino -->
                                <div class="form-section">
                                    <div class="form-section-title">
                                        <i class="fas fa-calendar-alt"></i>Programación y Destino
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="fechaEntrega" class="form-label">
                                                <i class="fas fa-calendar-check"></i>Fecha de Entrega <span class="text-danger">*</span>
                                            </label>
                                            <div class="input-group-icon">
                                                <input type="date" class="form-control" id="fechaEntrega" name="fecha_entrega" required>
                                                <i class="fas fa-calendar"></i>
                                            </div>
                                            <small class="info-text">
                                                <i class="fas fa-info-circle"></i>Seleccione la fecha programada para la entrega
                                            </small>
                                        </div>

                                        <div class="col-md-6 mb-3">
                                            <div class="input-group-icon">
                                                <label for="destino" class="form-label">
                                                    <i class="fas fa-map-marker-alt"></i>Destino (Distrito) <span class="text-danger">*</span>
                                                </label>
                                                <select class="form-select" id="destino" name="distrito_id" required>
                                                    <option value="" selected disabled>Seleccione un destino...</option>
                                                    <% ArrayList<DistritoBean> listaDistritos = (ArrayList<DistritoBean>) request.getAttribute("listaDistritos");
                                                        if (listaDistritos != null) {
                                                            for (DistritoBean distrito : listaDistritos) { %>
                                                    <option value="<%= distrito.getId() %>"><%= distrito.getNombre() %></option>
                                                    <%     }
                                                        } %>
                                                </select>
                                                <i class="fas fa-chevron-down"></i>
                                            </div>
                                            <small class="info-text">
                                                <i class="fas fa-info-circle"></i>Seleccione el distrito de destino para la entrega
                                            </small>
                                        </div>
                                    </div>
                                </div>

                                <!-- Botones de acción -->
                                <div class="d-flex justify-content-end gap-2 border-top">
                                    <a href="${pageContext.request.contextPath}/planes-transporte" class="btn btn-secondary">
                                        <i class="fas fa-times me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-custom-dark">
                                        <i class="fas fa-save me-2"></i>Guardar Plan de Transporte
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/logistica/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Validación del formulario
    document.getElementById('formPlanTransporte').addEventListener('submit', function(e) {
        const lote = document.getElementById('lote').value;
        const conductor = document.getElementById('conductor').value;
        const vehiculo = document.getElementById('vehiculo').value;
        const fechaEntrega = document.getElementById('fechaEntrega').value;
        const destino = document.getElementById('destino').value;
        
        if (!lote || !conductor || !vehiculo || !fechaEntrega || !destino) {
            e.preventDefault();
            alert('Por favor complete todos los campos obligatorios');
            return false;
        }
        
        // Validar que la fecha no sea anterior a hoy
        const hoy = new Date();
        hoy.setHours(0, 0, 0, 0);
        const fechaSeleccionada = new Date(fechaEntrega);
        
        if (fechaSeleccionada < hoy) {
            e.preventDefault();
            alert('La fecha de entrega no puede ser anterior a la fecha actual');
            return false;
        }
    });
    
    // Establecer fecha mínima como hoy
    document.addEventListener('DOMContentLoaded', function() {
        const fechaInput = document.getElementById('fechaEntrega');
        const hoy = new Date().toISOString().split('T')[0];
        fechaInput.setAttribute('min', hoy);
    });
</script>
</body>
</html>