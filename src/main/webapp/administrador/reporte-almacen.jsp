<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reporte de Almacén – Telito Bodeguero</title>
  
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/administrador/assets/css/style.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
  <div class="topbar">
    <div class="topbar-brand"><i class="fas fa-warehouse"></i> Telito Bodeguero</div>
    <div class="topbar-actions"><div class="user-avatar">TB</div></div>
  </div>

  <aside class="sidebar" id="sidebar">
      <div class="sidebar-menu-title">Menu</div>
      <nav>
          <a href="<%= request.getContextPath() %>/inicio"><i class="fas fa-home fa-fw"></i> Pestaña principal</a>
          <a href="<%= request.getContextPath() %>/UsuarioServlet"><i class="fas fa-users fa-fw"></i> Gestión de Usuarios</a>
          <a href="<%= request.getContextPath() %>/ProductoServlet?action=listarInventario"><i class="fas fa-boxes-stacked fa-fw"></i> Inventario General</a>
          <a href="<%= request.getContextPath() %>/administrador/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
          <a href="<%= request.getContextPath() %>/administrador/reportes-globales.jsp" class="active"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
          <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>
    
  <main class="content" id="content">
    <h1 class="page-title"><i class="fas fa-pallet"></i> Reporte de Almacén</h1>
    <div class="charts-grid">
      <div class="card">
        <h5 class="card-title">Movimientos del Día</h5>
        <div class="chart-container">
            <canvas id="movimientosDiaChart"></canvas>
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
  </main>

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
          orange: 'rgba(255, 159, 64, 0.8)',
          grey: 'rgba(201, 203, 207, 0.8)'
      };

      // --- GRÁFICO 1 MEJORADO ---
      try {
        const movLabels = JSON.parse('<%= request.getAttribute("movimientosLabelsJson") != null ? request.getAttribute("movimientosLabelsJson") : "[]" %>');
        const movData = JSON.parse('<%= request.getAttribute("movimientosDataJson") != null ? request.getAttribute("movimientosDataJson") : "[]" %>');
        new Chart(document.getElementById('movimientosDiaChart'), {
            type: 'pie',
            data: { labels: movLabels, datasets: [{ data: movData, backgroundColor: [ TELITO_COLORS.green, TELITO_COLORS.red, TELITO_COLORS.yellow ], borderColor: '#fff', borderWidth: 2, hoverOffset: 8 }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 13, family: "\'Segoe UI\', \'Roboto\', \'Helvetica Neue\', \'Arial\', sans-serif" }, padding: 20, usePointStyle: true, pointStyle: 'circle' } }, tooltip: { backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4, callbacks: { label: function(context) { let label = context.label || ''; if (label) { label += ': '; } if (context.parsed !== null) { label += context.parsed + ' Movimientos'; } return label; } } } }, animation: { animateScale: true, animateRotate: true } }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 1 (Almacén):", e); }

      // --- GRÁFICO 2 MEJORADO ---
      try {
        const topProductosLabels = JSON.parse('<%= request.getAttribute("topProductosLabelsJson") != null ? request.getAttribute("topProductosLabelsJson") : "[]" %>');
        const topProductosData = JSON.parse('<%= request.getAttribute("topProductosDataJson") != null ? request.getAttribute("topProductosDataJson") : "[]" %>');
        const ctx2 = document.getElementById('topProductosStockChart').getContext('2d');
        const gradientGreen = ctx2.createLinearGradient(0, 0, ctx2.canvas.clientWidth, 0);
        gradientGreen.addColorStop(0, 'rgba(75, 192, 192, 0.7)');
        gradientGreen.addColorStop(1, 'rgba(75, 192, 192, 0.9)');
        new Chart(ctx2, {
            type: 'bar',
            data: { labels: topProductosLabels, datasets: [{ label: 'Unidades en Stock', data: topProductosData, backgroundColor: gradientGreen, borderColor: 'rgba(75, 192, 192, 1)', borderWidth: 1, borderRadius: 4, borderSkipped: false }] },
            options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false }, tooltip: { backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4, callbacks: { label: function(context) { return context.raw + ' Unidades'; } } } }, scales: { x: { grid: { color: '#e9e9e9', drawBorder: false } }, y: { grid: { display: false } } } }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 2 (Almacén):", e); }
      
      // --- GRÁFICO 3 MEJORADO ---
      try {
        const ajustesLabels = JSON.parse('<%= request.getAttribute("ajustesLabelsJson") != null ? request.getAttribute("ajustesLabelsJson") : "[]" %>');
        const ajustesData = JSON.parse('<%= request.getAttribute("ajustesDataJson") != null ? request.getAttribute("ajustesDataJson") : "[]" %>');
        new Chart(document.getElementById('ajustesChart'), {
            type: 'doughnut',
            data: { labels: ajustesLabels, datasets: [{ data: ajustesData, backgroundColor: [ TELITO_COLORS.orange, TELITO_COLORS.yellow, TELITO_COLORS.purple, TELITO_COLORS.grey ], borderColor: '#fff', borderWidth: 2, hoverOffset: 8 }] },
            options: { responsive: true, maintainAspectRatio: false, cutout: '65%', plugins: { legend: { position: 'bottom', labels: { font: { size: 13, family: "\'Segoe UI\', \'Roboto\', \'Helvetica Neue\', \'Arial\', sans-serif" }, padding: 20, usePointStyle: true, pointStyle: 'circle' } }, tooltip: { backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4, callbacks: { label: function(context) { let label = context.label || ''; if (label) { label += ': '; } if (context.parsed !== null) { label += context.parsed + ' Ajustes'; } return label; } } } }, animation: { animateScale: true, animateRotate: true } }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 3 (Almacén):", e); }
      
      // --- GRÁFICO 4 MEJORADO ---
      try {
        const actividadLabels = JSON.parse('<%= request.getAttribute("actividadLabelsJson") != null ? request.getAttribute("actividadLabelsJson") : "[]" %>');
        const actividadEntradas = JSON.parse('<%= request.getAttribute("actividadEntradasJson") != null ? request.getAttribute("actividadEntradasJson") : "[]" %>');
        const actividadSalidas = JSON.parse('<%= request.getAttribute("actividadSalidasJson") != null ? request.getAttribute("actividadSalidasJson") : "[]" %>');
        const ctx4 = document.getElementById('actividadDiariaChart').getContext('2d');
        const gradientGreenLine = ctx4.createLinearGradient(0, 0, 0, ctx4.canvas.clientHeight);
        gradientGreenLine.addColorStop(0, 'rgba(75, 192, 192, 0.6)');
        gradientGreenLine.addColorStop(1, 'rgba(75, 192, 192, 0.1)');
        const gradientRedLine = ctx4.createLinearGradient(0, 0, 0, ctx4.canvas.clientHeight);
        gradientRedLine.addColorStop(0, 'rgba(255, 99, 132, 0.6)');
        gradientRedLine.addColorStop(1, 'rgba(255, 99, 132, 0.1)');
        new Chart(ctx4, {
            type: 'line',
            data: {
                labels: actividadLabels,
                datasets: [
                    { label: 'Entradas', data: actividadEntradas, fill: true, backgroundColor: gradientGreenLine, borderColor: 'rgba(75, 192, 192, 1)', borderWidth: 2, tension: 0.4, pointBackgroundColor: 'rgba(75, 192, 192, 1)', pointRadius: 3, pointHoverRadius: 6 },
                    { label: 'Salidas', data: actividadSalidas, fill: true, backgroundColor: gradientRedLine, borderColor: 'rgba(255, 99, 132, 1)', borderWidth: 2, tension: 0.4, pointBackgroundColor: 'rgba(255, 99, 132, 1)', pointRadius: 3, pointHoverRadius: 6 }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'top', align: 'end', labels: { font: { size: 13, family: "\'Segoe UI\', \'Roboto\', \'Helvetica Neue\', \'Arial\', sans-serif" }, usePointStyle: true, pointStyle: 'circle' } },
                    tooltip: { mode: 'index', intersect: false, backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4 }
                },
                scales: { y: { beginAtZero: true, grid: { color: '#e9e9e9', drawBorder: false } }, x: { grid: { display: false } } }
            }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 4 (Almacén):", e); }

    });
  </script>
</body>
</html>
