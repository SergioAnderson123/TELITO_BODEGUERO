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
                    <div class="page-header"><h2><i class="fas fa-plus me-2"></i>Generar Nuevo Plan de Transporte</h2></div>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-8 col-md-10 col-sm-12 mx-auto">
                    <div class="card">
                        <div class="card-body">
                            <form method="POST" action="${pageContext.request.contextPath}/planes-transporte">
                                <input type="hidden" name="action" value="guardar">

                                <div class="mb-3">
                                    <label for="lote" class="form-label">Producto y Lote a Transportar</label>
                                    <select class="form-select" id="lote" name="lote_id" required onchange="actualizarInfoLote()">
                                        <option value="" selected disabled>Seleccione un lote...</option>
                                        <% ArrayList<LoteBean> listaLotes = (ArrayList<LoteBean>) request.getAttribute("listaLotes");
                                            if (listaLotes != null) {
                                                for (LoteBean lote : listaLotes) { %>
                                        <option value="<%= lote.getId() %>" 
                                                data-stock="<%= lote.getStockActual() %>"
                                                data-unidades-paquete="<%= lote.getUnidadesPorPaquete() %>"
                                                data-paquetes="<%= lote.getPaquetesDisponibles() %>">
                                            <%= lote.getNombreProducto() %> (<%= lote.getCodigoLote() %>) - <%= lote.getPaquetesDisponibles() %> paquetes disponibles
                                        </option>
                                        <%     }
                                        } %>
                                    </select>
                                    <small class="form-text text-muted" id="infoLote">
                                        <i class="fas fa-info-circle"></i> Selecciona un lote para ver la información disponible
                                    </small>
                                </div>

                                <div class="mb-3">
                                    <label for="cantidad_paquetes" class="form-label">Cantidad de Paquetes a Transportar</label>
                                    <input type="number" class="form-control" id="cantidad_paquetes" name="cantidad_paquetes" 
                                           min="1" max="" required placeholder="Ingrese la cantidad de paquetes">
                                    <small class="form-text text-muted">
                                        <i class="fas fa-info-circle"></i> Ingrese la cantidad de paquetes a transportar (máximo: <span id="maxPaquetes">-</span> paquetes)
                                    </small>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="conductor" class="form-label">Conductor Asignado</label>
                                        <select class="form-select" id="conductor" name="conductor_id" required>
                                            <option value="" selected disabled>Seleccione un conductor...</option>
                                            <% ArrayList<ConductorBean> listaConductores = (ArrayList<ConductorBean>) request.getAttribute("listaConductores");
                                                if (listaConductores != null) {
                                                    for (ConductorBean conductor : listaConductores) { %>
                                            <option value="<%= conductor.getId() %>"><%= conductor.getNombreCompleto() %></option>
                                            <%     }
                                            } %>
                                        </select>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="vehiculo" class="form-label">Vehículo Asignado</label>
                                        <select class="form-select" id="vehiculo" name="vehiculo_id" required>
                                            <option value="" selected disabled>Seleccione un vehículo...</option>
                                            <% ArrayList<VehiculoBean> listaVehiculos = (ArrayList<VehiculoBean>) request.getAttribute("listaVehiculos");
                                                if (listaVehiculos != null) {
                                                    for (VehiculoBean vehiculo : listaVehiculos) { %>
                                            <option value="<%= vehiculo.getId() %>"><%= vehiculo.getPlaca() %></option>
                                            <%     }
                                            } %>
                                        </select>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="fechaEntrega" class="form-label">Fecha de Entrega Programada</label>
                                        <input type="date" class="form-control" id="fechaEntrega" name="fecha_entrega" required>
                                    </div>

                                    <div class="col-md-6 mb-3">
                                        <label for="destino" class="form-label">Destino (Distrito)</label>
                                        <select class="form-select" id="destino" name="distrito_id" required>
                                            <option value="" selected disabled>Seleccione un destino...</option>
                                            <% ArrayList<DistritoBean> listaDistritos = (ArrayList<DistritoBean>) request.getAttribute("listaDistritos");
                                                if (listaDistritos != null) {
                                                    for (DistritoBean distrito : listaDistritos) { %>
                                            <option value="<%= distrito.getId() %>"><%= distrito.getNombre() %></option>
                                            <%     }
                                            } %>
                                        </select>
                                    </div>
                                </div>

                                <hr>
                                <div class="d-flex justify-content-end">
                                    <a href="${pageContext.request.contextPath}/planes-transporte" class="btn btn-secondary me-2">Cancelar</a>
                                    <button type="submit" class="btn btn-custom-dark">Guardar Plan</button>
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
    function actualizarInfoLote() {
        const select = document.getElementById('lote');
        const option = select.options[select.selectedIndex];
        const cantidadInput = document.getElementById('cantidad_paquetes');
        const maxPaquetesSpan = document.getElementById('maxPaquetes');
        const infoLote = document.getElementById('infoLote');
        
        if (option.value) {
            const paquetesDisponibles = parseInt(option.getAttribute('data-paquetes')) || 0;
            const stockActual = parseInt(option.getAttribute('data-stock')) || 0;
            const unidadesPorPaquete = parseInt(option.getAttribute('data-unidades-paquete')) || 1;
            
            cantidadInput.max = paquetesDisponibles;
            maxPaquetesSpan.textContent = paquetesDisponibles;
            cantidadInput.placeholder = 'Máximo ' + paquetesDisponibles + ' paquetes';
            infoLote.innerHTML = '<i class="fas fa-info-circle"></i> Stock disponible: ' + stockActual + ' unidades (' + paquetesDisponibles + ' paquetes)';
        } else {
            cantidadInput.max = '';
            maxPaquetesSpan.textContent = '-';
            cantidadInput.placeholder = 'Ingrese la cantidad de paquetes';
            infoLote.innerHTML = '<i class="fas fa-info-circle"></i> Selecciona un lote para ver la información disponible';
        }
    }
</script>
</body>
</html>