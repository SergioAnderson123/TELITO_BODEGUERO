<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    Map<String, Integer> alertasPorNivel = (Map<String, Integer>) request.getAttribute("alertasPorNivel");
    Map<String, Integer> alertasPorTipo = (Map<String, Integer>) request.getAttribute("alertasPorTipo");
    Integer totalAlertasActivas = (Integer) request.getAttribute("totalAlertasActivas");
    ArrayList<Map<String, Object>> alertasActivas = (ArrayList<Map<String, Object>>) request.getAttribute("alertasActivas");
    Integer reglasActivas = (Integer) request.getAttribute("reglasActivas");
    
    if (alertasPorNivel == null) alertasPorNivel = new HashMap<>();
    if (alertasPorTipo == null) alertasPorTipo = new HashMap<>();
    if (totalAlertasActivas == null) totalAlertasActivas = 0;
    if (alertasActivas == null) alertasActivas = new ArrayList<>();
    if (reglasActivas == null) reglasActivas = 0;
    
    int alertasInfo = alertasPorNivel.getOrDefault("INFO", 0);
    int alertasWarning = alertasPorNivel.getOrDefault("WARNING", 0);
    int alertasCritical = alertasPorNivel.getOrDefault("CRITICAL", 0);
%>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Dashboard de Alertas"/>
    </jsp:include>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        /* REGLA DE ORO: Todo debe caber en una sola pantalla sin scroll vertical ni horizontal */
        html, body {
            overflow-x: hidden !important;
            max-width: 100vw !important;
        }
        
        .dashboard-content {
            padding: 10px !important;
            overflow-y: hidden !important;
            overflow-x: hidden !important;
            max-width: 100% !important;
        }
        
        .dashboard-wrapper {
            overflow-x: hidden !important;
            max-width: 100% !important;
        }
        
        .row {
            margin-left: 0 !important;
            margin-right: 0 !important;
        }
        
        .row > * {
            padding-left: 0.5rem !important;
            padding-right: 0.5rem !important;
        }
        
        /* Cards de métricas con gradientes atractivos */
        .metric-card {
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            overflow: hidden;
            position: relative;
        }
        
        .metric-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }
        
        .metric-card-info {
            background: linear-gradient(160deg, #83c5be 0%, #006d77 100%);
            color: white;
        }
        
        .metric-card-warning {
            background: linear-gradient(160deg, #ffb703 0%, #fb8500 100%);
            color: white;
        }
        
        .metric-card-critical {
            background: linear-gradient(160deg, #e63946 0%, #d62828 100%);
            color: white;
        }
        
        .metric-card-total {
            background: linear-gradient(160deg, #006d77 0%, #83c5be 100%);
            color: white;
        }
        
        .metric-card-rules {
            background: linear-gradient(160deg, #edf6f9 0%, #83c5be 100%);
            color: #006d77;
        }
        
        .metric-icon {
            font-size: 3rem;
            opacity: 0.3;
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
        }
        
        .metric-value {
            font-size: 2.5rem;
            font-weight: 800;
            margin: 0;
            line-height: 1;
        }
        
        .metric-label {
            font-size: 0.9rem;
            opacity: 0.9;
            margin-top: 8px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        /* Lista de alertas activas */
        .alert-item {
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 12px;
            border-left: 5px solid;
            transition: all 0.3s ease;
            background: white;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
        }
        
        .alert-item:hover {
            transform: translateX(5px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        }
        
        .alert-item.info {
            border-left-color: #83c5be;
            background: linear-gradient(90deg, rgba(131, 197, 190, 0.1) 0%, white 10%);
        }
        
        .alert-item.warning {
            border-left-color: #ffb703;
            background: linear-gradient(90deg, rgba(255, 183, 3, 0.1) 0%, white 10%);
        }
        
        .alert-item.critical {
            border-left-color: #e63946;
            background: linear-gradient(90deg, rgba(230, 57, 70, 0.15) 0%, white 10%);
        }
        
        .alert-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .badge-info {
            background: linear-gradient(160deg, #83c5be 0%, #006d77 100%);
            color: white;
        }
        
        .badge-warning {
            background: linear-gradient(160deg, #ffb703 0%, #fb8500 100%);
            color: white;
        }
        
        .badge-critical {
            background: linear-gradient(160deg, #e63946 0%, #d62828 100%);
            color: white;
        }
        
        /* Gráfico container */
        .chart-container {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            height: 300px;
        }
        
        /* Page header */
        .page-header h2 {
            color: #2d3748;
            font-weight: 700;
            font-size: 1.5rem;
            margin-bottom: 5px;
        }
        
        .page-header p {
            color: #718096;
            font-size: 0.9rem;
            margin-bottom: 0;
        }
        
        /* Botones de acción */
        .btn-action {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
        }
        
        /* Sección de alertas */
        .alerts-section {
            max-height: 400px;
            overflow-y: auto;
            padding-right: 5px;
        }
        
        .alerts-section::-webkit-scrollbar {
            width: 6px;
        }
        
        .alerts-section::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }
        
        .alerts-section::-webkit-scrollbar-thumb {
            background: linear-gradient(160deg, #006d77 0%, #83c5be 100%);
            border-radius: 10px;
        }
        
        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #a0aec0;
        }
        
        .empty-state i {
            font-size: 4rem;
            opacity: 0.3;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Configuracion"/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <!-- Header -->
            <div class="page-header mb-3">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h2><i class="fas fa-bell me-2" style="color: #006d77;"></i>Dashboard de Alertas</h2>
                        <p>Vista general de todas las alertas del sistema en tiempo real</p>
                    </div>
                    <div>
                        <a href="<%= request.getContextPath() %>/AlertaServlet?action=listar" class="btn btn-primary btn-action">
                            <i class="fas fa-cog me-2"></i>Gestionar Reglas
                        </a>
                    </div>
                </div>
            </div>

            <!-- Métricas principales -->
            <div class="row g-3 mb-3">
                <div class="col-xl-3 col-lg-6 col-md-6">
                    <div class="card metric-card metric-card-total">
                        <div class="card-body p-3">
                            <div class="metric-label">Total Alertas Activas</div>
                            <div class="metric-value"><%= totalAlertasActivas %></div>
                            <i class="fas fa-bell metric-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6">
                    <div class="card metric-card metric-card-info">
                        <div class="card-body p-3">
                            <div class="metric-label">Informativas</div>
                            <div class="metric-value"><%= alertasInfo %></div>
                            <i class="fas fa-info-circle metric-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6">
                    <div class="card metric-card metric-card-warning">
                        <div class="card-body p-3">
                            <div class="metric-label">Advertencias</div>
                            <div class="metric-value"><%= alertasWarning %></div>
                            <i class="fas fa-exclamation-triangle metric-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6 col-md-6">
                    <div class="card metric-card metric-card-critical">
                        <div class="card-body p-3">
                            <div class="metric-label">Críticas</div>
                            <div class="metric-value"><%= alertasCritical %></div>
                            <i class="fas fa-exclamation-circle metric-icon"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Gráficos y Lista de Alertas -->
            <div class="row g-3">
                <!-- Gráfico de distribución -->
                <div class="col-lg-5">
                    <div class="chart-container">
                        <h5 class="mb-3" style="color: #2d3748; font-weight: 700;">
                            <i class="fas fa-chart-pie me-2" style="color: #006d77;"></i>Distribución por Nivel
                        </h5>
                        <canvas id="nivelChart"></canvas>
                    </div>
                </div>
                
                <!-- Gráfico de tipos -->
                <div class="col-lg-7">
                    <div class="chart-container">
                        <h5 class="mb-3" style="color: #2d3748; font-weight: 700;">
                            <i class="fas fa-chart-bar me-2" style="color: #006d77;"></i>Distribución por Tipo
                        </h5>
                        <canvas id="tipoChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Lista de Alertas Activas -->
            <div class="row mt-3">
                <div class="col-12">
                    <div class="card shadow-sm" style="border-radius: 12px; border: none;">
                        <div class="card-header" style="background: linear-gradient(160deg, #006d77 0%, #83c5be 100%); color: white; border-radius: 12px 12px 0 0; padding: 15px 20px;">
                            <h5 class="mb-0" style="font-weight: 700;">
                                <i class="fas fa-list me-2"></i>Alertas Activas Recientes
                                <span class="badge bg-light text-dark ms-2"><%= alertasActivas.size() %></span>
                            </h5>
                        </div>
                        <div class="card-body p-3">
                            <div class="alerts-section">
                                <% if (alertasActivas != null && !alertasActivas.isEmpty()) { %>
                                    <% for (Map<String, Object> alerta : alertasActivas) { %>
                                        <% 
                                            String nivel = (String) alerta.get("nivel");
                                            String tipoAlerta = (String) alerta.get("tipo_alerta");
                                            String mensaje = (String) alerta.get("mensaje");
                                            String nombreProducto = (String) alerta.get("nombre_producto");
                                            String codigoLote = (String) alerta.get("codigo_lote");
                                            Integer idAlerta = (Integer) alerta.get("id");
                                            
                                            String nivelClass = nivel != null ? nivel.toLowerCase() : "info";
                                            String badgeClass = "badge-info";
                                            if ("WARNING".equals(nivel)) badgeClass = "badge-warning";
                                            else if ("CRITICAL".equals(nivel)) badgeClass = "badge-critical";
                                        %>
                                        <div class="alert-item <%= nivelClass %>">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <div class="flex-grow-1">
                                                    <div class="d-flex align-items-center gap-2 mb-2">
                                                        <span class="alert-badge <%= badgeClass %>"><%= nivel != null ? nivel : "INFO" %></span>
                                                        <span class="badge bg-secondary" style="font-size: 0.7rem;"><%= tipoAlerta != null ? tipoAlerta.replace("_", " ") : "N/A" %></span>
                                                    </div>
                                                    <p class="mb-1 fw-semibold" style="color: #2d3748; font-size: 0.95rem;"><%= mensaje != null ? mensaje : "Sin mensaje" %></p>
                                                    <% if (nombreProducto != null || codigoLote != null) { %>
                                                        <small class="text-muted">
                                                            <i class="fas fa-box me-1"></i>
                                                            <% if (nombreProducto != null) { %><%= nombreProducto %><% } %>
                                                            <% if (codigoLote != null) { %> - Lote: <%= codigoLote %><% } %>
                                                        </small>
                                                    <% } %>
                                                </div>
                                                <div>
                                                    <button class="btn btn-sm btn-outline-primary btn-action" 
                                                            onclick="marcarLeida(<%= idAlerta %>)" 
                                                            title="Marcar como leída">
                                                        <i class="fas fa-check"></i>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                <% } else { %>
                                    <div class="empty-state">
                                        <i class="fas fa-check-circle"></i>
                                        <p class="mb-0 fw-semibold">¡No hay alertas activas!</p>
                                        <small>El sistema está funcionando correctamente</small>
                                    </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Gráfico de distribución por nivel
    const nivelCtx = document.getElementById('nivelChart').getContext('2d');
    new Chart(nivelCtx, {
        type: 'doughnut',
                data: {
                    labels: ['Informativas', 'Advertencias', 'Críticas'],
                    datasets: [{
                        data: [<%= alertasInfo %>, <%= alertasWarning %>, <%= alertasCritical %>],
                        backgroundColor: [
                            'rgba(131, 197, 190, 0.8)',
                            'rgba(255, 183, 3, 0.8)',
                            'rgba(230, 57, 70, 0.8)'
                        ],
                        borderWidth: 0
                    }]
                },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 15,
                        font: {
                            size: 12,
                            weight: 'bold'
                        }
                    }
                }
            }
        }
    });
    
    // Gráfico de distribución por tipo
    const tipoCtx = document.getElementById('tipoChart').getContext('2d');
    const tipos = [];
    const cantidades = [];
    <% for (Map.Entry<String, Integer> entry : alertasPorTipo.entrySet()) { %>
        tipos.push('<%= entry.getKey().replace("_", " ") %>');
        cantidades.push(<%= entry.getValue() %>);
    <% } %>
    
    new Chart(tipoCtx, {
        type: 'bar',
                data: {
                    labels: tipos.length > 0 ? tipos : ['Sin datos'],
                    datasets: [{
                        label: 'Cantidad de Alertas',
                        data: cantidades.length > 0 ? cantidades : [0],
                        backgroundColor: [
                            'rgba(0, 109, 119, 0.8)',
                            'rgba(131, 197, 190, 0.8)',
                            'rgba(255, 183, 3, 0.8)',
                            'rgba(230, 57, 70, 0.8)',
                            'rgba(251, 133, 0, 0.8)'
                        ],
                        borderRadius: 8,
                        borderSkipped: false
                    }]
                },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 1
                    }
                }
            }
        }
    });
    
    // Marcar alerta como leída
    function marcarLeida(idAlerta) {
        fetch('<%= request.getContextPath() %>/administrador/DashboardAlertasServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=marcarLeida&id=' + idAlerta
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                location.reload();
            } else {
                alert('Error al marcar la alerta como leída');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error al procesar la solicitud');
        });
    }
</script>
</body>
</html>

