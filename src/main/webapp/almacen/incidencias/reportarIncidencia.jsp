<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    com.example.telito.almacen.beans.Lote lote = (com.example.telito.almacen.beans.Lote) request.getAttribute("lote");
    if (lote == null) {
        response.sendRedirect(request.getContextPath() + "/almacen/LoteServlet");
        return;
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Reportar Incidencia"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/almacen/layouts/header_almacen.jsp"/>
    <jsp:include page="/almacen/layouts/sidebar_almacen.jsp">
        <jsp:param name="activeMenu" value="Incidencias"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header mb-4">
                            <h2><i class="fas fa-exclamation-triangle me-2"></i>Reportar Incidencia</h2>
                            <p class="text-muted">Reporta faltantes o sobrantes de inventario detectados durante el conteo físico.</p>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-lg-5">
                        <div class="card shadow-sm">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0">Datos del Producto</h5>
                            </div>
                            <div class="card-body">
                                <p><strong>Producto:</strong> <%= lote.getNombreProducto() %></p>
                                <p><strong>Código Lote:</strong> <code><%= lote.getCodigoLote() %></code></p>
                                <p><strong>Cantidad en Sistema:</strong> 
                                    <span class="badge bg-primary fs-5"><%= lote.getStockActual() %></span>
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-7">
                        <div class="card shadow-sm">
                            <div class="card-header bg-warning text-dark">
                                <h5 class="mb-0">Formulario de Incidencia</h5>
                            </div>
                            <div class="card-body">
                                <form method="POST" action="<%= request.getContextPath() %>/almacen/IncidenciaServlet?action=reportar">
                                    <input type="hidden" name="loteId" value="<%= lote.getIdLote() %>">
                                    
                                    <div class="mb-3">
                                        <label for="cantidadReportada" class="form-label">Cantidad Real Contada:</label>
                                        <input type="number" class="form-control" id="cantidadReportada" 
                                               name="cantidadReportada" min="0" required>
                                        <small class="text-muted">Ingrese la cantidad física contada en el almacén</small>
                                    </div>

                                    <div class="mb-3">
                                        <label for="diferencia" class="form-label">Diferencia:</label>
                                        <input type="text" class="form-control" id="diferencia" readonly 
                                               style="font-weight: bold; font-size: 1.1rem;">
                                    </div>

                                    <div class="mb-3">
                                        <label for="tipoIncidencia" class="form-label">Tipo de Incidencia:</label>
                                        <select class="form-select" id="tipoIncidencia" name="tipoIncidencia" required>
                                            <option value="">Seleccione...</option>
                                            <option value="Faltante">Faltante</option>
                                            <option value="Sobrante">Sobrante</option>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label for="motivo" class="form-label">Motivo:</label>
                                        <select class="form-select" id="motivo" name="motivo" required>
                                            <option value="">Seleccione un motivo...</option>
                                            <option value="Error de Conteo Cíclico">Error de Conteo Cíclico</option>
                                            <option value="Producto Dañado">Producto Dañado</option>
                                            <option value="Merma / Vencimiento">Merma / Vencimiento</option>
                                            <option value="Sobrante no justificado">Sobrante no justificado</option>
                                            <option value="Error en Ingreso Anterior">Error en Ingreso Anterior</option>
                                            <option value="Pérdida por Robo">Pérdida por Robo</option>
                                            <option value="Otro">Otro</option>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label for="descripcion" class="form-label">Descripción (Opcional):</label>
                                        <textarea class="form-control" id="descripcion" name="descripcion" 
                                                  rows="3" placeholder="Proporcione detalles adicionales sobre la incidencia..."></textarea>
                                    </div>

                                    <div class="d-flex justify-content-end gap-2 mt-4">
                                        <a href="<%= request.getContextPath() %>/almacen/LoteServlet" class="btn btn-secondary">
                                            <i class="fas fa-times me-2"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-warning">
                                            <i class="fas fa-exclamation-triangle me-2"></i>Reportar Incidencia
                                        </button>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const cantidadReportadaInput = document.getElementById('cantidadReportada');
        const diferenciaInput = document.getElementById('diferencia');
        const tipoIncidenciaSelect = document.getElementById('tipoIncidencia');
        const stockSistema = <%= lote.getStockActual() %>;
        
        cantidadReportadaInput.addEventListener('input', function() {
            const cantidadReportada = parseInt(this.value, 10);
            if (!isNaN(cantidadReportada)) {
                const diferencia = cantidadReportada - stockSistema;
                diferenciaInput.value = diferencia;
                
                // Actualizar tipo de incidencia automáticamente
                if (diferencia < 0) {
                    diferenciaInput.style.color = 'red';
                    tipoIncidenciaSelect.value = 'Faltante';
                } else if (diferencia > 0) {
                    diferenciaInput.style.color = 'green';
                    tipoIncidenciaSelect.value = 'Sobrante';
                } else {
                    diferenciaInput.style.color = 'black';
                    tipoIncidenciaSelect.value = '';
                }
            } else {
                diferenciaInput.value = '';
            }
        });
    });
</script>
</body>
</html>

