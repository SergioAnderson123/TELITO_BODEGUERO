<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Mensajes de éxito o error --%>
<% if (session.getAttribute("successMsg") != null) { %>
<div class="alert alert-success" role="alert">
    <%= session.getAttribute("successMsg") %>
    <% session.removeAttribute("successMsg"); %>
</div>
<% } %>
<% if (session.getAttribute("errorMsg") != null) { %>
<div class="alert alert-danger" role="alert">
    <%= session.getAttribute("errorMsg") %>
    <% session.removeAttribute("errorMsg"); %>
</div>
<% } %>

<% ArrayList<Map<String, Object>> notificaciones = (ArrayList<Map<String, Object>>) request.getAttribute("notificaciones"); %>
<% Integer noLeidas = (Integer) request.getAttribute("noLeidas"); %>

<!doctype html>
<html lang="es">
<head>
    <title>Notificaciones – Telito Bodeguero</title>
    <%@ include file="/logistica/layouts/head.jsp" %>
    
    <style>
        .notification-card {
            border-left: 4px solid #dee2e6;
            transition: all 0.3s ease;
        }
        .notification-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .notification-card.critico {
            border-left-color: #dc3545;
            background-color: #f8d7da;
        }
        .notification-card.warn {
            border-left-color: #ffc107;
            background-color: #fff3cd;
        }
        .notification-card.info {
            border-left-color: #0dcaf0;
            background-color: #d1ecf1;
        }
        .notification-card.leida {
            opacity: 0.6;
        }
        .severity-badge {
            font-size: 0.75rem;
            font-weight: 600;
        }
        .timestamp {
            font-size: 0.875rem;
            color: #6c757d;
        }
    </style>
</head>
<body>
<%@ include file="/logistica/layouts/header.jsp" %>

<%@ include file="/logistica/layouts/sidebar.jsp" %>

<!-- Header ya incluido en layouts/header.jsp -->

<div class="dashboard-wrapper">
<div class="dashboard-content">
    <div class="page-header mb-4 d-flex justify-content-between align-items-center">
        <div>
            <h2 class="pageheader-title" style="font-weight: 700;">
                <i class="fas fa-bell me-2"></i>Notificaciones del Sistema
            </h2>
            <p class="pageheader-text">Alertas y notificaciones dirigidas al equipo de logística.</p>
        </div>
        <div>
            <% if (noLeidas != null && noLeidas > 0) { %>
            <a href="<%= request.getContextPath() %>/logistica/NotificacionServlet?action=marcarTodasLeidas" 
               class="btn btn-outline-primary" onclick="return confirm('¿Marcar todas como leídas?')">
                <i class="fas fa-check-double"></i> Marcar todas como leídas
            </a>
            <% } %>
        </div>
    </div>

    <!-- Resumen de notificaciones -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">Total</h5>
                    <h3 class="text-primary"><%= notificaciones != null ? notificaciones.size() : 0 %></h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">No leídas</h5>
                    <h3 class="text-warning"><%= noLeidas != null ? noLeidas : 0 %></h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">Críticas</h5>
                    <h3 class="text-danger">
                        <%= notificaciones != null ? notificaciones.stream().filter(n -> "CRITICO".equals(n.get("severidad"))).count() : 0 %>
                    </h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">Advertencias</h5>
                    <h3 class="text-warning">
                        <%= notificaciones != null ? notificaciones.stream().filter(n -> "WARN".equals(n.get("severidad"))).count() : 0 %>
                    </h3>
                </div>
            </div>
        </div>
    </div>

    <!-- Lista de notificaciones -->
    <div class="row">
        <div class="col-12">
            <% if (notificaciones != null && !notificaciones.isEmpty()) { %>
                <% for (Map<String, Object> notificacion : notificaciones) { %>
                <div class="card notification-card mb-3 <%= notificacion.get("severidad").toString().toLowerCase() %> <%= (Boolean)notificacion.get("leido") ? "leida" : "" %>">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <div class="flex-grow-1">
                                <div class="d-flex align-items-center mb-2">
                                    <% if ("STOCK_MINIMO".equals(notificacion.get("tipo"))) { %>
                                        <i class="fas fa-exclamation-triangle text-warning me-2"></i>
                                    <% } else { %>
                                        <i class="fas fa-clock text-danger me-2"></i>
                                    <% } %>
                                    
                                    <span class="badge severity-badge bg-<%= "CRITICO".equals(notificacion.get("severidad")) ? "danger" : "WARN".equals(notificacion.get("severidad")) ? "warning" : "info" %>">
                                        <%= notificacion.get("severidad") %>
                                    </span>
                                    
                                    <% if ((Boolean)notificacion.get("leido")) { %>
                                        <span class="badge bg-success ms-2">Leída</span>
                                    <% } %>
                                </div>
                                
                                <p class="mb-2"><%= notificacion.get("mensaje") %></p>
                                
                                <div class="d-flex align-items-center text-muted small">
                                    <i class="fas fa-clock me-1"></i>
                                    <span class="timestamp">
                                        <%= notificacion.get("creadoEn") %>
                                    </span>
                                    
                                    <% if (notificacion.get("productoNombre") != null) { %>
                                        <span class="ms-3">
                                            <i class="fas fa-box me-1"></i>
                                            <%= notificacion.get("productoNombre") %>
                                            <% if (notificacion.get("codigoSku") != null) { %>
                                                (<%= notificacion.get("codigoSku") %>)
                                            <% } %>
                                        </span>
                                    <% } %>
                                    
                                    <% if (notificacion.get("numeroLote") != null) { %>
                                        <span class="ms-3">
                                            <i class="fas fa-tag me-1"></i>
                                            Lote: <%= notificacion.get("numeroLote") %>
                                        </span>
                                    <% } %>
                                </div>
                            </div>
                            
                            <% if (!(Boolean)notificacion.get("leido")) { %>
                            <div class="ms-3">
                                <a href="<%= request.getContextPath() %>/logistica/NotificacionServlet?action=marcarLeida&id=<%= notificacion.get("id") %>" 
                                   class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-check"></i> Marcar como leída
                                </a>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            <% } else { %>
                <div class="card">
                    <div class="card-body text-center py-5">
                        <i class="fas fa-bell-slash fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">No hay notificaciones</h5>
                        <p class="text-muted">No tienes notificaciones pendientes en este momento.</p>
                    </div>
                </div>
            <% } %>
        </div>
    </div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const sidebar = document.getElementById('sidebar');
        const content = document.getElementById('content');
        const header = document.getElementById('header');
        const sidebarToggle = document.getElementById('sidebar-toggle');
        
        if (sidebarToggle) {
            sidebarToggle.addEventListener('click', () => {
                sidebar.classList.toggle('hidden');
                content.classList.toggle('full-width');
                header.classList.toggle('full-width');
            });
        }
    });
</script>
</body>
</html>
