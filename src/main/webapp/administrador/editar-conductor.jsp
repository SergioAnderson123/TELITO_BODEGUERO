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
                        <div class="page-header mb-4">
                            <h2 class="pageheader-title"><i class="fas fa-user-edit me-2"></i>Editar Conductor</h2>
                            <p class="pageheader-text">Modifica los datos del conductor.</p>
                        </div>
                    </div>
                </div>

                <!-- Formulario -->
                <div class="row">
                    <div class="col-xl-8 col-lg-10 col-md-12 col-sm-12 col-12 mx-auto">
                        <div class="card shadow-sm">
                            <div class="card-header bg-gradient-primary text-white mb-4" style="background: linear-gradient(160deg, var(--turquoise-dark) 0%, var(--seafoam) 100%); border-radius: 12px 12px 0 0; margin: -30px -30px 30px -30px; padding: 25px 30px;">
                                <h5 class="mb-0"><i class="fas fa-user-tie me-2"></i>Datos del Conductor</h5>
                                <small class="text-white-50">Modifique los campos que desee actualizar</small>
                            </div>
                            <div class="card-body">
                                <form method="POST" action="${pageContext.request.contextPath}/administrador/ConductorServlet">
                                    <input type="hidden" name="action" value="actualizar">
                                    <input type="hidden" name="id" value="${conductor.idConductor}">

                                    <div class="mb-4">
                                        <label for="nombreCompleto" class="form-label fw-semibold">
                                            <i class="fas fa-user text-primary me-2"></i>Nombre Completo <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control shadow-sm" id="nombreCompleto" name="nombreCompleto" required 
                                               value="${conductor.nombreCompleto}">
                                    </div>

                                    <div class="mb-4">
                                        <label for="licencia" class="form-label fw-semibold">
                                            <i class="fas fa-id-card text-primary me-2"></i>Número de Licencia <span class="text-danger">*</span>
                                        </label>
                                        <input type="text" class="form-control shadow-sm" id="licencia" name="licencia" required 
                                               value="${conductor.licencia}">
                                    </div>

                                    <div class="mt-5 pt-4 border-top d-flex justify-content-between align-items-center">
                                        <a href="${pageContext.request.contextPath}/administrador/ConductorServlet" class="btn btn-outline-secondary shadow-sm">
                                            <i class="fas fa-times me-2"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-primary shadow-sm px-4">
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

