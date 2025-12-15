<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="nav-left-sidebar">
    <div class="menu-list">
        <nav class="navbar navbar-expand">
            <ul class="navbar-nav flex-column w-100">
                <li class="nav-divider"><i class="fas fa-bars me-2"></i>MENU</li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Recepciones Pendientes"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes">
                        <i class="fas fa-truck-loading"></i>Recepciones Pendientes
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link <c:if test='${param.activeMenu == "Historial"}'>active</c:if>"
                       href="${pageContext.request.contextPath}/gerente-tienda/GerenteTiendaServlet?action=historial">
                        <i class="fas fa-history"></i>Historial de Recepciones
                    </a>
                </li>

            </ul>
        </nav>
    </div>
</div>

