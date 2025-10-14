<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Registrar Entrada de Inventario"/>
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
                        <div class="page-header"><h2 class="pageheader-title fs-1">Registrar Entrada de Inventario</h2></div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-body">
                                <form method="POST" action="${pageContext.request.contextPath}/almacen/EntradaServlet">
                                    <input type="hidden" name="id_orden_compra" value="${ordenCompra.idOrdenCompra}">
                                    <div class="mb-4 p-3 rounded" style="background-color: #eef7f6;">
                                        <h5 class="mb-3">Recepción de Orden de Compra: ${ordenCompra.numeroOrden}</h5>
                                        <p class="mb-1"><strong>Producto:</strong> <c:out value="${ordenCompra.nombreProducto}"/></p>
                                        <p class="mb-1"><strong>Proveedor:</strong> <c:out value="${ordenCompra.nombreProveedor}"/></p>
                                        <p class="mb-0"><strong>Cantidad Esperada:</strong> <c:out value="${ordenCompra.cantidad}"/></p>
                                    </div>
                                    <h5 class="mt-4">Datos del Nuevo Lote</h5>
                                    <hr>
                                    <div class="mb-3">
                                        <label for="codigo_lote" class="form-label">Código del Nuevo Lote</label>
                                        <input type="text" class="form-control" id="codigo_lote" name="codigo_lote" required>
                                    </div>
                                    <div class="mb-3">
                                        <label for="fecha_vencimiento" class="form-label">Fecha de Vencimiento</label>
                                        <input type="date" class="form-control" id="fechaVencimientoInput" name="fecha_vencimiento" required>
                                    </div>
                                    <div class="mb-3">
                                        <label for="ubicacion_id" class="form-label">Ubicación de Destino</label>
                                        <select class="form-select" id="ubicacion_id" name="ubicacion_id" required>
                                            <option value="" disabled selected>-- Elija una ubicación --</option>
                                            <c:forEach var="ubicacion" items="${listaUbicaciones}">
                                                <option value="${ubicacion.idUbicacion}"><c:out value="${ubicacion.nombre}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label for="distrito_id" class="form-label">Distrito de Destino</label>
                                        <select class="form-select" id="distrito_id" name="distrito_id" required>
                                            <option value="" disabled selected>-- Elija un distrito --</option>
                                            <c:forEach var="distrito" items="${listaDistritos}">
                                                <option value="${distrito.idDistrito}"><c:out value="${distrito.nombre}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="d-flex justify-content-end mt-4">
                                        <a href="${pageContext.request.contextPath}/almacen/EntradaServlet" class="btn btn-secondary me-2">Cancelar</a>
                                        <button type="submit" class="btn btn-primary">Confirmar Recepción</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/almacen/layouts/footer.jsp"/>
        </div>
    </div>
</div>

<script>
    // Este script se ejecutará tan pronto como la estructura de la página esté lista.
    document.addEventListener('DOMContentLoaded', function() {
        // MENSAJE 1: Esto nos confirmará que el script se está ejecutando.
        console.log("-> Script de restricción de fecha INICIADO.");

        const fechaInput = document.getElementById('fechaVencimientoInput');

        // MENSAJE 2: Esto nos dirá si encontró el campo de la fecha o no.
        console.log("-> Buscando el campo de fecha. Encontrado:", fechaInput);

        if (fechaInput) {
            const hoy = new Date();
            const anio = hoy.getFullYear();
            const mes = String(hoy.getMonth() + 1).padStart(2, '0');
            const dia = String(hoy.getDate()).padStart(2, '0');
            const fechaMinima = `${anio}-${mes}-${dia}`;

            fechaInput.setAttribute('min', fechaMinima);

            // MENSAJE 3: Esto confirmará que la restricción se aplicó.
            console.log("-> ¡ÉXITO! Atributo 'min' establecido en:", fechaMinima);
        } else {
            // MENSAJE 4: Si no lo encuentra, veremos este error.
            console.error("-> ¡ERROR! No se pudo encontrar el elemento con id='fechaVencimientoInput'. Revisa el HTML.");
        }
    });
</script>

</body>
</html>