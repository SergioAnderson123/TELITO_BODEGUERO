<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
    <jsp:include page="/administrador/layouts/head.jsp">
        <jsp:param name="pageTitle" value="Reporte de Productor"/>
    </jsp:include>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
      
      // --- Paleta de Colores Profesional ---
      const TELITO_COLORS = {
          blue: 'rgba(54, 162, 235, 0.8)',
          green: 'rgba(75, 192, 192, 0.8)',
          yellow: 'rgba(255, 206, 86, 0.8)',
          red: 'rgba(255, 99, 132, 0.8)',
          purple: 'rgba(153, 102, 255, 0.8)',
          orange: 'rgba(255, 159, 64, 0.8)'
      };

      // --- GRÁFICO 1 MEJORADO ---
      try {
        const topProductosLabels = JSON.parse('<%= request.getAttribute("topProductosLabelsJson") != null ? request.getAttribute("topProductosLabelsJson") : "[]" %>');
        const topProductosData = JSON.parse('<%= request.getAttribute("topProductosDataJson") != null ? request.getAttribute("topProductosDataJson") : "[]" %>');
        const ctx1 = document.getElementById('topProductosProductorChart').getContext('2d');
        const gradientGreen = ctx1.createLinearGradient(0, 0, ctx1.canvas.clientWidth, 0);
        gradientGreen.addColorStop(0, 'rgba(75, 192, 192, 0.7)');
        gradientGreen.addColorStop(1, 'rgba(75, 192, 192, 0.9)');
        new Chart(ctx1, {
            type: 'bar',
            data: { labels: topProductosLabels, datasets: [{ label: 'Unidades en Stock', data: topProductosData, backgroundColor: gradientGreen, borderColor: 'rgba(75, 192, 192, 1)', borderWidth: 1, borderRadius: 4, borderSkipped: false }] },
            options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false }, tooltip: { backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4, callbacks: { label: function(context) { return context.raw + ' Unidades'; } } } }, scales: { x: { grid: { color: '#e9e9e9', drawBorder: false } }, y: { grid: { display: false } } } }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 1 (Productor):", e); }

      // --- GRÁFICO 2 MEJORADO ---
      try {
        const valorCategoriaLabels = JSON.parse('<%= request.getAttribute("valorCategoriaLabelsJson") != null ? request.getAttribute("valorCategoriaLabelsJson") : "[]" %>');
        const valorCategoriaData = JSON.parse('<%= request.getAttribute("valorCategoriaDataJson") != null ? request.getAttribute("valorCategoriaDataJson") : "[]" %>');
        new Chart(document.getElementById('valorCategoriaChart'), {
            type: 'doughnut',
            data: {
                labels: valorCategoriaLabels,
                datasets: [{
                    data: valorCategoriaData,
                    backgroundColor: [ TELITO_COLORS.purple, TELITO_COLORS.blue, TELITO_COLORS.green, TELITO_COLORS.yellow, TELITO_COLORS.orange ],
                    borderColor: '#fff',
                    borderWidth: 2,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: { position: 'bottom', labels: { font: { size: 13, family: "\'Segoe UI\', \'Roboto\', \'Helvetica Neue\', \'Arial\', sans-serif" }, padding: 20, usePointStyle: true, pointStyle: 'circle' } },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.7)',
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 },
                        padding: 12,
                        cornerRadius: 4,
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                if (label) { label += ': '; }
                                if (context.parsed !== null) { label += new Intl.NumberFormat('es-PE', { style: 'currency', currency: 'PEN' }).format(context.raw); }
                                return label;
                            }
                        }
                    }
                },
                animation: { animateScale: true, animateRotate: true }
            }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 2 (Productor):", e); }
      
      // --- GRÁFICO 3 MEJORADO ---
      try {
        const lotesVencerLabels = JSON.parse('<%= request.getAttribute("lotesVencerLabelsJson") != null ? request.getAttribute("lotesVencerLabelsJson") : "[]" %>');
        const lotesVencerData = JSON.parse('<%= request.getAttribute("lotesVencerDataJson") != null ? request.getAttribute("lotesVencerDataJson") : "[]" %>');
        const backgroundColors = lotesVencerData.map(dias => {
            if (dias <= 15) return TELITO_COLORS.red;
            if (dias <= 30) return TELITO_COLORS.orange;
            return TELITO_COLORS.yellow;
        });
        const borderColors = lotesVencerData.map(dias => {
            if (dias <= 15) return 'rgba(255, 99, 132, 1)';
            if (dias <= 30) return 'rgba(255, 159, 64, 1)';
            return 'rgba(255, 206, 86, 1)';
        });
        new Chart(document.getElementById('lotesVencerChart'), {
            type: 'bar',
            data: { labels: lotesVencerLabels, datasets: [{ label: 'Días restantes', data: lotesVencerData, backgroundColor: backgroundColors, borderColor: borderColors, borderWidth: 1, borderRadius: 4 }] },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.7)',
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 },
                        padding: 12,
                        cornerRadius: 4,
                        callbacks: {
                            label: function(context) {
                                const dias = context.raw;
                                if (dias === 1) return 'Vence en 1 día';
                                return `Vence en ${dias} días`;
                            }
                        }
                    }
                },
                scales: { y: { beginAtZero: true, title: { display: true, text: 'Días Restantes' }, grid: { color: '#e9e9e9', drawBorder: false } }, x: { grid: { display: false } } }
            }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 3 (Productor):", e); }
      
      // --- GRÁFICO 4 MEJORADO ---
      try {
        const lotesUbicacionLabels = JSON.parse('<%= request.getAttribute("lotesUbicacionLabelsJson") != null ? request.getAttribute("lotesUbicacionLabelsJson") : "[]" %>');
        const lotesUbicacionData = JSON.parse('<%= request.getAttribute("lotesUbicacionDataJson") != null ? request.getAttribute("lotesUbicacionDataJson") : "[]" %>');
        new Chart(document.getElementById('lotesUbicacionChart'), {
            type: 'polarArea',
            data: {
                labels: lotesUbicacionLabels,
                datasets: [{ data: lotesUbicacionData, backgroundColor: [ TELITO_COLORS.blue, TELITO_COLORS.green, TELITO_COLORS.yellow, TELITO_COLORS.orange, TELITO_COLORS.purple ], borderWidth: 1, borderColor: '#fff' }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { font: { size: 13, family: "'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', sans-serif" }, padding: 20, usePointStyle: true, pointStyle: 'circle' } },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.7)',
                        titleFont: { size: 14, weight: 'bold' },
                        bodyFont: { size: 13 },
                        padding: 12,
                        cornerRadius: 4,
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                if (label) { label += ': '; }
                                if (context.parsed.r !== null) { label += context.parsed.r + ' Lotes'; }
                                return label;
                            }
                        }
                    }
                },
                scales: { r: { grid: { color: '#e9e9e9' }, ticks: { backdropColor: 'transparent' } } },
                animation: { animateScale: true, animateRotate: true }
            }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 4 (Productor):", e); }
    });
  </script>
</body>
</html>
