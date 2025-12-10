<%@ page import="com.example.telito.logistica.daos.InventarioDao" %>
<%@ page import="com.example.telito.almacen.daos.LoteDao" %>
<%@ page import="com.example.telito.administrador.daos.ProductoDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) {
        session.removeAttribute("errorMsg");
    }
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) {
        session.removeAttribute("successMsg");
    }
    String tipoMensaje = (String) session.getAttribute("tipoMensaje");
    if (tipoMensaje != null) {
        session.removeAttribute("tipoMensaje");
    }
    
    // Obtener información para mostrar
    InventarioDao inventarioDao = new InventarioDao();
    LoteDao loteDao = new LoteDao();
    ProductoDAO productoDAO = new ProductoDAO();
    
    // Obtener conteos (usando los métodos que obtienen todas las listas)
    int totalLogistica = inventarioDao.obtenerInventarioAgrupado(null, null).size();
    int totalAlmacen = loteDao.listarTodosLotesRegistrados().size();
    int totalProductores = productoDAO.listarProductos().size();
    
    String filtrosInfo = "Inventario completo - Todas las secciones";
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Enviar Reporte por Correo"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Inventario"/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <% if (errorMsg != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <%= errorMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>
            <% if (successMsg != null) { %>
            <div class="alert alert-<%= tipoMensaje != null ? tipoMensaje : "success" %> alert-dismissible fade show" role="alert">
                <%= successMsg %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <div class="page-header mb-4">
                <h2 class="pageheader-title">Enviar Reporte de Inventario General por Correo</h2>
                <p class="pageheader-text">Genera y envía un reporte Excel consolidado del Inventario General por correo electrónico.</p>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="table-card">
                        <div class="card-header">
                            <h5 class="mb-0 fw-semibold">Formulario de Envío</h5>
                        </div>
                        <div class="card-body">
                            <div class="alert alert-info mb-4">
                                <i class="fas fa-info-circle me-2"></i>
                                <strong>Información del reporte:</strong> Se generará un reporte Excel con <strong>3 hojas separadas</strong> que incluyen:
                            </div>

                            <div class="row mb-4">
                                <div class="col-md-4">
                                    <div class="card border-primary">
                                        <div class="card-body">
                                            <h6 class="card-title"><i class="fas fa-truck me-2"></i>Logística</h6>
                                            <p class="mb-0"><strong><%= totalLogistica %></strong> productos</p>
                                            <small class="text-muted">SKU, Producto, Paquetes, Precios, Estado</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="card border-info">
                                        <div class="card-body">
                                            <h6 class="card-title"><i class="fas fa-warehouse me-2"></i>Almacén</h6>
                                            <p class="mb-0"><strong><%= totalAlmacen %></strong> lotes</p>
                                            <small class="text-muted">Lote, Producto, Ubicación, Stock, Vencimiento</small>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="card border-success">
                                        <div class="card-body">
                                            <h6 class="card-title"><i class="fas fa-seedling me-2"></i>Productores</h6>
                                            <p class="mb-0"><strong><%= totalProductores %></strong> productos</p>
                                            <small class="text-muted">SKU, Producto, Categoría, Stock Total</small>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <form action="<%= request.getContextPath() %>/administrador/InventarioGeneralReporteServlet" method="POST">
                                <input type="hidden" name="action" value="enviar">

                                <div class="mb-3">
                                    <label for="email_destino" class="form-label">
                                        <i class="fas fa-envelope me-2"></i>Email de Destino <span class="text-danger">*</span>
                                    </label>
                                    <input type="email" class="form-control" id="email_destino" name="email_destino" 
                                           placeholder="correo@ejemplo.com" required>
                                    <small class="form-text text-muted">Ingresa el correo electrónico donde deseas recibir el reporte.</small>
                                </div>

                                <div class="mb-3">
                                    <label for="asunto" class="form-label">
                                        <i class="fas fa-tag me-2"></i>Asunto del Correo
                                    </label>
                                    <input type="text" class="form-control" id="asunto" name="asunto" 
                                           value="Reporte de Inventario General - TELITO BODEGUERO" 
                                           placeholder="Asunto del correo">
                                    <small class="form-text text-muted">Si no especificas un asunto, se usará uno por defecto.</small>
                                </div>

                                <div class="mb-3">
                                    <label for="mensaje" class="form-label">
                                        <i class="fas fa-comment me-2"></i>Mensaje Adicional (Opcional)
                                    </label>
                                    <textarea class="form-control" id="mensaje" name="mensaje" rows="4" 
                                              placeholder="Escribe un mensaje personalizado que aparecerá en el correo..."></textarea>
                                    <small class="form-text text-muted">Puedes agregar un mensaje personalizado que aparecerá en el cuerpo del correo.</small>
                                </div>

                                <div class="alert alert-warning">
                                    <i class="fas fa-exclamation-triangle me-2"></i>
                                    <strong>Nota:</strong> El archivo Excel se generará con <strong>3 hojas separadas</strong>:
                                    <ul class="mb-0 mt-2">
                                        <li><strong>Hoja 1 - Logística:</strong> Inventario agrupado por producto con precios y estados de stock</li>
                                        <li><strong>Hoja 2 - Almacén:</strong> Lotes registrados con ubicación, stock y fechas de vencimiento</li>
                                        <li><strong>Hoja 3 - Productores:</strong> Productos con categorías y stock total</li>
                                    </ul>
                                    <p class="mb-0 mt-2">Cada hoja incluye filtros automáticos que puedes usar para ordenar y filtrar los datos directamente en Excel.</p>
                                </div>

                                <div class="d-flex justify-content-between">
                                    <a href="<%= request.getContextPath() %>/administrador/inventario-general" class="btn btn-secondary">
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
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

