<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Ajuste de Inventario"/>
    </jsp:include>
</head>

<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp" />
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Gestión de inventario"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">

                <div class="row">
                    <div class="col-12">
                        <div class="page-header">
                            <h2 class="pageheader-title fs-1">Ajuste de inventario</h2>
                        </div>
                    </div>
                </div>

                <form method="post" action="${pageContext.request.contextPath}/almacen/LoteServlet">
                    <%-- CAMBIO: El formulario ahora envuelve ambas tarjetas --%>

                    <%-- CAMBIO CRUCIAL: Campo oculto para enviar el ID del lote --%>
                    <input type="hidden" name="id_lote" value="${loteAjustar.idLote}">

                    <div class="row">
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">Datos del Producto</h5>
                                </div>
                                <div class="card-body">
                                    <ul class="list-group list-group-flush">
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            <strong>Producto:</strong>
                                            <%-- CAMBIO: Dato dinámico --%>
                                            <span>${loteAjustar.nombreProducto}</span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            <strong>Código (Lote):</strong>
                                            <%-- CAMBIO: Dato dinámico --%>
                                            <span>${loteAjustar.codigoLote}</span>
                                        </li>
                                        <li class="list-group-item d-flex justify-content-between align-items-center">
                                            <strong>Cantidad actual:</strong>
                                            <%-- CAMBIO: Dato dinámico --%>
                                            <span class="badge bg-primary rounded-pill fs-6">${loteAjustar.stockActual}</span>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-8">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0">Formulario de Ajuste</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <label for="cantidadReal" class="form-label"><strong>Cantidad real contada:</strong></label>
                                            <%-- CAMBIO: Se añade el atributo 'name' --%>
                                            <input type="number" class="form-control form-control-lg" id="cantidadReal" name="stock_actual" value="${loteAjustar.stockActual}" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="diferencia" class="form-label"><strong>Diferencia:</strong></label>
                                            <input type="text" class="form-control form-control-lg" id="diferencia" readonly>
                                        </div>
                                    </div>

                                    <hr class="my-4">

                                    <div class="mb-3">
                                        <label for="motivoAjuste" class="form-label"><strong>Motivo de Ajuste / Incidencia:</strong></label>
                                        <%-- CAMBIO: Se añade el atributo 'name' --%>
                                        <select class="form-select" id="motivoAjuste" name="motivo_ajuste">
                                            <option selected>Seleccione un motivo...</option>
                                            <option value="conteo_ciclico">Error de Conteo Cíclico</option>
                                            <option value="producto_danado">Producto Dañado</option>
                                            <option value="merma">Merma / Vencimiento</option>
                                            <option value="sobrante">Sobrante no justificado</option>
                                            <option value="error_ingreso">Error en Ingreso Anterior</option>
                                            <option value="otro">Otro</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="card-footer text-end">
                                    <%-- CAMBIO: El botón cancelar ahora apunta al servlet --%>
                                    <a href="${pageContext.request.contextPath}/almacen/LoteServlet" class="btn btn-outline-secondary">Cancelar</a>
                                    <%-- CAMBIO: El botón confirmar ahora es de tipo 'submit' --%>
                                    <button type="submit" class="btn btn-primary">Confirmar ajuste</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        <jsp:include page="/almacen/layouts/footer.jsp" />
    </div>

    <%-- (Opcional) Puedes añadir un script para calcular la diferencia automáticamente --%>
    <script>
        document.getElementById('cantidadReal').addEventListener('input', function() {
            const cantidadActual = ${loteAjustar.stockActual};
            const cantidadReal = this.value;
            document.getElementById('diferencia').value = cantidadReal - cantidadActual;
        });
    </script>
</body>
</html>