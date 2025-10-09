<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<html>
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Registrar Entrada"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Registrar entradas"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <h1 class="pageheader-title fs-1">Registrar Entrada de Inventario</h1>
                <hr>
                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">Recepción de Orden de Compra</h5>
                    </div>
                    <div class="card-body">
                        <form method="post" action="EntradaServlet">
                            <input type="hidden" name="id_orden_compra" value="${ordenCompra.idOrdenCompra}">

                            <div class="alert alert-info">
                                <strong>Producto:</strong> ${ordenCompra.nombreProducto} <br>
                                <strong>Proveedor:</strong> ${ordenCompra.nombreProveedor} <br>
                                <strong>Cantidad Esperada:</strong> ${ordenCompra.cantidad}
                            </div>

                            <hr>
                            <h5 class="mb-3">Datos del Nuevo Lote</h5>

                            <div class="mb-3">
                                <label for="codigoLote" class="form-label">Código del Nuevo Lote</label>
                                <input type="text" class="form-control" id="codigoLote" name="codigo_lote" required>
                            </div>
                            <div class="mb-3">
                                <label for="fechaVenc" class="form-label">Fecha de Vencimiento</label>
                                <input type="date" class="form-control" id="fechaVenc" name="fecha_vencimiento">
                            </div>
                            <div class="mb-3">
                                <label for="ubicacion" class="form-label">Ubicación de Destino</label>
                                <select class="form-select" id="ubicacion" name="ubicacion_id" required>
                                    <option value="" selected disabled>-- Elija una ubicación --</option>
                                    <%-- Suponiendo que el servlet envía una lista de ubicaciones --%>
                                    <c:forEach var="ubicacion" items="${listaUbicaciones}">
                                        <option value="${ubicacion.idUbicacion}">${ubicacion.pasillo}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <a href="EntradaServlet" class="btn btn-secondary">Cancelar</a>
                            <button type="submit" class="btn btn-primary">Confirmar Recepción</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>
