<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <jsp:include page="/administrador/layouts/head.jsp">
      <jsp:param name="pageTitle" value="Acceso a Roles"/>
  </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Inicio'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
    <div class="container-fluid px-4">
        <div class="page-header mb-4">
            <h2 class="pageheader-title"><i class="fas fa-user-shield me-2"></i>Acceso a Roles</h2>
            <p class="pageheader-text">Selecciona la interfaz a la que deseas acceder y el modo de acceso.</p>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center mb-3">
                            <div class="flex-shrink-0 bg-warning bg-opacity-10 p-3 rounded">
                                <i class="fas fa-warehouse text-warning fa-2x"></i>
                            </div>
                            <div class="flex-grow-1 ms-3">
                                <h5 class="card-title mb-1">Almacén</h5>
                                <p class="card-text text-muted">Gestión de inventario y almacenes</p>
                            </div>
                        </div>
                        <div class="d-grid gap-2">
                            <a href="<%= request.getContextPath() %>/almacen/index.jsp" class="btn btn-warning">
                                <i class="fas fa-edit me-2"></i>Modo Edición
                            </a>
                            <a href="<%= request.getContextPath() %>/almacen/index.jsp?mode=readonly" class="btn btn-outline-warning">
                                <i class="fas fa-eye me-2"></i>Solo Lectura
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center mb-3">
                            <div class="flex-shrink-0 bg-info bg-opacity-10 p-3 rounded">
                                <i class="fas fa-truck text-info fa-2x"></i>
                            </div>
                            <div class="flex-grow-1 ms-3">
                                <h5 class="card-title mb-1">Logística</h5>
                                <p class="card-text text-muted">Distribución y transporte</p>
                            </div>
                        </div>
                        <div class="d-grid gap-2">
                            <a href="<%= request.getContextPath() %>/InventarioServlet" class="btn btn-info text-white">
                                <i class="fas fa-edit me-2"></i>Modo Edición
                            </a>
                            <a href="<%= request.getContextPath() %>/InventarioServlet?mode=readonly" class="btn btn-outline-info">
                                <i class="fas fa-eye me-2"></i>Solo Lectura
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card h-100">
                    <div class="card-body">
                        <div class="d-flex align-items-center mb-3">
                            <div class="flex-shrink-0 bg-success bg-opacity-10 p-3 rounded">
                                <i class="fas fa-seedling text-success fa-2x"></i>
                            </div>
                            <div class="flex-grow-1 ms-3">
                                <h5 class="card-title mb-1">Productor</h5>
                                <p class="card-text text-muted">Gestión de producción</p>
                            </div>
                        </div>
                        <div class="d-grid gap-2">
                            <a href="<%= request.getContextPath() %>/productor/index.jsp" class="btn btn-success">
                                <i class="fas fa-edit me-2"></i>Modo Edición
                            </a>
                            <a href="<%= request.getContextPath() %>/productor/index.jsp?mode=readonly" class="btn btn-outline-success">
                                <i class="fas fa-eye me-2"></i>Solo Lectura
                            </a>
                        </div>
                    </div>
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
