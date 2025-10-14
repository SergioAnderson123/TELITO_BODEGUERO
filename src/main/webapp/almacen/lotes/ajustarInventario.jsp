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
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Gestion de inventario"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header"><h2 class="pageheader-title fs-1">Ajuste de inventario</h2></div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-5">
                        <div class="card">
                            <div class="card-body">
                                <h4 class="card-title">Datos del Producto</h4>
                                <hr>
                                <p><strong>Producto:</strong> <c:out value="${lote.nombreProducto}"/></p>
                                <p><strong>Código (Lote):</strong> <c:out value="${lote.codigoLote}"/></p>
                                <p><strong>Cantidad actual:</strong> <span id="stockActualSpan" class="badge bg-primary fs-5">${lote.stockActual}</span></p>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-7">
                        <div class="card">
                            <div class="card-body">
                                <h4 class="card-title">Formulario de Ajuste</h4>
                                <hr>
                                <form method="POST" action="${pageContext.request.contextPath}/almacen/LoteServlet?action=guardarAjuste">

                                    <input type="hidden" name="idLote" value="${lote.idLote}">
                                    <input type="hidden" id="stockActual" name="stockActual" value="${lote.stockActual}">

                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label for="cantidadContada" class="form-label">Cantidad real contada:</label>
                                            <input type="number" class="form-control" id="cantidadContada" name="cantidadContada" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label for="diferencia" class="form-label">Diferencia:</label>
                                            <input type="text" class="form-control" id="diferencia" readonly style="font-weight: bold;">
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="motivo" class="form-label">Motivo de Ajuste / Incidencia:</label>
                                        <select class="form-select" id="motivo" name="motivo" required>
                                            <option value="" disabled selected>Seleccione un motivo...</option>
                                            <option value="Error de Conteo Cíclico">Error de Conteo Cíclico</option>
                                            <option value="Producto Dañado">Producto Dañado</option>
                                            <option value="Merma / Vencimiento">Merma / Vencimiento</option>
                                            <option value="Sobrante no justificado">Sobrante no justificado</option>
                                            <option value="Error en Ingreso Anterior">Error en Ingreso Anterior</option>
                                            <option value="Otro">Otro</option>
                                        </select>
                                    </div>

                                    <div class="d-flex justify-content-end mt-4">
                                        <a href="${pageContext.request.contextPath}/almacen/LoteServlet" class="btn btn-secondary me-2">Cancelar</a>
                                        <button type="submit" class="btn btn-primary">Confirmar Ajuste</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Script para calcular la diferencia en tiempo real
    document.addEventListener('DOMContentLoaded', function() {
        const cantidadContadaInput = document.getElementById('cantidadContada');
        const diferenciaInput = document.getElementById('diferencia');
        const stockActual = parseInt(document.getElementById('stockActual').value, 10);

        cantidadContadaInput.addEventListener('input', function() {
            const cantidadContada = parseInt(this.value, 10);
            if (!isNaN(cantidadContada)) {
                const diferencia = cantidadContada - stockActual;
                diferenciaInput.value = diferencia;
                if (diferencia > 0) {
                    diferenciaInput.style.color = 'green';
                } else if (diferencia < 0) {
                    diferenciaInput.style.color = 'red';
                } else {
                    diferenciaInput.style.color = 'black';
                }
            } else {
                diferenciaInput.value = '';
            }
        });
    });
</script>
</body>
</html>