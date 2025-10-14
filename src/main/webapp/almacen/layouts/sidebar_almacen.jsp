<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="nav-left-sidebar sidebar-dark">
    <div class="menu-list">
        <nav class="navbar navbar-expand navbar-light">
            <ul class="navbar-nav flex-column w-100">
                <li class="nav-divider">
                    Menu
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Gestion de inventario"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/almacen/LoteServlet?action=lista">
                        <i class="fas fa-fw fa-box"></i>Gestion de inventario
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Registrar entradas"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/almacen/EntradaServlet?action=lista">
                        <i class="fas fa-fw fa-arrow-down"></i>Registrar entradas
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Registrar salidas"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/almacen/PedidoServlet?action=lista">
                        <i class="fas fa-fw fa-arrow-up"></i>Registrar salidas
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link ${param.activeMenu == 'Historial' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/almacen/MovimientoServlet">
                        <i class="fas fa-history"></i>Historial de Movimientos
                    </a>
                </li>

            </ul>
        </nav>
    </div>
</div>