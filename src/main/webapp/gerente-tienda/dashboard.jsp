<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    Usuario usuario = (Usuario) session.getAttribute("usuario");
    Integer recepcionesPendientes = (Integer) request.getAttribute("recepcionesPendientes");
    Integer recepcionesCompletadas = (Integer) request.getAttribute("recepcionesCompletadas");
    
    if (recepcionesPendientes == null) recepcionesPendientes = 0;
    if (recepcionesCompletadas == null) recepcionesCompletadas = 0;
    
    String nombreDistrito = "Tu Distrito";
    if (usuario != null && usuario.getDistritoId() != null) {
        // Aquí podrías cargar el nombre del distrito desde la BD si lo necesitas
    }
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/gerente-tienda/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Dashboard - Gerente de Tienda"/>
    </jsp:include>
</head>
<body>
    <div class="dashboard-main-wrapper">
        <jsp:include page="/gerente-tienda/layouts/sidebar_gerente.jsp">
            <jsp:param name="activeMenu" value="Dashboard"/>
        </jsp:include>
        
        <div class="dashboard-wrapper">
            <jsp:include page="/gerente-tienda/layouts/header_gerente.jsp"/>
            
            <div class="dashboard-content">
                <div class="container-fluid">
                    <!-- Page Header -->
                    <div class="page-header mb-1" style="padding-top: 0.5rem; padding-bottom: 0.5rem;">
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                            <div>
                                <h2 class="pageheader-title mb-0" style="font-size: 1.4rem; line-height: 1.2;">
                                    <i class="fas fa-chart-line me-2"></i>Dashboard
                                </h2>
                                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">
                                    Bienvenido, <%= usuario != null ? usuario.getNombres() : "Gerente" %>
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Estadísticas -->
                    <div class="stats-container">
                        <div class="stat-card">
                            <h3>Recepciones Pendientes</h3>
                            <p><%= recepcionesPendientes %></p>
                        </div>
                        <div class="stat-card">
                            <h3>Recepciones Completadas</h3>
                            <p><%= recepcionesCompletadas %></p>
                        </div>
                    </div>
                    
                    <!-- Acciones Rápidas -->
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header">
                                    <h5 class="mb-0"><i class="fas fa-bolt me-2"></i>Acciones Rápidas</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row">
                                        <div class="col-md-4 mb-3">
                                            <a href="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes" 
                                               class="btn btn-primary w-100 p-3">
                                                <i class="fas fa-truck-loading fa-2x mb-2 d-block"></i>
                                                <strong>Ver Recepciones Pendientes</strong>
                                            </a>
                                        </div>
                                        <div class="col-md-4 mb-3">
                                            <a href="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet?action=historial" 
                                               class="btn btn-outline-primary w-100 p-3">
                                                <i class="fas fa-history fa-2x mb-2 d-block"></i>
                                                <strong>Ver Historial</strong>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="/gerente-tienda/layouts/footer.jsp"/>
</body>
</html>

