<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Editar Conductor"/>
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
                            <h2><i class="fas fa-user-edit me-2"></i>Editar Conductor</h2>
                            <p class="text-muted">Modifica los datos del conductor.</p>
                        </div>
                    </div>
                </div>

                <!-- Formulario -->
                <div class="row">
                    <div class="col-lg-6 col-md-8 col-sm-12 mx-auto">
                        <div class="card">
                            <div class="card-header">
                                <h5>Datos del Conductor</h5>
                            </div>
                            <div class="card-body">
                                <form method="POST" action="${pageContext.request.contextPath}/administrador/ConductorServlet">
                                    <input type="hidden" name="action" value="actualizar">
                                    <input type="hidden" name="id" value="${conductor.idConductor}">

                                    <div class="mb-3">
                                        <label for="nombreCompleto" class="form-label">Nombre Completo <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="nombreCompleto" name="nombreCompleto" required 
                                               value="${conductor.nombreCompleto}">
                                    </div>

                                    <div class="mb-3">
                                        <label for="licencia" class="form-label">Número de Licencia <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control" id="licencia" name="licencia" required 
                                               value="${conductor.licencia}">
                                    </div>

                                    <hr>
                                    <div class="d-flex justify-content-end">
                                        <a href="${pageContext.request.contextPath}/administrador/ConductorServlet" class="btn btn-secondary me-2">
                                            Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-primary">
                                            <i class="fas fa-save me-2"></i>Actualizar Conductor
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <jsp:include page="/administrador/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

