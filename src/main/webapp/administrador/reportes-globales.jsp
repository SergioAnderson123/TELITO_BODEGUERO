<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <jsp:include page="/administrador/layouts/head.jsp">
      <jsp:param name="pageTitle" value="Reportes Globales"/>
  </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Reportes'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
    <section class="content-box">
      <h1 class="page-title"><i class="fas fa-chart-pie"></i> Reportes Globales</h1>
      <p class="page-subtitle">Elige el tablero de indicadores que deseas visualizar.</p>

      <div class="menu-grid">
        <a class="menu-card" href="<%= request.getContextPath() %>/administrador/reportes?action=logistica">
          <div class="menu-card-icon icon-logistica"><i class="fas fa-chart-line"></i></div>
          <div>
            <div class="menu-card-title">Reporte Logística</div>
            <div class="menu-card-desc">Movimientos, distribución y transporte.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/administrador/reportes?action=productor">
          <div class="menu-card-icon icon-productor"><i class="fas fa-seedling"></i></div>
           <div>
            <div class="menu-card-title">Reporte Productor</div>
            <div class="menu-card-desc">Producción, lotes, costos y caducidad.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/administrador/reportes?action=almacen">
          <div class="menu-card-icon icon-almacen"><i class="fas fa-warehouse"></i></div>
           <div>
            <div class="menu-card-title">Reporte Almacén</div>
            <div class="menu-card-desc">Stock, entradas, salidas y ajustes.</div>
          </div>
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
