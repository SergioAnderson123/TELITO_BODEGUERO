<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Preparación de datos para JavaScript --%>
<% 
    String planesLabelsJson = (String) request.getAttribute("planesLabelsJson");
    String planesDataJson = (String) request.getAttribute("planesDataJson");
    String productosSalidaLabelsJson = (String) request.getAttribute("productosSalidaLabelsJson");
    String productosSalidaDataJson = (String) request.getAttribute("productosSalidaDataJson");
    String conductoresLabelsJson = (String) request.getAttribute("conductoresLabelsJson");
    String conductoresDataJson = (String) request.getAttribute("conductoresDataJson");
    String pedidosMesLabelsJson = (String) request.getAttribute("pedidosMesLabelsJson");
    String pedidosMesDataJson = (String) request.getAttribute("pedidosMesDataJson");
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
                    <h5 class="card-title">Rendimiento de Conductores (Entregas)</h5>
                    <div class="chart-container">
                        <canvas id="conductoresChart"></canvas>
                    </div>
                </div>
                <div class="card">
                    <h5 class="card-title">Historial de Pedidos Despachados</h5>
                    <div class="chart-container">
                        <canvas id="pedidosMesChart"></canvas>
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

        try {
            const conductoresLabels = JSON.parse('<%= conductoresLabelsJson != null ? conductoresLabelsJson : "[]" %>');
            const conductoresData = JSON.parse('<%= conductoresDataJson != null ? conductoresDataJson : "[]" %>');

            const ctx3 = document.getElementById('conductoresChart').getContext('2d');
            const gradientGreen = ctx3.createLinearGradient(0, 0, 0, ctx3.canvas.height);
            gradientGreen.addColorStop(0, 'rgba(40, 167, 69, 0.95)');
            gradientGreen.addColorStop(1, 'rgba(32, 201, 151, 0.7)');

            new Chart(ctx3, {
                type: 'bar',
                data: {
                    labels: conductoresLabels,
                    datasets: [{
                        label: 'Entregas Realizadas',
                        data: conductoresData,
                        backgroundColor: gradientGreen,
                        borderColor: 'rgba(40, 167, 69, 1)',
                        borderWidth: 2,
                        borderRadius: 8,
                        borderSkipped: false,
                        hoverBackgroundColor: 'rgba(40, 167, 69, 1)',
                        hoverBorderWidth: 3
                    }]
                },
                options: {
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
                            borderColor: '#28a745',
                            borderWidth: 2,
                            callbacks: {
                                label: function(context) {
                                    return 'Entregas: ' + context.raw.toLocaleString() + ' realizadas';
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
                                color: '#2b2d42',
                                maxRotation: 45,
                                minRotation: 0
                            }
                        }
                    },
                    animation: {
                        duration: 1500,
                        easing: 'easeInOutQuart'
                    }
                }
            });
        } catch (e) { console.error("Error al renderizar el Gráfico 3 (Conductores):", e); }

        try {
            const pedidosMesLabels = JSON.parse('<%= pedidosMesLabelsJson != null ? pedidosMesLabelsJson : "[]" %>');
            const pedidosMesData = JSON.parse('<%= pedidosMesDataJson != null ? pedidosMesDataJson : "[]" %>');

            const ctx4 = document.getElementById('pedidosMesChart').getContext('2d');
            const gradientPurple = ctx4.createLinearGradient(0, 0, 0, ctx4.canvas.height);
            gradientPurple.addColorStop(0, 'rgba(108, 99, 255, 0.7)');
            gradientPurple.addColorStop(0.5, 'rgba(153, 102, 255, 0.4)');
            gradientPurple.addColorStop(1, 'rgba(153, 102, 255, 0.1)');

            new Chart(ctx4, {
                type: 'line',
                data: {
                    labels: pedidosMesLabels,
                    datasets: [{
                        label: 'Pedidos Despachados',
                        data: pedidosMesData,
                        fill: true,
                        backgroundColor: gradientPurple,
                        borderColor: 'rgba(108, 99, 255, 1)',
                        borderWidth: 3,
                        tension: 0.4,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: 'rgba(108, 99, 255, 1)',
                        pointBorderWidth: 3,
                        pointRadius: 5,
                        pointHoverRadius: 8,
                        pointHoverBackgroundColor: 'rgba(108, 99, 255, 1)',
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
                            borderColor: '#6c63ff',
                            borderWidth: 2,
                            callbacks: {
                                label: function(context) {
                                    return 'Despachados: ' + context.raw.toLocaleString() + ' pedidos';
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
        } catch (e) { console.error("Error al renderizar el Gráfico 4 (Pedidos):", e); }

    });
</script>
</body>
</html>
