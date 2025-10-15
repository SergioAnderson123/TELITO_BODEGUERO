<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <jsp:include page="/administrador/layouts/head.jsp">
      <jsp:param name="pageTitle" value="Configuración"/>
  </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value='Configuracion'/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
    <section class="content-box">
      <h1 class="page-title"><i class="fas fa-cogs"></i> Configuración del Sistema</h1>
      <p class="page-subtitle">Selecciona el área de configuración que deseas administrar.</p>

      <div class="menu-grid">
        <a class="menu-card" href="<%= request.getContextPath() %>/ProductoServlet?action=listarStock">
          <div class="menu-card-icon icon-alert"><i class="fas fa-triangle-exclamation"></i></div>
          <div>
            <div class="menu-card-title">Configurar Stock Mínimo</div>
            <div class="menu-card-desc">Define umbrales y notificaciones para el stock.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/AlertaServlet">
          <div class="menu-card-icon icon-notification"><i class="fas fa-bell"></i></div>
           <div>
            <div class="menu-card-title">Gestión de Alertas</div>
            <div class="menu-card-desc">Crea y administra las reglas de notificación del sistema.</div>
          </div>
        </a>

        <a class="menu-card" href="<%= request.getContextPath() %>/PlantillaServlet">
          <div class="menu-card-icon icon-security"><i class="fas fa-file-excel"></i></div>
           <div>
            <div class="menu-card-title">Gestión de Plantillas</div>
            <div class="menu-card-desc">Administra las plantillas para la carga masiva de datos.</div>
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
