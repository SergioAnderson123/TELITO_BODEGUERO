<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="nav-left-sidebar">
    <div class="menu-list">
        <nav class="navbar navbar-expand">
            <ul class="navbar-nav flex-column w-100">
                <li class="nav-divider"><i class="fas fa-bars me-2"></i>Menu</li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Movimiento"}'>active</c:if>'"
                       href="${pageContext.request.contextPath}/MovimientoProductoServlet">
                        <i class="fas fa-exchange-alt"></i>Movimiento de Productos
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Inventario"}'>active</c:if>'"
                       href="${pageContext.request.contextPath}/InventarioServlet">
                        <i class="fas fa-warehouse"></i>Gestion de Inventario
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "OrdenCompra"}'>active</c:if>'"
                       href="${pageContext.request.contextPath}/orden-compra">
                        <i class="fas fa-file-invoice-dollar"></i>Orden de Compra
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Distribucion"}'>active</c:if>'"
                       href="${pageContext.request.contextPath}/planes-transporte">
                        <i class="fas fa-truck"></i>Distribucion y Transporte
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Alertas"}'>active</c:if>'"
                       href="${pageContext.request.contextPath}/logistica/alertas">
                        <i class="fas fa-bell"></i>Alertas
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


