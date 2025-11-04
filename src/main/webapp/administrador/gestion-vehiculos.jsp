<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Vehículos"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/header_admin.jsp"/>
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Vehiculos"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <!-- Encabezado -->
                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2><i class="fas fa-truck me-2"></i>Gestión de Vehículos</h2>
                            <p class="text-muted">Administra los vehículos del sistema de transporte.</p>
                        </div>
                    </div>
                </div>

                <!-- Mensajes de alerta -->
                <c:if test="${not empty sessionScope.mensaje}">
                    <div class="alert alert-${sessionScope.tipoMensaje} alert-dismissible fade show" role="alert">
                        ${sessionScope.mensaje}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <c:remove var="mensaje" scope="session"/>
                    <c:remove var="tipoMensaje" scope="session"/>
                </c:if>

                <!-- Botón crear vehículo y tamaño de página -->
                <div class="row mb-3">
                    <div class="col-6">
                        <a href="${pageContext.request.contextPath}/administrador/VehiculoServlet?action=crear" class="btn btn-primary">
                            <i class="fas fa-plus me-2"></i>Nuevo Vehículo
                        </a>
                    </div>
                    <div class="col-6 d-flex justify-content-end align-items-center">
                        <form method="get" action="${pageContext.request.contextPath}/administrador/VehiculoServlet">
                            <input type="hidden" name="action" value="listar">
                            <input type="hidden" name="page" value="1">
                            <label class="me-2 text-muted small">Mostrar</label>
                            <select name="size" class="form-select form-select-sm" onchange="this.form.submit()">
                                <option value="10" ${size == 10 ? 'selected' : ''}>10</option>
                                <option value="25" ${size == 25 ? 'selected' : ''}>25</option>
                                <option value="50" ${size == 50 ? 'selected' : ''}>50</option>
                            </select>
                        </form>
                    </div>
                </div>

                <!-- Tabla de vehículos -->
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Tabla de Vehículos</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">#</th>
                                            <th scope="col">Placa</th>
                                            <th scope="col">Marca</th>
                                            <th scope="col">Modelo</th>
                                            <th scope="col">Capacidad (Kg)</th>
                                            <th scope="col" class="text-center">Acciones</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <%
                                            Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                            Integer sizeObj = (Integer) request.getAttribute("size");
                                            int currentPageInt = (currentPageObj != null) ? currentPageObj : 1;
                                            int sizeInt = (sizeObj != null) ? sizeObj : 10;
                                            int contador = (currentPageInt - 1) * sizeInt + 1;
                                        %>
                                        <c:forEach var="vehiculo" items="${listaVehiculos}">
                                            <tr>
                                                <td><%= contador++ %></td>
                                                <td><span class="badge bg-primary">${vehiculo.placa}</span></td>
                                                <td>${vehiculo.marca}</td>
                                                <td>${vehiculo.modelo}</td>
                                                <td>${vehiculo.capacidadKg} kg</td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/administrador/VehiculoServlet?action=editar&id=${vehiculo.idVehiculo}" 
                                                       class="btn btn-sm btn-warning" title="Editar">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="#" 
                                                       data-placa="${vehiculo.placa}"
                                                       onclick="confirmarEliminacion(${vehiculo.idVehiculo}, this.dataset.placa)" 
                                                       class="btn btn-sm btn-danger" title="Eliminar">
                                                        <i class="fas fa-trash"></i>
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                                
                                <%-- Incluir componente de paginación --%>
                                <jsp:include page="/WEB-INF/includes/pagination.jsp" />
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <jsp:include page="/administrador/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    function confirmarEliminacion(id, placa) {
        showConfirm(
            '¿Estás seguro de eliminar el vehículo con placa "' + placa + '"? Esta acción no se puede deshacer.',
            function() {
                window.location.href = '${pageContext.request.contextPath}/administrador/VehiculoServlet?action=eliminar&id=' + id;
            },
            'Confirmar eliminación'
        );
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

