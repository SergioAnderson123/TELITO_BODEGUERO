<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Enviar Reporte por Correo"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Historial"/>
    </jsp:include>
    <jsp:include page="/almacen/layouts/header_almacen.jsp" />

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    ${sessionScope.errorMsg}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>

            <div class="page-header mb-4">
                <h2><i class="fas fa-envelope me-2"></i>Enviar Reporte de Movimientos por Correo</h2>
                <p class="text-muted">Genera y envía un reporte Excel de los movimientos de inventario del almacén por correo electrónico.</p>
            </div>

            <div class="row">
                <div class="col-xl-8 col-lg-10 col-md-12 mx-auto">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-file-excel me-2"></i>Formulario de Envío</h5>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info mb-4">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Información del reporte:</strong> Se generará un reporte Excel que incluye:
                                <ul class="mb-0 mt-2">
                                    <li>Fecha</li>
                                    <li>Producto</li>
                                    <li>Tipo de Movimiento (Entrada/Salida/Ajuste)</li>
                                    <li>Cantidad</li>
                                    <li>Lote</li>
                                    <li>Destino/Origen</li>
                                    <li>Personal Responsable</li>
                                    <li>Observaciones</li>
                                    <li><strong>Resumen de Entradas, Salidas y Ajustes</strong></li>
                                </ul>
                            </div>

                            <form action="<%= request.getContextPath() %>/almacen/MovimientoReporteServlet" method="POST">
                                <input type="hidden" name="action" value="enviar">

                                <div class="mb-3">
                                    <label for="email_destino" class="form-label">
                                        <i class="fas fa-envelope me-2"></i>Email de Destino <span class="text-danger">*</span>
                                    </label>
                                    <input type="email" class="form-control" id="email_destino" name="email_destino" required>
                                </div>

                                <div class="mb-3">
                                    <label for="asunto" class="form-label">
                                        <i class="fas fa-tag me-2"></i>Asunto del Correo
                                    </label>
                                    <input type="text" class="form-control" id="asunto" name="asunto" 
                                           value="Reporte de Movimientos - Almacén - TELITO BODEGUERO">
                                </div>

                                <div class="mb-3">
                                    <label for="mensaje" class="form-label">
                                        <i class="fas fa-comment me-2"></i>Mensaje Adicional (Opcional)
                                    </label>
                                    <textarea class="form-control" id="mensaje" name="mensaje" rows="4"></textarea>
                                </div>

                                <div class="d-flex justify-content-between mt-4 pt-3 border-top">
                                    <a href="<%= request.getContextPath() %>/almacen/MovimientoServlet" class="btn btn-secondary">
                                        <i class="fas fa-arrow-left me-2"></i>Cancelar
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane me-2"></i>Enviar Reporte
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="/almacen/layouts/footer.jsp" />
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

