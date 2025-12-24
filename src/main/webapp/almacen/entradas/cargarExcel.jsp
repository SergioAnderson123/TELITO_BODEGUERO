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
        <jsp:param name="activeMenu" value="Cargar Excel"/>
    </jsp:include>

    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-12">
                        <div class="page-header mb-3" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                            <h2 style="font-size: 1.4rem; line-height: 1.2; margin-bottom: 0.2rem;">
                                <i class="fas fa-file-excel me-2"></i>Cargar Entradas desde Excel
                            </h2>
                            <p class="text-muted mb-0" style="font-size: 0.85rem;">Valida y carga múltiples entradas de inventario desde un archivo Excel.</p>
                        </div>
                    </div>
                </div>
                
                <!-- Mensajes de error -->
                <%
                    java.util.ArrayList<String> errores = (java.util.ArrayList<String>) request.getAttribute("errores");
                    if (errores != null && !errores.isEmpty()) {
                %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert" style="padding: 0.65rem 0.85rem; margin-bottom: 0.75rem; font-size: 0.85rem;">
                    <h6 class="alert-heading mb-2" style="font-size: 0.9rem;">
                        <i class="fas fa-exclamation-triangle me-2"></i>Errores encontrados:
                    </h6>
                    <ul class="mb-0" style="padding-left: 1.25rem; font-size: 0.8rem;">
                        <% for (String error : errores) { %>
                            <li><%= error %></li>
                        <% } %>
                    </ul>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                </div>
                <% } %>
                
                <!-- Mensaje de éxito -->
                <%
                    String successMsg = (String) session.getAttribute("successMsg");
                    if (successMsg != null) {
                        session.removeAttribute("successMsg");
                %>
                <div class="alert alert-success alert-dismissible fade show" role="alert" style="padding: 0.65rem 0.85rem; margin-bottom: 0.75rem; font-size: 0.85rem;">
                    <i class="fas fa-check-circle me-2"></i><%= successMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="font-size: 0.7rem;"></button>
                </div>
                <% } %>
                
                <div class="row mt-3">
                    <div class="col-lg-12">
                        <div class="card shadow-sm" style="border-radius: 10px;">
                            <div class="card-body" style="padding: 2rem;">
                                <h3 class="mb-4" style="border-bottom: 2px solid #6F4E37; padding-bottom: 0.75rem; font-size: 1.5rem; color: #6F4E37;">
                                    <i class="fas fa-list-ol me-2"></i>Instrucciones
                                </h3>
                                
                                <div class="row g-3 mb-4">
                                    <div class="col-md-4">
                                        <div class="d-flex align-items-start gap-3" style="padding: 1rem; background-color: #f8f9fa; border-radius: 8px;">
                                            <div style="background-color: #6F4E37; color: white; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 1.1rem; flex-shrink: 0;">1</div>
                                            <div>
                                                <strong style="font-size: 1rem; display: block; margin-bottom: 0.5rem;">Descarga la plantilla oficial</strong>
                                                <a href="${pageContext.request.contextPath}/almacen/ExcelValidacionServlet?action=descargarPlantilla" 
                                                   class="btn btn-sm btn-outline-primary" style="font-size: 0.9rem; padding: 0.4rem 0.8rem;">
                                                    <i class="fas fa-download me-1"></i>Descargar
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="d-flex align-items-start gap-3" style="padding: 1rem; background-color: #f8f9fa; border-radius: 8px; height: 100%;">
                                            <div style="background-color: #6F4E37; color: white; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 1.1rem; flex-shrink: 0;">2</div>
                                            <div>
                                                <strong style="font-size: 1rem; display: block; margin-bottom: 0.5rem;">Rellena los datos</strong>
                                                <small style="font-size: 0.9rem; color: #6c757d;">Completa la información en la plantilla descargada</small>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="d-flex align-items-start gap-3" style="padding: 1rem; background-color: #f8f9fa; border-radius: 8px; height: 100%;">
                                            <div style="background-color: #6F4E37; color: white; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 1.1rem; flex-shrink: 0;">3</div>
                                            <div>
                                                <strong style="font-size: 1rem; display: block; margin-bottom: 0.5rem;">Sube el archivo</strong>
                                                <small style="font-size: 0.9rem; color: #6c757d;">Carga el archivo para validación</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="alert alert-info mb-4" style="padding: 1rem 1.25rem; font-size: 1rem;">
                                    <div style="display: flex; align-items: start; gap: 12px;">
                                        <i class="fas fa-info-circle" style="color: #0c5460; margin-top: 3px; flex-shrink: 0; font-size: 1.1rem;"></i>
                                        <div>
                                            <strong style="font-size: 1rem;">Formato requerido:</strong> Código Lote, Código SKU, Cantidad, Fecha Vencimiento (dd/MM/yyyy), Ubicación, Orden Compra (opcional)
                                        </div>
                                    </div>
                                </div>

                                <form method="POST" action="${pageContext.request.contextPath}/almacen/ExcelValidacionServlet?action=validar" 
                                      enctype="multipart/form-data" id="formCargaExcel">
                                    
                                    <div class="mb-4">
                                        <label for="archivoExcel" class="form-label" style="font-size: 1.1rem; font-weight: 600; margin-bottom: 0.75rem;">
                                            <i class="fas fa-file-excel me-2"></i>Seleccionar archivo Excel
                                        </label>
                                        <input type="file" 
                                               class="form-control" 
                                               id="archivoExcel" 
                                               name="archivoExcel" 
                                               accept=".xlsx,.xls"
                                               required
                                               style="font-size: 1rem; padding: 0.75rem;">
                                        <small class="text-muted" style="font-size: 0.9rem; margin-top: 0.5rem; display: block;">Formatos aceptados: .xlsx, .xls (máximo 10 MB)</small>
                                    </div>
                                    
                                    <div class="d-flex justify-content-end gap-3 mt-4">
                                        <a href="${pageContext.request.contextPath}/almacen/EntradaServlet" 
                                           class="btn btn-secondary" style="font-size: 1rem; padding: 0.6rem 1.2rem;">
                                            <i class="fas fa-times me-1"></i>Cancelar
                                        </a>
                                        <button type="submit" class="btn btn-primary" id="btnValidar" style="font-size: 1rem; padding: 0.6rem 1.2rem;">
                                            <i class="fas fa-check-circle me-1"></i>Validar Archivo
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

