<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.example.webbapplogistica.model.beans.*" %>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Generar Plan de Transporte - Sistema de Logística</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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

<style>
    body{background-color:#efeff6;}.dashboard-main-wrapper{display:flex;min-height:100vh;}.nav-left-sidebar{width:260px;position:fixed;top:60px;left:0;z-index:1000;background-color:#0e0c28 !important;height:calc(100vh - 60px);box-shadow:0 0 28px 0 rgba(82,63,105,0.08);}.dashboard-wrapper{margin-left:260px;width:calc(100% - 260px);min-height:100vh;}.dashboard-header{position:fixed;top:0;left:260px;right:0;z-index:999;height:60px;}.dashboard-content{padding-top:80px;min-height:calc(100vh - 60px);padding-left:20px;padding-right:20px;}.menu-list{height:100%;overflow-y:auto;padding-top:20px;}.nav-left-sidebar .navbar{padding:0;}.nav-left-sidebar .navbar-nav{width:100%;}.nav-left-sidebar .nav-link{padding:12px 30px !important;color:#8287a0 !important;font-size:0.875rem;display:flex;align-items:center;border-left:3px solid transparent;}.nav-left-sidebar .nav-link i{width:20px;margin-right:10px;font-size:1rem;}.nav-left-sidebar .nav-link:hover,.nav-left-sidebar .nav-link.active{background-color:rgba(255,255,255,0.08) !important;color:#ffffff !important;border-left-color:#007bff;}.nav-divider{padding:20px 30px 10px;color:rgba(255,255,255,0.5) !important;font-size:0.75rem;text-transform:uppercase;}.dashboard-nav{box-shadow:0 1px 3px rgba(0,0,0,0.1);border-bottom:1px solid #e5e5e5;background-color:#ffffff !important;height:60px;}.navbar-brand{font-weight:700;font-size:1.2rem;color:#2c3e50 !important;}.concept-brand{position:absolute;left:20px;top:50%;transform:translateY(-50%);z-index:1001;}.page-header{margin-bottom:30px;}.pageheader-title{font-size:24px;font-weight:700;color:#3d405c;}.card{border:none;box-shadow:0 2px 10px rgba(0,0,0,0.1);border-radius:10px;}
    .btn-custom-dark { background-color: #0e0c28; border-color: #0e0c28; color: #ffffff; }
    .btn-custom-dark:hover { background-color: #1a183c; border-color: #1a183c; color: #ffffff; }
</style>
</body>
</html>