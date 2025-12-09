<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Preparación de Plan de Transporte"/>
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
                            <h2><i class="fas fa-truck-loading me-2"></i>Preparación de Plan de Transporte</h2>
                            <p class="text-muted">Confirma los detalles antes de despachar el lote.</p>
                        </div>
                    </div>
                </div>

                <!-- Detalles del Plan -->
                <div class="card mb-4">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0">Detalles del Plan de Transporte</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <p><strong>Número de Plan:</strong> <span class="badge bg-secondary fs-6">${plan.numeroPlan}</span></p>
                                <p><strong>Conductor:</strong> ${plan.nombreConductor}</p>
                                <p><strong>Vehículo:</strong> <span class="badge bg-primary">${plan.placaVehiculo}</span></p>
                            </div>
                            <div class="col-md-6">
                                <p><strong>Destino:</strong> ${plan.nombreDestino}</p>
                                <p><strong>Fecha de Entrega:</strong> ${plan.fechaEntrega}</p>
                                <p><strong>Estado:</strong> <span class="badge bg-warning text-dark">${plan.estado}</span></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Detalles del Lote -->
                <form method="post" action="${pageContext.request.contextPath}/almacen/PedidoServlet">
                    <input type="hidden" name="action" value="prepararPlanTransporte">
                    <input type="hidden" name="id_plan" value="${plan.idPlan}">

                    <div class="card">
                        <div class="card-header">
                            <h5>Producto y Lote a Despachar</h5>
                        </div>
                        <div class="card-body">
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger">${error}</div>
                            </c:if>

                            <div class="table-responsive">
                                <table class="table table-bordered">
                                    <thead class="bg-light">
                                    <tr>
                                        <th>Producto</th>
                                        <th>Código de Lote</th>
                                        <th class="text-center">Paquetes Disponibles</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <tr>
                                        <td><strong>${plan.nombreProducto}</strong></td>
                                        <td><span class="badge bg-secondary fs-6">${plan.codigoLote}</span></td>
                                        <td class="text-center">
                                            <span class="badge bg-success fs-5">${plan.paquetesDisponibles} paquetes</span>
                                        </td>
                                    </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="alert alert-info mt-3">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Nota:</strong> Se despachará todo el stock disponible del lote (${plan.paquetesDisponibles} paquetes).
                            </div>
                        </div>

                        <div class="card-footer text-end">
                            <a href="${pageContext.request.contextPath}/almacen/PedidoServlet" class="btn btn-outline-secondary">
                                <i class="fas fa-arrow-left me-2"></i>Volver a la lista
                            </a>
                            <button type="submit" class="btn btn-success">
                                <i class="fas fa-check me-2"></i>Finalizar Preparación
                            </button>
                        </div>
                    </div>
                </form>

            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>

