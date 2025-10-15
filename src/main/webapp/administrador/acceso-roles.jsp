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
    <section class="content-box">
      <h1 class="page-title"><i class="fas fa-user-shield"></i> Acceso a Roles</h1>
      <p class="page-subtitle">Selecciona la interfaz a la que deseas acceder.</p>

      <div class="menu-grid">
        <a class="menu-card" href="#">
          <div class="menu-card-icon icon-almacen"><i class="fas fa-warehouse"></i></div>
          <div class="menu-card-title">Almacén</div>
        </a>

          <a class="menu-card" href="<%= request.getContextPath() %>/InventarioServlet">
              <div class="menu-card-icon icon-logistica"><i class="fas fa-truck"></i></div>
              <div class="menu-card-title">Logística</div>
          </a>

        <a class="menu-card" href="#">
          <div class="menu-card-icon icon-productor"><i class="fas fa-seedling"></i></div>
          <div class="menu-card-title">Productor</div>
        </a>
      </div>

    </section>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
