<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Pedidos Pendientes"/>
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
                            <h2 class="pageheader-title fs-1">Pedidos pendientes de despacho</h2>
                        </div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <h5 class="card-header">Tabla de pedidos</h5>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">Numero de Pedido</th>
                                            <th scope="col">Destino</th>
                                            <th scope="col">Estado de preparación</th>
                                            <th scope="col">Preparar pedido</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="pedido" items="${listaPedidos}">
                                            <tr>
                                                <td>${pedido.numeroPedido}</td>
                                                <td>${pedido.destino}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                            <span class="badge bg-danger">Pendiente</span>
                                                        </c:when>
                                                        <c:when test="${pedido.estadoPreparacion == 'En preparación'}">
                                                            <span class="badge bg-warning text-dark">En preparación</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-success">Despachado</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:if test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                        <a href="PedidoServlet?action=preparar&id=${pedido.idPedido}" class="btn btn-primary btn-sm">Preparar</a>
                                                    </c:if>
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
            </div>
            <jsp:include page="/layouts/footer.jsp"/>
        </div>
    </div>
    <%-- Tus scripts JS --%>
</body>
</html>