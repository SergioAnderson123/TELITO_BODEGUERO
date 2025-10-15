<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="nav-left-sidebar">
    <div class="menu-list">
        <nav class="navbar navbar-expand">
            <ul class="navbar-nav flex-column w-100">
                <li class="nav-divider"><i class="fas fa-bars me-2"></i>Menu</li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Inicio"}'>active</c:if>'" href="${pageContext.request.contextPath}/inicio">
                        <i class="fas fa-home"></i>Inicio
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Usuarios"}'>active</c:if>'" href="${pageContext.request.contextPath}/UsuarioServlet">
                        <i class="fas fa-users"></i>Gestión de Usuarios
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Inventario"}'>active</c:if>'" href="${pageContext.request.contextPath}/ProductoServlet?action=listarInventario">
                        <i class="fas fa-boxes-stacked"></i>Inventario General
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Reportes"}'>active</c:if>'" href="${pageContext.request.contextPath}/administrador/reportes-globales.jsp">
                        <i class="fas fa-chart-pie"></i>Reportes Globales
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Configuracion"}'>active</c:if>'" href="${pageContext.request.contextPath}/administrador/configuracion.jsp">
                        <i class="fas fa-cogs"></i>Configuración
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/">
                        <i class="fas fa-th-large"></i>Ir a Roles
                    </a>
                </li>
            </ul>
        </nav>
    </div>
</div>

