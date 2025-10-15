<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="nav-left-sidebar">
    <div class="menu-list">
        <nav class="navbar navbar-expand">
            <ul class="navbar-nav flex-column w-100">
                <li class="nav-divider"><i class="fas fa-bars me-2"></i>Menu</li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Gestion de inventario"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/almacen/LoteServlet?action=lista">
                        <i class="fas fa-box"></i>Gestion de Inventario
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Registrar entradas"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/almacen/EntradaServlet?action=lista">
                        <i class="fas fa-arrow-down"></i>Registrar Entradas
                    </a>
                </li>
                
                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Registrar salidas"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/almacen/PedidoServlet?action=lista">
                        <i class="fas fa-arrow-up"></i>Registrar Salidas
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link ${param.activeMenu == 'Historial' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/almacen/MovimientoServlet">
                        <i class="fas fa-history"></i>Historial de Movimientos
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
