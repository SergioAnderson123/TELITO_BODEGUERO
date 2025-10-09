<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Órdenes de Compra Pendientes"/>
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

                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2 class="pageheader-title fs-1">Órdenes de Compra Pendientes de Recepción</h2>
                        </div>
                    </div>
                </div>

                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <h5 class="card-header">Tabla de Órdenes de Compra</h5>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">Producto</th>
                                            <th scope="col">Proveedor</th>
                                            <th scope="col">Cantidad Esperada</th>
                                            <th scope="col">Estado</th>
                                            <th scope="col">Acción</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="orden" items="${listaOrdenes}">
                                            <tr>
                                                <td>${orden.nombreProducto}</td>
                                                <td>${orden.nombreProveedor}</td>
                                                <td>${orden.cantidad}</td>
                                                <td>
                                                        <%-- Lógica para mostrar el badge de estado --%>
                                                    <c:choose>
                                                        <c:when test="${orden.estado == 'Aprobado'}">
                                                            <span class="badge bg-info text-dark">Aprobado</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">${orden.estado}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                        <%-- Botón que lleva al formulario de recepción --%>
                                                    <a class="btn btn-primary btn-sm" href="EntradaServlet?action=recibir&id=${orden.idOrdenCompra}">Registrar Entrada</a>
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
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</body>
</html>