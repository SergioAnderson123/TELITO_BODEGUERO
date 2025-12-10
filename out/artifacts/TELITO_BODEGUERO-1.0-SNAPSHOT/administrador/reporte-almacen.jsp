<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Reporte de Almacén"/>
    </jsp:include>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Estilos profesionales para el reporte */
        .page-title {
            color: #ffc107;
            font-weight: 700;
            font-size: 1.8rem;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #ffc107;
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
            box-shadow: 0 4px 20px rgba(255, 193, 7, 0.12);
            padding: 25px;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 30px rgba(255, 193, 7, 0.2);
            border-color: #ffc107;
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
            background: linear-gradient(135deg, #ffc107 0%, #fd7e14 100%);
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
    <h1 class="page-title"><i class="fas fa-pallet"></i> Reporte de Almacén</h1>
    <div class="charts-grid">
      <div class="card">
        <h5 class="card-title">Movimientos últimos 7 días</h5>
        <div class="chart-container">
            <canvas id="movimientos7dChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Top 5 Productos con Más Stock</h5>
        <div class="chart-container">
            <canvas id="topProductosStockChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Motivos de Ajuste de Inventario</h5>
        <div class="chart-container">
            <canvas id="ajustesChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Actividad de Inventario (Últimos 30 días)</h5>
        <div class="chart-container">
            <canvas id="actividadDiariaChart"></canvas>
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
      
      // Configuración global mejorada
      Chart.defaults.font.family = "'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', sans-serif";
      Chart.defaults.font.size = 13;
      Chart.defaults.color = '#2b2d42';

      // --- GRÁFICO 1: Movimientos últimos 7 días (barras apiladas) ---
      try {
        const m7Labels = JSON.parse('<%= request.getAttribute("mov7dLabelsJson") != null ? request.getAttribute("mov7dLabelsJson") : "[]" %>');
        const m7Entradas = JSON.parse('<%= request.getAttribute("mov7dEntradasJson") != null ? request.getAttribute("mov7dEntradasJson") : "[]" %>');
        const m7Salidas = JSON.parse('<%= request.getAttribute("mov7dSalidasJson") != null ? request.getAttribute("mov7dSalidasJson") : "[]" %>');
        const m7Ajustes = JSON.parse('<%= request.getAttribute("mov7dAjustesJson") != null ? request.getAttribute("mov7dAjustesJson") : "[]" %>');
        
        new Chart(document.getElementById('movimientos7dChart'), {
            type: 'bar',
            data: {
                labels: m7Labels,
                datasets: [
                    {
                        label: 'Entradas',
                        data: m7Entradas,
                        backgroundColor: 'rgba(40, 167, 69, 0.85)',
                        borderColor: 'rgba(40, 167, 69, 1)',
                        borderWidth: 2,
                        borderRadius: 6,
                        stack: 'stack1'
                    },
                    {
                        label: 'Salidas',
                        data: m7Salidas,
                        backgroundColor: 'rgba(220, 53, 69, 0.85)',
                        borderColor: 'rgba(220, 53, 69, 1)',
                        borderWidth: 2,
                        borderRadius: 6,
                        stack: 'stack1'
                    },
                    {
                        label: 'Ajustes',
                        data: m7Ajustes,
                        backgroundColor: 'rgba(255, 193, 7, 0.85)',
                        borderColor: 'rgba(255, 193, 7, 1)',
                        borderWidth: 2,
                        borderRadius: 6,
                        stack: 'stack1'
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            font: { size: 14, weight: '600' },
                            padding: 15,
                            usePointStyle: true,
                            pointStyle: 'circle',
                            color: '#2b2d42'
                        }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        backgroundColor: 'rgba(43, 45, 66, 0.95)',
                        titleFont: { size: 15, weight: 'bold' },
                        bodyFont: { size: 14 },
                        padding: 15,
                        cornerRadius: 8,
                        borderColor: '#ffc107',
                        borderWidth: 2,
                        callbacks: {
                            label: function(context) {
                                return context.dataset.label + ': ' + context.raw.toLocaleString() + ' movimientos';
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        stacked: true,
                        grid: { display: false },
                        ticks: {
                            font: { size: 13, weight: '600' },
                            color: '#2b2d42'
                        }
                    },
                    y: {
                        stacked: true,
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)',
                            drawBorder: false
                        },
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
      } catch (e) { console.error("Error al renderizar el Gráfico 1 (Almacén 7d):", e); }

      // --- GRÁFICO 2: Top 5 Productos con Más Stock ---
      try {
        const topProductosLabels = JSON.parse('<%= request.getAttribute("topProductosLabelsJson") != null ? request.getAttribute("topProductosLabelsJson") : "[]" %>');
        const topProductosData = JSON.parse('<%= request.getAttribute("topProductosDataJson") != null ? request.getAttribute("topProductosDataJson") : "[]" %>');
        const ctx2 = document.getElementById('topProductosStockChart').getContext('2d');
        const gradientOrange = ctx2.createLinearGradient(0, 0, ctx2.canvas.width, 0);
        gradientOrange.addColorStop(0, 'rgba(255, 193, 7, 0.9)');
        gradientOrange.addColorStop(1, 'rgba(253, 126, 20, 0.9)');
        
        new Chart(ctx2, {
            type: 'bar',
            data: {
                labels: topProductosLabels,
                datasets: [{
                    label: 'Unidades en Stock',
                    data: topProductosData,
                    backgroundColor: gradientOrange,
                    borderColor: 'rgba(255, 193, 7, 1)',
                    borderWidth: 2,
                    borderRadius: 8,
                    borderSkipped: false,
                    hoverBackgroundColor: 'rgba(255, 193, 7, 1)',
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
                        borderColor: '#ffc107',
                        borderWidth: 2,
                        callbacks: {
                            label: function(context) {
                                return 'Stock: ' + context.raw.toLocaleString() + ' unidades';
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
      } catch (e) { console.error("Error al renderizar el Gráfico 2 (Almacén):", e); }
      
      // --- GRÁFICO 3: Motivos de Ajuste ---
      try {
        const ajustesLabels = JSON.parse('<%= request.getAttribute("ajustesLabelsJson") != null ? request.getAttribute("ajustesLabelsJson") : "[]" %>');
        const ajustesData = JSON.parse('<%= request.getAttribute("ajustesDataJson") != null ? request.getAttribute("ajustesDataJson") : "[]" %>');
        
        new Chart(document.getElementById('ajustesChart'), {
            type: 'doughnut',
            data: {
                labels: ajustesLabels,
                datasets: [{
                    data: ajustesData,
                    backgroundColor: [
                        'rgba(253, 126, 20, 0.85)',
                        'rgba(255, 193, 7, 0.85)',
                        'rgba(108, 99, 255, 0.85)',
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
                        borderColor: '#ffc107',
                        borderWidth: 2,
                        displayColors: true,
                        callbacks: {
                            label: function(context) {
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((context.parsed / total) * 100).toFixed(1);
                                return context.label + ': ' + context.parsed + ' (' + percentage + '%)';
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
      } catch (e) { console.error("Error al renderizar el Gráfico 3 (Almacén):", e); }
      
      // --- GRÁFICO 4: Actividad Diaria (30 días) ---
      try {
        const actividadLabels = JSON.parse('<%= request.getAttribute("actividadLabelsJson") != null ? request.getAttribute("actividadLabelsJson") : "[]" %>');
        const actividadEntradas = JSON.parse('<%= request.getAttribute("actividadEntradasJson") != null ? request.getAttribute("actividadEntradasJson") : "[]" %>');
        const actividadSalidas = JSON.parse('<%= request.getAttribute("actividadSalidasJson") != null ? request.getAttribute("actividadSalidasJson") : "[]" %>');
        
        const ctx4 = document.getElementById('actividadDiariaChart').getContext('2d');
        const gradientGreenLine = ctx4.createLinearGradient(0, 0, 0, ctx4.canvas.height);
        gradientGreenLine.addColorStop(0, 'rgba(40, 167, 69, 0.6)');
        gradientGreenLine.addColorStop(0.5, 'rgba(40, 167, 69, 0.3)');
        gradientGreenLine.addColorStop(1, 'rgba(40, 167, 69, 0.05)');
        
        const gradientRedLine = ctx4.createLinearGradient(0, 0, 0, ctx4.canvas.height);
        gradientRedLine.addColorStop(0, 'rgba(220, 53, 69, 0.6)');
        gradientRedLine.addColorStop(0.5, 'rgba(220, 53, 69, 0.3)');
        gradientRedLine.addColorStop(1, 'rgba(220, 53, 69, 0.05)');
        
        new Chart(ctx4, {
            type: 'line',
            data: {
                labels: actividadLabels,
                datasets: [
                    {
                        label: 'Entradas',
                        data: actividadEntradas,
                        fill: true,
                        backgroundColor: gradientGreenLine,
                        borderColor: 'rgba(40, 167, 69, 1)',
                        borderWidth: 3,
                        tension: 0.4,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: 'rgba(40, 167, 69, 1)',
                        pointBorderWidth: 3,
                        pointRadius: 4,
                        pointHoverRadius: 7,
                        pointHoverBackgroundColor: 'rgba(40, 167, 69, 1)',
                        pointHoverBorderColor: '#ffffff',
                        pointHoverBorderWidth: 3
                    },
                    {
                        label: 'Salidas',
                        data: actividadSalidas,
                        fill: true,
                        backgroundColor: gradientRedLine,
                        borderColor: 'rgba(220, 53, 69, 1)',
                        borderWidth: 3,
                        tension: 0.4,
                        pointBackgroundColor: '#ffffff',
                        pointBorderColor: 'rgba(220, 53, 69, 1)',
                        pointBorderWidth: 3,
                        pointRadius: 4,
                        pointHoverRadius: 7,
                        pointHoverBackgroundColor: 'rgba(220, 53, 69, 1)',
                        pointHoverBorderColor: '#ffffff',
                        pointHoverBorderWidth: 3
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    legend: {
                        position: 'top',
                        align: 'end',
                        labels: {
                            font: { size: 14, weight: '600' },
                            padding: 15,
                            usePointStyle: true,
                            pointStyle: 'circle',
                            color: '#2b2d42'
                        }
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        backgroundColor: 'rgba(43, 45, 66, 0.95)',
                        titleFont: { size: 15, weight: 'bold' },
                        bodyFont: { size: 14 },
                        padding: 15,
                        cornerRadius: 8,
                        borderColor: '#ffc107',
                        borderWidth: 2,
                        callbacks: {
                            label: function(context) {
                                return context.dataset.label + ': ' + context.raw.toLocaleString() + ' movimientos';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)',
                            drawBorder: false
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
      } catch (e) { console.error("Error al renderizar el Gráfico 4 (Almacén):", e); }

    });
  </script>
</body>
</html>
