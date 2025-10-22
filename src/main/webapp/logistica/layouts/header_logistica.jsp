<div class="dashboard-header">
    <nav class="navbar navbar-expand">
        <div class="container-fluid">
            <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/logistica/InventarioServlet">
                <i class="fas fa-truck me-2" style="color: var(--seafoam);"></i>
                <span>Telito Bodeguero</span>
            </a>

            <ul class="navbar-nav ms-auto">
                <li class="nav-item me-3">
                    <a class="nav-link position-relative" href="${pageContext.request.contextPath}/logistica/alertas" title="Alertas">
                        <i class="fas fa-bell"></i>
                        <span id="alert-badge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="display:none;">0</span>
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=Logistica&background=006d77&color=fff" alt="User" class="rounded-circle me-2" width="32" height="32">
                        <span style="color:#006d77;">Logística</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="#"><i class="fas fa-user me-2"></i>Perfil</a></li>
                        <li><a class="dropdown-item" href="#"><i class="fas fa-cog me-2"></i>Configuración</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-danger" href="#"><i class="fas fa-sign-out-alt me-2"></i>Cerrar Sesión</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </nav>
</div>

<!-- Modal de Alertas -->
<div class="modal fade" id="alertasModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="fas fa-bell me-2"></i>Alertas</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body" id="alertasModalBody">
        <div class="text-muted">Cargando alertas...</div>
      </div>
      <div class="modal-footer">
        <a href="${pageContext.request.contextPath}/logistica/alertas" class="btn btn-outline-primary">Ver todas</a>
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
      </div>
    </div>
  </div>
  </div>

<script>
document.addEventListener('DOMContentLoaded', async function() {
  try {
    const base = '${pageContext.request.contextPath}';
    const res = await fetch(base + '/logistica/alertas?format=json', { credentials: 'same-origin' });
    if (!res.ok) return;
    const mensajes = await res.json();
    const badge = document.getElementById('alert-badge');
    if (Array.isArray(mensajes) && mensajes.length > 0) {
      badge.textContent = mensajes.length;
      badge.style.display = 'inline-block';

      // Mostrar modal solo en primer acceso de la sesión de logística
      if (!sessionStorage.getItem('logistica_alerts_shown')) {
        const body = document.getElementById('alertasModalBody');
        body.innerHTML = '';
        const ul = document.createElement('ul');
        ul.className = 'list-group';
        mensajes.forEach(m => {
          const li = document.createElement('li');
          li.className = 'list-group-item d-flex align-items-center';
          const icon = document.createElement('i');
          icon.className = 'fas fa-exclamation-triangle text-warning me-2';
          const span = document.createElement('span');
          span.textContent = m; // evitar colisiones con EL de JSP
          li.appendChild(icon);
          li.appendChild(span);
          ul.appendChild(li);
        });
        body.appendChild(ul);
        const modal = new bootstrap.Modal(document.getElementById('alertasModal'));
        modal.show();
        sessionStorage.setItem('logistica_alerts_shown', '1');
      }
    }
  } catch (e) {
    console.error('No se pudieron cargar las alertas', e);
  }
});
</script>
