<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="nav-left-sidebar">
    <div class="menu-list">
        <nav class="navbar navbar-expand">
            <ul class="navbar-nav flex-column w-100">
                <li class="nav-divider"><i class="fas fa-bars me-2"></i>Menu</li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Inicio"}'>active</c:if>" href="${pageContext.request.contextPath}/inicio">
                        <i class="fas fa-home"></i>Inicio
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Usuarios"}'>active</c:if>" href="${pageContext.request.contextPath}/UsuarioServlet">
                        <i class="fas fa-users"></i>Gestión de Usuarios
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Inventario"}'>active</c:if>" href="${pageContext.request.contextPath}/administrador/inventario-general">
                        <i class="fas fa-boxes-stacked"></i>Inventario General
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Reportes"}'>active</c:if>" href="${pageContext.request.contextPath}/administrador/reportes?action=globales">
                        <i class="fas fa-chart-pie"></i>Reportes Globales
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Conductores"}'>active</c:if>" href="${pageContext.request.contextPath}/administrador/ConductorServlet">
                        <i class="fas fa-user-tie"></i>Gestión de Conductores
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Vehiculos"}'>active</c:if>" href="${pageContext.request.contextPath}/administrador/VehiculoServlet">
                        <i class="fas fa-truck"></i>Gestión de Vehículos
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Configuracion"}'>active</c:if>" href="${pageContext.request.contextPath}/administrador/configuracion.jsp">
                        <i class="fas fa-cogs"></i>Configuración
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/">
                        <i class="fas fa-home"></i>Ir a la web principal
                    </a>
                </li>
            </ul>
        </nav>
    </div>
</div>