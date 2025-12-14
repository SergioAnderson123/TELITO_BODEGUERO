<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Preparación de datos para JavaScript --%>
<% 
    String planesLabelsJson = (String) request.getAttribute("planesLabelsJson");
    String planesDataJson = (String) request.getAttribute("planesDataJson");
    String productosSalidaLabelsJson = (String) request.getAttribute("productosSalidaLabelsJson");
    String productosSalidaDataJson = (String) request.getAttribute("productosSalidaDataJson");
    // Reportes adicionales
    String distritosLabelsJson = (String) request.getAttribute("distritosLabelsJson");
    String distritosDataJson = (String) request.getAttribute("distritosDataJson");
    String ordenesEstadoLabelsJson = (String) request.getAttribute("ordenesEstadoLabelsJson");
    String ordenesEstadoDataJson = (String) request.getAttribute("ordenesEstadoDataJson");
    String tendenciasLabelsJson = (String) request.getAttribute("tendenciasLabelsJson");
    String tendenciasDataJson = (String) request.getAttribute("tendenciasDataJson");
    // Nuevos reportes funcionales
    String zonasLabelsJson = (String) request.getAttribute("zonasLabelsJson");
    String zonasDataJson = (String) request.getAttribute("zonasDataJson");
    String vehiculosLabelsJson = (String) request.getAttribute("vehiculosLabelsJson");
    String vehiculosDataJson = (String) request.getAttribute("vehiculosDataJson");
    String productosSolicitadosLabelsJson = (String) request.getAttribute("productosSolicitadosLabelsJson");
    String productosSolicitadosDataJson = (String) request.getAttribute("productosSolicitadosDataJson");
    String comparativaLabelsJson = (String) request.getAttribute("comparativaLabelsJson");
    String comparativaDataJson = (String) request.getAttribute("comparativaDataJson");
%>

