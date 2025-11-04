<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Pedidos Pendientes"/>
    </jsp:include>
</head>

<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Registrar salidas"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2><i class="fas fa-truck-loading me-2"></i>Registro de Salidas</h2>
                            <p class="text-muted">Gestiona pedidos y planes de transporte pendientes de preparación.</p>
                        </div>
                    </div>
                </div>

                <!-- TABLA DE PEDIDOS -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Pedidos Pendientes</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">N° Pedido</th>
                                            <th scope="col">Cliente</th>
                                            <th scope="col">Destino</th>
                                            <th scope="col">Estado</th>
                                            <th scope="col">Acciones</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:choose>
                                            <c:when test="${not empty listaPedidos}">
                                                <c:forEach var="pedido" items="${listaPedidos}">
                                                    <tr>
                                                        <td><span class="badge bg-primary">${pedido.numeroPedido}</span></td>
                                                        <td>${pedido.cliente != null ? pedido.cliente.nombre : 'N/A'}</td>
                                                        <td>${pedido.destino}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                                    <span class="badge bg-warning">Pendiente</span>
                                                                </c:when>
                                                                <c:when test="${pedido.estadoPreparacion == 'Despachado'}">
                                                                    <span class="badge bg-success">Despachado</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary">${pedido.estadoPreparacion}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:if test="${pedido.estadoPreparacion == 'Pendiente'}">
                                                                <a href="PedidoServlet?action=preparar&id=${pedido.idPedido}" class="btn btn-primary btn-sm">
                                                                    <i class="fas fa-box-open me-1"></i>Preparar
                                                                </a>
                                                            </c:if>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="5" class="text-center text-muted">
                                                        <i class="fas fa-inbox fa-2x mb-2"></i><br>
                                                        No hay pedidos pendientes.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <%-- Incluir componente de paginación --%>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TABLA DE PLANES DE TRANSPORTE -->
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Planes de Transporte</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">N° Plan</th>
                                            <th scope="col">Producto</th>
                                            <th scope="col">Lote</th>
                                            <th scope="col">Paquetes</th>
                                            <th scope="col">Conductor</th>
                                            <th scope="col">Destino</th>
                                            <th scope="col">Fecha Entrega</th>
                                            <th scope="col">Estado</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:choose>
                                            <c:when test="${not empty listaPlanes}">
                                                <c:forEach var="plan" items="${listaPlanes}">
                                                    <tr>
                                                        <td><span class="badge bg-secondary">${plan.numeroPlan}</span></td>
                                                        <td>${plan.nombreProducto}</td>
                                                        <td><strong>${plan.codigoLote}</strong></td>
                                                        <td>${plan.paquetesDisponibles} paquetes</td>
                                                        <td>${plan.nombreConductor}</td>
                                                        <td>${plan.nombreDestino}</td>
                                                        <td>${plan.fechaEntrega}</td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${plan.estado == 'Pendiente'}">
                                                                    <a href="PedidoServlet?action=prepararPlan&id=${plan.idPlan}" class="btn btn-info btn-sm text-white">
                                                                        <i class="fas fa-box-open me-1"></i>Preparar
                                                                    </a>
                                                                </c:when>
                                                                <c:when test="${plan.estado == 'Salida'}">
                                                                    <span class="badge bg-success fs-6">
                                                                        <i class="fas fa-check-circle me-1"></i>Despachado
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary">${plan.estado}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="8" class="text-center text-muted">
                                                        <i class="fas fa-inbox fa-2x mb-2"></i><br>
                                                        No hay planes de transporte.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
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
</div>


<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>