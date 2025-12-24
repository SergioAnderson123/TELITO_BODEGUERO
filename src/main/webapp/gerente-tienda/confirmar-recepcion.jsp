<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.example.telito.almacen.beans.PlanTransporte" %>
<%@ page import="com.example.telito.administrador.beans.Usuario" %>

<%
    PlanTransporte plan = (PlanTransporte) request.getAttribute("plan");
    if (plan == null) {
        response.sendRedirect(request.getContextPath() + "/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes");
        return;
    }
    Usuario usuario = (Usuario) session.getAttribute("usuario");
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/gerente-tienda/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Confirmar Recepción"/>
    </jsp:include>
    <style>
        .info-card {
            background: linear-gradient(135deg, #FFFEF9 0%, #ffffff 100%);
            border-left: 4px solid #6F4E37;
            border-radius: 8px;
        }
        .btn-confirmar {
            background: linear-gradient(135deg, #6F4E37 0%, #8B6F47 100%);
            border: none;
            padding: 12px 30px;
            font-weight: 600;
            color: white;
        }
        .btn-confirmar:hover {
            background: linear-gradient(135deg, #8B6F47 0%, #A0826D 100%);
            color: white;
        }
    </style>
</head>
<body>
    <div class="dashboard-main-wrapper">
        <jsp:include page="/gerente-tienda/layouts/sidebar_gerente.jsp">
            <jsp:param name="activeMenu" value="Recepciones Pendientes"/>
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
                                    <i class="fas fa-check-circle me-2"></i>Confirmar Recepción
                                </h2>
                                <p class="pageheader-text mb-0" style="font-size: 0.85rem; margin-top: 0.2rem;">
                                    Verifica y confirma la recepción del plan de transporte
                                </p>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Información del Plan -->
                    <div class="card mb-4">
                        <div class="card-header">
                            <h5 class="mb-0"><i class="fas fa-info-circle me-2"></i>Información del Plan de Transporte</h5>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Número de Plan</label>
                                        <h5 class="mb-0"><strong><%= plan.getNumeroPlan() %></strong></h5>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Producto</label>
                                        <h5 class="mb-0"><%= plan.getNombreProducto() %></h5>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Código de Lote</label>
                                        <h5 class="mb-0"><%= plan.getCodigoLote() %></h5>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Conductor</label>
                                        <h5 class="mb-0"><%= plan.getNombreConductor() %></h5>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Vehículo</label>
                                        <h5 class="mb-0"><%= plan.getPlacaVehiculo() %></h5>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Fecha de Entrega</label>
                                        <h5 class="mb-0"><%= plan.getFechaEntrega() %></h5>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Destino</label>
                                        <h5 class="mb-0"><%= plan.getNombreDestino() %></h5>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="info-card p-3">
                                        <label class="text-muted small">Estado</label>
                                        <h5 class="mb-0">
                                            <% if ("En Ruta".equals(plan.getEstado())) { %>
                                                <span class="badge bg-warning text-dark">
                                                    <i class="fas fa-truck me-1"></i>En Ruta
                                                </span>
                                            <% } else if ("Salida".equals(plan.getEstado())) { %>
                                                <span class="badge bg-info">
                                                    <i class="fas fa-arrow-right me-1"></i>Salida
                                                </span>
                                            <% } else { %>
                                                <span class="badge bg-secondary"><%= plan.getEstado() %></span>
                                            <% } %>
                                        </h5>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Formulario de Confirmación -->
                    <div class="card">
                        <div class="card-body">
                            <form method="POST" action="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet" id="formConfirmarRecepcion">
                                <input type="hidden" name="action" value="confirmar">
                                <input type="hidden" name="id_plan" value="<%= plan.getIdPlan() %>">
                                
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    <strong>Instrucciones:</strong> Verifica que los productos recibidos coincidan con la información del plan. 
                                    Al confirmar, el estado del plan cambiará a "Entregado".
                                </div>
                                
                                <div class="d-flex justify-content-between align-items-center mt-4">
                                    <a href="<%= request.getContextPath() %>/gerente-tienda/GerenteTiendaServlet?action=recepciones-pendientes" 
                                       class="btn btn-secondary">
                                        <i class="fas fa-arrow-left me-1"></i>Volver
                                    </a>
                                    <button type="submit" class="btn btn-confirmar text-white">
                                        <i class="fas fa-check me-1"></i>Confirmar Recepción
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="/gerente-tienda/layouts/footer.jsp"/>
    
    <script>
        document.getElementById('formConfirmarRecepcion').addEventListener('submit', function(e) {
            if (!confirm('¿Estás seguro de confirmar la recepción de este plan de transporte?')) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>

