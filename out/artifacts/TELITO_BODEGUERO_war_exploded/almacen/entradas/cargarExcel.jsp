<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/almacen/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Cargar Entradas desde Excel"/>
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
                            <h2><i class="fas fa-file-excel me-2"></i>Cargar Entradas desde Excel</h2>
                            <p class="text-muted">Valida y carga múltiples entradas de inventario desde un archivo Excel.</p>
                        </div>
                    </div>
                </div>
                
                <!-- Mensajes de error -->
                <%
                    java.util.ArrayList<String> errores = (java.util.ArrayList<String>) request.getAttribute("errores");
                    if (errores != null && !errores.isEmpty()) {
                %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <h5 class="alert-heading">
                        <i class="fas fa-exclamation-triangle me-2"></i>Errores encontrados:
                    </h5>
                    <ul class="mb-0">
                        <% for (String error : errores) { %>
                            <li><%= error %></li>
                        <% } %>
                    </ul>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% } %>
                
                <!-- Mensaje de éxito -->
                <%
                    String successMsg = (String) session.getAttribute("successMsg");
                    if (successMsg != null) {
                        session.removeAttribute("successMsg");
                %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% } %>
                
                <div class="row mt-4">
                    <div class="col-lg-12">
                        <div class="card">
                            <div class="card-body">
                                <h3 class="mb-4" style="border-bottom: 1px solid #dee2e6; padding-bottom: 0.75rem;">Instrucciones</h3>
                                
                                <ol style="list-style-type: none; padding-left: 0;">
                                    <li class="mb-3">
                                        <strong>1) Descarga la plantilla oficial</strong> para asegurar el formato correcto
                                        <div class="mt-2">
                                            <a href="${pageContext.request.contextPath}/almacen/ExcelValidacionServlet?action=descargarPlantilla" 
                                               class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-download me-2"></i>Descargar plantilla Excel
                                            </a>
                                        </div>
                                    </li>
                                    <li class="mb-2"><strong>2) Rellena los datos</strong> en la plantilla descargada</li>
                                    <li class="mb-4"><strong>3) Sube el archivo</strong> para su validación</li>
                                </ol>
                                
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    <strong>Formato requerido:</strong> El archivo debe tener las siguientes columnas en orden:
                                    <ul class="mb-0 mt-2">
                                        <li>Código Lote</li>
                                        <li>Código SKU Producto</li>
                                        <li>Cantidad</li>
                                        <li>Fecha Vencimiento (formato: dd/MM/yyyy)</li>
                                        <li>Ubicación</li>
                                        <li>Orden Compra (opcional)</li>
                                    </ul>
                                </div>

                                <form method="POST" action="${pageContext.request.contextPath}/almacen/ExcelValidacionServlet?action=validar" 
                                      enctype="multipart/form-data" id="formCargaExcel">
                                    
                                    <div class="mb-4">
                                        <label for="archivoExcel" class="form-label">
                                            <i class="fas fa-file-excel me-2"></i>Seleccionar archivo Excel
                                        </label>
                                        <input type="file" 
                                               class="form-control" 
                                               id="archivoExcel" 
                                               name="archivoExcel" 
                                               accept=".xlsx,.xls"
                                               required>
                                        <small class="text-muted">Formatos aceptados: .xlsx, .xls (máximo 10 MB)</small>
                                    </div>
                                    
                                    <div class="d-flex justify-content-end gap-2 mt-4">
                                        <a href="${pageContext.request.contextPath}/almacen/EntradaServlet" 
                                           class="btn btn-secondary">
                                            <i class="fas fa-times me-2"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-primary" id="btnValidar">
                                            <i class="fas fa-check-circle me-2"></i>Validar Archivo
                                        </button>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const form = document.getElementById('formCargaExcel');
        const btnValidar = document.getElementById('btnValidar');
        const fileInput = document.getElementById('archivoExcel');
        
        form.addEventListener('submit', function(e) {
            if (fileInput.files.length === 0) {
                e.preventDefault();
                alert('Por favor, seleccione un archivo Excel');
                return false;
            }
            
            // Mostrar indicador de carga
            btnValidar.disabled = true;
            btnValidar.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Validando...';
        });
        
        // Validar tamaño de archivo
        fileInput.addEventListener('change', function() {
            const file = this.files[0];
            if (file) {
                const maxSize = 10 * 1024 * 1024; // 10 MB
                if (file.size > maxSize) {
                    alert('El archivo es demasiado grande. El tamaño máximo es 10 MB');
                    this.value = '';
                }
            }
        });
    });
</script>
</body>
</html>

