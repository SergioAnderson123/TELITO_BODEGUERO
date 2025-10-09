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
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reporte de Logística – Telito Bodeguero</title>
  
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
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
          <a href="<%= request.getContextPath() %>/acceso-roles.jsp"><i class="fas fa-user-shield fa-fw"></i> Acceso a Roles</a>
          <a href="<%= request.getContextPath() %>/reportes-globales.jsp" class="active"><i class="fas fa-chart-pie fa-fw"></i> Reportes Globales</a>
          <a href="<%= request.getContextPath() %>/administrador/configuracion.jsp"><i class="fas fa-cogs fa-fw"></i> Configuración</a>
      </nav>
      <div class="sidebar-footer"><a href="#"><i class="fas fa-sign-out-alt fa-fw"></i> Cerrar sesión</a></div>
  </aside>

  <header class="header" id="header">
      <div class="header-left"><i class="fas fa-bars" id="sidebar-toggle"></i></div>
  </header>
    
  <main class="content" id="content">
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
          grey: 'rgba(201, 203, 207, 0.8)'
      };

      // --- GRÁFICO 1 MEJORADO ---
      try {
        const planesLabels = JSON.parse('<%= planesLabelsJson != null ? planesLabelsJson : "[]" %>');
        const planesData = JSON.parse('<%= planesDataJson != null ? planesDataJson : "[]" %>');
        new Chart(document.getElementById('planesTransporteChart'), {
            type: 'pie',
            data: { labels: planesLabels, datasets: [{ data: planesData, backgroundColor: [ TELITO_COLORS.green, TELITO_COLORS.yellow, TELITO_COLORS.blue, TELITO_COLORS.red ], borderColor: '#fff', borderWidth: 2, hoverOffset: 8 }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 13, family: "'Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', sans-serif" }, padding: 20, usePointStyle: true, pointStyle: 'circle' } }, tooltip: { backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4, callbacks: { label: function(context) { let label = context.label || ''; if (label) { label += ': '; } if (context.parsed !== null) { label += context.parsed + ' Planes'; } return label; } } } }, animation: { animateScale: true, animateRotate: true } }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 1:", e); }

      // --- GRÁFICO 2 MEJORADO ---
      try {
        const productosSalidaLabels = JSON.parse('<%= productosSalidaLabelsJson != null ? productosSalidaLabelsJson : "[]" %>');
        const productosSalidaData = JSON.parse('<%= productosSalidaDataJson != null ? productosSalidaDataJson : "[]" %>');
        const ctx2 = document.getElementById('productosSalidaChart').getContext('2d');
        const gradientBar = ctx2.createLinearGradient(0, 0, ctx2.canvas.clientWidth, 0);
        gradientBar.addColorStop(0, 'rgba(54, 162, 235, 0.7)');
        gradientBar.addColorStop(1, 'rgba(54, 162, 235, 0.9)');
        new Chart(ctx2, {
            type: 'bar',
            data: { labels: productosSalidaLabels, datasets: [{ label: 'Cantidad de Salidas', data: productosSalidaData, backgroundColor: gradientBar, borderColor: 'rgba(54, 162, 235, 1)', borderWidth: 1, borderRadius: 4, borderSkipped: false }] },
            options: { indexAxis: 'y', responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false }, tooltip: { backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4, callbacks: { label: function(context) { return context.raw + ' Unidades'; } } } }, scales: { x: { grid: { color: '#e9e9e9', drawBorder: false } }, y: { grid: { display: false } } } }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 2:", e); }

      // --- GRÁFICO 3 MEJORADO ---
      try {
        const conductoresLabels = JSON.parse('<%= conductoresLabelsJson != null ? conductoresLabelsJson : "[]" %>');
        const conductoresData = JSON.parse('<%= conductoresDataJson != null ? conductoresDataJson : "[]" %>');
        const ctx3 = document.getElementById('conductoresChart').getContext('2d');
        const gradientGreen = ctx3.createLinearGradient(0, 0, 0, ctx3.canvas.clientHeight);
        gradientGreen.addColorStop(0, 'rgba(75, 192, 192, 0.9)');
        gradientGreen.addColorStop(1, 'rgba(75, 192, 192, 0.6)');
        new Chart(ctx3, {
            type: 'bar',
            data: { labels: conductoresLabels, datasets: [{ label: 'Entregas Realizadas', data: conductoresData, backgroundColor: gradientGreen, borderColor: 'rgba(75, 192, 192, 1)', borderWidth: 1, borderRadius: 4, borderSkipped: false }] },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false }, tooltip: { backgroundColor: 'rgba(0, 0, 0, 0.7)', titleFont: { size: 14, weight: 'bold' }, bodyFont: { size: 13 }, padding: 12, cornerRadius: 4, callbacks: { label: function(context) { return context.raw + ' Entregas'; } } } }, scales: { y: { beginAtZero: true, grid: { color: '#e9e9e9', drawBorder: false } }, x: { grid: { display: false } } } }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 3:", e); }

      // --- GRÁFICO 4 MEJORADO ---
      try {
        const pedidosMesLabels = JSON.parse('<%= pedidosMesLabelsJson != null ? pedidosMesLabelsJson : "[]" %>');
        const pedidosMesData = JSON.parse('<%= pedidosMesDataJson != null ? pedidosMesDataJson : "[]" %>');
        const ctx4 = document.getElementById('pedidosMesChart').getContext('2d');
        const gradientPurple = ctx4.createLinearGradient(0, 0, 0, ctx4.canvas.clientHeight);
        gradientPurple.addColorStop(0, 'rgba(153, 102, 255, 0.6)');
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
                    borderColor: 'rgba(153, 102, 255, 1)',
                    borderWidth: 3,
                    tension: 0.4,
                    pointBackgroundColor: 'rgba(153, 102, 255, 1)',
                    pointRadius: 4,
                    pointHoverRadius: 7,
                    pointHoverBackgroundColor: '#fff',
                    pointHoverBorderColor: 'rgba(153, 102, 255, 1)'
                }]
            },
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
                            label: function(context) { return context.raw + ' Pedidos'; }
                        }
                    }
                },
                scales: {
                    y: { beginAtZero: true, grid: { color: '#e9e9e9', drawBorder: false } },
                    x: { grid: { display: false } }
                }
            }
        });
      } catch (e) { console.error("Error al renderizar el Gráfico 4:", e); }

    });
  </script>
</body>
</html>
