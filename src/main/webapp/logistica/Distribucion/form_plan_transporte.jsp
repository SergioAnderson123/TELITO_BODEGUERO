<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.example.telito.logistica.beans.LoteBean" %>
<%@ page import="com.example.telito.logistica.beans.ConductorBean" %>
<%@ page import="com.example.telito.logistica.beans.VehiculoBean" %>
<%@ page import="com.example.telito.logistica.beans.DistritoBean" %>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Generar Plan de Transporte - Sistema de Logística</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/logistica/assets/style.css">
</head>
<body>
<div class="dashboard-main-wrapper">
    <div class="dashboard-header">
        <nav class="navbar navbar-expand-lg bg-white fixed-top dashboard-nav">
            <div class="container-fluid"><a class="navbar-brand concept-brand" href="#"><strong>Concept</strong></a></div>
        </nav>
    </div>
    <div class="nav-left-sidebar sidebar-dark">
        <div class="menu-list">
            <nav class="navbar navbar-expand navbar-light">
                <ul class="navbar-nav flex-column w-100">
                    <li class="nav-divider">Menu</li>
                    <li class="my-2"></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/MovimientoProductoServlet"><i class="fas fa-fw fa-exchange-alt"></i>Movimiento de Productos</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/InventarioServlet"><i class="fas fa-fw fa-warehouse"></i>Gestión de Inventario</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/orden-compra"><i class="fas fa-fw fa-file-invoice-dollar"></i>Orden de Compra</a></li>
                    <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/planes-transporte"><i class="fas fa-fw fa-truck"></i>Distribución y Transporte</a></li>
                </ul>
            </nav>
        </div>
    </div>

    <div class="dashboard-wrapper">
        <div class="container-fluid dashboard-content">
            <div class="row">
                <div class="col-12">
                    <div class="page-header"><h1 class="pageheader-title">Generar Nuevo Plan de Transporte</h1></div>
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
                                    <select class="form-select" id="lote" name="lote_id" required>
                                        <option value="" selected disabled>Seleccione un lote...</option>
                                        <% ArrayList<LoteBean> listaLotes = (ArrayList<LoteBean>) request.getAttribute("listaLotes");
                                            if (listaLotes != null) {
                                                for (LoteBean lote : listaLotes) { %>
                                        <option value="<%= lote.getId() %>"><%= lote.getNombreProducto() %> (<%= lote.getCodigoLote() %>)</option>
                                        <%     }
                                        } %>
                                    </select>
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
    </div>
</div>
</body>
</html>