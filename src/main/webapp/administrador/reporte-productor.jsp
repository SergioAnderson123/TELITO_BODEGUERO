<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%-- Preparación de datos para JavaScript --%>
<% 
    // Reportes individuales del productor logueado
    String topProductosLabelsJson = (String) request.getAttribute("topProductosLabelsJson");
    String topProductosDataJson = (String) request.getAttribute("topProductosDataJson");
    String valorCategoriaLabelsJson = (String) request.getAttribute("valorCategoriaLabelsJson");
    String valorCategoriaDataJson = (String) request.getAttribute("valorCategoriaDataJson");
    String lotesVencerLabelsJson = (String) request.getAttribute("lotesVencerLabelsJson");
    String lotesVencerDataJson = (String) request.getAttribute("lotesVencerDataJson");
    String lotesUbicacionLabelsJson = (String) request.getAttribute("lotesUbicacionLabelsJson");
    String lotesUbicacionDataJson = (String) request.getAttribute("lotesUbicacionDataJson");
    // Nuevos reportes agregados de TODOS los productores
    String distribucionProductoresLabelsJson = (String) request.getAttribute("distribucionProductoresLabelsJson");
    String distribucionProductoresDataJson = (String) request.getAttribute("distribucionProductoresDataJson");
    String topProductoresStockLabelsJson = (String) request.getAttribute("topProductoresStockLabelsJson");
    String topProductoresStockDataJson = (String) request.getAttribute("topProductoresStockDataJson");
    String productosComunesLabelsJson = (String) request.getAttribute("productosComunesLabelsJson");
    String productosComunesDataJson = (String) request.getAttribute("productosComunesDataJson");
    String ordenesPorProductorLabelsJson = (String) request.getAttribute("ordenesPorProductorLabelsJson");
    String ordenesPorProductorDataJson = (String) request.getAttribute("ordenesPorProductorDataJson");
    String valorInventarioProductoresLabelsJson = (String) request.getAttribute("valorInventarioProductoresLabelsJson");
    String valorInventarioProductoresDataJson = (String) request.getAttribute("valorInventarioProductoresDataJson");
