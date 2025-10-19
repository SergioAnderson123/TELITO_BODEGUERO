<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <title>Logística – Telito Bodeguero</title>
    <%@ include file="/logistica/layouts/head.jsp" %>
    <style>
        .notification-bell {
            position: relative;
            color: #343a40;
            margin-right: 1rem;
            padding: 0.5rem;
            border-radius: 50%;
            transition: background-color 0.2s ease;
        }
        .notification-bell:hover {
            background-color: #e9ecef;
        }
        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background: linear-gradient(45deg, #dc3545, #e74c3c);
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            font-size: 0.7rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            border: 2px solid #fff;
        }
    </style>
</head>
<body>
<%@ include file="/logistica/layouts/header.jsp" %>

<%@ include file="/logistica/layouts/sidebar.jsp" %>

<!-- Header ya incluido en layouts/header.jsp -->

<div class="dashboard-wrapper">
<div class="dashboard-content">
    <div class="page-header mb-4">
        <h1 class="pageheader-title">
            <i class="fas fa-truck me-2"></i>Dashboard de Logística
        </h1>
        <p class="pageheader-text">Gestiona el transporte, inventario y distribución de productos.</p>
    </div>

    <!-- Accesos rápidos -->
    <div class="row">
        <div class="col-lg-3 col-md-6 mb-4">
            <a href="<%= request.getContextPath() %>/InventarioServlet" class="card quick-link-card">
                <div class="card-body text-center">
                    <i class="fas fa-boxes fs-1 mb-3 text-primary"></i>
                    <h5 class="text-dark">Inventario</h5>
                    <span class="text-muted small">Gestionar stock y movimientos</span>
                </div>
            </a>
        </div>

        <div class="col-lg-3 col-md-6 mb-4">
            <a href="<%= request.getContextPath() %>/PlanTransporteServlet" class="card quick-link-card">
                <div class="card-body text-center">
                    <i class="fas fa-truck fs-1 mb-3 text-success"></i>
                    <h5 class="text-dark">Plan Transporte</h5>
                    <span class="text-muted small">Planificar entregas</span>
                </div>
            </a>
        </div>

        <div class="col-lg-3 col-md-6 mb-4">
            <a href="<%= request.getContextPath() %>/OrdenCompraServlet" class="card quick-link-card">
                <div class="card-body text-center">
                    <i class="fas fa-shopping-cart fs-1 mb-3 text-warning"></i>
                    <h5 class="text-dark">Órdenes</h5>
                    <span class="text-muted small">Gestionar compras</span>
                </div>
            </a>
        </div>

        <div class="col-lg-3 col-md-6 mb-4">
            <a href="<%= request.getContextPath() %>/logistica/NotificacionServlet" class="card quick-link-card">
                <div class="card-body text-center">
                    <i class="fas fa-bell fs-1 mb-3 text-danger"></i>
                    <h5 class="text-dark">Notificaciones</h5>
                    <span class="text-muted small">Ver alertas del sistema</span>
                </div>
            </a>
        </div>
    </div>

    <!-- Información adicional -->
    <div class="row mt-4">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Bienvenido al módulo de Logística</h5>
                </div>
                <div class="card-body">
                    <p>Desde aquí puedes gestionar todos los aspectos relacionados con la logística de la empresa:</p>
                    <ul>
                        <li><strong>Inventario:</strong> Control de stock y movimientos de productos</li>
                        <li><strong>Plan Transporte:</strong> Planificación y seguimiento de entregas</li>
                        <li><strong>Órdenes:</strong> Gestión de órdenes de compra y distribución</li>
                        <li><strong>Notificaciones:</strong> Alertas automáticas del sistema</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', () => {
        // Layout estilo Productor no requiere toggles aquí
        
        // Cargar contador de notificaciones
        loadNotificationCount();

        // Chequear stock-out periódicamente y mostrar modal si existe al menos uno
        checkStockOut();
        setInterval(checkStockOut, 30000); // cada 30s

        // Chequear push del admin y mostrar modal con botón cerrar (ack)
        checkAdminPush();
        setInterval(checkAdminPush, 15000); // cada 15s
    });
    
    function loadNotificationCount() {
        fetch('<%= request.getContextPath() %>/logistica/NotificacionServlet?action=contar')
            .then(response => response.json())
            .then(data => {
                const bell = document.querySelector('.notification-bell');
                if (data.count > 0) {
                    if (!bell.querySelector('.notification-badge')) {
                        const badge = document.createElement('span');
                        badge.className = 'notification-badge';
                        badge.textContent = data.count;
                        bell.appendChild(badge);
                    } else {
                        bell.querySelector('.notification-badge').textContent = data.count;
                    }
                } else {
                    const badge = bell.querySelector('.notification-badge');
                    if (badge) badge.remove();
                }
            })
            .catch(error => console.error('Error loading notification count:', error));
    }

    function checkStockOut() {
        fetch('<%= request.getContextPath() %>/logistica/NotificacionServlet?action=contarStockOut')
            .then(response => response.json())
            .then(data => {
                if (data.count && data.count > 0) {
                    showStockOutModal(data.count);
                }
            })
            .catch(error => console.error('Error checking stock-out:', error));
    }

    function showStockOutModal(count) {
        let modalEl = document.getElementById('stockOutModal');
        if (!modalEl) {
            modalEl = document.createElement('div');
            modalEl.id = 'stockOutModal';
            modalEl.className = 'modal fade';
            modalEl.tabIndex = -1;
            modalEl.innerHTML = `
<div class="modal-dialog modal-dialog-centered">
  <div class="modal-content">
    <div class="modal-header bg-danger text-white">
      <h5 class="modal-title"><i class="fas fa-triangle-exclamation me-2"></i>Alerta: Productos sin stock</h5>
      <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>
    <div class="modal-body">
      <p>Existen <strong id="stockOutCount"></strong> producto(s) en situación de <strong>sin stock</strong>.</p>
      <p class="mb-0">Revisa las <a href="<%= request.getContextPath() %>/logistica/NotificacionServlet">notificaciones</a> para ver el detalle.</p>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
      <a href="<%= request.getContextPath() %>/logistica/NotificacionServlet" class="btn btn-danger">Ver notificaciones</a>
    </div>
  </div>
 </div>`;
            document.body.appendChild(modalEl);
        }

        modalEl.querySelector('#stockOutCount').textContent = count;
        const modal = new bootstrap.Modal(modalEl, { backdrop: 'static' });
        if (!modalEl.classList.contains('show')) {
            modal.show();
        }
    }

    function checkAdminPush() {
        fetch('<%= request.getContextPath() %>/logistica/NotificacionServlet?action=checkAdminPush')
            .then(r => r.json())
            .then(data => {
                if (data.count && data.count > 0) {
                    showAdminPushModal();
                }
            })
            .catch(console.error);
    }

    function showAdminPushModal() {
        let modalEl = document.getElementById('adminPushModal');
        if (!modalEl) {
            modalEl = document.createElement('div');
            modalEl.id = 'adminPushModal';
            modalEl.className = 'modal fade';
            modalEl.tabIndex = -1;
            modalEl.innerHTML = `
<div class="modal-dialog modal-dialog-centered">
  <div class="modal-content">
    <div class="modal-header bg-primary text-white">
      <h5 class="modal-title"><i class="fas fa-bullhorn me-2"></i>Aviso del Administrador</h5>
      <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
    </div>
    <div class="modal-body">
      <p>Tienes un nuevo aviso del Administrador. Revisa tus notificaciones para más detalle.</p>
    </div>
    <div class="modal-footer">
      <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" id="adminPushCloseBtn">Cerrar</button>
      <a href="<%= request.getContextPath() %>/logistica/NotificacionServlet" class="btn btn-primary">Ver notificaciones</a>
    </div>
  </div>
 </div>`;
            document.body.appendChild(modalEl);
            // Registrar ack al cerrar con el botón Cerrar
            modalEl.addEventListener('shown.bs.modal', () => {
                const btn = document.getElementById('adminPushCloseBtn');
                if (btn) {
                    btn.addEventListener('click', ackAdminPush);
                }
            });
        }
        const modal = new bootstrap.Modal(modalEl, { backdrop: 'static' });
        if (!modalEl.classList.contains('show')) {
            modal.show();
        }
    }

    function ackAdminPush() {
        fetch('<%= request.getContextPath() %>/logistica/NotificacionServlet?action=ackAdminPush')
            .catch(console.error);
    }
</script>
</body>
</html>
