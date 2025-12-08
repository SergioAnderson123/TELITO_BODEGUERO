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
                        <div class="page-header">
                            <h2><i class="fas fa-plus-circle me-2"></i>Registrar Entrada de Inventario</h2>
                            <p class="text-muted">Registra la recepción de productos en el almacén según la orden de compra.</p>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-12">
                        <div class="card">
                            <div class="card-header">
                                <h5>Formulario de Recepción</h5>
                            </div>
                            <div class="card-body">
                                <!-- Mensaje de error si existe -->
                                <c:if test="${not empty error}">
                                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                        <i class="fas fa-exclamation-triangle me-2"></i>
                                        <strong>Error:</strong> ${error}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                </c:if>
                                
                                <!-- Lista de errores de validación -->
                                <%
                                    java.util.ArrayList<String> errores = (java.util.ArrayList<String>) request.getAttribute("errores");
                                    if (errores != null && !errores.isEmpty()) {
                                %>
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <h5 class="alert-heading">
                                        <i class="fas fa-exclamation-triangle me-2"></i>Se encontraron los siguientes errores:
                                    </h5>
                                    <ul class="mb-0">
                                        <% for (String errorMsg : errores) { %>
                                            <li><%= errorMsg %></li>
                                        <% } %>
                                    </ul>
                                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                </div>
                                <% } %>
                                
                                <form method="POST" action="${pageContext.request.contextPath}/almacen/EntradaServlet">
                                    <input type="hidden" name="id_orden_compra" value="${ordenCompra.idOrdenCompra}">
                                    <input type="hidden" name="producto_esperado" value="${ordenCompra.nombreProducto}">
                                    <c:if test="${not empty loteAsignado}">
                                        <input type="hidden" name="codigo_lote_esperado" value="${loteAsignado.codigoLote}">
                                        <input type="hidden" name="fecha_vencimiento_esperada" value="${loteAsignado.fechaVencimiento}">
                                    </c:if>
                                    
                                    <div class="mb-4 p-3 rounded" style="background-color: #eef7f6;">
                                        <h5 class="mb-3">
                                            <i class="fas fa-clipboard-check me-2"></i>Recepción de Orden de Compra: ${ordenCompra.numeroOrden}
                                        </h5>
                                        <div class="row">
                                            <div class="col-md-6">
                                                <p class="mb-2"><strong><i class="fas fa-box text-primary me-1"></i>Producto:</strong> <c:out value="${ordenCompra.nombreProducto}"/></p>
                                                <p class="mb-2"><strong><i class="fas fa-user text-success me-1"></i>Proveedor:</strong> <c:out value="${ordenCompra.nombreProveedor}"/></p>
                                                <p class="mb-0"><strong><i class="fas fa-cubes text-info me-1"></i>Cantidad Esperada:</strong> <c:out value="${ordenCompra.cantidad}"/> paquetes</p>
                                            </div>
                                            <c:if test="${not empty loteAsignado}">
                                                <div class="col-md-6 border-start">
                                                    <p class="mb-2 text-success"><strong><i class="fas fa-check-circle me-1"></i>Lote Asignado por el Productor:</strong></p>
                                                    <p class="mb-2"><strong>Código:</strong> <span class="badge bg-success">${loteAsignado.codigoLote}</span></p>
                                                    <p class="mb-0"><strong>Fecha Venc.:</strong> <span class="badge bg-warning text-dark">${loteAsignado.fechaVencimiento}</span></p>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                    <h5 class="mt-4">
                                        <i class="fas fa-check-double me-2 text-warning"></i>Verificación de Producto Recibido Físicamente
                                    </h5>
                                    <p class="text-muted small">
                                        <i class="fas fa-info-circle me-1"></i>
                                        Por favor, escriba los datos del producto físico que está recibiendo para confirmar que coincide con el lote asignado por el productor.
                                    </p>
                                    <hr>
                                    
                                    <div class="row">
                                        <div class="col-md-12 mb-3">
                                            <label for="producto_verificacion" class="form-label">
                                                <i class="fas fa-box me-1"></i>1. Nombre del Producto Recibido
                                                <span class="text-danger">*</span>
                                            </label>
                                            <input type="text" class="form-control" id="producto_verificacion" name="producto_verificacion" 
                                                   placeholder="Escriba el nombre exacto del producto" required>
                                            <small class="text-muted">Debe coincidir con: <strong><c:out value="${ordenCompra.nombreProducto}"/></strong></small>
                                        </div>
                                        
                                        <c:if test="${not empty loteAsignado}">
                                            <div class="col-md-6 mb-3">
                                                <label for="codigo_lote_verificacion" class="form-label">
                                                    <i class="fas fa-barcode me-1"></i>2. Código del Lote Recibido
                                                    <span class="text-danger">*</span>
                                                </label>
                                                <input type="text" class="form-control" id="codigo_lote_verificacion" name="codigo_lote_verificacion" 
                                                       placeholder="Escriba el código del lote" required>
                                                <small class="text-muted">Debe coincidir con: <strong class="text-success">${loteAsignado.codigoLote}</strong></small>
                                            </div>
                                            
                                            <div class="col-md-6 mb-3">
                                                <label for="fecha_vencimiento_verificacion" class="form-label">
                                                    <i class="fas fa-calendar-alt me-1"></i>3. Fecha de Vencimiento del Lote
                                                    <span class="text-danger">*</span>
                                                </label>
                                                <input type="date" class="form-control" id="fecha_vencimiento_verificacion" name="fecha_vencimiento_verificacion" required>
                                                <small class="text-muted">Debe coincidir con: <strong class="text-warning">${loteAsignado.fechaVencimiento}</strong></small>
                                            </div>
                                        </c:if>
                                        
                                        <c:if test="${empty loteAsignado}">
                                            <div class="col-12">
                                                <div class="alert alert-warning">
                                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                                    <strong>Atención:</strong> Esta orden no tiene un lote asignado por el productor. 
                                                    Solo se validará el nombre del producto.
                                                </div>
                                            </div>
                                        </c:if>
                                    </div>
                                    
                                    <h5 class="mt-4">
                                        <i class="fas fa-warehouse me-2"></i>Ubicación en Almacén
                                    </h5>
                                    <hr>
                                    <div class="mb-3">
                                        <label for="ubicacion_id" class="form-label">Ubicación de Destino</label>
                                        <select class="form-select" id="ubicacion_id" name="ubicacion_id" required>
                                            <option value="" disabled selected>-- Elija una ubicación --</option>
                                            <c:forEach var="ubicacion" items="${listaUbicaciones}">
                                                <option value="${ubicacion.idUbicacion}"><c:out value="${ubicacion.nombre}"/></option>
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

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>