%>

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
      <div class="card">
        <h5 class="card-title">Distribución de Productores por Cantidad de Productos</h5>
        <div class="chart-container">
            <canvas id="distribucionProductoresChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Top Productores por Stock Total</h5>
        <div class="chart-container">
            <canvas id="topProductoresStockChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Productos Más Comunes entre Todos los Productores</h5>
        <div class="chart-container">
            <canvas id="productosComunesChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Distribución de Órdenes de Compra por Productor</h5>
        <div class="chart-container">
            <canvas id="ordenesPorProductorChart"></canvas>
        </div>
      </div>
      <div class="card">
        <h5 class="card-title">Comparativa de Valor de Inventario por Productor</h5>
        <div class="chart-container">
            <canvas id="valorInventarioProductoresChart"></canvas>
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

      // --- GRÁFICO 1: Top 5 Productos con Más Stock (Individual) ---
      try {
        const topProductosLabels = JSON.parse('<%= topProductosLabelsJson != null ? topProductosLabelsJson : "[]" %>');
        const topProductosData = JSON.parse('<%= topProductosDataJson != null ? topProductosDataJson : "[]" %>');
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

      // --- GRÁFICO 2: Valor por Categoría (Individual) ---
      try {
        const valorCategoriaLabels = JSON.parse('<%= valorCategoriaLabelsJson != null ? valorCategoriaLabelsJson : "[]" %>');
        const valorCategoriaData = JSON.parse('<%= valorCategoriaDataJson != null ? valorCategoriaDataJson : "[]" %>');
        
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
      
      // --- GRÁFICO 3: Lotes Próximos a Vencer (Individual) ---
      try {
        const lotesVencerLabels = JSON.parse('<%= lotesVencerLabelsJson != null ? lotesVencerLabelsJson : "[]" %>');
        const lotesVencerData = JSON.parse('<%= lotesVencerDataJson != null ? lotesVencerDataJson : "[]" %>');
        
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
      
      // --- GRÁFICO 4: Distribución por Ubicación (Individual) ---
      try {
        const lotesUbicacionLabels = JSON.parse('<%= lotesUbicacionLabelsJson != null ? lotesUbicacionLabelsJson : "[]" %>');
        const lotesUbicacionData = JSON.parse('<%= lotesUbicacionDataJson != null ? lotesUbicacionDataJson : "[]" %>');
        
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

      // ========== GRÁFICO 5: Distribución de Productores por Cantidad de Productos (TODOS) ==========
      try {
        const distribucionProductoresLabels = JSON.parse('<%= distribucionProductoresLabelsJson != null ? distribucionProductoresLabelsJson : "[]" %>');
        const distribucionProductoresData = JSON.parse('<%= distribucionProductoresDataJson != null ? distribucionProductoresDataJson : "[]" %>');

        const ctx5 = document.getElementById('distribucionProductoresChart').getContext('2d');
        const gradientCyan = ctx5.createLinearGradient(0, 0, ctx5.canvas.width, 0);
        gradientCyan.addColorStop(0, 'rgba(23, 162, 184, 0.9)');
        gradientCyan.addColorStop(1, 'rgba(0, 168, 150, 0.9)');

        new Chart(ctx5, {
            type: 'bar',
            data: {
                labels: distribucionProductoresLabels,
                datasets: [{
                    label: 'Cantidad de Productos',
                    data: distribucionProductoresData,
                    backgroundColor: gradientCyan,
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
                                return 'Productos: ' + context.raw.toLocaleString();
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
      } catch (e) { console.error("Error al renderizar el Gráfico 5 (Distribución Productores):", e); }

      // ========== GRÁFICO 6: Top Productores por Stock Total (TODOS) ==========
      try {
        const topProductoresStockLabels = JSON.parse('<%= topProductoresStockLabelsJson != null ? topProductoresStockLabelsJson : "[]" %>');
        const topProductoresStockData = JSON.parse('<%= topProductoresStockDataJson != null ? topProductoresStockDataJson : "[]" %>');

        const ctx6 = document.getElementById('topProductoresStockChart').getContext('2d');
        const gradientGreen = ctx6.createLinearGradient(0, 0, ctx6.canvas.width, 0);
        gradientGreen.addColorStop(0, 'rgba(40, 167, 69, 0.9)');
        gradientGreen.addColorStop(1, 'rgba(32, 201, 151, 0.9)');

        new Chart(ctx6, {
            type: 'bar',
            data: {
                labels: topProductoresStockLabels,
                datasets: [{
                    label: 'Stock Total',
                    data: topProductoresStockData,
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
      } catch (e) { console.error("Error al renderizar el Gráfico 6 (Top Productores Stock):", e); }

      // ========== GRÁFICO 7: Productos Más Comunes entre Productores (TODOS) ==========
      try {
        const productosComunesLabels = JSON.parse('<%= productosComunesLabelsJson != null ? productosComunesLabelsJson : "[]" %>');
        const productosComunesData = JSON.parse('<%= productosComunesDataJson != null ? productosComunesDataJson : "[]" %>');

        new Chart(document.getElementById('productosComunesChart'), {
            type: 'doughnut',
            data: {
                labels: productosComunesLabels,
                datasets: [{
                    data: productosComunesData,
                    backgroundColor: [
                        'rgba(108, 99, 255, 0.85)',
                        'rgba(23, 162, 184, 0.85)',
                        'rgba(40, 167, 69, 0.85)',
                        'rgba(255, 193, 7, 0.85)',
                        'rgba(253, 126, 20, 0.85)',
                        'rgba(220, 53, 69, 0.85)',
                        'rgba(255, 99, 132, 0.85)',
                        'rgba(153, 102, 255, 0.85)'
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
                        borderColor: '#6c63ff',
                        borderWidth: 2,
                        displayColors: true,
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = ((context.parsed / total) * 100).toFixed(1);
                                return label + ': ' + context.parsed + ' productores (' + percentage + '%)';
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
      } catch (e) { console.error("Error al renderizar el Gráfico 7 (Productos Comunes):", e); }

      // ========== GRÁFICO 8: Distribución de Órdenes de Compra por Productor (TODOS) ==========
      try {
        const ordenesPorProductorLabels = JSON.parse('<%= ordenesPorProductorLabelsJson != null ? ordenesPorProductorLabelsJson : "[]" %>');
        const ordenesPorProductorData = JSON.parse('<%= ordenesPorProductorDataJson != null ? ordenesPorProductorDataJson : "[]" %>');

        const ctx8 = document.getElementById('ordenesPorProductorChart').getContext('2d');
        const gradientPurple = ctx8.createLinearGradient(0, 0, ctx8.canvas.width, 0);
        gradientPurple.addColorStop(0, 'rgba(108, 99, 255, 0.9)');
        gradientPurple.addColorStop(1, 'rgba(153, 102, 255, 0.9)');

        new Chart(ctx8, {
            type: 'bar',
            data: {
                labels: ordenesPorProductorLabels,
                datasets: [{
                    label: 'Órdenes de Compra',
                    data: ordenesPorProductorData,
                    backgroundColor: gradientPurple,
                    borderColor: 'rgba(108, 99, 255, 1)',
                    borderWidth: 2,
                    borderRadius: 8,
                    borderSkipped: false,
                    hoverBackgroundColor: 'rgba(108, 99, 255, 1)',
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
                        borderColor: '#6c63ff',
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
      } catch (e) { console.error("Error al renderizar el Gráfico 8 (Órdenes por Productor):", e); }

      // ========== GRÁFICO 9: Comparativa de Valor de Inventario por Productor (TODOS) ==========
      try {
        const valorInventarioProductoresLabels = JSON.parse('<%= valorInventarioProductoresLabelsJson != null ? valorInventarioProductoresLabelsJson : "[]" %>');
        const valorInventarioProductoresData = JSON.parse('<%= valorInventarioProductoresDataJson != null ? valorInventarioProductoresDataJson : "[]" %>');

        const ctx9 = document.getElementById('valorInventarioProductoresChart').getContext('2d');
        const gradientGold = ctx9.createLinearGradient(0, 0, ctx9.canvas.width, 0);
        gradientGold.addColorStop(0, 'rgba(255, 193, 7, 0.9)');
        gradientGold.addColorStop(1, 'rgba(253, 126, 20, 0.9)');

        new Chart(ctx9, {
            type: 'bar',
            data: {
                labels: valorInventarioProductoresLabels,
                datasets: [{
                    label: 'Valor de Inventario',
                    data: valorInventarioProductoresData,
                    backgroundColor: gradientGold,
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
                                const value = new Intl.NumberFormat('es-PE', { style: 'currency', currency: 'PEN' }).format(context.raw);
                                return 'Valor: ' + value;
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
                            color: '#2b2d42',
                            callback: function(value) {
                                return new Intl.NumberFormat('es-PE', { style: 'currency', currency: 'PEN', notation: 'compact' }).format(value);
                            }
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
      } catch (e) { console.error("Error al renderizar el Gráfico 9 (Valor Inventario Productores):", e); }

    });
  </script>
</body>
</html>
