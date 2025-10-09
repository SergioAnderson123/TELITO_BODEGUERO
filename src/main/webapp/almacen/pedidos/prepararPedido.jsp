<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Preparación de Pedido"/>
    </jsp:include>
</head>

<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/layouts/header_almacen.jsp"/>
    <jsp:include page="/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Registrar salidas"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2 class="pageheader-title fs-1">Preparación de Pedido</h2>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header"><h5>Detalles del Pedido</h5></div>
                    <div class="card-body">
                        <table class="table table-bordered mb-0">
                            <thead class="bg-light">
                            <tr>
                                <th>Número de pedido</th>
                                <th>Destino</th>
                                <th>Cliente</th>
                            </tr>
                            </thead>
                            <tbody>
                            <tr>
                                <td>${pedido.numeroPedido}</td>
                                <td>${pedido.destino}</td>
                                <td>${pedido.cliente.nombre}</td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/PedidoServlet">

                    <input type="hidden" name="id_pedido" value="${pedido.idPedido}">

                    <div class="row mt-4">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">Lista de productos del pedido ${pedido.numeroPedido}</h5>
                                </div>
                                <div class="card-body">
                                    <c:if test="${not empty error}">
                                        <div class="alert alert-danger">${error}</div>
                                    </c:if>
                                    <div class="table-responsive">
                                        <table class="table">
                                            <thead class="bg-light">
                                            <tr>
                                                <th>Código de producto</th>
                                                <th>Producto</th>
                                                <th>Ubicación (Seleccionar Lote)</th>
                                                <th class="text-center">Cantidad requerida</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <%-- Bucle principal para cada producto del pedido --%>
                                            <c:forEach var="item" items="${pedido.items}">
                                                <tr>
                                                    <td>${item.codigoProducto}</td>
                                                    <td>${item.nombreProducto}</td>
                                                    <td>
                                                            <%-- Bucle anidado para mostrar los lotes como opciones --%>
                                                        <c:forEach var="lote" items="${item.lotesDisponibles}" varStatus="loopStatus">
                                                            <div class="form-check">
                                                                <input class="form-check-input" type="radio"
                                                                       name="lote_seleccionado_${item.productoId}"
                                                                       id="lote_${lote.idLote}"
                                                                       value="${lote.idLote}" ${loopStatus.first ? 'checked' : ''}>
                                                                <label class="form-check-label" for="lote_${lote.idLote}">
                                                                        ${lote.nombreUbicacion} (Stock: ${lote.stockActual})
                                                                </label>
                                                            </div>
                                                        </c:forEach>
                                                    </td>
                                                    <td class="text-center">${item.cantidadRequerida}</td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                <div class="card-footer text-end">
                                    <a href="${pageContext.request.contextPath}/PedidoServlet" class="btn btn-outline-secondary">Volver a la lista</a>
                                    <button type="submit" class="btn btn-primary">Finalizar preparación</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <jsp:include page="/layouts/footer.jsp"/>
        </div>
    </div>
</body>
</html>