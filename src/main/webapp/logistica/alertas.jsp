<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/logistica/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Alertas de Logística"/>
    </jsp:include>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/logistica/layouts/sidebar_logistica.jsp">
        <jsp:param name="activeMenu" value="Alertas"/>
    </jsp:include>
    <jsp:include page="/logistica/layouts/header_logistica.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <div class="container-fluid px-4">
                <div class="page-header mb-4">
                    <h2 class="pageheader-title"><i class="fas fa-bell me-2"></i>Alertas</h2>
                    <p class="pageheader-text">Alertas activas generadas por las reglas configuradas para Logística.</p>
                </div>

                <div class="card">
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty requestScope.mensajes}">
                                <div class="alert alert-success mb-0"><i class="fas fa-check-circle me-2"></i>No hay alertas activas en este momento.</div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-striped align-middle">
                                        <thead class="table-dark">
                                            <tr>
                                                <th style="width:80px;">#</th>
                                                <th>Alerta</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="msg" items="${mensajes}" varStatus="st">
                                                <tr>
                                                    <td><span class="badge bg-secondary">${st.index + 1}</span></td>
                                                    <td><i class="fas fa-exclamation-triangle text-warning me-2"></i>${msg}</td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