<!doctype html>
<html lang="es">
<head>
  <jsp:include page="/administrador/layouts/head.jsp">
      <jsp:param name="pageTitle" value="Reporte de Logística"/>
  </jsp:include>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    /* Estilos profesionales para el reporte */
    .page-title {
        color: #17a2b8;
        font-weight: 700;
        font-size: 1.8rem;
        margin-bottom: 30px;
        padding-bottom: 15px;
        border-bottom: 3px solid #17a2b8;
        display: flex;
        align-items: center;
    }
    
    .page-title i {
        margin-right: 15px;
        font-size: 2rem;
    }
    
    .charts-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
        gap: 25px;
        margin-bottom: 40px;
    }
    
    .card {
        background: #ffffff;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(23, 162, 184, 0.12);
        padding: 25px;
        transition: all 0.3s ease;
        border: 2px solid transparent;
    }
    
    .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 30px rgba(23, 162, 184, 0.2);
        border-color: #17a2b8;
    }
    
    .card-title {
        color: #2b2d42;
        font-weight: 700;
        font-size: 1.1rem;
        margin-bottom: 20px;
        padding-bottom: 12px;
        border-bottom: 2px solid #e9ecef;
        display: flex;
        align-items: center;
    }
    
    .card-title::before {
        content: '';
        width: 4px;
        height: 24px;
        background: linear-gradient(135deg, #17a2b8 0%, #20c997 100%);
        margin-right: 12px;
        border-radius: 2px;
    }
    
    .chart-container {
        position: relative;
        height: 350px;
        padding: 10px;
    }
    
    @media (max-width: 1200px) {
        .charts-grid {
            grid-template-columns: 1fr;
        }
    }
    
    @media (max-width: 768px) {
        .chart-container {
            height: 300px;
        }
        
        .page-title {
            font-size: 1.4rem;
        }
        
        .card {
            padding: 20px;
        }
    }
  </style>
</head>
<body>
<div class="dashboard-main-wrapper">
    <jsp:include page="/administrador/layouts/sidebar_admin.jsp">
        <jsp:param name="activeMenu" value="Reportes"/>
    </jsp:include>
    <jsp:include page="/administrador/layouts/header_admin.jsp" />
    <div class="dashboard-wrapper">
        <div class="dashboard-content">
            <h1 class="page-title"><i class="fas fa-chart-line"></i> Reporte de Logística</h1>
            <div class="charts-grid">
                <div class="card">
                    <h5 class="card-title">Estado de los Planes de Transporte</h5>
                    <div class="chart-container">
                        <canvas id="planesTransporteChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Productos con Mayor Movimiento de Salida</h5>
                    <div class="chart-container">
                        <canvas id="productosSalidaChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Distribución de Planes por Distrito</h5>
                    <div class="chart-container">
                        <canvas id="distritosChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Órdenes de Compra por Estado</h5>
                    <div class="chart-container">
                        <canvas id="ordenesEstadoChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Tendencias de Planes de Transporte (Últimos 6 Meses)</h5>
                    <div class="chart-container">
                        <canvas id="tendenciasChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Distribución de Planes por Zona Geográfica</h5>
                    <div class="chart-container">
                        <canvas id="zonasChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Vehículos Más Utilizados</h5>
                    <div class="chart-container">
                        <canvas id="vehiculosChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Productos Más Solicitados en Órdenes de Compra</h5>
                    <div class="chart-container">
                        <canvas id="productosSolicitadosChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Comparativa: Planes Pendientes vs Completados</h5>
                    <div class="chart-container">
                        <canvas id="comparativaChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/administrador/layouts/footer.jsp" />
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const sidebarToggle = document.getElementById('sidebar-toggle');
        const sidebar = document.getElementById('sidebar');
        const content = document.getElementById('content');
        const header = document.getElementById('header');

        if (sidebarToggle && sidebar && content && header) {
            sidebarToggle.addEventListener('click', () => {
                sidebar.classList.toggle('hidden');
                content.classList.toggle('full-width');
                header.classList.toggle('full-width');
            });
        }

        // Colores profesionales con gradientes
        const TELITO_COLORS = {
            blue: ['rgba(23, 162, 184, 0.9)', 'rgba(32, 201, 151, 0.9)'],
            green: ['rgba(40, 167, 69, 0.9)', 'rgba(32, 201, 151, 0.9)'],
            yellow: ['rgba(255, 193, 7, 0.9)', 'rgba(253, 126, 20, 0.9)'],
            red: ['rgba(220, 53, 69, 0.9)', 'rgba(253, 126, 20, 0.9)'],
            purple: ['rgba(108, 99, 255, 0.9)', 'rgba(153, 102, 255, 0.9)'],
            grey: ['rgba(108, 117, 125, 0.9)', 'rgba(173, 181, 189, 0.9)']
        };

        // Configuración global mejorada
        Chart.defaults.font.family = "'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', sans-serif";
        Chart.defaults.font.size = 13;
        Chart.defaults.color = '#2b2d42';

        try {
            const planesLabels = JSON.parse('<%= planesLabelsJson != null ? planesLabelsJson : "[]" %>');
            const planesData = JSON.parse('<%= planesDataJson != null ? planesDataJson : "[]" %>');

            new Chart(document.getElementById('planesTransporteChart'), {
                type: 'doughnut',
                data: {
                    labels: planesLabels,
                    datasets: [{
                        data: planesData,
                        backgroundColor: [
                            'rgba(40, 167, 69, 0.85)',
                            'rgba(255, 193, 7, 0.85)',
                            'rgba(23, 162, 184, 0.85)',
                            'rgba(220, 53, 69, 0.85)'
                        ],
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        hoverOffset: 15,
                        hoverBorderWidth: 3,
                        hoverBorderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '60%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                font: { size: 14, weight: '600' },
                                padding: 20,
                                usePointStyle: true,
                                pointStyle: 'circle',
                                color: '#2b2d42'
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#17a2b8',
                            borderWidth: 2,
                            displayColors: true,
                            callbacks: {
                                label: function(context) {
                                    let label = context.label || '';
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = ((context.parsed / total) * 100).toFixed(1);
                                    return label + ': ' + context.parsed + ' (' + percentage + '%)';
                                }
                            }
                        }
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true,
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 1 (Planes):", e); }

        try {
            const productosSalidaLabels = JSON.parse('<%= productosSalidaLabelsJson != null ? productosSalidaLabelsJson : "[]" %>');
            const productosSalidaData = JSON.parse('<%= productosSalidaDataJson != null ? productosSalidaDataJson : "[]" %>');

            const ctx2 = document.getElementById('productosSalidaChart').getContext('2d');
            const gradientBar = ctx2.createLinearGradient(0, 0, ctx2.canvas.width, 0);
            gradientBar.addColorStop(0, 'rgba(23, 162, 184, 0.9)');
            gradientBar.addColorStop(1, 'rgba(32, 201, 151, 0.9)');

            new Chart(ctx2, {
                type: 'bar',
                data: {
                    labels: productosSalidaLabels,
                    datasets: [{
                        label: 'Cantidad de Salidas',
                        data: productosSalidaData,
                        backgroundColor: gradientBar,
                        borderColor: 'rgba(23, 162, 184, 1)',
                        borderWidth: 2,
                        borderRadius: 8,
                        borderSkipped: false,
                        hoverBackgroundColor: 'rgba(23, 162, 184, 1)',
                        hoverBorderWidth: 3
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#17a2b8',
                            borderWidth: 2,
                            callbacks: {
                                label: function(context) {
                                    return 'Salidas: ' + context.raw.toLocaleString() + ' unidades';
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)',
                                drawBorder: false,
                                lineWidth: 1
                            },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        },
                        y: {
                            grid: { display: false },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        }
                    },
                    animation: {
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 2 (Salida):", e); }

        // ========== GRÁFICO 5: Distribución de Planes por Distrito ==========
        try {
            const distritosLabels = JSON.parse('<%= distritosLabelsJson != null ? distritosLabelsJson : "[]" %>');
            const distritosData = JSON.parse('<%= distritosDataJson != null ? distritosDataJson : "[]" %>');

            const ctx5 = document.getElementById('distritosChart').getContext('2d');
            const gradientOrange = ctx5.createLinearGradient(0, 0, ctx5.canvas.width, 0);
            gradientOrange.addColorStop(0, 'rgba(255, 159, 64, 0.9)');
            gradientOrange.addColorStop(1, 'rgba(255, 99, 71, 0.9)');

            new Chart(ctx5, {
                type: 'bar',
                data: {
                    labels: distritosLabels,
                    datasets: [{
                        label: 'Planes de Transporte',
                        data: distritosData,
                        backgroundColor: gradientOrange,
                        borderColor: 'rgba(255, 159, 64, 1)',
                        borderWidth: 2,
                        borderRadius: 8,
                        borderSkipped: false,
                        hoverBackgroundColor: 'rgba(255, 159, 64, 1)',
                        hoverBorderWidth: 3
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#ff9f40',
                            borderWidth: 2,
                            callbacks: {
                                label: function(context) {
                                    return 'Planes: ' + context.raw.toLocaleString();
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)',
                                drawBorder: false,
                                lineWidth: 1
                            },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        },
                        y: {
                            grid: { display: false },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        }
                    },
                    animation: {
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 5 (Distritos):", e); }

        // ========== GRÁFICO 6: Órdenes de Compra por Estado ==========
        try {
            const ordenesEstadoLabels = JSON.parse('<%= ordenesEstadoLabelsJson != null ? ordenesEstadoLabelsJson : "[]" %>');
            const ordenesEstadoData = JSON.parse('<%= ordenesEstadoDataJson != null ? ordenesEstadoDataJson : "[]" %>');

            new Chart(document.getElementById('ordenesEstadoChart'), {
                type: 'doughnut',
                data: {
                    labels: ordenesEstadoLabels,
                    datasets: [{
                        data: ordenesEstadoData,
                        backgroundColor: [
                            'rgba(255, 193, 7, 0.85)',
                            'rgba(23, 162, 184, 0.85)',
                            'rgba(40, 167, 69, 0.85)',
                            'rgba(220, 53, 69, 0.85)',
                            'rgba(108, 117, 125, 0.85)',
                            'rgba(255, 159, 64, 0.85)'
                        ],
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        hoverOffset: 15,
                        hoverBorderWidth: 3,
                        hoverBorderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '60%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                font: { size: 14, weight: '600' },
                                padding: 20,
                                usePointStyle: true,
                                pointStyle: 'circle',
                                color: '#2b2d42'
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#17a2b8',
                            borderWidth: 2,
                            displayColors: true,
                            callbacks: {
                                label: function(context) {
                                    let label = context.label || '';
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = ((context.parsed / total) * 100).toFixed(1);
                                    return label + ': ' + context.parsed + ' (' + percentage + '%)';
                                }
                            }
                        }
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true,
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 6 (Órdenes Estado):", e); }

        // ========== GRÁFICO 7: Tendencias de Planes de Transporte ==========
        try {
            const tendenciasLabels = JSON.parse('<%= tendenciasLabelsJson != null ? tendenciasLabelsJson : "[]" %>');
            const tendenciasData = JSON.parse('<%= tendenciasDataJson != null ? tendenciasDataJson : "[]" %>');

            const ctx7 = document.getElementById('tendenciasChart').getContext('2d');
            const gradientTeal = ctx7.createLinearGradient(0, 0, 0, ctx7.canvas.height);
            gradientTeal.addColorStop(0, 'rgba(0, 168, 150, 0.7)');
            gradientTeal.addColorStop(0.5, 'rgba(0, 168, 150, 0.4)');
            gradientTeal.addColorStop(1, 'rgba(0, 168, 150, 0.1)');

            new Chart(ctx7, {
                type: 'line',
                data: {
                    labels: tendenciasLabels,
                    datasets: [{
                        label: 'Planes de Transporte',
                        data: tendenciasData,
                        fill: true,
                        backgroundColor: gradientTeal,
                        borderColor: 'rgba(0, 168, 150, 1)',
                        borderWidth: 3,
                        tension: 0.4,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: 'rgba(0, 168, 150, 1)',
                        pointBorderWidth: 3,
                        pointRadius: 6,
                        pointHoverRadius: 9,
                        pointHoverBackgroundColor: 'rgba(0, 168, 150, 1)',
                        pointHoverBorderColor: '#ffffff',
                        pointHoverBorderWidth: 3
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false
                    },
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#00a896',
                            borderWidth: 2,
                            callbacks: {
                                label: function(context) {
                                    return 'Planes: ' + context.raw.toLocaleString();
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)',
                                drawBorder: false,
                                lineWidth: 1
                            },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        },
                        x: {
                            grid: { display: false },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        }
                    },
                    animation: {
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 7 (Tendencias):", e); }

        // ========== GRÁFICO 8: Distribución de Planes por Zona Geográfica ==========
        try {
            const zonasLabels = JSON.parse('<%= zonasLabelsJson != null ? zonasLabelsJson : "[]" %>');
            const zonasData = JSON.parse('<%= zonasDataJson != null ? zonasDataJson : "[]" %>');

            new Chart(document.getElementById('zonasChart'), {
                type: 'doughnut',
                data: {
                    labels: zonasLabels,
                    datasets: [{
                        data: zonasData,
                        backgroundColor: [
                            'rgba(23, 162, 184, 0.85)',
                            'rgba(40, 167, 69, 0.85)',
                            'rgba(255, 193, 7, 0.85)',
                            'rgba(220, 53, 69, 0.85)'
                        ],
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        hoverOffset: 15,
                        hoverBorderWidth: 3,
                        hoverBorderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '60%',
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                font: { size: 14, weight: '600' },
                                padding: 20,
                                usePointStyle: true,
                                pointStyle: 'circle',
                                color: '#2b2d42'
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#17a2b8',
                            borderWidth: 2,
                            displayColors: true,
                            callbacks: {
                                label: function(context) {
                                    let label = context.label || '';
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = ((context.parsed / total) * 100).toFixed(1);
                                    return label + ': ' + context.parsed + ' planes (' + percentage + '%)';
                                }
                            }
                        }
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true,
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 8 (Zonas):", e); }

        // ========== GRÁFICO 9: Vehículos Más Utilizados ==========
        try {
            const vehiculosLabels = JSON.parse('<%= vehiculosLabelsJson != null ? vehiculosLabelsJson : "[]" %>');
            const vehiculosData = JSON.parse('<%= vehiculosDataJson != null ? vehiculosDataJson : "[]" %>');

            const ctx9 = document.getElementById('vehiculosChart').getContext('2d');
            const gradientBlue = ctx9.createLinearGradient(0, 0, ctx9.canvas.width, 0);
            gradientBlue.addColorStop(0, 'rgba(23, 162, 184, 0.9)');
            gradientBlue.addColorStop(1, 'rgba(0, 123, 255, 0.9)');

            new Chart(ctx9, {
                type: 'bar',
                data: {
                    labels: vehiculosLabels,
                    datasets: [{
                        label: 'Planes Asignados',
                        data: vehiculosData,
                        backgroundColor: gradientBlue,
                        borderColor: 'rgba(23, 162, 184, 1)',
                        borderWidth: 2,
                        borderRadius: 8,
                        borderSkipped: false,
                        hoverBackgroundColor: 'rgba(23, 162, 184, 1)',
                        hoverBorderWidth: 3
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#17a2b8',
                            borderWidth: 2,
                            callbacks: {
                                label: function(context) {
                                    return 'Planes: ' + context.raw.toLocaleString();
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)',
                                drawBorder: false,
                                lineWidth: 1
                            },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        },
                        y: {
                            grid: { display: false },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        }
                    },
                    animation: {
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 9 (Vehículos):", e); }

        // ========== GRÁFICO 10: Productos Más Solicitados en Órdenes de Compra ==========
        try {
            const productosSolicitadosLabels = JSON.parse('<%= productosSolicitadosLabelsJson != null ? productosSolicitadosLabelsJson : "[]" %>');
            const productosSolicitadosData = JSON.parse('<%= productosSolicitadosDataJson != null ? productosSolicitadosDataJson : "[]" %>');

            const ctx10 = document.getElementById('productosSolicitadosChart').getContext('2d');
            const gradientPink = ctx10.createLinearGradient(0, 0, 0, ctx10.canvas.height);
            gradientPink.addColorStop(0, 'rgba(255, 99, 132, 0.9)');
            gradientPink.addColorStop(1, 'rgba(255, 159, 64, 0.7)');

            new Chart(ctx10, {
                type: 'bar',
                data: {
                    labels: productosSolicitadosLabels,
                    datasets: [{
                        label: 'Órdenes de Compra',
                        data: productosSolicitadosData,
                        backgroundColor: gradientPink,
                        borderColor: 'rgba(255, 99, 132, 1)',
                        borderWidth: 2,
                        borderRadius: 8,
                        borderSkipped: false,
                        hoverBackgroundColor: 'rgba(255, 99, 132, 1)',
                        hoverBorderWidth: 3
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#ff6384',
                            borderWidth: 2,
                            callbacks: {
                                label: function(context) {
                                    return 'Órdenes: ' + context.raw.toLocaleString();
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: {
                                color: 'rgba(0, 0, 0, 0.05)',
                                drawBorder: false,
                                lineWidth: 1
                            },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        },
                        y: {
                            grid: { display: false },
                            ticks: {
                                font: { size: 13, weight: '600' },
                                color: '#2b2d42'
                            }
                        }
                    },
                    animation: {
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 10 (Productos Solicitados):", e); }

        // ========== GRÁFICO 11: Comparativa Planes Pendientes vs Completados ==========
        try {
            const comparativaLabels = JSON.parse('<%= comparativaLabelsJson != null ? comparativaLabelsJson : "[]" %>');
            const comparativaData = JSON.parse('<%= comparativaDataJson != null ? comparativaDataJson : "[]" %>');

            new Chart(document.getElementById('comparativaChart'), {
                type: 'pie',
                data: {
                    labels: comparativaLabels,
                    datasets: [{
                        data: comparativaData,
                        backgroundColor: [
                            'rgba(255, 193, 7, 0.85)',
                            'rgba(40, 167, 69, 0.85)',
                            'rgba(23, 162, 184, 0.85)',
                            'rgba(108, 117, 125, 0.85)'
                        ],
                        borderColor: '#ffffff',
                        borderWidth: 3,
                        hoverOffset: 15,
                        hoverBorderWidth: 3,
                        hoverBorderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                font: { size: 14, weight: '600' },
                                padding: 20,
                                usePointStyle: true,
                                pointStyle: 'circle',
                                color: '#2b2d42'
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(43, 45, 66, 0.95)',
                            titleFont: { size: 15, weight: 'bold' },
                            bodyFont: { size: 14 },
                            padding: 15,
                            cornerRadius: 8,
                            borderColor: '#ffc107',
                            borderWidth: 2,
                            displayColors: true,
                            callbacks: {
                                label: function(context) {
                                    let label = context.label || '';
                                    const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    const percentage = ((context.parsed / total) * 100).toFixed(1);
                                    return label + ': ' + context.parsed + ' planes (' + percentage + '%)';
                                }
                            }
                        }
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true,
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 11 (Comparativa):", e); }

    });
</script>
</body>
</html>
