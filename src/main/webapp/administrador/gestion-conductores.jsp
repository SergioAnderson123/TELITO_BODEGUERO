<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Gestión de Conductores"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/header_admin.jsp"/>
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Conductores"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <!-- Encabezado -->
                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2><i class="fas fa-user-tie me-2"></i>Gestión de Conductores</h2>
                            <p class="text-muted">Administra los conductores del sistema de transporte.</p>
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

                <!-- Botón crear conductor -->
                <div class="row mb-3">
                    <div class="col-12">
                        <a href="${pageContext.request.contextPath}/administrador/ConductorServlet?action=crear" class="btn btn-primary">
                            <i class="fas fa-plus me-2"></i>Nuevo Conductor
                        </a>
                    </div>
                </div>

                <!-- Tabla de conductores -->
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Lista de Conductores</h5>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead class="bg-light">
                                        <tr>
                                            <th scope="col">#</th>
                                            <th scope="col">Nombre Completo</th>
                                            <th scope="col">Licencia</th>
                                            <th scope="col" class="text-center">Acciones</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="conductor" items="${listaConductores}">
                                            <tr>
                                                <td>${conductor.idConductor}</td>
                                                <td>${conductor.nombreCompleto}</td>
                                                <td><span class="badge bg-info">${conductor.licencia}</span></td>
                                                <td class="text-center">
                                                    <a href="${pageContext.request.contextPath}/administrador/ConductorServlet?action=editar&id=${conductor.idConductor}" 
                                                       class="btn btn-sm btn-warning" title="Editar">
                                                        <i class="fas fa-edit"></i>
                                                    </a>
                                                    <a href="#" 
                                                       onclick="confirmarEliminacion(${conductor.idConductor}, '${conductor.nombreCompleto}')" 
                                                       class="btn btn-sm btn-danger" title="Eliminar">
                                                        <i class="fas fa-trash"></i>
                                                    </a>
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
            <jsp:include page="/administrador/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    function confirmarEliminacion(id, nombre) {
        if (confirm('¿Estás seguro de eliminar al conductor "' + nombre + '"? Esta acción no se puede deshacer.')) {
            window.location.href = '${pageContext.request.contextPath}/administrador/ConductorServlet?action=eliminar&id=' + id;
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

