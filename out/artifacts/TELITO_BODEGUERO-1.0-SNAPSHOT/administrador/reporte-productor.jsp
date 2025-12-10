<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Reporte de Productor"/>
    </jsp:include>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Estilos profesionales para el reporte */
        .page-title {
            color: #28a745;
            font-weight: 700;
            font-size: 1.8rem;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #28a745;
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
            box-shadow: 0 4px 20px rgba(40, 167, 69, 0.12);
            padding: 25px;
            transition: all 0.3s ease;
            border: 2px solid transparent;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 30px rgba(40, 167, 69, 0.2);
            border-color: #28a745;
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
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
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
    <h1 class="page-title"><i class="fas fa-seedling"></i> Reporte de Productor</h1>
    <div class="charts-grid">
      <div class="card">
        <h5 class="card-title">Mis 5 Productos con Más Stock</h5>
        <div class="chart-container">
            <canvas id="topProductosProductorChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Valor de Mi Inventario por Categoría</h5>
        <div class="chart-container">
            <canvas id="valorCategoriaChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Mis Lotes Próximos a Vencer (60 días)</h5>
        <div class="chart-container">
            <canvas id="lotesVencerChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Distribución de Mis Lotes por Ubicación</h5>
        <div class="chart-container">
            <canvas id="lotesUbicacionChart"></canvas>
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

      // --- GRÁFICO 1: Top 5 Productos con Más Stock ---
      try {
        const topProductosLabels = JSON.parse('<%= request.getAttribute("topProductosLabelsJson") != null ? request.getAttribute("topProductosLabelsJson") : "[]" %>');
        const topProductosData = JSON.parse('<%= request.getAttribute("topProductosDataJson") != null ? request.getAttribute("topProductosDataJson") : "[]" %>');
        const ctx1 = document.getElementById('topProductosProductorChart').getContext('2d');
        const gradientGreen = ctx1.createLinearGradient(0, 0, ctx1.canvas.width, 0);
        gradientGreen.addColorStop(0, 'rgba(40, 167, 69, 0.9)');
        gradientGreen.addColorStop(1, 'rgba(32, 201, 151, 0.9)');
        
        new Chart(ctx1, {
            type: 'bar',
            data: {
                labels: topProductosLabels,
                datasets: [{
                    label: 'Unidades en Stock',
                    data: topProductosData,
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
                        borderColor: '#28a745',
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
      } catch (e) { console.error("Error al renderizar el Gráfico 1 (Productor):", e); }

      // --- GRÁFICO 2: Valor por Categoría ---
      try {
        const valorCategoriaLabels = JSON.parse('<%= request.getAttribute("valorCategoriaLabelsJson") != null ? request.getAttribute("valorCategoriaLabelsJson") : "[]" %>');
        const valorCategoriaData = JSON.parse('<%= request.getAttribute("valorCategoriaDataJson") != null ? request.getAttribute("valorCategoriaDataJson") : "[]" %>');
        
        new Chart(document.getElementById('valorCategoriaChart'), {
            type: 'doughnut',
            data: {
                labels: valorCategoriaLabels,
                datasets: [{
                    data: valorCategoriaData,
                    backgroundColor: [
                        'rgba(108, 99, 255, 0.85)',
                        'rgba(23, 162, 184, 0.85)',
                        'rgba(40, 167, 69, 0.85)',
                        'rgba(255, 193, 7, 0.85)',
                        'rgba(253, 126, 20, 0.85)'
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
                        borderColor: '#28a745',
                        borderWidth: 2,
                        displayColors: true,
                        callbacks: {
                            label: function(context) {
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((context.parsed / total) * 100).toFixed(1);
                                const value = new Intl.NumberFormat('es-PE', { style: 'currency', currency: 'PEN' }).format(context.parsed);
                                return context.label + ': ' + value + ' (' + percentage + '%)';
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
      } catch (e) { console.error("Error al renderizar el Gráfico 2 (Productor):", e); }
      
      // --- GRÁFICO 3: Lotes Próximos a Vencer ---
      try {
        const lotesVencerLabels = JSON.parse('<%= request.getAttribute("lotesVencerLabelsJson") != null ? request.getAttribute("lotesVencerLabelsJson") : "[]" %>');
        const lotesVencerData = JSON.parse('<%= request.getAttribute("lotesVencerDataJson") != null ? request.getAttribute("lotesVencerDataJson") : "[]" %>');
        
        const backgroundColors = lotesVencerData.map(dias => {
            if (dias <= 15) return 'rgba(220, 53, 69, 0.85)';
            if (dias <= 30) return 'rgba(253, 126, 20, 0.85)';
            return 'rgba(255, 193, 7, 0.85)';
        });
        
        const borderColors = lotesVencerData.map(dias => {
            if (dias <= 15) return 'rgba(220, 53, 69, 1)';
            if (dias <= 30) return 'rgba(253, 126, 20, 1)';
            return 'rgba(255, 193, 7, 1)';
        });
        
        new Chart(document.getElementById('lotesVencerChart'), {
            type: 'bar',
            data: {
                labels: lotesVencerLabels,
                datasets: [{
                    label: 'Días restantes',
                    data: lotesVencerData,
                    backgroundColor: backgroundColors,
                    borderColor: borderColors,
                    borderWidth: 2,
                    borderRadius: 8,
                    borderSkipped: false
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
                                const dias = context.raw;
                                if (dias === 1) return 'Vence en 1 día';
                                return `Vence en ${dias} días`;
                            },
                            afterLabel: function(context) {
                                const dias = context.raw;
                                if (dias <= 15) return '⚠️ Urgente';
                                if (dias <= 30) return '⚠️ Pronto';
                                return '✓ Normal';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: { display: true, text: 'Días Restantes', font: { size: 14, weight: '600' } },
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
      } catch (e) { console.error("Error al renderizar el Gráfico 3 (Productor):", e); }
      
      // --- GRÁFICO 4: Distribución por Ubicación ---
      try {
        const lotesUbicacionLabels = JSON.parse('<%= request.getAttribute("lotesUbicacionLabelsJson") != null ? request.getAttribute("lotesUbicacionLabelsJson") : "[]" %>');
        const lotesUbicacionData = JSON.parse('<%= request.getAttribute("lotesUbicacionDataJson") != null ? request.getAttribute("lotesUbicacionDataJson") : "[]" %>');
        
        new Chart(document.getElementById('lotesUbicacionChart'), {
            type: 'polarArea',
            data: {
                labels: lotesUbicacionLabels,
                datasets: [{
                    data: lotesUbicacionData,
                    backgroundColor: [
                        'rgba(23, 162, 184, 0.75)',
                        'rgba(40, 167, 69, 0.75)',
                        'rgba(255, 193, 7, 0.75)',
                        'rgba(253, 126, 20, 0.75)',
                        'rgba(108, 99, 255, 0.75)'
                    ],
                    borderWidth: 2,
                    borderColor: '#ffffff'
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
                        borderColor: '#28a745',
                        borderWidth: 2,
                        callbacks: {
                            label: function(context) {
                                return context.label + ': ' + context.parsed.r + ' lotes';
                            }
                        }
                    }
                },
                scales: {
                    r: {
                        grid: { color: 'rgba(0, 0, 0, 0.1)' },
                        ticks: {
                            backdropColor: 'transparent',
                            font: { size: 12, weight: '600' },
                            color: '#2b2d42'
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
      } catch (e) { console.error("Error al renderizar el Gráfico 4 (Productor):", e); }
    });
  </script>
</body>
</html>
